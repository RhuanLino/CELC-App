import { io, Socket } from 'socket.io-client';

const STORAGE_KEY = 'wireswolfs.server';

export function getServerUrl(): string {
  return localStorage.getItem(STORAGE_KEY) || window.location.origin;
}

export function setServerUrl(url: string) {
  const cleaned = url.replace(/\/$/, '');
  localStorage.setItem(STORAGE_KEY, cleaned);
  resetSocket();
}

async function api<T>(path: string, options: RequestInit = {}): Promise<T> {
  const res = await fetch(`${getServerUrl()}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      ...(options.headers || {}),
    },
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(body || `HTTP ${res.status}`);
  }
  return res.json();
}

export const Api = {
  listRoles: () => api<any[]>('/api/roles'),
  listGames: () => api<any[]>('/api/games'),
  createGame: (hostName: string) =>
    api<{ gameId: string; hostToken: string; playerId: string }>('/api/games', {
      method: 'POST',
      body: JSON.stringify({ hostName }),
    }),
  joinGame: (gameId: string, name: string) =>
    api<{ playerId: string; playerToken: string }>(
      `/api/games/${gameId}/join`,
      { method: 'POST', body: JSON.stringify({ name }) },
    ),
  setRolePool: (gameId: string, hostToken: string, rolePool: string[]) =>
    api(`/api/games/${gameId}/role-pool`, {
      method: 'POST',
      body: JSON.stringify({ hostToken, rolePool }),
    }),
  startGame: (gameId: string, hostToken: string) =>
    api(`/api/games/${gameId}/start`, {
      method: 'POST',
      body: JSON.stringify({ hostToken }),
    }),
  ackRole: (gameId: string, playerToken: string) =>
    api(`/api/games/${gameId}/ack-role`, {
      method: 'POST',
      body: JSON.stringify({ playerToken }),
    }),
  submitNightAction: (gameId: string, payload: any) =>
    api(`/api/games/${gameId}/night-action`, {
      method: 'POST',
      body: JSON.stringify(payload),
    }),
  resolveNight: (gameId: string, hostToken: string) =>
    api(`/api/games/${gameId}/resolve-night`, {
      method: 'POST',
      body: JSON.stringify({ hostToken }),
    }),
  goDiscussion: (gameId: string, hostToken: string) =>
    api(`/api/games/${gameId}/discussion`, {
      method: 'POST',
      body: JSON.stringify({ hostToken }),
    }),
  startVoting: (gameId: string, hostToken: string) =>
    api(`/api/games/${gameId}/start-voting`, {
      method: 'POST',
      body: JSON.stringify({ hostToken }),
    }),
  vote: (gameId: string, payload: any) =>
    api(`/api/games/${gameId}/vote`, {
      method: 'POST',
      body: JSON.stringify(payload),
    }),
  resolveVotes: (gameId: string, hostToken: string) =>
    api(`/api/games/${gameId}/resolve-votes`, {
      method: 'POST',
      body: JSON.stringify({ hostToken }),
    }),
  getState: (gameId: string, token?: string) =>
    api<any>(`/api/games/${gameId}/state${token ? `?token=${token}` : ''}`),
  chat: (gameId: string, payload: any) =>
    api(`/api/games/${gameId}/chat`, {
      method: 'POST',
      body: JSON.stringify(payload),
    }),
};

let socket: Socket | null = null;
export function getSocket(): Socket {
  if (!socket) {
    socket = io(getServerUrl(), {
      transports: ['websocket', 'polling'],
      extraHeaders: { 'ngrok-skip-browser-warning': 'true' },
    });
  }
  return socket;
}

export function resetSocket() {
  if (socket) {
    socket.disconnect();
    socket = null;
  }
}
