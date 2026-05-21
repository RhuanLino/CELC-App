import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Game } from './game.entity';

@Entity()
export class Player {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column()
  token: string;

  @Column({ nullable: true })
  role: string | null;

  @Column({ default: true })
  isAlive: boolean;

  @Column({ default: false })
  isRevealed: boolean;

  @Column({ default: 0 })
  seatOrder: number;

  @Column({ default: false })
  canVote: boolean;

  @Column({ default: false })
  canSpeak: boolean;

  @Column({ default: false })
  roleAcknowledged: boolean;

  @Column({ type: 'simple-json', nullable: true })
  flags: Record<string, any> | null;

  @ManyToOne(() => Game, (g) => g.players, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'gameId' })
  game: Game;

  @Column()
  gameId: string;
}
