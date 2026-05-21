import { Injectable, Logger } from '@nestjs/common';
import { Player } from '../entities/player.entity';
import {
  ROLES,
  getRole,
  isWolf,
  WOLF_WEAKNESS_ORDER,
} from './roles';

export interface ActionRecord {
  actorId: string;
  targetId?: string | null;
  secondaryTargetId?: string | null;
  actionType: string;
  payload?: Record<string, any> | null;
}

export interface ResolutionEvent {
  type: string;
  message: string;
  isPublic: boolean;
  recipientId?: string | null;
  data?: Record<string, any>;
}

export interface ResolutionResult {
  deaths: string[]; // player ids in order of death
  events: ResolutionEvent[]; // events to log/emit
  stateMutations: Record<string, any>; // patch for game.state
}

interface ResolvePlayer extends Player {}

/**
 * Core game logic. Stateless service — takes the current set of players and
 * actions, returns a resolution result the GameService can persist.
 */
@Injectable()
export class GameEngine {
  private readonly logger = new Logger(GameEngine.name);

  /**
   * Assigns roles randomly from the host-defined pool. Pool length must match
   * player count. Returns mutated players (caller persists them).
   */
  assignRoles(players: Player[], rolePool: string[]): Player[] {
    if (players.length !== rolePool.length) {
      throw new Error(
        `Pool de funções (${rolePool.length}) não bate com a quantidade de jogadores (${players.length}).`,
      );
    }
    const shuffled = [...rolePool].sort(() => Math.random() - 0.5);
    const sortedPlayers = [...players].sort((a, b) => a.seatOrder - b.seatOrder);
    sortedPlayers.forEach((p, i) => {
      p.role = shuffled[i];
      p.isAlive = true;
      p.isRevealed = p.role === 'presidente';
      p.canVote = true;
      p.canSpeak = p.role !== 'bebado';
      p.flags = {};
    });
    return sortedPlayers;
  }

  /**
   * Returns the ordered list of players who must act on a given night.
   * Order is presentation order (UI calls them one by one).
   */
  nightActionOrder(players: Player[], round: number): Player[] {
    const alive = players.filter((p) => p.isAlive);
    return alive
      .filter((p) => {
        const role = getRole(p.role!);
        if (!role || !role.hasNightAction) return false;
        if (role.firstNightOnly && round !== 1) return false;
        // skip if blocked by nightmare werewolf this round
        if (p.flags?.blockedNightRound === round) return false;
        return true;
      })
      .sort((a, b) => (getRole(a.role!)?.nightOrder ?? 999) - (getRole(b.role!)?.nightOrder ?? 999));
  }

