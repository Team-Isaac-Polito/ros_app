import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isaac_app/features/sensors_page/components/latency_chart/data/ros_bandwidth_stream_provider/ros_bandwith_stream_provider.dart';
import 'package:isaac_app/features/sensors_page/components/latency_chart/data/ros_traffic_provider/ros_traffic_provider.dart';
import 'package:isaac_app/features/sensors_page/components/latency_chart/models/bandwidth_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LatencyChartWidget extends ConsumerWidget {
  const LatencyChartWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(rosTrafficProvider);
    final bandwidthAsync = ref.watch(bandwidthProvider);

    return bandwidthAsync.when(
      data: (history) {
        final chartData = history.asMap().entries.map((e) {
          return BandwidthData(e.key, e.value);
        }).toList();

        return Padding(
          padding: const EdgeInsets.only(top: 16, right: 16, bottom: 8),
          child: SfCartesianChart(
            title: ChartTitle(text: 'Network Bandwidth (KB/s)'),
            primaryXAxis: const NumericAxis(isVisible: false), 
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: 'KB/s'),
            ),
            series: <CartesianSeries<BandwidthData, int>>[
              SplineAreaSeries<BandwidthData, int>(
                dataSource: chartData,
                xValueMapper: (BandwidthData d, _) => d.second,
                yValueMapper: (BandwidthData d, _) => d.kbps,
                name: 'Bandwidth',
                color: Colors.green.withValues(alpha: 0.3),
                borderColor: Colors.green,
                borderWidth: 2,
                animationDuration: 500,
              )
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text("Errore: $err")),
    );
  }
}