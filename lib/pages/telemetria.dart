// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Função para criar diversos gráficos com o mesmo design
LineChart criarGrafico(String title, double minY, double maxY, List<FlSpot> spots) {
return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
        
          // Esconder os valores em baixo
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            )
          ),
          // Título do gráfico
          topTitles: AxisTitles(
            axisNameSize: 80,
            axisNameWidget: Text(
              title,
              style: TextStyle( 
                fontSize: 20
              ),
            )
          ),
        ),
        minX: 0, maxX: 20, minY: minY, maxY: maxY,
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) =>
          FlLine(
            color: Color.fromARGB(139, 255, 0, 0),
            strokeWidth: 2,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            strokeWidth: 0
          )
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: spots,
          )
        ]
      )
);
}

class Telemetria extends StatefulWidget {
  const Telemetria({super.key});

  @override
  State<Telemetria> createState() => _TelemetriaState();
}

class _TelemetriaState extends State<Telemetria> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Telemetria"),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 500,
            child: Dados.combustivel
          ),
        ],
      )
    );
  }
}

// Esta classe serve para disponibilizar os dados para público
class Dados{
  
  static void inserirDado(LineChart lineChart, y) {
    int dataLength = lineChart.data.lineBarsData[0].spots.length;
    // Enquanto o gráfico não tiver sido preenchido até a borda direita,
    // Apenas adicionar dados sem mover o gráfico
    if( dataLength < lineChart.data.maxX){
      lineChart.data.lineBarsData[0].spots.add(
        FlSpot(dataLength.toDouble(), y)
      );
    }
    // Se a quantidade de dados fizer com que seja necessário o scroll
    else{
      print("Iniciando scroll");
      // Primeiramente diminuímos em 1 o x dos spots seguintes
      for(int i = 1; i<dataLength; i++){
        double currentY = lineChart.data.lineBarsData[0].spots[i].y;
        print("[$i, $currentY] -> [${i-1}, $currentY]");
        lineChart.data.lineBarsData[0].spots[i-1] = FlSpot(i-1, currentY);
      }
      
      // Em seguida, adicionamos o novo spot na última posição
      lineChart.data.lineBarsData[0].spots[dataLength-1] = FlSpot(dataLength-1, y);
      print("[20, ${lineChart.data.lineBarsData[0].spots[dataLength-1].y}]");
    }
  }

  static LineChart combustivel = criarGrafico(
    "combustivel (%)",
    0, 100,
    [
      FlSpot(0, 0),
      FlSpot(1, 10),
      FlSpot(2, 15),
      FlSpot(3, 15.6),
      FlSpot(4, 20),
      FlSpot(5, 21),
      FlSpot(6, 25),
      FlSpot(7, 25.6),
      FlSpot(8, 24),
      FlSpot(9, 20),
      FlSpot(10, 20.1),
      FlSpot(11, 50.2),
      FlSpot(12, 55),
      FlSpot(13, 14.2),
      FlSpot(14, 51),
      FlSpot(15, 51),
      FlSpot(16, 12),
      FlSpot(17, 92),
      FlSpot(18, 32),
      FlSpot(19, 64),
      FlSpot(20, 14),
    ]
  );
}