  /**
   * Resolves all night actions for the round.
   */
  resolveNight(
    players: Player[],
    actions: ActionRecord[],
    round: number,
    gameState: Record<string, any>,
  ): ResolutionResult {
    const events: ResolutionEvent[] = [];
    const playerMap = new Map(players.map((p) => [p.id, p]));
    const state = { ...gameState };

    // Working sets / flags collected during action interpretation
    const protectedBy: Map<string, Set<string>> = new Map();
    const bodyguardOn: Map<string, string> = new Map(); // protectedId -> guardId
    const blocks: Set<string> = new Set(); // actor IDs blocked this night
    const trapsActive: Set<string> = new Set(state.activeTraps ?? []);
    const newTraps: string[] = [];
    const wolfTargetVotes: Map<string, number> = new Map();
    let witchHeal = false;
    let witchPoisonTarget: string | null = null;
    const visitedByDama: Map<string, string> = new Map(); // damaId -> targetId
    let priestAction: { actorId: string; targetId: string } | null = null;
    const damageQueue: { targetId: string; cause: string; sourceId?: string }[] = [];

    // Apply Nightmare Werewolf blocks first (already filtered in order, but
    // duplicate safety: any pending block entries take effect for this round).
    for (const a of actions) {
      if (a.actionType === 'nightmare_block' && a.targetId) {
        const target = playerMap.get(a.targetId);
        if (target) {
          target.flags = { ...target.flags, blockedNightRound: round };
          blocks.add(a.targetId);
        }
      }
    }

    // --- Pass 1: collect actions (in role.nightOrder) ---
    const ordered = [...actions].sort((a, b) => {
      const ra = playerMap.get(a.actorId);
      const rb = playerMap.get(b.actorId);
      const oa = ra ? getRole(ra.role!)?.nightOrder ?? 999 : 999;
      const ob = rb ? getRole(rb.role!)?.nightOrder ?? 999 : 999;
      return oa - ob;
    });

    for (const a of ordered) {
      const actor = playerMap.get(a.actorId);
      if (!actor || !actor.isAlive) continue;
      if (blocks.has(actor.id)) continue;

      switch (a.actionType) {
        case 'cupid_link': {
          if (a.targetId && a.secondaryTargetId) {
            state.couple = [a.targetId, a.secondaryTargetId];
            events.push({
              type: 'cupid_link',
              isPublic: false,
              recipientId: a.targetId,
              message: 'Você foi enlaçado pelo Cupido. Seu par é revelado no DM.',
              data: { partnerId: a.secondaryTargetId },
            });
            events.push({
              type: 'cupid_link',
              isPublic: false,
              recipientId: a.secondaryTargetId,
              message: 'Você foi enlaçado pelo Cupido. Seu par é revelado no DM.',
              data: { partnerId: a.targetId },
            });
          }
          break;
        }

        case 'kitten_convert': {
          if (a.targetId) {
            const t = playerMap.get(a.targetId);
            if (t && t.isAlive) {
              t.role = 'lobisomem';
              t.flags = { ...t.flags, convertedRound: round };
              events.push({
                type: 'kitten_convert',
                isPublic: false,
                recipientId: t.id,
                message: 'Você foi convertido em Lobisomem.',
              });
              state.kittenUsed = true;
            }
          }
          break;
        }

        case 'wolf_kill_vote': {
          if (a.targetId && isWolf(actor.role)) {
            const weight = actor.role === 'lobisomem_alfa' ? 2 : 1;
            wolfTargetVotes.set(
              a.targetId,
              (wolfTargetVotes.get(a.targetId) ?? 0) + weight,
            );
          }
          break;
        }

        case 'trap_set': {
          if (a.targetId) {
            newTraps.push(a.targetId);
          }
          break;
        }

        case 'doctor_protect': {
          if (a.targetId) {
            if (!protectedBy.has(a.targetId)) protectedBy.set(a.targetId, new Set());
            protectedBy.get(a.targetId)!.add(actor.id);
            actor.flags = { ...actor.flags, lastProtected: a.targetId };
          }
          break;
        }

        case 'bodyguard_protect': {
          if (a.targetId) {
            bodyguardOn.set(a.targetId, actor.id);
          }
          break;
        }

        case 'witch_heal': {
          witchHeal = true;
          state.witchHealUsed = true;
          break;
        }

        case 'witch_poison': {
          if (a.targetId) {
            witchPoisonTarget = a.targetId;
            state.witchPoisonUsed = true;
          }
          break;
        }

        case 'dama_visit': {
          if (a.targetId) visitedByDama.set(actor.id, a.targetId);
          break;
        }

        case 'grandma_silence': {
          if (a.targetId) {
            const t = playerMap.get(a.targetId);
            if (t) t.flags = { ...t.flags, voteBlockedRound: round + 1 };
          }
          break;
        }

        case 'assassin_kill': {
          if (a.targetId) damageQueue.push({ targetId: a.targetId, cause: 'assassin', sourceId: actor.id });
          break;
        }

        case 'arsonist_douse': {
          if (a.targetId) {
            const t = playerMap.get(a.targetId);
            if (t) t.flags = { ...t.flags, doused: true };
          }
          if (a.secondaryTargetId) {
            const t2 = playerMap.get(a.secondaryTargetId);
            if (t2) t2.flags = { ...t2.flags, doused: true };
          }
          break;
        }

        case 'arsonist_burn': {
          for (const p of players) {
            if (p.flags?.doused && p.isAlive) {
              damageQueue.push({ targetId: p.id, cause: 'arson', sourceId: actor.id });
            }
          }
          break;
        }

        case 'witch_investigate': {
          if (a.targetId) {
            const t = playerMap.get(a.targetId);
            const role = t?.role ?? '';
            const isSeerOrWolf =
              role === 'lobo_vidente' || isWolf(role);
            events.push({
              type: 'witch_investigate_result',
              isPublic: false,
              recipientId: actor.id,
              message: isSeerOrWolf
                ? `${t!.name} é Vidente ou Lobisomem.`
                : `${t!.name} não é Vidente nem Lobisomem.`,
            });
          }
          break;
        }

        case 'wolf_seer': {
          if (a.targetId) {
            const t = playerMap.get(a.targetId);
            if (t) {
              const role = getRole(t.role!);
              events.push({
                type: 'wolf_seer_result',
                isPublic: false,
                recipientId: actor.id,
                message: `${t.name} é ${role?.name ?? '???'}.`,
              });
            }
          }
          break;
        }

        case 'detective_compare': {
          if (a.targetId && a.secondaryTargetId) {
            const t1 = playerMap.get(a.targetId);
            const t2 = playerMap.get(a.secondaryTargetId);
            const same = t1 && t2 && getRole(t1.role!)?.team === getRole(t2.role!)?.team;
            events.push({
              type: 'detective_result',
              isPublic: false,
              recipientId: actor.id,
              message: same
                ? `${t1!.name} e ${t2!.name} são do mesmo time.`
                : `${t1!.name} e ${t2!.name} são de times diferentes.`,
            });
          }
          break;
        }

        case 'vigilante_investigate': {
          if (a.targetId) {
            const t = playerMap.get(a.targetId);
            if (t) {
              events.push({
                type: 'vigilante_investigate_result',
                isPublic: false,
                recipientId: actor.id,
                message: `${t.name} é ${getRole(t.role!)?.name}.`,
              });
            }
          }
          break;
        }

        case 'vigilante_shoot': {
          if (a.targetId) damageQueue.push({ targetId: a.targetId, cause: 'vigilante', sourceId: actor.id });
          break;
        }

        case 'sniper_mark': {
          if (a.targetId) {
            actor.flags = { ...actor.flags, markedTarget: a.targetId };
          }
          break;
        }

        case 'sniper_shoot': {
          const marked = actor.flags?.markedTarget;
          const target = a.targetId ?? marked;
          if (target) {
            const t = playerMap.get(target);
            const team = getRole(t?.role!)?.team;
            if (team === 'village') {
              damageQueue.push({ targetId: actor.id, cause: 'sniper_backfire' });
            } else {
              damageQueue.push({ targetId: target, cause: 'sniper', sourceId: actor.id });
            }
            actor.flags = { ...actor.flags, markedTarget: null };
          }
          break;
        }

        case 'priest_blessing': {
          if (a.targetId) priestAction = { actorId: actor.id, targetId: a.targetId };
          break;
        }

        case 'gravedigger_target': {
          if (a.targetId) {
            actor.flags = { ...actor.flags, gravediggerTarget: a.targetId };
          }
          break;
        }

        case 'medium_revive': {
          if (a.targetId) {
            const t = playerMap.get(a.targetId);
            if (t && !t.isAlive) {
              t.isAlive = true;
              events.push({
                type: 'medium_revive',
                isPublic: true,
                message: `${actor.name} (Médium) reviveu ${t.name}.`,
              });
            }
          }
          break;
        }

        case 'swap_roles': {
          if (a.targetId && a.secondaryTargetId) {
            const t1 = playerMap.get(a.targetId);
            const t2 = playerMap.get(a.secondaryTargetId);
            if (t1 && t2) {
              const tmp = t1.role;
              t1.role = t2.role;
              t2.role = tmp;
              events.push({
                type: 'role_swapped',
                isPublic: false,
                recipientId: t1.id,
                message: 'Sua função foi trocada pelo Menino Travesso.',
              });
              events.push({
                type: 'role_swapped',
                isPublic: false,
                recipientId: t2.id,
                message: 'Sua função foi trocada pelo Menino Travesso.',
              });
            }
          }
          break;
        }
      }
    }

    // --- Pass 2: resolve wolves' chosen victim ---
    if (wolfTargetVotes.size > 0) {
      const max = Math.max(...wolfTargetVotes.values());
      const tied = [...wolfTargetVotes.entries()]
        .filter(([, v]) => v === max)
        .map(([id]) => id);
      const chosenId = tied[Math.floor(Math.random() * tied.length)];
      damageQueue.unshift({ targetId: chosenId, cause: 'wolves' });
    }

    // --- Pass 3: priest result ---
    if (priestAction) {
      const t = playerMap.get(priestAction.targetId);
      const actor = playerMap.get(priestAction.actorId);
      if (t && actor) {
        if (isWolf(t.role)) {
          damageQueue.push({ targetId: t.id, cause: 'priest', sourceId: actor.id });
        } else {
          damageQueue.push({ targetId: actor.id, cause: 'priest_backfire' });
        }
      }
    }

    // --- Pass 4: apply damages with protection/witch heal/curse ---
    const dyingThisNight: Set<string> = new Set();
    for (const dmg of damageQueue) {
      const target = playerMap.get(dmg.targetId);
      if (!target || !target.isAlive) continue;

      // Wolf attack against Homem Sábio: immune
      if (dmg.cause === 'wolves' && target.role === 'homem_sabio') continue;
      // Wolf attack against Incendiário: immune
      if (dmg.cause === 'wolves' && target.role === 'incendiario') continue;

      // Trap protection: target is trapped this round (set in prior round)
      if (dmg.cause === 'wolves' && trapsActive.has(target.id)) {
        // weakest wolf dies instead
        const wolves = players.filter((p) => p.isAlive && isWolf(p.role));
        const weakest = wolves.sort((a, b) => {
          const ai = WOLF_WEAKNESS_ORDER.indexOf(a.role!);
          const bi = WOLF_WEAKNESS_ORDER.indexOf(b.role!);
          return (ai === -1 ? 99 : ai) - (bi === -1 ? 99 : bi);
        })[0];
        if (weakest) dyingThisNight.add(weakest.id);
        continue;
      }

      // Bodyguard absorbs
      if (bodyguardOn.has(target.id)) {
        const guardId = bodyguardOn.get(target.id)!;
        dyingThisNight.add(guardId);
        continue;
      }

      // Doctor protect (only saves from wolves and assassin/sniper-style?
      // Per spec, primarily wolves. We accept it for all damage except witch
      // poison, priest backfire and arson, which are typically un-saveable.)
      if (protectedBy.has(target.id) && dmg.cause === 'wolves') {
        continue; // saved
      }

      // Wolf attack on Amaldiçoado: transform instead of die
      if (dmg.cause === 'wolves' && target.role === 'amaldicoado') {
        target.role = 'lobisomem';
        events.push({
          type: 'cursed_transform',
          isPublic: false,
          recipientId: target.id,
          message: 'Você foi atacado e se transformou em Lobisomem.',
        });
        continue;
      }

      // Wolf attack on Valentão: delayed death (next dawn after the next day)
      if (dmg.cause === 'wolves' && target.role === 'valentao' && !target.flags?.wounded) {
        target.flags = { ...target.flags, wounded: true, woundedRound: round };
        continue;
      }

      dyingThisNight.add(target.id);
    }

    // --- Witch heal cancels all wolf deaths if used (cure all that would die that night) ---
    if (witchHeal) {
      // We approximate: clear everyone slated to die this night
      for (const id of [...dyingThisNight]) {
        dyingThisNight.delete(id);
      }
    }

    // Witch poison applies after heal (separate decision)
    if (witchPoisonTarget) {
      dyingThisNight.add(witchPoisonTarget);
    }

    // --- Pass 5: process Valentão delayed death from previous round ---
    for (const p of players) {
      if (p.isAlive && p.flags?.wounded && p.flags?.woundedRound !== round) {
        dyingThisNight.add(p.id);
      }
    }

    // --- Pass 6: dama de vermelho visiting wolves or dying targets ---
    for (const [damaId, targetId] of visitedByDama.entries()) {
      const target = playerMap.get(targetId);
      const dama = playerMap.get(damaId);
      if (!target || !dama) continue;
      if (isWolf(target.role) || dyingThisNight.has(targetId)) {
        dyingThisNight.add(damaId);
      } else if (dyingThisNight.has(damaId)) {
        // dama was target of wolves but is visiting non-wolf → survives
        dyingThisNight.delete(damaId);
      }
    }

    // --- Pass 7: kill chain (Vingador, Filhote, Cientista, Casal) ---
    const deathQueue: string[] = [...dyingThisNight];
    const finalDeaths: string[] = [];
    const processedDeaths: Set<string> = new Set();

    while (deathQueue.length > 0) {
      const id = deathQueue.shift()!;
      if (processedDeaths.has(id)) continue;
      const p = playerMap.get(id);
      if (!p || !p.isAlive) continue;

      p.isAlive = false;
      finalDeaths.push(id);
      processedDeaths.add(id);

      // Couple chain
      if (state.couple && Array.isArray(state.couple) && state.couple.includes(id)) {
        const partner = state.couple.find((x: string) => x !== id);
        if (partner && !processedDeaths.has(partner)) deathQueue.push(partner);
      }

      // Cientista Maluco chain
      if (p.role === 'cientista_maluco') {
        const sorted = players.sort((a, b) => a.seatOrder - b.seatOrder);
        const idx = sorted.findIndex((x) => x.id === id);
        const neighbors: string[] = [];
        for (let off = -1; off <= 1; off += 2) {
          for (let step = 1; step <= sorted.length; step++) {
            const n = sorted[(idx + off * step + sorted.length * step) % sorted.length];
            if (n && n.id !== id && n.isAlive && !processedDeaths.has(n.id)) {
              neighbors.push(n.id);
              break;
            }
          }
        }
        for (const n of neighbors) deathQueue.push(n);
        events.push({
          type: 'scientist_explosion',
          isPublic: true,
          message: `${p.name} morreu e a substância tóxica matou os vizinhos.`,
        });
      }

      // Vingador and Lobisomem Filhote → require user pick. We queue a pending
      // revenge slot; GameService will wait for that input before continuing.
      if (p.role === 'vingador' || p.role === 'lobisomem_filhote') {
        state.pendingRevenge = state.pendingRevenge || [];
        (state.pendingRevenge as string[]).push(id);
      }

      // Ladrão de Túmulos: if target dies, gravedigger inherits role
      for (const other of players) {
        if (other.role === 'ladrao_de_tumulos' && other.flags?.gravediggerTarget === id) {
          other.role = p.role!;
          events.push({
            type: 'gravedigger_inherit',
            isPublic: false,
            recipientId: other.id,
            message: `Você herdou a função: ${getRole(p.role!)?.name}.`,
          });
        }
      }

      // Public death announcement (always silent)
      events.push({
        type: 'death',
        isPublic: true,
        message: `${p.name} morreu.`,
        data: { playerId: p.id },
      });

      // Caçador de Cabeças: if their target dies other than by lynch, becomes aldeão
      for (const other of players) {
        if (other.role === 'cacador_de_cabecas' && other.flags?.bountyTarget === id) {
          other.role = 'aldeao';
          events.push({
            type: 'bounty_lost',
            isPublic: false,
            recipientId: other.id,
            message: 'Seu alvo morreu. Você virou Aldeão Comum.',
          });
        }
      }
    }

    // Persist updated traps for next round
    state.activeTraps = newTraps;

    return {
      deaths: finalDeaths,
      events,
      stateMutations: state,
    };
  }

