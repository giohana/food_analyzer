import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../camera/open_camera.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Uint8List? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Home',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: _cardAnalyze(Icons.camera_alt, 'Tirar foto', () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const OpenCamera(),
                      ),
                    );
                  })),
                  Expanded(child: _cardAnalyze(Icons.add_photo_alternate, 'Escolher da galeria', () => callGallery())),
                ],
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ultimas Analises',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text('Voce ainda não realizou nenhuma análise.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardAnalyze(IconData icon, String label, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.green[700]),
            const SizedBox(height: 16.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UPLOAD IMAGE AND EDIT
  Future<void> callGallery() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (picked == null) {
        return;
      }
      _image = await picked.readAsBytes();
      _setEdition(_image, picked.path);
    } catch (e) {
      Navigator.of(context).pop(e);
    }
  }

  Future<void> _setEdition(Uint8List? bytes, String? filePath) async {
    try {
      late File file;
      file = await _createFileFromBytes(bytes!);

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Editar imagem',
            toolbarColor: Colors.green,
            toolbarWidgetColor: Colors.white,
            showCropGrid: true,
            lockAspectRatio: false,
            initAspectRatio: CropAspectRatioPreset.square,
            activeControlsWidgetColor: Colors.green,
          ),
          IOSUiSettings(
            title: 'Editar imagem',
            doneButtonTitle: 'Concluir',
            cancelButtonTitle: 'Cancelar',
            rotateClockwiseButtonHidden: true,
            showCancelConfirmationDialog: true,
            showActivitySheetOnDone: false,
            hidesNavigationBar: true,
          ),
        ],
      );
      final croppedBytes = await croppedFile?.readAsBytes();
      if (croppedBytes == null) {
        _dialogError(context);
        return;
      }
      final result = await compressImage(croppedBytes);
      if (result == null) {
        _dialogError(context);
        return;
      }
    } catch (e) {
      _dialogError(context);
    }
  }

  static const _maxLength = 2000000;

  Future<Uint8List?> compressImage(Uint8List imageBytes) async {
    var encoded = imageBytes;
    var length = encoded.lengthInBytes;
    var factor = _maxLength / length;
    var image = await compute(_decodeImage, encoded);
    if (image == null) {
      return null;
    }
    while (length > _maxLength) {
      final newWidth = (image!.width * factor).toInt();
      image = img.copyResize(
        image,
        width: newWidth,
      );
      encoded = _encodeImage(image);
      length = encoded.lengthInBytes;
      factor = _maxLength / length;
    }
    final encodedImage = _encodeImage(image!);
    return encodedImage;
  }

  static img.Image? _decodeImage(Uint8List original) {
    return img.decodeImage(original);
  }

  Uint8List _encodeImage(img.Image original) {
    final croppedList = img.encodeJpg(original, quality: 75);
    final croppedBytes = Uint8List.fromList(croppedList);
    return croppedBytes;
  }

  Future<File> _createFileFromBytes(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final imagePath = '${tempDir.path}/image.jpg';
    final file = await File(imagePath).writeAsBytes(bytes);
    return file;
  }

  Future<void> _dialogError(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro inesperado'),
          content: const Text('Ocorreu um erro insperado, por favor tente novamente mais tarde',
              style: TextStyle(fontWeight: FontWeight.bold)),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
