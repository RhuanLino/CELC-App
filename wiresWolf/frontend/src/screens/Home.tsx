import { useEffect, useState } from 'react';
import { Api } from '../api';

interface Props {
  serverUrl: string;
  onServerChange: (url: string) => void;
  onSession: (s: any) => void;
}

export default function Home({ serverUrl, onServerChange, onSession }: Props) {
  const [server, setServer] = useState(serverUrl);
  const [mode, setMode] = useState<'host' | 'join' | null>(null);
  const [name, setName] = useState('');
  const [gameId, setGameId] = useState('');
  const [games, setGames] = useState<any[]>([]);
  const [err, setErr] = useState('');

  useEffect(() => {
    if (mode === 'join') {
      Api.listGames().then(setGames).catch(() => setGames([]));
    }
  }, [mode]);

  const saveServer = () => {
    onServerChange(server);
  };

  const create = async () => {
    setErr('');
    try {
      const r = await Api.createGame(name);
      onSession({ kind: 'host', gameId: r.gameId, hostToken: r.hostToken, playerId: r.playerId });
    } catch (e: any) {
      setErr(e.message);
    }
  };

  const join = async () => {
    setErr('');
    try {
      const r = await Api.joinGame(gameId, name);
      onSession({ kind: 'player', gameId, playerToken: r.playerToken, playerId: r.playerId });
    } catch (e: any) {
      setErr(e.message);
    }
  };

  return (
    <>
      <div className="card">
        <h3>Servidor</h3>
        <input
          className="input"
          value={server}
          onChange={(e) => setServer(e.target.value)}
          placeholder="http://192.168.x.x:8080 ou https://xxx.ngrok-free.app"
        />
        <button className="ghost" onClick={saveServer}>Salvar IP do servidor</button>
      </div>

      {!mode && (
        <div className="card">
          <button onClick={() => setMode('host')}>Criar Partida (Host)</button>
          <button className="ghost" onClick={() => setMode('join')}>Entrar em Partida</button>
        </div>
      )}

      {mode === 'host' && (
        <div className="card">
          <h3>Criar partida</h3>
          <input
            className="input"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Seu nome (Mestre do Jogo)"
          />
          <button onClick={create} disabled={!name}>Criar</button>
          <button className="ghost" onClick={() => setMode(null)}>Voltar</button>
        </div>
      )}

      {mode === 'join' && (
        <div className="card">
          <h3>Entrar em partida</h3>
          <input
            className="input"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Seu nome"
          />
          <input
            className="input"
            value={gameId}
            onChange={(e) => setGameId(e.target.value)}
            placeholder="ID da partida"
          />
          {games.length > 0 && (
            <select className="select" value={gameId} onChange={(e) => setGameId(e.target.value)}>
              <option value="">— escolha uma partida ativa —</option>
              {games
                .filter((g) => g.status === 'lobby')
                .map((g) => (
                  <option key={g.id} value={g.id}>{g.id.slice(0, 8)}…</option>
                ))}
            </select>
          )}
          <button onClick={join} disabled={!name || !gameId}>Entrar</button>
          <button className="ghost" onClick={() => setMode(null)}>Voltar</button>
        </div>
      )}

      {err && <div className="card" style={{ color: '#f99' }}>{err}</div>}
    </>
  );
}
