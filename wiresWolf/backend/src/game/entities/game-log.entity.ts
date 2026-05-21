import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Game } from './game.entity';

@Entity()
export class GameLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  round: number;

  @Column()
  phase: string;

  @Column()
  event: string;

  @Column({ type: 'simple-json', nullable: true })
  data: Record<string, any> | null;

  @Column({ default: true })
  isPublic: boolean;

  @Column({ nullable: true })
  recipientId: string | null;

  @ManyToOne(() => Game, (g) => g.logs, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'gameId' })
  game: Game;

  @Column()
  gameId: string;

  @CreateDateColumn()
  createdAt: Date;
}
