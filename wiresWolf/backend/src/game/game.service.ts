import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { randomBytes, randomUUID } from 'crypto';
import { Game } from './entities/game.entity';
import { Player } from './entities/player.entity';
import { NightAction } from './entities/night-action.entity';
import { Vote } from './entities/vote.entity';
import { GameLog } from './entities/game-log.entity';
import { GameEngine } from './engine/game-engine.service';
import { ROLES, getRole, isWolf } from './engine/roles';

export interface PublicPlayer {
  id: string;
  name: string;
  isAlive: boolean;
  isRevealed: boolean;
  seatOrder: number;
  role?: string | null;
}

@Injectable()
export class GameService {
  constructor(
    @InjectRepository(Game) private games: Repository<Game>,
    @InjectRepository(Player) private players: Repository<Player>,
    @InjectRepository(NightAction) private actions: Repository<NightAction>,
    @InjectRepository(Vote) private votes: Repository<Vote>,
    @InjectRepository(GameLog) private logs: Repository<GameLog>,
    private readonly engine: GameEngine,
  ) {}

  private token() {
    return randomBytes(16).toString('hex');
  }

  // ------------------------ Lobby ------------------------

  async createGame(hostName: string) {
    const game = this.games.create({
      id: randomUUID(),
      status: 'lobby',
      phase: 'lobby',
      round: 0,
      hostToken: this.token(),
      state: {},
    });
    await this.games.save(game);

    const host = this.players.create({
      id: randomUUID(),
      name: hostName,
      token: game.hostToken!,
      gameId: game.id,
      seatOrder: 0,
      flags: { isHost: true },
    });
    await this.players.save(host);

    return { gameId: game.id, hostToken: game.hostToken, playerId: host.id };
  }

  async listRoles() {
    return Object.values(ROLES).map((r) => ({
      id: r.id,
      name: r.name,
      team: r.team,
      description: r.description,
    }));
  }

  async joinGame(gameId: string, name: string) {
    const game = await this.getGameOrFail(gameId);
    if (game.phase !== 'lobby') {
      throw new BadRequestException('A partida já começou.');
    }
    const existing = await this.players.find({ where: { gameId } });
    if (existing.find((p) => p.name === name)) {
      throw new BadRequestException('Já existe um jogador com esse nome.');
    }
    const player = this.players.create({
      id: randomUUID(),
      name,
      token: this.token(),
      gameId,
      seatOrder: existing.length,
    });
    await this.players.save(player);
    return { playerId: player.id, playerToken: player.token };
  }

  async setRolePool(gameId: string, hostToken: string, rolePool: string[]) {
    const game = await this.requireHost(gameId, hostToken);
    for (const r of rolePool) {
      if (!ROLES[r]) throw new BadRequestException(`Função desconhecida: ${r}`);
    }
    game.rolePool = rolePool;
    await this.games.save(game);
    return { ok: true };
  }

  async startGame(gameId: string, hostToken: string) {
    const game = await this.requireHost(gameId, hostToken);
    const players = await this.players.find({ where: { gameId } });
    if (players.length < 4) {
      throw new BadRequestException('Mínimo de 4 jogadores.');
    }
    if (!game.rolePool || game.rolePool.length !== players.length) {
      throw new BadRequestException(
        `Pool de funções precisa ter exatamente ${players.length} entradas.`,
      );
    }
    this.engine.assignRoles(players, game.rolePool);
    // Bounty hunter target assignment
    const hunters = players.filter((p) => p.role === 'cacador_de_cabecas');
    for (const h of hunters) {
      const candidates = players.filter((p) => p.id !== h.id);
      const target = candidates[Math.floor(Math.random() * candidates.length)];
      h.flags = { ...h.flags, bountyTarget: target.id };
    }
    // President revealed
    const president = players.find((p) => p.role === 'presidente');
    if (president) {
      game.state = { ...(game.state ?? {}), presidentRevealed: true };
    }
    await this.players.save(players);
    game.status = 'in_progress';
    game.phase = 'role_reveal';
    game.round = 1;
    await this.games.save(game);
    return { ok: true };
  }

  // ------------------------ Phases ------------------------

  async acknowledgeRole(gameId: string, playerToken: string) {
    const player = await this.requirePlayer(gameId, playerToken);
    player.roleAcknowledged = true;
    await this.players.save(player);

    const all = await this.players.find({ where: { gameId } });
    const everyone = all.every((p) => p.roleAcknowledged);
    if (everyone) {
      const game = await this.getGameOrFail(gameId);
      if (game.phase === 'role_reveal') {
        game.phase = 'night';
        await this.games.save(game);
      }
    }
    return { ok: true };
  }

