import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';


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
      return const GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(-22.816837154373108, -47.069913411788164),
          zoom: 18,
        ),
        mapType: MapType.satellite,
        myLocationEnabled: true,
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
    body: body());
  }
}