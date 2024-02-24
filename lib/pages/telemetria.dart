// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

class Telemetria extends StatelessWidget {
  const Telemetria({super.key});
  
  // Função para criar diversos gráficos com o mesmo design
  LineChart grafico(double minX, double maxX, double minY, double maxY, List<FlSpot> spots) {
    return LineChart(
          LineChartData(
            minX: minX, maxX: maxX, minY: minY, maxY: maxY,
            gridData: FlGridData(
              show: true,
              getDrawingHorizontalLine: (value) =>
              FlLine(
                color: Color.fromARGB(139, 255, 0, 0),
                strokeWidth: 2,
              )
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
              )
            ]
          )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Telemetria"),
      ),
      body: ListView(
        children: [
          Container(
            height: 500,
              child: grafico(
                0, 10, 0, 10,
                [
                  FlSpot(0, 0),
                  FlSpot(1, 1),
                  FlSpot(2, 3),
                  FlSpot(4, 5),
                  FlSpot(5, 8),
                ]
              )
            ),
          Container(
            height: 500,
              child: grafico(
                0, 10, 0, 10,
                [
                  FlSpot(0, 0),
                  FlSpot(1, 8),
                  FlSpot(2, 9),
                  FlSpot(4, 4),
                  FlSpot(5, 3),
                ]
              )
            ),
          Container(
            height: 500,
              child: grafico(
                0, 10, 0, 10,
                [
                  FlSpot(0, 0),
                  FlSpot(3, 5),
                  FlSpot(8, 3),
                  FlSpot(9, 2),
                  FlSpot(10, 2),
                ]
              )
            ),
        ],
      )
    );
  }
}