  async submitNightAction(gameId: string, dto: any) {
    const player = await this.requirePlayer(gameId, dto.playerToken);
    const game = await this.getGameOrFail(gameId);
    if (game.phase !== 'night') {
      throw new BadRequestException('Não é noite.');
    }
    const action = this.actions.create({
      id: randomUUID(),
      gameId,
      round: game.round,
      actorId: player.id,
      targetId: dto.targetId ?? null,
      secondaryTargetId: dto.secondaryTargetId ?? null,
      actionType: dto.actionType,
      payload: dto.payload ?? null,
    });
    await this.actions.save(action);
    return { ok: true };
  }

  async resolveNight(gameId: string, hostToken: string) {
    const game = await this.requireHost(gameId, hostToken);
    if (game.phase !== 'night') {
      throw new BadRequestException('Fase atual não é noite.');
    }
    const players = await this.players.find({ where: { gameId } });
    const acts = await this.actions.find({
      where: { gameId, round: game.round },
    });

    const result = this.engine.resolveNight(
      players,
      acts.map((a) => ({
        actorId: a.actorId,
        targetId: a.targetId,
        secondaryTargetId: a.secondaryTargetId,
        actionType: a.actionType,
        payload: a.payload,
      })),
      game.round,
      game.state ?? {},
    );

    game.state = result.stateMutations;
    await this.persistResolution(game, players, result);

    game.phase = 'dawn';
    await this.games.save(game);
    const winner = this.engine.checkWinner(players, game.state ?? {});
    if (winner) {
      game.winner = winner;
      game.status = 'finished';
      game.phase = 'end';
      await this.games.save(game);
    }
    return { ok: true, events: result.events.filter((e) => e.isPublic) };
  }

  async advanceToDiscussion(gameId: string, hostToken: string) {
    const game = await this.requireHost(gameId, hostToken);
    if (game.phase !== 'dawn') {
      throw new BadRequestException('Fase atual não é amanhecer.');
    }
    game.phase = 'discussion';
    await this.games.save(game);
    return { ok: true };
  }

  async startVoting(gameId: string, hostToken: string) {
    const game = await this.requireHost(gameId, hostToken);
    if (game.phase !== 'discussion') {
      throw new BadRequestException('Fase atual não é discussão.');
    }
    game.phase = 'voting';
    await this.games.save(game);
    return { ok: true };
  }

  async submitVote(gameId: string, dto: any) {
    const game = await this.getGameOrFail(gameId);
    if (game.phase !== 'voting') {
      throw new BadRequestException('Não é momento de votar.');
    }
    const player = await this.requirePlayer(gameId, dto.playerToken);
    if (!player.isAlive) throw new BadRequestException('Jogador morto não vota.');
    if (!player.canVote) throw new BadRequestException('Você não pode votar.');
    const existing = await this.votes.findOne({
      where: { gameId, round: game.round, voterId: player.id },
    });
    if (existing) {
      existing.targetId = dto.targetId ?? null;
      await this.votes.save(existing);
    } else {
      const vote = this.votes.create({
        id: randomUUID(),
        gameId,
        round: game.round,
        voterId: player.id,
        targetId: dto.targetId ?? null,
      });
      await this.votes.save(vote);
    }
    return { ok: true };
  }

  async resolveVotes(gameId: string, hostToken: string) {
    const game = await this.requireHost(gameId, hostToken);
    if (game.phase !== 'voting') {
      throw new BadRequestException('Fase atual não é votação.');
    }
    const players = await this.players.find({ where: { gameId } });
    const votes = await this.votes.find({
      where: { gameId, round: game.round },
    });
    const result = this.engine.resolveVotes(
      players,
      votes.map((v) => ({ voterId: v.voterId, targetId: v.targetId })),
      { ...(game.state ?? {}), round: game.round },
    );
    game.state = result.stateMutations;
    await this.persistResolution(game, players, result);

    const winner = this.engine.checkWinner(players, game.state ?? {});
    if (winner) {
      game.winner = winner;
      game.status = 'finished';
      game.phase = 'end';
      await this.games.save(game);
      return { ok: true, events: result.events.filter((e) => e.isPublic), winner };
    }

    game.phase = 'night';
    game.round += 1;
    await this.games.save(game);
    return { ok: true, events: result.events.filter((e) => e.isPublic) };
  }

