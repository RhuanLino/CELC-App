import 'dart:math' as math;
import 'package:celc_app/data/models/calendar_model.dart';
import 'package:celc_app/data/services/calendar_service.dart';
import 'package:flutter/material.dart';

// ─── Main Screen ─────────────────────────────────────────────────────────────
class FrequencePage extends StatefulWidget {
  const FrequencePage({super.key});

  @override
  State<FrequencePage> createState() => _FrequencePageState();
}

class _FrequencePageState extends State<FrequencePage> {
  final _service = CalendarService();

  FrequenciaResumoModel? _resumo;
  List<CalendarioItemModel> _atividades = [];
  bool _loading = true;

  // Seletor: por padrão mês anterior ao atual
  late int _mesSelecionado;
  late int _anoSelecionado;

  static const _meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Mês anterior (se janeiro, vai para dezembro do ano anterior)
    if (now.month == 1) {
      _mesSelecionado = 12;
      _anoSelecionado = now.year - 1;
    } else {
      _mesSelecionado = now.month - 1;
      _anoSelecionado = now.year;
    }
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final results = await Future.wait([
      _service.getFrequenciaResumo(mes: _mesSelecionado, ano: _anoSelecionado),
      _service.getCalendario(),
    ]);

    setState(() {
      _resumo = results[0] as FrequenciaResumoModel?;
      _atividades = results[1] as List<CalendarioItemModel>;
      _loading = false;
    });
  }

  // Gera lista de meses disponíveis: do mais antigo até o mês anterior ao atual
  List<({int mes, int ano})> _mesesDisponiveis() {
    final now = DateTime.now();
    // Limita a 24 meses para trás
    final options = <({int mes, int ano})>[];
    for (int i = 1; i <= 24; i++) {
      final dt = DateTime(now.year, now.month - i);
      options.add((mes: dt.month, ano: dt.year));
    }
    return options.reversed.toList();
  }

  void _abrirSeletor() async {
    final opcoes = _mesesDisponiveis();
    final selecionado = await showModalBottomSheet<({int mes, int ano})>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => _MesSelectorSheet(
            opcoes: opcoes,
            mesSelecionado: _mesSelecionado,
            anoSelecionado: _anoSelecionado,
            meses: _meses,
          ),
    );

    if (selecionado != null) {
      setState(() {
        _mesSelecionado = selecionado.mes;
        _anoSelecionado = selecionado.ano;
      });
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Seletor de mês/ano ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: InkWell(
                onTap: _abrirSeletor,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Frequência de',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_meses[_mesSelecionado - 1]} $_anoSelecionado',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: cs.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ── Conteúdo ────────────────────────────────────────────────────
            Expanded(
              child:
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DashboardSection(resumo: _resumo),
                            const SizedBox(height: 16),
                            const _MonthlyHistorySection(),
                            const SizedBox(height: 16),
                            _NextClassesSection(atividades: _atividades),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Sheet Seletor ─────────────────────────────────────────────────────
class _MesSelectorSheet extends StatelessWidget {
  final List<({int mes, int ano})> opcoes;
  final int mesSelecionado;
  final int anoSelecionado;
  final List<String> meses;

  const _MesSelectorSheet({
    required this.opcoes,
    required this.mesSelecionado,
    required this.anoSelecionado,
    required this.meses,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.35,
      maxChildSize: 0.75,
      expand: false,
      builder: (ctx, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Selecionar período',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: opcoes.length,
                itemBuilder: (ctx, i) {
                  final op = opcoes[i];
                  final isSelected =
                      op.mes == mesSelecionado && op.ano == anoSelecionado;
                  return ListTile(
                    onTap: () => Navigator.pop(context, op),
                    selected: isSelected,
                    selectedTileColor: cs.primaryContainer.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 2,
                    ),
                    title: Text(
                      '${meses[op.mes - 1]} ${op.ano}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isSelected ? cs.primary : cs.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    trailing:
                        isSelected
                            ? Icon(Icons.check_circle, color: cs.primary)
                            : null,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Dashboard Section ────────────────────────────────────────────────────────
class _DashboardSection extends StatelessWidget {
  final FrequenciaResumoModel? resumo;
  const _DashboardSection({required this.resumo});

  String _presencaLabel(double p) {
    if (p <= 0.50) return 'Sentimos sua falta';
    if (p >= 0.70) return 'Você está fazendo a diferença';
    return 'Juntos somos mais fortes';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final percentual = resumo?.percentualPresenca ?? 0.0;
    final totalAtividades = resumo?.totalAtividades ?? 0;
    final totalPresencas = resumo?.totalPresencas ?? 0;
    final totalFaltas = resumo?.totalFaltas ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _GlassCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: _AttendanceCircle(percentage: percentual),
                ),
                const SizedBox(height: 12),
                Text(
                  _presencaLabel(percentual),
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Total de Atividades',
                      value: '$totalAtividades',
                      valueColor: cs.primary,
                      borderColor: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      label: 'Presenças',
                      value: '$totalPresencas',
                      valueColor: cs.secondary,
                      borderColor: cs.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Faltas',
                      value: '$totalFaltas',
                      valueColor: cs.error,
                      borderColor: cs.error,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      label: 'Sequência',
                      value: '8 dias',
                      valueColor: cs.tertiary,
                      borderColor: cs.tertiary,
                      labelSuffix: Icon(
                        Icons.local_fire_department,
                        size: 14,
                        color: cs.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Attendance Circle ────────────────────────────────────────────────────────
class _AttendanceCircle extends StatefulWidget {
  final double percentage;
  const _AttendanceCircle({required this.percentage});

  @override
  State<_AttendanceCircle> createState() => _AttendanceCircleState();
}

class _AttendanceCircleState extends State<_AttendanceCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.percentage,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(_AttendanceCircle old) {
    super.didUpdateWidget(old);
    if (old.percentage != widget.percentage) {
      _controller.reset();
      _animation = Tween<double>(
        begin: 0,
        end: widget.percentage,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return CustomPaint(
          painter: _CirclePainter(
            progress: _animation.value,
            trackColor: cs.surfaceContainerHighest,
            progressColor: cs.secondary,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(_animation.value * 100).round()}%',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'PRESENÇA',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  const _CirclePainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;
    const strokeWidth = 10.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CirclePainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor;
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Color borderColor;
  final Widget? labelSuffix;

  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.borderColor,
    this.labelSuffix,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      padding: const EdgeInsets.all(12),
      leftBorderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (labelSuffix != null) ...[
                const SizedBox(width: 2),
                labelSuffix!,
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Monthly History ──────────────────────────────────────────────────────────
class _MonthlyHistorySection extends StatelessWidget {
  const _MonthlyHistorySection();

  static const _presentDays = {
    2,
    3,
    4,
    7,
    8,
    9,
    10,
    11,
    14,
    15,
    16,
    17,
    18,
    21,
    22,
    23,
    24,
    25,
    28,
    29,
  };
  static const _absentDays = {5, 12, 19, 26};
  static const _dayNames = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Histórico Mensal',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('Ver Detalhes')),
          ],
        ),
        const SizedBox(height: 8),
        _GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(31, (i) {
                    final day = i + 1;
                    final isPresent = _presentDays.contains(day);
                    final isAbsent = _absentDays.contains(day);
                    final isToday = day == 30;
                    final dayName = _dayNames[day % 7];

                    final Color bgColor;
                    final Color textColor;
                    if (isPresent) {
                      bgColor = cs.secondaryContainer;
                      textColor = cs.onSecondaryContainer;
                    } else if (isAbsent) {
                      bgColor = cs.errorContainer;
                      textColor = cs.onErrorContainer;
                    } else {
                      bgColor = cs.surfaceContainerHighest;
                      textColor = cs.outline;
                    }

                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      decoration:
                          isToday
                              ? BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: cs.primary, width: 2),
                                color: cs.primary.withOpacity(0.05),
                              )
                              : null,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dayName,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: bgColor,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$day',
                              style: Theme.of(
                                context,
                              ).textTheme.labelLarge?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isPresent)
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: cs.secondary,
                            )
                          else if (isAbsent)
                            Icon(Icons.cancel, size: 14, color: cs.error)
                          else
                            const SizedBox(height: 14),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              Divider(color: cs.outlineVariant, height: 24),
              Row(
                children: [
                  _LegendDot(color: cs.secondaryContainer, label: 'Presença'),
                  const SizedBox(width: 16),
                  _LegendDot(color: cs.errorContainer, label: 'Falta'),
                  const SizedBox(width: 16),
                  _LegendDot(
                    color: cs.surfaceContainerHighest,
                    label: 'S/ Aula',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─── Next Classes ─────────────────────────────────────────────────────────────
class _NextClassesSection extends StatelessWidget {
  final List<CalendarioItemModel> atividades;
  const _NextClassesSection({required this.atividades});

  static const _diasSemana = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

  String _dayLabel(String dataStr) {
    final date = DateTime.tryParse(dataStr);
    if (date == null) return '';
    final hoje = DateTime.now();
    final amanha = hoje.add(const Duration(days: 1));
    if (date.year == hoje.year &&
        date.month == hoje.month &&
        date.day == hoje.day) {
      return 'Hoje';
    }
    if (date.year == amanha.year &&
        date.month == amanha.month &&
        date.day == amanha.day) {
      return 'Amanhã';
    }
    return _diasSemana[date.weekday % 7];
  }

  String _dayNumber(String dataStr) {
    final date = DateTime.tryParse(dataStr);
    return date != null ? '${date.day}' : '';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (atividades.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Próximas Atividades',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhuma atividade programada.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Próximas Atividades',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...atividades.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final highlighted = index == 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ClassCard(
              dayLabel: _dayLabel(item.data),
              dayNumber: _dayNumber(item.data),
              title: item.descricao,
              time: '15:00 - 18:00',
              highlighted: highlighted,
              action:
                  highlighted
                      ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Próxima',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: cs.secondary),
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          );
        }),
      ],
    );
  }
}

class _ClassCard extends StatelessWidget {
  final String dayLabel;
  final String dayNumber;
  final String title;
  final String time;
  final bool highlighted;
  final Widget action;

  const _ClassCard({
    required this.dayLabel,
    required this.dayNumber,
    required this.title,
    required this.time,
    required this.highlighted,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color:
                  highlighted
                      ? cs.primaryContainer
                      : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayLabel.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color:
                        highlighted
                            ? cs.onPrimaryContainer
                            : cs.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  dayNumber,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: highlighted ? cs.onPrimaryContainer : cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: cs.onSurface),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 16,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          action,
        ],
      ),
    );
  }
}

// ─── Glass Card ───────────────────────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? leftBorderColor;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.leftBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (leftBorderColor != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(0.7),
            border: Border.all(color: cs.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: leftBorderColor),
                Expanded(child: Padding(padding: padding, child: child)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: child,
    );
  }
}
