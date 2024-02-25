import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
      title: const Text("Mapa"),
    ),
    body: GoogleMap(initialCameraPosition: CameraPosition(
      target: LatLng(-22.816837154373108, -47.069913411788164),
      zoom: 18)
      )
    );
  }
}