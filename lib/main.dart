import 'package:flutter/material.dart';
import 'package:telemetria_baja/pages/mapa.dart';
import 'package:telemetria_baja/pages/telemetria.dart';
//import 'package:flutter/widgets.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/telemetria': (context) => Telemetria(),
        '/mapa': (context) => Mapa(),
      },
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Telemetria Baja"),
          backgroundColor: const Color.fromARGB(255, 48, 158, 53),
        ),
        body: Center(
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Builder(
              builder: (context) => TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 35, 187, 22),
                  textStyle: const TextStyle(fontSize: 80)
                ),
                onPressed: (){},
                child: const Text("Mapa")
              )
            ),
            Builder(
              builder: (context) => TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 35, 187, 22),
                  textStyle: const TextStyle(fontSize: 80)
                ),
                onPressed: (){
                  Navigator.pushNamed(context, '/telemetria');
                },
                child: const Text("Telemetria")
              )
            ),
          ],
          )
        ),
      ),
    );
  }
}
