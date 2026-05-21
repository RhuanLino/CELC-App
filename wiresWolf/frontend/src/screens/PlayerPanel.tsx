import { useEffect, useState } from 'react';
import { Api, getSocket } from '../api';

interface Props {
  session: { gameId: string; playerToken: string; playerId: string };
  onExit: () => void;
}

const NIGHT_ACTIONS: Record<string, { label: string; needsTarget?: boolean; needsSecond?: boolean; choices?: { id: string; label: string }[] }> = {
  medico: { label: 'Proteger', needsTarget: true },
  guarda_costas: { label: 'Proteger', needsTarget: true },
  bruxa: {
    label: 'Usar poção',
    choices: [
      { id: 'witch_heal', label: 'Curar (AOE)' },
      { id: 'witch_poison', label: 'Envenenar (escolher alvo)' },
    ],
  },
  detetive: { label: 'Comparar 2 jogadores', needsTarget: true, needsSecond: true },
  dama_de_vermelho: { label: 'Visitar', needsTarget: true },
  vovo_rabugenta: { label: 'Bloquear voto', needsTarget: true },
  assassino: { label: 'Matar', needsTarget: true },
  incendiario: {
    label: 'Ação',
    choices: [
      { id: 'arsonist_douse', label: 'Encharcar (1 alvo)' },
      { id: 'arsonist_burn', label: 'Queimar todos os encharcados' },
    ],
  },
  feiticeira: { label: 'Investigar (vidente/lobo)', needsTarget: true },
  lobo_vidente: { label: 'Descobrir função', needsTarget: true },
  vigilante: {
    label: 'Ação',
    choices: [
      { id: 'vigilante_investigate', label: 'Investigar' },
      { id: 'vigilante_shoot', label: 'Atirar' },
    ],
  },
  franco_atirador: {
    label: 'Ação',
    choices: [
      { id: 'sniper_mark', label: 'Marcar alvo' },
      { id: 'sniper_shoot', label: 'Atirar no alvo marcado' },
    ],
  },
  cacador_de_feras: { label: 'Colocar armadilha', needsTarget: true },
  padre: { label: 'Usar água benta', needsTarget: true },
  ladrao_de_tumulos: { label: 'Escolher alvo', needsTarget: true },
  cupido: { label: 'Formar casal', needsTarget: true, needsSecond: true },
  menino_travesso: { label: 'Trocar 2 funções', needsTarget: true, needsSecond: true },
  medium: { label: 'Reviver morto', needsTarget: true },
  nightmare_werewolf: { label: 'Bloquear jogador', needsTarget: true },
  lobisomem: { label: 'Voto lobo (vítima)', needsTarget: true },
  lobo_solitario: { label: 'Voto lobo (vítima)', needsTarget: true },
  lobisomem_filhote: { label: 'Voto lobo (vítima)', needsTarget: true },
  lobisomem_alfa: { label: 'Voto lobo (vítima)', needsTarget: true },
  lobo_gatinho: {
    label: 'Ação',
    choices: [
      { id: 'wolf_kill_vote', label: 'Voto lobo (matar)' },
      { id: 'kitten_convert', label: 'Converter (1 vez)' },
    ],
  },
  lobo_sombrio: { label: 'Voto lobo (vítima)', needsTarget: true },
};

const WOLF_ACTION_MAP: Record<string, string> = {
  lobisomem: 'wolf_kill_vote',
  lobo_solitario: 'wolf_kill_vote',
  lobisomem_filhote: 'wolf_kill_vote',
  lobisomem_alfa: 'wolf_kill_vote',
  lobo_sombrio: 'wolf_kill_vote',
  nightmare_werewolf: 'nightmare_block',
  lobo_vidente: 'wolf_seer',
  feiticeira: 'witch_investigate',
};

const SIMPLE_ACTION_MAP: Record<string, string> = {
  medico: 'doctor_protect',
  guarda_costas: 'bodyguard_protect',
  detetive: 'detective_compare',
  dama_de_vermelho: 'dama_visit',
  vovo_rabugenta: 'grandma_silence',
  assassino: 'assassin_kill',
  cacador_de_feras: 'trap_set',
  padre: 'priest_blessing',
  ladrao_de_tumulos: 'gravedigger_target',
  cupido: 'cupid_link',
  menino_travesso: 'swap_roles',
  medium: 'medium_revive',
};

