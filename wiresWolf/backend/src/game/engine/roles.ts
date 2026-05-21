export type Team = 'village' | 'wolves' | 'neutral';

export interface RoleDef {
  id: string;
  name: string;
  team: Team;
  description: string;
  hasNightAction: boolean;
  /** Lower runs first inside the night resolver. */
  nightOrder?: number;
  /** True if this role plays only on first night. */
  firstNightOnly?: boolean;
  /** True for roles that take public day actions. */
  hasDayAction?: boolean;
}

export const ROLES: Record<string, RoleDef> = {
  // --- VILLAGE ---
  aldeao: {
    id: 'aldeao',
    name: 'Aldeão',
    team: 'village',
    description:
      'Sem ação noturna. Participa da discussão e da votação. Encontre os lobos antes que eles dominem a aldeia.',
    hasNightAction: false,
  },
  medico: {
    id: 'medico',
    name: 'Médico',
    team: 'village',
    description:
      'À noite, escolhe 1 jogador para proteger. Não pode proteger o mesmo alvo 2 noites seguidas. Pode se proteger.',
    hasNightAction: true,
    nightOrder: 60,
  },
  vingador: {
    id: 'vingador',
    name: 'Vingador',
    team: 'village',
    description:
      'Sem ação noturna. Ao morrer, escolhe publicamente 1 jogador vivo para morrer junto.',
    hasNightAction: false,
  },
  bruxa: {
    id: 'bruxa',
    name: 'Bruxa',
    team: 'village',
    description:
      'Possui 1 poção de cura (salva todos que iriam morrer naquela noite) e 1 poção de veneno (mata 1 alvo). Cada poção é usada apenas 1 vez no jogo.',
    hasNightAction: true,
    nightOrder: 80,
  },
  pacifista: {
    id: 'pacifista',
    name: 'Pacifista',
    team: 'village',
    description:
      '1 vez por jogo, durante o dia: revela a função de 1 jogador e cancela a votação. O Pacifista não é identificado.',
    hasNightAction: false,
    hasDayAction: true,
  },
  padre: {
    id: 'padre',
    name: 'Padre',
    team: 'village',
    description:
      '1 vez no jogo, à noite: usa água benta em 1 alvo. Se for lobo, o alvo morre; se não for, o Padre morre.',
    hasNightAction: true,
    nightOrder: 200,
  },
  prefeito: {
    id: 'prefeito',
    name: 'Prefeito',
    team: 'village',
    description:
      'Durante o dia, pode revelar publicamente sua função. A partir daí, seu voto vale 2.',
    hasNightAction: false,
    hasDayAction: true,
  },
  guarda_costas: {
    id: 'guarda_costas',
    name: 'Guarda-costas',
    team: 'village',
    description:
      'À noite, escolhe 1 alvo para proteger. Se os lobos atacarem o alvo, o Guarda-costas morre no lugar.',
    hasNightAction: true,
    nightOrder: 70,
  },
  detetive: {
    id: 'detetive',
    name: 'Detetive',
    team: 'village',
    description:
      'À noite, escolhe 2 jogadores e descobre se ambos pertencem ao mesmo time.',
    hasNightAction: true,
    nightOrder: 150,
  },
  homem_sabio: {
    id: 'homem_sabio',
    name: 'Homem Sábio',
    team: 'village',
    description:
      'Passivo: nunca pode ser morto pelos lobos. Vulnerável a Bruxa, Assassino, Incendiário, Padre, Vigilante etc.',
    hasNightAction: false,
  },
  principe_bonitao: {
    id: 'principe_bonitao',
    name: 'Príncipe Bonitão',
    team: 'village',
    description:
      'Passivo: na primeira vez que for linchado, sobrevive e revela a função.',
    hasNightAction: false,
  },
  irmao: {
    id: 'irmao',
    name: 'Irmão',
    team: 'village',
    description:
      'Você vê os outros Irmãos no início do jogo. Sem ação noturna especial.',
    hasNightAction: false,
  },
  cientista_maluco: {
    id: 'cientista_maluco',
    name: 'Cientista Maluco',
    team: 'village',
    description:
      'Sem ação noturna. Ao morrer, os 2 jogadores adjacentes na ordem de assentos morrem automaticamente.',
    hasNightAction: false,
  },
  cacador_de_cabecas: {
    id: 'cacador_de_cabecas',
    name: 'Caçador de Cabeças',
    team: 'neutral',
    description:
      'Recebe um alvo no início do jogo. Vence se conseguir fazer o alvo ser linchado. Se o alvo morre de outra forma, vira Aldeão.',
    hasNightAction: false,
  },
  valentao: {
    id: 'valentao',
    name: 'Valentão',
    team: 'village',
    description:
      'Passivo: se atacado pelos lobos, sobrevive a noite e morre ao amanhecer do dia seguinte ao ataque.',
    hasNightAction: false,
  },
  menino_travesso: {
    id: 'menino_travesso',
    name: 'Menino Travesso',
    team: 'village',
    description:
      '1 vez no jogo, à noite, escolhe 2 jogadores e troca as funções deles.',
    hasNightAction: true,
    nightOrder: 5,
  },
  dama_de_vermelho: {
    id: 'dama_de_vermelho',
    name: 'Dama de Vermelho',
    team: 'village',
    description:
      'À noite, visita 1 jogador. Se for lobo ou for atacado pelos lobos, morre junto. Se for o alvo dos lobos mas estiver visitando, sobrevive.',
    hasNightAction: true,
    nightOrder: 90,
  },
  vovo_rabugenta: {
    id: 'vovo_rabugenta',
    name: 'Vovó Rabugenta',
    team: 'village',
    description:
      'À noite, escolhe 1 jogador que não poderá votar no próximo dia.',
    hasNightAction: true,
    nightOrder: 100,
  },
  bebado: {
    id: 'bebado',
    name: 'Bêbado',
    team: 'village',
    description:
      'Você não pode falar no chat. Sem ação noturna. Pode votar normalmente.',
    hasNightAction: false,
  },
  idiota: {
    id: 'idiota',
    name: 'Idiota',
    team: 'village',
    description:
      'Passivo: se for linchado, não morre — revela a função e perde o voto permanentemente.',
    hasNightAction: false,
  },
  pistoleiro: {
    id: 'pistoleiro',
    name: 'Pistoleiro',
    team: 'village',
    description:
      'Tem 2 balas. Pode atirar 1 por dia. Após o primeiro tiro, revela a função.',
    hasNightAction: false,
    hasDayAction: true,
  },
  vigilante: {
    id: 'vigilante',
    name: 'Vigilante',
    team: 'village',
    description:
      'À noite, escolhe investigar (descobre função exata) OU atirar (mata alvo silenciosamente).',
    hasNightAction: true,
    nightOrder: 160,
  },
  franco_atirador: {
    id: 'franco_atirador',
    name: 'Franco-atirador',
    team: 'village',
    description:
      'Marca um alvo em uma noite e na próxima confirma o tiro. Tem 2 flechas. Atirar em um aldeão volta a flecha contra ele.',
    hasNightAction: true,
    nightOrder: 170,
  },
  cacador_de_feras: {
    id: 'cacador_de_feras',
    name: 'Caçador de Feras',
    team: 'village',
    description:
      'À noite, coloca armadilha em 1 jogador. Ativa-se na próxima noite. Se os lobos atacarem o armadilhado, o lobo mais fraco morre.',
    hasNightAction: true,
    nightOrder: 50,
  },
  medium: {
    id: 'medium',
    name: 'Médium',
    team: 'village',
    description:
      '1 vez no jogo, revive 1 jogador morto. A função é revelada publicamente.',
    hasNightAction: true,
    nightOrder: 220,
  },
  cupido: {
    id: 'cupido',
    name: 'Cupido',
    team: 'village',
    description:
      'Apenas na noite 1: escolhe 2 jogadores para formar um casal. Se um morre, o outro morre. O casal vence se forem os 2 últimos vivos.',
    hasNightAction: true,
    nightOrder: 1,
    firstNightOnly: true,
  },
  bobo: {
    id: 'bobo',
    name: 'Bobo',
    team: 'neutral',
    description: 'Vence solo se for linchado pela aldeia durante o dia.',
    hasNightAction: false,
  },
  ladrao_de_tumulos: {
    id: 'ladrao_de_tumulos',
    name: 'Ladrão de Túmulos',
    team: 'village',
    description:
      'Noite 1: escolhe 1 alvo. Se esse alvo morrer, o Ladrão assume a função dele.',
    hasNightAction: true,
    nightOrder: 195,
    firstNightOnly: true,
  },
  presidente: {
    id: 'presidente',
    name: 'Presidente',
    team: 'village',
    description:
      'Função revelada desde o início. Se morrer, a aldeia perde imediatamente.',
    hasNightAction: false,
  },

  // --- WOLVES ---
  lobisomem: {
    id: 'lobisomem',
    name: 'Lobisomem',
    team: 'wolves',
    description:
      'À noite, junto com os outros lobos, escolhem 1 vítima. Possui chat exclusivo da matilha.',
    hasNightAction: true,
    nightOrder: 30,
  },
  lobo_solitario: {
    id: 'lobo_solitario',
    name: 'Lobo Solitário',
    team: 'wolves',
    description:
      'Como Lobisomem, mas só vence se for o único lobo vivo no momento da vitória.',
    hasNightAction: true,
    nightOrder: 30,
  },
  lobisomem_filhote: {
    id: 'lobisomem_filhote',
    name: 'Lobisomem Filhote',
    team: 'wolves',
    description: 'Lobisomem comum. Ao morrer, escolhe 1 jogador para morrer junto.',
    hasNightAction: true,
    nightOrder: 30,
  },
  amaldicoado: {
    id: 'amaldicoado',
    name: 'Amaldiçoado',
    team: 'village',
    description:
      'Começa como aldeão. Se atacado pelos lobos sem proteção, transforma-se silenciosamente em Lobisomem.',
    hasNightAction: false,
  },
  feiticeira: {
    id: 'feiticeira',
    name: 'Feiticeira',
    team: 'wolves',
    description:
      'Pertence aos lobos mas não conhece a matilha. À noite, investiga se um alvo é Vidente ou Lobisomem.',
    hasNightAction: true,
    nightOrder: 130,
  },
  lobo_gatinho: {
    id: 'lobo_gatinho',
    name: 'Lobo Gatinho',
    team: 'wolves',
    description:
      '1 vez no jogo: ao invés de matar a vítima da noite, converte-a em Lobisomem.',
    hasNightAction: true,
    nightOrder: 20,
  },
  lobo_vidente: {
    id: 'lobo_vidente',
    name: 'Lobo Vidente',
    team: 'wolves',
    description:
      'Lobisomem. À noite, descobre a função exata de 1 alvo. Se ficar sozinho, vira Lobisomem comum.',
    hasNightAction: true,
    nightOrder: 140,
  },
  lobisomem_alfa: {
    id: 'lobisomem_alfa',
    name: 'Lobisomem Alfa',
    team: 'wolves',
    description: 'Lobisomem. Seu voto na escolha da vítima vale 2.',
    hasNightAction: true,
    nightOrder: 30,
  },
  lobo_sombrio: {
    id: 'lobo_sombrio',
    name: 'Lobo Sombrio',
    team: 'wolves',
    description:
      '1 vez no jogo, durante o dia: dobra os votos dos lobos e oculta todos os votos.',
    hasNightAction: true,
    nightOrder: 30,
    hasDayAction: true,
  },
  nightmare_werewolf: {
    id: 'nightmare_werewolf',
    name: 'Nightmare Werewolf',
    team: 'wolves',
    description:
      'Lobisomem. 2 vezes no jogo, escolhe 1 jogador que não poderá agir naquela noite.',
    hasNightAction: true,
    nightOrder: 40,
  },

  // --- NEUTRALS ---
  assassino: {
    id: 'assassino',
    name: 'Assassino',
    team: 'neutral',
    description: 'À noite, mata 1 jogador. Vence se for o último vivo.',
    hasNightAction: true,
    nightOrder: 110,
  },
  incendiario: {
    id: 'incendiario',
    name: 'Incendiário',
    team: 'neutral',
    description:
      'À noite, encharca 1-2 jogadores OU queima todos os encharcados de uma vez. Imune a ataques dos lobos. Vence se for o último vivo.',
    hasNightAction: true,
    nightOrder: 120,
  },
};

export const ROLE_IDS = Object.keys(ROLES);

export function getRole(id: string): RoleDef | undefined {
  return ROLES[id];
}

export function isWolf(roleId: string | null | undefined): boolean {
  if (!roleId) return false;
  const r = ROLES[roleId];
  return r ? r.team === 'wolves' : false;
}

export function teamOf(roleId: string | null | undefined): Team | null {
  if (!roleId) return null;
  return ROLES[roleId]?.team ?? null;
}

/** Hierarchy used when Caçador de Feras kills the "weakest" wolf. */
export const WOLF_WEAKNESS_ORDER: string[] = [
  'lobisomem',
  'lobo_solitario',
  'amaldicoado',
  'lobisomem_filhote',
  'feiticeira',
  'lobo_gatinho',
  'lobo_vidente',
  'nightmare_werewolf',
  'lobo_sombrio',
  'lobisomem_alfa',
];
