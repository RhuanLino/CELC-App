import 'package:flutter/material.dart';

class FrequenciaProgress extends StatelessWidget {
  final int percentage;
  final int percentageAbsent;
  final int presentDays;
  final int absentDays;
  final double? width;
  final Color? primaryColor;
  final Color? absentColor;

  const FrequenciaProgress({
    super.key,
    required this.percentage,
    required this.percentageAbsent,
    required this.presentDays,
    required this.absentDays,
    this.width,
    this.primaryColor,
    this.absentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultPrimaryColor = primaryColor ?? theme.primaryColor;
    final defaultAbsentColor = absentColor ?? Colors.red;

    return Container(
      width: width ?? 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                // Text presentes
              const Text(
                'Minha frequência',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child:
                  const Text(
                    'Detalhes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ), 
                )
            ],
          ),
          const SizedBox(height: 20),
          
          // Circular progress and linear progress side by side
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular progress indicator
              Column(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: percentage / 100,
                            strokeWidth: 10, // mais espesso para destacar
                            backgroundColor: theme.dividerColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getPercentageColor(percentage, defaultPrimaryColor),
                            ),
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4)
                ],
              ),
              const SizedBox(width: 20),
              
              // Linear progress bar with details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Days information
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Text presentes
                      const Text(
                        'Presentes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                        _buildDayInfo('Presente', presentDays, defaultPrimaryColor, theme),
                      ],
                    ),
                    
                    const SizedBox(height: 8),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: theme.dividerColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getPercentageColor(percentage, defaultPrimaryColor),
                        ),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Days information
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Faltas',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildDayInfo('Ausente', absentDays, defaultAbsentColor, theme),
                      ],
                    ),
                    const SizedBox(height: 8),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentageAbsent / 100,
                        backgroundColor: theme.dividerColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getPercentageColor(percentageAbsent, defaultAbsentColor),
                        ),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayInfo(String label, int days, Color color, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$days dias',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Color _getPercentageColor(int percentage, Color primaryColor) {
    if (percentage >= 80) return primaryColor;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}