  /**
   * Tallies votes and determines who, if anyone, is lynched. Applies special
   * passives (Idiota, Príncipe Bonitão).
   */
  resolveVotes(
    players: Player[],
    votes: { voterId: string; targetId: string | null }[],
    gameState: Record<string, any>,
  ): ResolutionResult {
    const events: ResolutionEvent[] = [];
    const state = { ...gameState };
    const playerMap = new Map(players.map((p) => [p.id, p]));

    if (state.pacifistCancelled) {
      events.push({
        type: 'vote_cancelled',
        isPublic: true,
        message: 'A votação foi cancelada pelo Pacifista.',
      });
      state.pacifistCancelled = false;
      return { deaths: [], events, stateMutations: state };
    }

    const tally: Map<string, number> = new Map();
    const wolfShadowMode = !!state.wolfShadowActive;
    for (const v of votes) {
      if (!v.targetId) continue;
      const voter = playerMap.get(v.voterId);
      if (!voter || !voter.isAlive || !voter.canVote) continue;
      if (voter.flags?.voteBlockedRound === gameState.round) continue;
      let weight = 1;
      if (voter.role === 'prefeito' && voter.isRevealed) weight = 2;
      if (wolfShadowMode && isWolf(voter.role)) weight = 2;
      tally.set(v.targetId, (tally.get(v.targetId) ?? 0) + weight);
    }

    if (tally.size === 0) {
      events.push({
        type: 'no_lynch',
        isPublic: true,
        message: 'Ninguém recebeu votos. Ninguém foi linchado.',
      });
      state.wolfShadowActive = false;
      return { deaths: [], events, stateMutations: state };
    }

    const max = Math.max(...tally.values());
    const tied = [...tally.entries()].filter(([, v]) => v === max).map(([id]) => id);
    state.wolfShadowActive = false;
    if (tied.length > 1) {
      events.push({
        type: 'no_lynch_tie',
        isPublic: true,
        message: 'Empate na votação. Ninguém foi linchado.',
      });
      return { deaths: [], events, stateMutations: state };
    }

    const chosenId = tied[0];
    const chosen = playerMap.get(chosenId);
    if (!chosen) return { deaths: [], events, stateMutations: state };

    // Idiota
    if (chosen.role === 'idiota' && !chosen.isRevealed) {
      chosen.isRevealed = true;
      chosen.canVote = false;
      events.push({
        type: 'idiot_survives',
        isPublic: true,
        message: `${chosen.name} é o Idiota! Sobreviveu ao linchamento e perdeu o direito de voto.`,
      });
      return { deaths: [], events, stateMutations: state };
    }

    // Príncipe Bonitão
    if (chosen.role === 'principe_bonitao' && !chosen.isRevealed) {
      chosen.isRevealed = true;
      events.push({
        type: 'prince_survives',
        isPublic: true,
        message: `${chosen.name} é o Príncipe Bonitão! Sobreviveu ao linchamento.`,
      });
      return { deaths: [], events, stateMutations: state };
    }

    // Bobo wins
    if (chosen.role === 'bobo') {
      chosen.isAlive = false;
      events.push({
        type: 'jester_win',
        isPublic: true,
        message: `${chosen.name} foi linchado — era o Bobo! Vitória solo do Bobo.`,
      });
      state.winner = 'bobo';
      return { deaths: [chosen.id], events, stateMutations: state };
    }

    // Caçador de Cabeças: any other hunter wins if his target was lynched
    for (const other of players) {
      if (other.role === 'cacador_de_cabecas' && other.flags?.bountyTarget === chosen.id && other.isAlive) {
        state.winner = 'bountyhunter';
        events.push({
          type: 'bountyhunter_win',
          isPublic: true,
          message: `${other.name} (Caçador de Cabeças) cumpriu sua missão.`,
        });
      }
    }

    // Run lynch through standard kill chain
    return this.applyLynch(players, chosen, state, events);
  }

