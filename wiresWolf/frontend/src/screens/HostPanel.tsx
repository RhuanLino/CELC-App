import { useEffect, useState } from 'react';
import { Api, getSocket } from '../api';

interface Props {
  session: { gameId: string; hostToken: string; playerId: string };
  onExit: () => void;
}

export default function HostPanel({ session, onExit }: Props) {
  const [state, setState] = useState<any>(null);
  const [roles, setRoles] = useState<any[]>([]);
  const [pool, setPool] = useState<string[]>([]);
  const [err, setErr] = useState('');

  const refresh = async () => {
    try {
      const s = await Api.getState(session.gameId);
      setState(s);
    } catch (e: any) {
      setErr(e.message);
    }
  };

  useEffect(() => {
    refresh();
    Api.listRoles().then(setRoles);
    const sock = getSocket();
    sock.emit('join_game', { gameId: session.gameId });
    sock.on('state_changed', refresh);
    const t = setInterval(refresh, 3000);
    return () => {
      sock.off('state_changed', refresh);
      clearInterval(t);
    };
  }, []);

  if (!state) return <div className="card">Carregando…</div>;

  const toggleRole = (id: string) => {
    setPool((p) => [...p, id]);
  };
  const removeFromPool = (idx: number) => {
    setPool((p) => p.filter((_, i) => i !== idx));
  };

  const savePool = async () => {
    try {
      await Api.setRolePool(session.gameId, session.hostToken, pool);
      refresh();
    } catch (e: any) {
      setErr(e.message);
    }
  };

  const startGame = async () => {
    try {
      await Api.startGame(session.gameId, session.hostToken);
      refresh();
    } catch (e: any) {
      setErr(e.message);
    }
  };

  const advance = async (fn: () => Promise<any>) => {
    try {
      await fn();
      refresh();
    } catch (e: any) {
      setErr(e.message);
    }
  };

  return (
    <>
      <div className="card">
        <small>ID: <strong>{session.gameId}</strong></small>
        <div className={`phase-banner ${state.phase}`}>
          Fase: {state.phase} • Rodada {state.round}
        </div>
      </div>

      <div className="card">
        <h3>Jogadores ({state.players.length})</h3>
        {state.players.map((p: any) => (
          <div key={p.id} className={`player-pill ${p.isAlive ? '' : 'dead'}`}>
            <span>{p.seatOrder + 1}. {p.name}</span>
            {p.role && <span className="tag">{p.role}</span>}
          </div>
        ))}
      </div>

      {state.phase === 'lobby' && (
        <div className="card">
          <h3>Pool de funções ({pool.length}/{state.players.length})</h3>
          <div style={{ maxHeight: 180, overflowY: 'auto', marginBottom: 8 }}>
            {pool.map((r, i) => (
              <div key={i} className="role-checkbox" onClick={() => removeFromPool(i)}>
                <span>{roles.find((x) => x.id === r)?.name || r}</span>
                <small>tap p/ remover</small>
              </div>
            ))}
          </div>
          <h4 style={{ marginTop: 12, marginBottom: 6 }}>Disponíveis</h4>
          <div style={{ maxHeight: 240, overflowY: 'auto' }}>
            {roles.map((r) => (
              <div key={r.id} className="role-checkbox" onClick={() => toggleRole(r.id)}>
                <span>
                  <span className={`tag ${r.team}`}>{r.team}</span> {r.name}
                </span>
                <small>+</small>
              </div>
            ))}
          </div>
          <button onClick={savePool} disabled={pool.length !== state.players.length}>
            Salvar Pool
          </button>
          <button className="success" onClick={startGame} disabled={pool.length !== state.players.length}>
            Iniciar Partida
          </button>
        </div>
      )}

      {state.phase === 'role_reveal' && (
        <div className="card">
          <h3>Distribuição de funções</h3>
          <p>Cada jogador deve abrir o app e confirmar a função.</p>
        </div>
      )}

      {state.phase === 'night' && (
        <div className="card">
          <h3>🌙 Noite — rodada {state.round}</h3>
          <p>Aguarde os jogadores submeterem ações.</p>
          <button className="warn" onClick={() => advance(() => Api.resolveNight(session.gameId, session.hostToken))}>
            Resolver Noite
          </button>
        </div>
      )}

      {state.phase === 'dawn' && (
        <div className="card">
          <h3>☀️ Amanhecer</h3>
          <button onClick={() => advance(() => Api.goDiscussion(session.gameId, session.hostToken))}>
            Ir para Discussão
          </button>
        </div>
      )}

      {state.phase === 'discussion' && (
        <div className="card">
          <h3>💬 Discussão</h3>
          <button onClick={() => advance(() => Api.startVoting(session.gameId, session.hostToken))}>
            Iniciar Votação
          </button>
        </div>
      )}

      {state.phase === 'voting' && (
        <div className="card">
          <h3>🗳️ Votação</h3>
          <button className="warn" onClick={() => advance(() => Api.resolveVotes(session.gameId, session.hostToken))}>
            Apurar Votos
          </button>
        </div>
      )}

      {state.phase === 'end' && (
        <div className="card">
          <h3>🏁 Fim de Jogo</h3>
          <p>Vencedor: <strong>{state.winner}</strong></p>
        </div>
      )}

      <div className="card">
        <h3>Eventos públicos</h3>
        {state.logs.slice(-15).map((l: any, i: number) => (
          <div key={i} className="log-line">[R{l.round}] {l.message}</div>
        ))}
      </div>

      {err && <div className="card" style={{ color: '#f99' }}>{err}</div>}
      <button className="ghost" onClick={onExit}>Sair</button>
    </>
  );
}