export default function PlayerPanel({ session, onExit }: Props) {
  const [state, setState] = useState<any>(null);
  const [target, setTarget] = useState<string>('');
  const [target2, setTarget2] = useState<string>('');
  const [choice, setChoice] = useState<string>('');
  const [chatText, setChatText] = useState('');
  const [wolfChatText, setWolfChatText] = useState('');
  const [err, setErr] = useState('');

  const refresh = async () => {
    try {
      const s = await Api.getState(session.gameId, session.playerToken);
      setState(s);
    } catch (e: any) {
      setErr(e.message);
    }
  };

  useEffect(() => {
    refresh();
    const sock = getSocket();
    sock.emit('join_game', { gameId: session.gameId, playerToken: session.playerToken });
    sock.on('state_changed', refresh);
    const t = setInterval(refresh, 2500);
    return () => {
      sock.off('state_changed', refresh);
      clearInterval(t);
    };
  }, []);

  if (!state) return <div className="card">Carregando…</div>;
  const me = state.me;
  if (!me) return <div className="card">Sessão expirou. <button onClick={onExit}>Sair</button></div>;

  const ackRole = async () => {
    await Api.ackRole(session.gameId, session.playerToken);
    refresh();
  };

  const submitAction = async () => {
    setErr('');
    try {
      const role = me.role;
      const def = NIGHT_ACTIONS[role];
      if (!def) return;
      let actionType = SIMPLE_ACTION_MAP[role] ?? WOLF_ACTION_MAP[role] ?? choice;
      if (def.choices && choice) actionType = choice;
      await Api.submitNightAction(session.gameId, {
        playerToken: session.playerToken,
        actionType,
        targetId: target || undefined,
        secondaryTargetId: target2 || undefined,
      });
      setTarget('');
      setTarget2('');
      setChoice('');
      refresh();
    } catch (e: any) {
      setErr(e.message);
    }
  };

  const submitVote = async (targetId: string | null) => {
    try {
      await Api.vote(session.gameId, { playerToken: session.playerToken, targetId });
      refresh();
    } catch (e: any) {
      setErr(e.message);
    }
  };

  const sendChat = async (channel: 'public' | 'wolves') => {
    const text = channel === 'public' ? chatText : wolfChatText;
    if (!text.trim()) return;
    try {
      await Api.chat(session.gameId, { playerToken: session.playerToken, text, channel });
      if (channel === 'public') setChatText('');
      else setWolfChatText('');
      refresh();
    } catch (e: any) {
      setErr(e.message);
    }
  };

  const alivePlayers = state.players.filter((p: any) => p.isAlive && p.id !== me.id);
  const targets = state.players.filter((p: any) => p.isAlive);
  const actionDef = me.role ? NIGHT_ACTIONS[me.role] : null;

  return (
    <>
      <div className="card">
        <div className={`phase-banner ${state.phase}`}>
          {state.phase} • Rodada {state.round}
        </div>
        <small>Você: <strong>{me.name}</strong> {me.isAlive ? '' : '💀'}</small>
      </div>

      {state.phase === 'role_reveal' && (
        <div className="card role-card">
          <h2>{me.role}</h2>
          <p className="desc">{actionDef?.label || 'Função sem ação noturna ativa.'}</p>
          {!me.flags?.bountyTarget ? null : (
            <p style={{ color: '#ffd370', marginTop: 12 }}>
              Seu alvo: <strong>{state.players.find((p: any) => p.id === me.flags.bountyTarget)?.name}</strong>
            </p>
          )}
          {!me.roleAcknowledged && <button onClick={ackRole}>Li e Entendi</button>}
        </div>
      )}

      {state.phase === 'night' && me.isAlive && (
        <div className="card">
          <h3>🌙 Sua ação noturna</h3>
          {!actionDef && <p>Você não tem ação esta noite. Aguarde o amanhecer.</p>}
          {actionDef && (
            <>
              {actionDef.choices && (
                <select className="select" value={choice} onChange={(e) => setChoice(e.target.value)}>
                  <option value="">— escolha —</option>
                  {actionDef.choices.map((c) => (
                    <option key={c.id} value={c.id}>{c.label}</option>
                  ))}
                </select>
              )}
              {(actionDef.needsTarget || choice) && (
                <select className="select" value={target} onChange={(e) => setTarget(e.target.value)}>
                  <option value="">— alvo —</option>
                  {targets.map((p: any) => (
                    <option key={p.id} value={p.id}>{p.name}</option>
                  ))}
                </select>
              )}
              {actionDef.needsSecond && (
                <select className="select" value={target2} onChange={(e) => setTarget2(e.target.value)}>
                  <option value="">— segundo alvo —</option>
                  {targets.map((p: any) => (
                    <option key={p.id} value={p.id}>{p.name}</option>
                  ))}
                </select>
              )}
              <button onClick={submitAction}>Submeter Ação</button>
            </>
          )}
        </div>
      )}

      {state.phase === 'discussion' && me.isAlive && (
        <div className="card">
          <h3>💬 Chat</h3>
          {me.canSpeak ? (
            <>
              <input
                className="input"
                value={chatText}
                onChange={(e) => setChatText(e.target.value)}
                placeholder="Digite sua mensagem"
              />
              <button onClick={() => sendChat('public')}>Enviar</button>
            </>
          ) : (
            <p style={{ color: '#f99' }}>Você está bêbado — não pode falar.</p>
          )}
        </div>
      )}

      {state.phase === 'voting' && me.isAlive && (
        <div className="card">
          <h3>🗳️ Votar</h3>
          {!me.canVote && <p style={{ color: '#f99' }}>Você não pode votar nesta rodada.</p>}
          {me.canVote && (
            <>
              {alivePlayers.map((p: any) => (
                <button key={p.id} onClick={() => submitVote(p.id)}>Votar em {p.name}</button>
              ))}
              <button className="ghost" onClick={() => submitVote(null)}>Pular voto</button>
            </>
          )}
        </div>
      )}

      <div className="card">
        <h3>Jogadores</h3>
        {state.players.map((p: any) => (
          <div key={p.id} className={`player-pill ${p.isAlive ? '' : 'dead'}`}>
            <span>{p.seatOrder + 1}. {p.name}</span>
            {p.isRevealed && p.role && <span className="tag">{p.role}</span>}
          </div>
        ))}
      </div>

      <div className="card">
        <h3>Eventos</h3>
        {state.logs.slice(-12).map((l: any, i: number) => (
          <div key={i} className="log-line">[R{l.round}] {l.message}</div>
        ))}
      </div>

      {state.dms?.length > 0 && (
        <div className="card">
          <h3>📩 Mensagens privadas</h3>
          {state.dms.slice(-12).map((l: any, i: number) => (
            <div key={i} className="log-line dm">[R{l.round}] {l.message}</div>
          ))}
        </div>
      )}

      {me.role && ['lobisomem', 'lobo_solitario', 'lobisomem_filhote', 'lobisomem_alfa', 'lobo_sombrio', 'nightmare_werewolf', 'lobo_vidente', 'lobo_gatinho', 'amaldicoado'].includes(me.role) && state.phase === 'night' && (
        <div className="card">
          <h3>🐺 Chat da matilha</h3>
          <input
            className="input"
            value={wolfChatText}
            onChange={(e) => setWolfChatText(e.target.value)}
            placeholder="Mensagem aos lobos"
          />
          <button className="danger" onClick={() => sendChat('wolves')}>Enviar (lobos)</button>
        </div>
      )}

      {state.phase === 'end' && (
        <div className="card">
          <h3>🏁 Fim de Jogo</h3>
          <p>Vencedor: <strong>{state.winner}</strong></p>
        </div>
      )}

      {err && <div className="card" style={{ color: '#f99' }}>{err}</div>}
      <button className="ghost" onClick={onExit}>Sair</button>
    </>
  );
}