  private applyLynch(
    players: Player[],
    chosen: Player,
    state: Record<string, any>,
    events: ResolutionEvent[],
  ): ResolutionResult {
    const playerMap = new Map(players.map((p) => [p.id, p]));
    const deaths: string[] = [];
    const q: string[] = [chosen.id];
    const seen: Set<string> = new Set();

    while (q.length > 0) {
      const id = q.shift()!;
      if (seen.has(id)) continue;
      const p = playerMap.get(id);
      if (!p || !p.isAlive) continue;
      p.isAlive = false;
      deaths.push(id);
      seen.add(id);

      if (state.couple && Array.isArray(state.couple) && state.couple.includes(id)) {
        const partner = state.couple.find((x: string) => x !== id);
        if (partner && !seen.has(partner)) q.push(partner);
      }
      if (p.role === 'cientista_maluco') {
        const sorted = players.sort((a, b) => a.seatOrder - b.seatOrder);
        const idx = sorted.findIndex((x) => x.id === id);
        for (let off = -1; off <= 1; off += 2) {
          for (let step = 1; step <= sorted.length; step++) {
            const n = sorted[(idx + off * step + sorted.length * step) % sorted.length];
            if (n && n.id !== id && n.isAlive && !seen.has(n.id)) {
              q.push(n.id);
              break;
            }
          }
        }
        events.push({
          type: 'scientist_explosion',
          isPublic: true,
          message: `${p.name} morreu e a substância tóxica matou os vizinhos.`,
        });
      }
      if (p.role === 'vingador' || p.role === 'lobisomem_filhote') {
        state.pendingRevenge = state.pendingRevenge || [];
        (state.pendingRevenge as string[]).push(id);
      }
      events.push({
        type: 'death',
        isPublic: true,
        message: `${p.name} morreu.`,
        data: { playerId: p.id },
      });
    }

    return { deaths, events, stateMutations: state };
  }

