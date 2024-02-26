import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> pedirAcessoALocalizacao() async {
  var status = await Permission.locationWhenInUse.request();

  if (status == PermissionStatus.granted) {
    return;
  } else if(status == PermissionStatus.denied){
    status = await Permission.locationWhenInUse.request();   
    return Future.error("Você precisa permitir o acesso à localização");
  } else if(status == PermissionStatus.permanentlyDenied){
    return Future.error("""Você negou permanentemente o acesso à localização,
    para utilizar esta função, permita o acesso à localização nas configurações do dispositivo""");
  }
}

class Mapa extends StatefulWidget {
  const Mapa({super.key});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: const Text("Mapa Baja"),
    ),
    body: const GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(-22.816837154373108, -47.069913411788164),
        zoom: 18,
        ),
      mapType: MapType.satellite,
      myLocationEnabled: true,
      ),
    );
  }
}