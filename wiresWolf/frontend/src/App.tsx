import { useEffect, useState } from 'react';
import { Api, getServerUrl, setServerUrl } from './api';
import HostPanel from './screens/HostPanel';
import PlayerPanel from './screens/PlayerPanel';
import Home from './screens/Home';

type Session =
  | { kind: 'none' }
  | { kind: 'host'; gameId: string; hostToken: string; playerId: string }
  | { kind: 'player'; gameId: string; playerToken: string; playerId: string };

const SESSION_KEY = 'wireswolfs.session';

export default function App() {
  const [session, setSession] = useState<Session>({ kind: 'none' });
  const [server, setServer] = useState(getServerUrl());

  useEffect(() => {
    const saved = localStorage.getItem(SESSION_KEY);
    if (saved) setSession(JSON.parse(saved));
  }, []);

  const updateSession = (s: Session) => {
    setSession(s);
    if (s.kind === 'none') localStorage.removeItem(SESSION_KEY);
    else localStorage.setItem(SESSION_KEY, JSON.stringify(s));
  };

  const updateServer = (url: string) => {
    setServerUrl(url);
    setServer(url);
  };

  return (
    <div className="app">
      <h1>🐺 WiresWolfs</h1>
      {session.kind === 'none' && (
        <Home
          serverUrl={server}
          onServerChange={updateServer}
          onSession={updateSession}
        />
      )}
      {session.kind === 'host' && (
        <HostPanel session={session} onExit={() => updateSession({ kind: 'none' })} />
      )}
      {session.kind === 'player' && (
        <PlayerPanel session={session} onExit={() => updateSession({ kind: 'none' })} />
      )}
    </div>
  );
}
