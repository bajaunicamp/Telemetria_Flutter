// ignore_for_file: prefer_const_constructors, avoid_print

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

void main() async{
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
                  Builder(builder: (context) => ElevatedButton(
                    onPressed: (){
                      Navigator.pushNamed(context, '/mapa');
                    },
                    child: Text("Mapa")
                    )
                  ),
                  Builder(builder: (context) => ElevatedButton(
                    onPressed: (){
                      Navigator.pushNamed(context, '/telemetria');
                    },
                    child: Text("Telemetria") 
                    )
                  )
                ],
              ) 
            ),
            widgetServidor()
          ],
        ),
      )
    );
  }

  String serverIP = "0.0.0.0";
  TextEditingController serverIP_controller = TextEditingController();
  int port = 0;
  TextEditingController port_controller = TextEditingController();
  bool conectado = false;
  late Socket socket;

  // ignore: non_constant_identifier_names
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
              ]
            )
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: (){
                setState(() {
                    if (serverIP_controller.text != ""){
                      serverIP = serverIP_controller.text;
                    }
                    if (port_controller.text != "") {
                      port = int.parse(port_controller.text);
                    }
                });
                // Tentei implementar uns try-catch, mas to sem tempo. Então
                // pra conectar no servidor tem que fazer tudo certinho
                try{
                  conectarAoServidor();
                  setState(() {
                    conectado = true;
                  });
                } catch(e){
                  print(e);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 11, 230, 40),
                elevation: 20
              ),
              child: Text("Conectar"),
            )
          )
        ]
      )
    );
    
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
            ]
          )
        ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: (){
                setState(() {
                    conectado = false;
                    print("[END] Desconectado do Servidor ${socket.remoteAddress.address}:${socket.remotePort}");
                    enviarMensagemAoServidor("!DISCONNECT");
                    socket.destroy();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 230, 11, 11),
                elevation: 20
              ),
              child: Text("Desonectar"),
            )
          )
        ]
      )
    );
    
    if (!conectado){
      return conectar;
    }
    else{
      return desconectar;
    }
  }
  
  // Eu sei que essa função provavelmente não deveria estar aqui, mas ela está
  Future<void> conectarAoServidor() async{
    try{
      socket = await Socket.connect(serverIP, port);
    } catch(e){
      print("[SERVIDOR] Não foi possível conectar: $e");
      return Future.error(e);
    }
    print("[CONECTADO] Cliente conectado ao servidor ${socket.remoteAddress.address}:${socket.remotePort}");
    
    socket.listen(
      (Uint8List data) {
        final serverResponse = String.fromCharCodes(data);
        
        List<String> splitResponse = serverResponse.split(" ");
        // Se for uma resposta de GPS
        if (splitResponse[0].compareTo("[VELOCIDADE]") == 0){
          print("Dados de velocidade recebidos");
          //Dados.inserirDado(Dados.velocidade, double.parse(splitResponse[1]));
        }
        // Se for uma resposta do Combustível
        else if (splitResponse[0].compareTo("[COMBUSTIVEL]") == 0){
          print("Dados do combustível recebidos");
          combustivel.inserirDado(double.parse(splitResponse[1]));
        } 
        // Se não for nenhuma das respostas esperadas, apenas imprimí-la
        else {
          print("[SERVER] $serverResponse");
        }
      },
      onError: (error){
        print("[ERROR] $error");
        socket.destroy();
      },
      onDone: (){
        print("[END] A conexão com o servidor terminou");
        socket.destroy();
      }

      );
  } 
  
  void enviarMensagemAoServidor(String mensagem) {
    int messageLength = mensagem.length;
    socket.write(messageLength.toString());
    socket.write(mensagem);
  }
}