  private async persistResolution(
    game: Game,
    players: Player[],
    result: { events: any[]; deaths: string[] },
  ) {
    await this.players.save(players);
    const logs = result.events.map((e) =>
      this.logs.create({
        id: randomUUID(),
        gameId: game.id,
        round: game.round,
        phase: game.phase,
        event: e.type,
        data: { message: e.message, ...(e.data ?? {}) },
        isPublic: e.isPublic,
        recipientId: e.recipientId ?? null,
      }),
    );
    if (logs.length > 0) await this.logs.save(logs);
  }

  // ------------------------ Queries ------------------------

  async getGameState(gameId: string, playerToken?: string) {
    const game = await this.getGameOrFail(gameId);
    const players = await this.players.find({ where: { gameId } });
    const me = playerToken
      ? players.find((p) => p.token === playerToken)
      : null;

    const publicPlayers: PublicPlayer[] = players
      .sort((a, b) => a.seatOrder - b.seatOrder)
      .map((p) => ({
        id: p.id,
        name: p.name,
        isAlive: p.isAlive,
        isRevealed: p.isRevealed,
        seatOrder: p.seatOrder,
        role:
          game.phase === 'end' || p.isRevealed
            ? p.role
            : me && me.id === p.id
              ? p.role
              : null,
      }));

    const publicLogs = await this.logs.find({
      where: { gameId, isPublic: true },
      order: { createdAt: 'ASC' },
    });

    const privateLogs = me
      ? await this.logs
          .createQueryBuilder('l')
          .where('l.gameId = :gameId', { gameId })
          .andWhere('l.isPublic = :pub', { pub: false })
          .andWhere('l.recipientId = :rec', { rec: me.id })
          .orderBy('l.createdAt', 'ASC')
          .getMany()
      : [];

    return {
      id: game.id,
      status: game.status,
      phase: game.phase,
      round: game.round,
      winner: game.winner,
      players: publicPlayers,
      me: me
        ? {
            id: me.id,
            name: me.name,
            role: me.role,
            isAlive: me.isAlive,
            canVote: me.canVote,
            canSpeak: me.canSpeak,
            flags: me.flags,
          }
        : null,
      logs: publicLogs.map((l) => ({
        round: l.round,
        phase: l.phase,
        event: l.event,
        message: l.data?.message,
        data: l.data,
        createdAt: l.createdAt,
      })),
      dms: privateLogs.map((l) => ({
        round: l.round,
        phase: l.phase,
        event: l.event,
        message: l.data?.message,
        data: l.data,
        createdAt: l.createdAt,
      })),
    };
  }

  async listGames() {
    const games = await this.games.find({ order: { createdAt: 'DESC' } });
    return games.map((g) => ({
      id: g.id,
      status: g.status,
      phase: g.phase,
      round: g.round,
    }));
  }

  // ------------------------ Chat ------------------------

  async postChat(gameId: string, dto: any) {
    const game = await this.getGameOrFail(gameId);
    const player = await this.requirePlayer(gameId, dto.playerToken);
    if (!player.canSpeak && (dto.channel ?? 'public') === 'public') {
      throw new BadRequestException('Você não pode falar.');
    }
    if (dto.channel === 'wolves' && !isWolf(player.role)) {
      throw new BadRequestException('Canal restrito aos lobos.');
    }
    const log = this.logs.create({
      id: randomUUID(),
      gameId,
      round: game.round,
      phase: game.phase,
      event: 'chat',
      data: { from: player.name, text: dto.text, channel: dto.channel ?? 'public' },
      isPublic: (dto.channel ?? 'public') === 'public',
      recipientId: null,
    });
    await this.logs.save(log);
    return { ok: true };
  }

  async getWolfChat(gameId: string, playerToken: string) {
    const player = await this.requirePlayer(gameId, playerToken);
    if (!isWolf(player.role)) throw new BadRequestException('Não autorizado.');
    const logs = await this.logs.find({
      where: { gameId, event: 'chat' },
      order: { createdAt: 'ASC' },
    });
    return logs
      .filter((l) => l.data?.channel === 'wolves')
      .map((l) => ({ from: l.data?.from, text: l.data?.text, at: l.createdAt }));
  }

  // ------------------------ Helpers ------------------------

  private async getGameOrFail(id: string) {
    const g = await this.games.findOne({ where: { id } });
    if (!g) throw new NotFoundException('Partida não encontrada.');
    return g;
  }

  private async requireHost(gameId: string, hostToken: string) {
    const g = await this.getGameOrFail(gameId);
    if (g.hostToken !== hostToken) throw new BadRequestException('Não é o host.');
    return g;
  }

  private async requirePlayer(gameId: string, token: string) {
    const p = await this.players.findOne({ where: { gameId, token } });
    if (!p) throw new NotFoundException('Jogador não encontrado.');
    return p;
  }
}
