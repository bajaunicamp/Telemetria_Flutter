import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telemetria_baja/main.dart';

PosicaoBaja posicaoBaja = PosicaoBaja();

class Mapa extends StatefulWidget {
  const Mapa({super.key});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  bool permissaoGarantida = false;

  Future<void> pedirAcessoALocalizacao() async{
    late PermissionStatus locationPermission;
    try{
      locationPermission = await Permission.locationWhenInUse.request();
    } catch(e){
      return Future.error(e);
    }
    if(locationPermission == PermissionStatus.granted){
      permissaoGarantida = true;
    }
    else{
      false;
    }
  }

  Widget body() {
    pedirAcessoALocalizacao();
    if(permissaoGarantida){
      return ListenableBuilder(
        listenable: posicaoBaja, 
        builder: (context, child) =>
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(-22.816837154373108, -47.069913411788164),
              zoom: 18,
            ),
            mapType: MapType.satellite,
            myLocationEnabled: true,
            markers: posicaoBaja.markers,
        )
      );
    }
    else{
      return Column(
        children: [
          const Text("Você não permitiu o acesso à localização"),
          ElevatedButton(
            onPressed: () {
              setState(() {
                pedirAcessoALocalizacao();
              });
            },
            child: const Text("Pedir acesso à localização")
          )
        ]
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: const Text("Mapa Baja"),
    ),
    // O body é uma função pois ele vai depender do estado da permissão
    // de localização
    body: body(),
    );
  }
}

class PosicaoBaja with ChangeNotifier{
  double _latitude = -22.823140730111103;
  double _longitude = -47.064638387666776;
  Set<Marker> markers = { };
  
  void atualizarPosicao(double latitude, double longitude){
    _latitude = latitude;
    _longitude = longitude;
    markers.clear();
    markers.add(
      Marker(
        markerId: MarkerId("Tamayado"),
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(
          title: "Tamayado\nPosição $latitude | $longitude"
        ),
      )
    );
    notifyListeners();
  }
}
