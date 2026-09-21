import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class UbicacionPage extends StatefulWidget {
  const UbicacionPage({super.key});

  @override
  State<UbicacionPage> createState() =>
      _UbicacionPageState();
}

class _UbicacionPageState
    extends State<UbicacionPage> {
  String ubicacion =
      'Pulse el botón para obtener la ubicación';

  Future<void> obtenerUbicacion() async {
    try {
      bool gpsActivo =
          await Geolocator.isLocationServiceEnabled();

      if (!gpsActivo) {
        setState(() {
          ubicacion =
              '❌ El GPS del dispositivo está desactivado';
        });
        return;
      }

      LocationPermission permiso =
          await Geolocator.checkPermission();

      if (permiso ==
          LocationPermission.denied) {
        permiso =
            await Geolocator.requestPermission();
      }

      if (permiso ==
          LocationPermission.denied) {
        setState(() {
          ubicacion =
              '❌ Permiso de ubicación denegado';
        });
        return;
      }

      if (permiso ==
          LocationPermission.deniedForever) {
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (dialogContext) =>
              AlertDialog(
            title: const Text(
              'Permiso requerido',
            ),
            content: const Text(
              'La ubicación fue denegada permanentemente. Debe habilitarla desde la configuración del dispositivo.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text(
                  'Cancelar',
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await Geolocator
                      .openAppSettings();
                },
                child: const Text(
                  'Abrir ajustes',
                ),
              ),
            ],
          ),
        );

        return;
      }

      final posicion =
          await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(
          accuracy:
              LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        ubicacion =
            '✅ Ubicación obtenida\n\n'
            '📍 Latitud: ${posicion.latitude}\n'
            '📍 Longitud: ${posicion.longitude}\n\n'
            '🌎 Google Maps:\n'
            'https://maps.google.com/?q=${posicion.latitude},${posicion.longitude}';
      });
    } catch (e) {
      setState(() {
        ubicacion = '❌ Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ubicación GPS',
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed:
                  obtenerUbicacion,
              icon: const Icon(
                Icons.location_on,
              ),
              label: const Text(
                'Obtener ubicación',
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  ubicacion,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}