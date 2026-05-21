import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
} from '@nestjs/common';
import { GameService } from './game.service';
import {
  CreateGameDto,
  JoinGameDto,
  SetRolePoolDto,
  AdvancePhaseDto,
  SubmitNightActionDto,
  SubmitVoteDto,
  ChatMessageDto,
} from './dto/game.dto';

@Controller('api')
export class GameController {
  constructor(private readonly service: GameService) {}

  @Get('roles')
  listRoles() {
    return this.service.listRoles();
  }

  @Get('games')
  listGames() {
    return this.service.listGames();
  }

  @Post('games')
  create(@Body() dto: CreateGameDto) {
    return this.service.createGame(dto.hostName);
  }

  @Post('games/:id/join')
  join(@Param('id') id: string, @Body() dto: JoinGameDto) {
    return this.service.joinGame(id, dto.name);
  }

  @Post('games/:id/role-pool')
  setPool(
    @Param('id') id: string,
    @Body() body: SetRolePoolDto & { hostToken: string },
  ) {
    return this.service.setRolePool(id, body.hostToken, body.rolePool);
  }

  @Post('games/:id/start')
  start(@Param('id') id: string, @Body() body: AdvancePhaseDto) {
    return this.service.startGame(id, body.hostToken);
  }

  @Post('games/:id/ack-role')
  ackRole(
    @Param('id') id: string,
    @Body() body: { playerToken: string },
  ) {
    return this.service.acknowledgeRole(id, body.playerToken);
  }

  @Post('games/:id/night-action')
  nightAction(
    @Param('id') id: string,
    @Body() dto: SubmitNightActionDto,
  ) {
    return this.service.submitNightAction(id, dto);
  }

  @Post('games/:id/resolve-night')
  resolveNight(
    @Param('id') id: string,
    @Body() body: AdvancePhaseDto,
  ) {
    return this.service.resolveNight(id, body.hostToken);
  }

  @Post('games/:id/discussion')
  toDiscussion(
    @Param('id') id: string,
    @Body() body: AdvancePhaseDto,
  ) {
    return this.service.advanceToDiscussion(id, body.hostToken);
  }

  @Post('games/:id/start-voting')
  toVoting(
    @Param('id') id: string,
    @Body() body: AdvancePhaseDto,
  ) {
    return this.service.startVoting(id, body.hostToken);
  }

  @Post('games/:id/vote')
  vote(@Param('id') id: string, @Body() dto: SubmitVoteDto) {
    return this.service.submitVote(id, dto);
  }

  @Post('games/:id/resolve-votes')
  resolveVotes(
    @Param('id') id: string,
    @Body() body: AdvancePhaseDto,
  ) {
    return this.service.resolveVotes(id, body.hostToken);
  }

  @Get('games/:id/state')
  state(@Param('id') id: string, @Query('token') token?: string) {
    return this.service.getGameState(id, token);
  }

  @Post('games/:id/chat')
  chat(@Param('id') id: string, @Body() dto: ChatMessageDto) {
    return this.service.postChat(id, dto);
  }

  @Get('games/:id/wolf-chat')
  wolfChat(@Param('id') id: string, @Query('token') token: string) {
    return this.service.getWolfChat(id, token);
  }
}
