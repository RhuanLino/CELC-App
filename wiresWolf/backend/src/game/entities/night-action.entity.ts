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
export class NightAction {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  round: number;

  @Column()
  actorId: string;

  @Column({ nullable: true })
  targetId: string | null;

  @Column({ nullable: true })
  secondaryTargetId: string | null;

  @Column()
  actionType: string;

  @Column({ type: 'simple-json', nullable: true })
  payload: Record<string, any> | null;

  @ManyToOne(() => Game, (g) => g.nightActions, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'gameId' })
  game: Game;

  @Column()
  gameId: string;

  @CreateDateColumn()
  createdAt: Date;
}
