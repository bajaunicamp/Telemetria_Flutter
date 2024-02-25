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
  double seconds = 0;
  
  // Sou incapaz de atualizar esse widget assim que o dados chegam
  // Já gastei 2h30 tentando fazer isso e não consegui, portanto
  // vou criar um timer pra atualizar a cada 1 segundo
  @override
  void initState(){
    super.initState();

  }
  
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
          SizedBox(
            height: 500,
            child: Dados.velocidade
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
      FlSpot(0, 100),
      FlSpot(1, 98),
      FlSpot(2, 95),
      FlSpot(3, 93),
      FlSpot(4, 92),
      FlSpot(5, 91),
      FlSpot(6, 80),
      FlSpot(7, 77),
      FlSpot(8, 74),
      FlSpot(9, 71),
      FlSpot(10,70),
      FlSpot(11, 64),
      FlSpot(12, 62),
      FlSpot(13, 60),
      FlSpot(14, 55),
      FlSpot(15, 54.5),
      FlSpot(16, 54),
      FlSpot(17, 40),
      FlSpot(18, 38),
      FlSpot(19, 30),
      FlSpot(20, 20),
    ]
  );
  
  static LineChart velocidade = criarGrafico("Velocidade (km/h)", 0, 50, 
  [
      FlSpot(0, 0),
      FlSpot(1, 10),
      FlSpot(2, 10.5),
      FlSpot(3, 11),
      FlSpot(4, 11.89),
      FlSpot(5, 12),
      FlSpot(6, 12),
      FlSpot(7, 12),
      FlSpot(8, 12.5),
      FlSpot(9, 12.9),
      FlSpot(10,13),
      FlSpot(11,14),
      FlSpot(12,15),
      FlSpot(13,18),
      FlSpot(14,20),
      FlSpot(15,24),
      FlSpot(16,28),
      FlSpot(17,29),
      FlSpot(18,30),
      FlSpot(19,30.1),
      FlSpot(20,30.5),
  ]);
}


