import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Game } from './entities/game.entity';
import { Player } from './entities/player.entity';
import { NightAction } from './entities/night-action.entity';
import { Vote } from './entities/vote.entity';
import { GameLog } from './entities/game-log.entity';
import { GameService } from './game.service';
import { GameController } from './game.controller';
import { GameGateway } from './game.gateway';
import { GameEngine } from './engine/game-engine.service';

@Module({
  imports: [TypeOrmModule.forFeature([Game, Player, NightAction, Vote, GameLog])],
  controllers: [GameController],
  providers: [GameService, GameEngine, GameGateway],
})
export class GameModule {}
