// ignore_for_file: prefer_const_constructors, avoid_print


import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

Dado combustivel = Dado(
  maxY: 100,
  minY: 0,
  title: "combustivel (%)"
);
Dado velocidade = Dado(
  maxY: 50,
  minY: 0,
  title: "Velocidade (km/h)"
);

// Como o TPMS não está funcionando como deverial atualmente, esse gráfico é apenas ilustrativo pra
// mostrar pros juízes que o TPMS não está funcionando. O gráfico verdadeiro do tpms deverá conter
// quatro linhas, uma pra cada pneu e adicionar uma legenda em baixo 
Dado tpms = Dado(
  title: "Pressão dos Pneus (psi)",
  minY: 0,
  maxY: 30
);

class Telemetria extends StatefulWidget {
  const Telemetria({super.key});
  
  @override
  State<Telemetria> createState() => _TelemetriaState();
}

class _TelemetriaState extends State<Telemetria> {
  List<FlSpot> spots = combustivel.spots;

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
            child: velocidade.grafico
          ),
          SizedBox(
            height: 500,
            child: tpms.grafico
          ),
        ],
      )
    );
  }
}

// Esta classe serve para disponibilizar os dados para público
class Dado with ChangeNotifier{

  late ListenableBuilder grafico;

  final String title;
  final double minY;
  final double maxY;
  
  List<FlSpot> spots = [
  ];

  Dado({
    required this.title,
    required this.minY,
    required this.maxY,
  }){
    grafico = criarGrafico(title, minY, maxY, spots);
  }
  
  ListenableBuilder criarGrafico(String title, double minY, double maxY, List<FlSpot> spots) =>
   ListenableBuilder(
    listenable: this, 
    builder: (context, child) =>
   LineChart(
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
      )
   );

  void inserirDado(double y) {
    int dataLength = spots.length;
    int maxX = 20;
    // Enquanto o gráfico não tiver sido preenchido até a borda direita,
    // Apenas adicionar dados sem mover o gráfico
    if( dataLength < maxX){
      spots.add(
        FlSpot(dataLength.toDouble(), y)
      );
    }
    // Se a quantidade de dados fizer com que seja necessário o scroll
    else{
      print("Iniciando scroll");
      // Primeiramente diminuímos em 1 o x dos spots seguintes
      for(int i = 1; i<dataLength; i++){
        double currentY = spots[i].y;
        print("[$i, $currentY] -> [${i-1}, $currentY]");
        spots[i-1] = FlSpot(i-1, currentY);
      }
      
      // Em seguida, adicionamos o novo spot na última posição
      spots[dataLength-1] = FlSpot(dataLength-1, y);
      print("[20, ${spots[dataLength-1].y}]");
    }
    notifyListeners();
  }
}