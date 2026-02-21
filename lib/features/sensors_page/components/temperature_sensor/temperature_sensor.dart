import 'package:flutter/material.dart';
import 'package:isaac_app/features/sensors_page/components/temperature_sensor/models/temperature_datetime.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TemperatureSensor extends StatelessWidget {
  const TemperatureSensor({super.key});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: 'Temperature (°C)'),
      primaryXAxis: DateTimeAxis(
        isVisible: false, // Nascondiamo le date per pulizia
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 500, // Oltre 500ms la connessione è critica
        plotBands: <PlotBand>[
          // Fascia Gialla (Attenzione)
          PlotBand(
            start: 150, end: 300, color: Colors.orange.withValues(alpha: 0.1),
          ),
          // Fascia Rossa (Critica)
          PlotBand(
            start: 300, end: 500, color: Colors.red.withValues(alpha: 0.1),
          ),
        ],
      ),
      series: <CartesianSeries<TemperatureDatetime, DateTime>>[
        SplineAreaSeries<TemperatureDatetime, DateTime>(
          dataSource: [TemperatureDatetime(datetime: DateTime(2026), temperature:  20), TemperatureDatetime(datetime: DateTime(2026), temperature:  20)],
          xValueMapper: (TemperatureDatetime d, _) => d.datetime,
          yValueMapper: (TemperatureDatetime d, _) => d.temperature,
          name: 'Ping',
          color: Colors.blue.withValues(alpha: 0.3),
          borderColor: Colors.blue,
          borderWidth: 2,
          animationDuration: 500, // Rende il movimento fluido
        )
      ],
    );
  }
}
