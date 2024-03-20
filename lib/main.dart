// ignore_for_file: prefer_const_constructors, avoid_print, non_constant_identifier_names

// Me desculpem pelo main gigante, mas to sem tempo de dividir essee código com arquivos menores
// Provavelmente criar uma classe pra lidar com o servidor seria muito mais inteligente, mas
// fazer o que

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:telemetria_baja/pages/mapa.dart';
import 'package:telemetria_baja/pages/telemetria.dart';
//import 'package:flutter/widgets.dart';

void main() async {
  // Mapa
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
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
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Builder(
                      builder: (context) => ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/mapa');
                          },
                          child: Text("Mapa"))),
                  Builder(
                      builder: (context) => ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/telemetria');
                          },
                          child: Text("Telemetria")))
                ],
              )),
              widgetServidor()
            ],
          ),
        ));
  }

  String serverIP = "0.0.0.0";
  TextEditingController serverIP_controller = TextEditingController();
  int port = 0;
  TextEditingController port_controller = TextEditingController();
  bool conectado = false;
  late Socket socket;

  Widget widgetServidor() {
    // ignore: sized_box_for_whitespace
    Widget conectar = Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 150,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Server IP",
                      ),
                      controller: serverIP_controller,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Porta",
                      ),
                      controller: port_controller,
                    ),
                  ])),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (serverIP_controller.text != "") {
                          serverIP = serverIP_controller.text;
                        }
                        if (port_controller.text != "") {
                          port = int.parse(port_controller.text);
                        }
                      });
                      // Tentei implementar uns try-catch, mas to sem tempo. Então
                      // pra conectar no servidor tem que fazer tudo certinho
                      try {
                        conectarAoServidor();
                        setState(() {
                          conectado = true;
                        });
                      } catch (e) {
                        print(e);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 11, 230, 40),
                        elevation: 20),
                    child: Text("Conectar"),
                  ))
            ]));

    Widget desconectar = Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 150,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Text("Server IP: $serverIP"),
                    Text("Porta: $port")
                  ])),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        conectado = false;
                        print(
                            "[END] Desconectado do Servidor ${socket.remoteAddress.address}:${socket.remotePort}");
                        enviarMensagemAoServidor("!DISCONNECT");
                        socket.destroy();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 230, 11, 11),
                        elevation: 20),
                    child: Text("Desonectar"),
                  ))
            ]));

    if (!conectado) {
      return conectar;
    } else {
      return desconectar;
    }
  }

  // Eu sei que essa função provavelmente não deveria estar aqui, mas ela está
  Future<void> conectarAoServidor() async {
    try {
      socket = await Socket.connect(serverIP, port);
    } catch (e) {
      print("[SERVIDOR] Não foi possível conectar: $e");
      return Future.error(e);
    }
    print(
        "[CONECTADO] Cliente conectado ao servidor ${socket.remoteAddress.address}:${socket.remotePort}");
    enviarMensagemAoServidor("[CONNECTION] App");

    socket.listen((Uint8List data) {
      final serverResponse = String.fromCharCodes(data);

      List<String> splitResponse = serverResponse.split(" ");
      String tipo = splitResponse[0];
      // Se for uma resposta de GPS
      if (tipo.compareTo("[VE]") == 0) {
        print("Dados de velocidade recebidos");
        velocidade.inserirDado(double.parse(splitResponse[1]));
      } else if (tipo.compareTo("[TPMS]") == 0) {
        print("Dados do TPMS recebidos");
        tpms.inserirDado(double.parse(splitResponse[1]));
      }
      // Se for uma resposta do Combustível
      else if (tipo.compareTo("[COMBUSTIVEL]") == 0) {
        print("Dados do combustível recebidos");
        combustivel.inserirDado(double.parse(splitResponse[1]));
      } else if (tipo.compareTo("[LA]") == 0 && DateTime.now().isAfter(posicaoBaja.latitude_last_update.add(const Duration(milliseconds: 500)))) {
        print("Latitude recebida");
        String latitude_raw = splitResponse[1];
        int a = int.parse(latitude_raw[0]);
        int b = int.parse(latitude_raw[1]);
        // não tem c na latitude
        int d = int.parse(latitude_raw[2]);
        int e = int.parse(latitude_raw[3]);
        int f = int.parse(latitude_raw[5]); //pulando o ponto
        int g = int.parse(latitude_raw[6]);
        int h = int.parse(latitude_raw[7]);
        int i = int.parse(latitude_raw[8]);
        int j = int.parse(latitude_raw[9]);

        double latitude = -((a * 10 + b) +
            ((d * 10 + e) / 60) +
            ((f * 10000 + g * 1000 + h * 100 + i * 10 + j) / 6000000));
        posicaoBaja.atualizarPosicao(latitude, 0);
      } else if (tipo.compareTo("[LO]") == 0 && DateTime.now().isAfter(posicaoBaja.longitude_last_update.add(Duration(milliseconds: 500)))) {
        String longitude_raw = splitResponse[1];
        int a = int.parse(longitude_raw[0]);
        int b = int.parse(longitude_raw[1]);
        int c = int.parse(longitude_raw[2]);
        int d = int.parse(longitude_raw[3]);
        int e = int.parse(longitude_raw[4]);
        int f = int.parse(longitude_raw[6]); //pulando o ponto
        int g = int.parse(longitude_raw[7]);
        int h = int.parse(longitude_raw[8]);
        int i = int.parse(longitude_raw[9]);

        double longitude = -((a * 100 + b * 10 + c) +
            ((d * 10 + e) / 60) +
            ((f * 1000 + g * 100 + h * 10 + i) / 600000));

        posicaoBaja.atualizarPosicao(0, longitude);
      }
      // Se não for nenhuma das respostas esperadas, apenas imprimí-la
      else {
        print("[SERVER] $serverResponse");
      }
    }, onError: (error) {
      print("[ERROR] $error");
      setState(() {
        conectado = false;
      });
      socket.destroy();
    }, onDone: () {
      print("[END] A conexão com o servidor terminou");
      setState(() {
        conectado = false;
      });
      socket.destroy();
    });
  }

  void enviarMensagemAoServidor(String mensagem) {
    socket.write(mensagem);
  }
}
