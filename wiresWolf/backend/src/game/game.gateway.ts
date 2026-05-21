import {
  ConnectedSocket,
  MessageBody,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { GameService } from './game.service';

@WebSocketGateway({ cors: { origin: '*' } })
export class GameGateway {
  @WebSocketServer() server: Server;

  constructor(private readonly service: GameService) {}

  @SubscribeMessage('join_game')
  async joinRoom(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { gameId: string; playerToken?: string },
  ) {
    client.join(`game:${data.gameId}`);
    const state = await this.service.getGameState(data.gameId, data.playerToken);
    client.emit('state', state);
    return { ok: true };
  }

  @SubscribeMessage('refresh')
  async refresh(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { gameId: string; playerToken?: string },
  ) {
    const state = await this.service.getGameState(data.gameId, data.playerToken);
    client.emit('state', state);
  }

  broadcastState(gameId: string) {
    this.server.to(`game:${gameId}`).emit('state_changed', { gameId });
  }
}