  /**
   * Checks for a win condition after each death/resolution.
   * Returns the winner string or null if no winner yet.
   */
  checkWinner(players: Player[], state: Record<string, any>): string | null {
    if (state.winner) return state.winner;

    const alive = players.filter((p) => p.isAlive);
    if (alive.length === 0) return 'draw';

    // President death loses for village
    if (state.presidentRevealed && !players.find((p) => p.role === 'presidente')?.isAlive) {
      return 'wolves';
    }

    // Couple: last two alive and both lovers
    if (state.couple && Array.isArray(state.couple) && alive.length === 2) {
      const ids = alive.map((p) => p.id).sort();
      const couple = [...state.couple].sort();
      if (ids[0] === couple[0] && ids[1] === couple[1]) return 'couple';
    }

    // Solo wins
    if (alive.length === 1) {
      const last = alive[0];
      if (last.role === 'assassino') return 'assassin';
      if (last.role === 'incendiario') return 'arsonist';
    }

    const wolves = alive.filter((p) => isWolf(p.role));
    const villagers = alive.filter((p) => !isWolf(p.role));
    if (wolves.length === 0) return 'village';
    if (wolves.length >= villagers.length) {
      // Lobo Solitário só ganha sozinho
      if (wolves.length === 1 && wolves[0].role === 'lobo_solitario') return 'lone_wolf';
      return 'wolves';
    }
    return null;
  }
}
