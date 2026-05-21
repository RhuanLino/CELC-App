import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { GameModule } from './game/game.module';
import { Game } from './game/entities/game.entity';
import { Player } from './game/entities/player.entity';
import { NightAction } from './game/entities/night-action.entity';
import { Vote } from './game/entities/vote.entity';
import { GameLog } from './game/entities/game-log.entity';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'sqljs',
      location: 'game.db',
      autoSave: true,
      entities: [Game, Player, NightAction, Vote, GameLog],
      synchronize: true,
    }),
    GameModule,
  ],
})
export class AppModule {}
