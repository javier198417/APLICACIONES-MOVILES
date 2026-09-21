import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CamaraPage extends StatefulWidget {
  const CamaraPage({super.key});

  @override
  State<CamaraPage> createState() => _CamaraPageState();
}

class _CamaraPageState extends State<CamaraPage> {
  File? imagen;

  final FlutterSecureStorage storage =
      const FlutterSecureStorage();

  Future<void> tomarFoto() async {
    final permiso = await Permission.camera.request();

    if (!mounted) return;

    if (permiso.isGranted) {
      final picker = ImagePicker();

      final foto = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (!mounted) return;

      if (foto != null) {
        await storage.write(
          key: 'foto_perfil',
          value: foto.path,
        );

        debugPrint(
          '================================',
        );
        debugPrint('FOTO GUARDADA');
        debugPrint(foto.path);
        debugPrint(
          '================================',
        );

        setState(() {
          imagen = File(foto.path);
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Foto de perfil guardada correctamente',
            ),
          ),
        );

        await Future.delayed(
          const Duration(seconds: 1),
        );

        if (!mounted) return;

        Navigator.pop(context);
      }
    } else if (permiso.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '❌ Debe conceder permiso para usar la cámara',
          ),
        ),
      );
    } else if (permiso.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder: (dialogContext) =>
            AlertDialog(
          title: const Text(
            'Permiso requerido',
          ),
          content: const Text(
            'La cámara fue denegada permanentemente. Debe habilitarla desde la configuración del dispositivo.',
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
                await openAppSettings();
              },
              child: const Text(
                'Abrir ajustes',
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> cargarFotoGuardada() async {
    final ruta = await storage.read(
      key: 'foto_perfil',
    );

    debugPrint(
      '================================',
    );
    debugPrint(
      'LEYENDO FOTO PERFIL',
    );
    debugPrint('$ruta');
    debugPrint(
      '================================',
    );

    if (ruta != null) {
      final archivo = File(ruta);

      if (await archivo.exists()) {
        if (!mounted) return;

        setState(() {
          imagen = archivo;
        });
      } else {
        debugPrint(
          '⚠️ La ruta existe pero el archivo no se encontró',
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    cargarFotoGuardada();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Foto de Perfil',
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 70,
              backgroundColor:
                  Colors.teal.shade100,
              backgroundImage:
                  imagen != null
                      ? FileImage(imagen!)
                      : null,
              child: imagen == null
                  ? const Icon(
                      Icons.person,
                      size: 70,
                      color: Colors.teal,
                    )
                  : null,
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: tomarFoto,
              icon: const Icon(
                Icons.camera_alt,
              ),
              label: const Text(
                'Tomar Foto',
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'La fotografía se guardará como imagen de perfil del cliente.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}