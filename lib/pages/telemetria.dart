// ignore_for_file: prefer_const_constructors, avoid_print


import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

Dado combustivel = Dado(
  maxY: 100,
  minY: 0,
  title: "combustivel (%)"
);

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
            child: ListenableBuilder(
              listenable: combustivel,
              builder: (context, child) {
                return combustivel.grafico;
              },
            )
            //combustivel.grafico
          ),
          ElevatedButton(
           onPressed: (){
            combustivel.inserirDado(10);
           },
           child: Text("Inserir dado"),
         )
        ],
      )
    );
  }
}

// Esta classe serve para disponibilizar os dados para público
class Dado with ChangeNotifier{

  late LineChart grafico;

  final String title;
  final double minY;
  final double maxY;

  List<FlSpot> spots = [
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
  ];

  Dado({
    required this.title,
    required this.minY,
    required this.maxY,
  }){
    grafico = criarGrafico(title, minY, maxY, spots);
  }
  
  LineChart criarGrafico(String title, double minY, double maxY, List<FlSpot> spots) =>
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
  );

  void inserirDado(double y) {
    int dataLength = grafico.data.lineBarsData[0].spots.length;
    // Enquanto o gráfico não tiver sido preenchido até a borda direita,
    // Apenas adicionar dados sem mover o gráfico
    if( dataLength < grafico.data.maxX){
      grafico.data.lineBarsData[0].spots.add(
        FlSpot(dataLength.toDouble(), y)
      );
    }
    // Se a quantidade de dados fizer com que seja necessário o scroll
    else{
      print("Iniciando scroll");
      // Primeiramente diminuímos em 1 o x dos spots seguintes
      for(int i = 1; i<dataLength; i++){
        double currentY = grafico.data.lineBarsData[0].spots[i].y;
        print("[$i, $currentY] -> [${i-1}, $currentY]");
        grafico.data.lineBarsData[0].spots[i-1] = FlSpot(i-1, currentY);
      }
      
      // Em seguida, adicionamos o novo spot na última posição
      grafico.data.lineBarsData[0].spots[dataLength-1] = FlSpot(dataLength-1, y);
      print("[20, ${grafico.data.lineBarsData[0].spots[dataLength-1].y}]");
    }
    notifyListeners();
  }

}


