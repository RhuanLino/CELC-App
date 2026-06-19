import 'package:celc_app/data/models/mensalidades_model.dart';
import 'package:celc_app/data/services/mensalidades_service.dart';
import 'package:flutter/material.dart';

class MensalidadeTab extends StatefulWidget {
  const MensalidadeTab({super.key});

  @override
  State<MensalidadeTab> createState() => _MensalidadeTabState();
}

class _MensalidadeTabState extends State<MensalidadeTab> {
  int _selectedFilter = 0;
  final filters = ['Todas', 'Atrasadas', 'Em Aberto', 'Pagas'];

  List<MensalidadeModel> mensalidades = [];
  bool loading = true;

  List<MensalidadeModel> get filtered {
    if (_selectedFilter == 0) {
      return mensalidades;
    }

    const map = {1: 'atrasada', 2: 'aberto', 3: 'paga'};

    return mensalidades.where((m) => m.status == map[_selectedFilter]).toList();
  }

  @override
  void initState() {
    super.initState();
    carregarMensalidades();
  }

  Future<void> carregarMensalidades() async {
    final data = await MensalidadesService().getMensalidades();

    if (!mounted) return;

    setState(() {
      mensalidades = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryGrid(cs),
          const SizedBox(height: 16),
          _buildFilterChips(cs),
          const SizedBox(height: 16),
          _buildList(cs),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─── Summary Grid ─────────────────────────────────────────────────────────

  Widget _buildSummaryGrid(ColorScheme cs) {
    final atrasadas = mensalidades.where((m) => m.status == 'atrasado').length;
    final abertas = mensalidades.where((m) => m.status == 'aberto').length;
    final pagas = mensalidades.where((m) => m.status == 'pago').length;

    return Row(
      children: [
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 160,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Próximo Vencimento',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Text(
                  '15 Out',
                  style: TextStyle(
                    color: cs.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: 0.75,
                    minHeight: 6,
                    backgroundColor: cs.outlineVariant,
                    valueColor: AlwaysStoppedAnimation(cs.secondary),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '75% das parcelas pagas',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Filter Chips ─────────────────────────────────────────────────────────

  Widget _buildFilterChips(ColorScheme cs) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (i) {
          final selected = _selectedFilter == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filters[i]),
              selected: selected,
              onSelected: (_) => setState(() => _selectedFilter = i),
              selectedColor: cs.primary,
              labelStyle: TextStyle(
                color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: cs.surfaceContainerLow,
              shape: const StadiumBorder(),
              showCheckmark: false,
            ),
          );
        }),
      ),
    );
  }

  // ─── List ─────────────────────────────────────────────────────────────────

  Widget _buildList(ColorScheme cs) {
    final atrasadas = filtered.where((m) => m.status == 'atrasado').toList();

    final abertas = filtered.where((m) => m.status == 'aberto').toList();

    final pagas = filtered.where((m) => m.status == 'pago').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (atrasadas.isNotEmpty) ...[
          _sectionHeader('Atrasadas', Icons.error, cs.error),
          const SizedBox(height: 12),
          ...atrasadas.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOverdueCard(cs, m.nome, m.vencimento!),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (abertas.isNotEmpty) ...[
          _sectionHeader('Em Aberto', Icons.schedule, cs.primary),
          const SizedBox(height: 12),
          ...abertas.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOpenCard(cs, m.nome, m.vencimento!),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (pagas.isNotEmpty) ...[
          _sectionHeader('Pagas', Icons.check_circle, cs.secondary),
          const SizedBox(height: 12),
          _buildPaidGrid(cs, pagas),
        ],
      ],
    );
  }

  Widget _sectionHeader(String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // ─── Cards ────────────────────────────────────────────────────────────────

  Widget _buildOverdueCard(ColorScheme cs, String month, String dueDate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.errorContainer, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.history, color: cs.error),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Vencimento: $dueDate',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showPixSnackbar(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text('Pagar', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenCard(ColorScheme cs, String month, String dueDate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.event_outlined, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Vencimento: $dueDate',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _showPixSnackbar(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.primary,
              side: BorderSide(color: cs.primary, width: 2),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: const Text('Antecipar', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaidGrid(ColorScheme cs, List<MensalidadeModel> pagas) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.4,
      ),
      itemCount: pagas.length,
      itemBuilder: (_, i) {
        final m = pagas[i];
        return Opacity(
          opacity: 0.8,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: cs.secondaryContainer,
                  child: Icon(
                    Icons.done,
                    color: cs.onSecondaryContainer,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        m.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Pago em ${m.pagoEm}',
                        style: TextStyle(fontSize: 11, color: cs.secondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPixSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pagamento via PIX ainda não disponível.')),
    );
  }
}
