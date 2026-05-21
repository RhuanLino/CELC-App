import { IsArray, IsOptional, IsString, ArrayMinSize } from 'class-validator';

export class CreateGameDto {
  @IsString()
  hostName: string;
}

export class JoinGameDto {
  @IsString()
  name: string;
}

export class SetRolePoolDto {
  @IsArray()
  @ArrayMinSize(4)
  @IsString({ each: true })
  rolePool: string[];
}

export class StartGameDto {}

export class AckRoleDto {
  @IsString()
  playerToken: string;
}

export class SubmitNightActionDto {
  @IsString()
  playerToken: string;

  @IsString()
  actionType: string;

  @IsOptional()
  @IsString()
  targetId?: string;

  @IsOptional()
  @IsString()
  secondaryTargetId?: string;

  @IsOptional()
  payload?: Record<string, any>;
}

export class SubmitVoteDto {
  @IsString()
  playerToken: string;

  @IsOptional()
  @IsString()
  targetId?: string | null;
}

export class AdvancePhaseDto {
  @IsString()
  hostToken: string;
}

export class ChatMessageDto {
  @IsString()
  playerToken: string;

  @IsString()
  text: string;

  @IsOptional()
  @IsString()
  channel?: 'public' | 'wolves';
}
