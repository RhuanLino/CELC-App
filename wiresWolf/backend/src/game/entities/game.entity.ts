import {
  Column,
  CreateDateColumn,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Player } from './player.entity';
import { NightAction } from './night-action.entity';
import { Vote } from './vote.entity';
import { GameLog } from './game-log.entity';

export type GameStatus = 'lobby' | 'in_progress' | 'finished';
export type GamePhase =
  | 'lobby'
  | 'role_reveal'
  | 'night'
  | 'dawn'
  | 'discussion'
  | 'voting'
  | 'end';

@Entity()
export class Game {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ default: 'lobby' })
  status: GameStatus;

  @Column({ default: 'lobby' })
  phase: GamePhase;

  @Column({ default: 0 })
  round: number;

  @Column({ type: 'simple-json', nullable: true })
  rolePool: string[] | null;

  @Column({ type: 'simple-json', nullable: true })
  state: Record<string, any> | null;

  @Column({ nullable: true })
  hostToken: string | null;

  @Column({ nullable: true })
  winner: string | null;

  @CreateDateColumn()
  createdAt: Date;

  @OneToMany(() => Player, (p) => p.game, { cascade: true })
  players: Player[];

  @OneToMany(() => NightAction, (n) => n.game, { cascade: true })
  nightActions: NightAction[];

  @OneToMany(() => Vote, (v) => v.game, { cascade: true })
  votes: Vote[];

  @OneToMany(() => GameLog, (l) => l.game, { cascade: true })
  logs: GameLog[];
}
