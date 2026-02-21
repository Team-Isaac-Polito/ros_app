import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/sensors_page/components/latency_chart/models/latency_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LatencyChartWidget extends ConsumerWidget {
  const LatencyChartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final data = ref.watch(latencyChartProvider);

    return SfCartesianChart(
      title: ChartTitle(text: 'Latenza Connessione (ms)'),
      primaryXAxis: DateTimeAxis(
        isVisible: false, // Nascondiamo le date per pulizia
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 500, // Oltre 500ms la connessione è critica
        plotBands: <PlotBand>[
          // Fascia Gialla (Attenzione)
          PlotBand(
            start: 150, end: 300, color: Colors.orange.withOpacity(0.1),
          ),
          // Fascia Rossa (Critica)
          PlotBand(
            start: 300, end: 500, color: Colors.red.withOpacity(0.1),
          ),
        ],
      ),
      series: <CartesianSeries<LatencyData, DateTime>>[
        SplineAreaSeries<LatencyData, DateTime>(
          dataSource: [LatencyData(DateTime(2026), 20), LatencyData(DateTime(2025), 20)],
          xValueMapper: (LatencyData d, _) => d.time,
          yValueMapper: (LatencyData d, _) => d.latency,
          name: 'Ping',
          color: Colors.blue.withOpacity(0.3),
          borderColor: Colors.blue,
          borderWidth: 2,
          animationDuration: 500, // Rende il movimento fluido
        )
      ],
    );
  }
}