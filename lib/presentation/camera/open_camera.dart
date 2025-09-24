import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:food_analyzer/presentation/camera/camera_component.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/button_full_widget.dart';

class OpenCamera extends StatefulWidget {
  const OpenCamera({super.key});

  @override
  State<OpenCamera> createState() => _OpenCameraState();
}

class _OpenCameraState extends State<OpenCamera> with WidgetsBindingObserver {
  CameraController? controller;
  bool _loading = true;

  bool _cameraPermissionIsGranted = false;
  late CameraDescription _currentCamera;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _handleCameraPermission();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && !_cameraPermissionIsGranted) {
      final permissionStatus = await Permission.camera.status;
      if (permissionStatus.isGranted) {
        await _handleCameraPermission();
      }
      _setLoadingComponent(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildComponent()),
    );
  }

  Widget _buildComponent() {
    if (!_loading) {
      if (controller != null && controller!.value.isInitialized && _cameraPermissionIsGranted) {
        return CameraComponent(
          cameraController: controller!,
          onTakePhoto: _takePicture,
        );
      }
      if (!_cameraPermissionIsGranted) {
        return _cameraNotGrantedComponent();
      }
    }
    return Center(child: CircularProgressIndicator());
  }

  Future<void> _handleCameraPermission() async {
    final permissionStatus = await Permission.camera.request();
    if (permissionStatus.isGranted) {
      _cameraPermissionIsGranted = true;
      await _configureCameras();
    } else {
      _cameraPermissionIsGranted = false;
    }
    _setLoadingComponent(false);
  }

  Future<void> _configureCameras() async {
    try {
      final cameras = await availableCameras();
      _currentCamera = cameras.first;
      await _handleCamera();
    } on Exception catch (_) {}
  }

  Future<void> _handleCamera() async {
    try {
      controller = CameraController(
        _currentCamera,
        ResolutionPreset.max,
        enableAudio: false,
      );
      if (controller == null) return;
      await controller!.initialize();
      if (!mounted) {
        return;
      }
      controller!.setFlashMode(FlashMode.off);
      await controller!.lockCaptureOrientation(
        DeviceOrientation.portraitUp,
      );
      setState(() {});
    } catch (_) {}
  }

  void _setLoadingComponent(bool status) {
    setState(() {
      _loading = status;
    });
  }

  Widget _cameraNotGrantedComponent() {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          width: size.width,
          child: ElevatedButton(
              onPressed: () {
                _setLoadingComponent(true);
                openAppSettings();
              },
              child: Text('Abrir Permissões'))),
    );
  }

  Future<void> _takePicture() async {
    try {
      _showAlertDialogLoading();
      var imageFile = await controller!.takePicture();
      var imageFileCompressed = await compressImage(
        imageFile.path,
      );
      if (imageFileCompressed == null) {
        Navigator.of(context).pop();
        throw Exception('Erro ao comprimir a imagem.');
      }
      var imageBase64 = toBase64(imageFileCompressed.path);
      Navigator.pop(context);
      _setEdition(
        await imageFileCompressed.readAsBytes(),
        imageFileCompressed.path,
      );
      unawaited(Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => ConfirmImagePage(
            appImageResult: AppImageResult(
              imageBase64: imageBase64,
              imageFile: imageFile.path,
            ),
            preConfirmImageFunction: () {},
          ),
        ),
      ));
    } on Exception catch (_) {
      throw Exception('Erro ao tirar foto.');
    }
  }

  Future<File> _createFileFromBytes(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final imagePath = '${tempDir.path}/image.jpg';
    final file = await File(imagePath).writeAsBytes(bytes);
    return file;
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
    } catch (e) {
      _dialogError(context);
    }
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

  static Future<File?> compressImage(String path) async {
    var result = await FlutterImageCompress.compressWithFile(
      path,
      minWidth: 720,
      minHeight: 1280,
      quality: 95,
      keepExif: true,
      autoCorrectionAngle: true,
    );
    final file = File(path);
    if (result != null) {
      return file.writeAsBytes(
        result,
        flush: true,
        mode: FileMode.write,
      );
    }
    return null;
  }

  static String toBase64(String filePath) {
    var bytes = File(filePath).readAsBytesSync();
    var data = base64.encode(bytes);
    return 'data:image/jpeg;base64,$data';
  }

  void _showAlertDialogLoading() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: 100,
            child: Column(
              children: const [
                SizedBox(height: 20),
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                  'Carregando...',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ConfirmImagePage extends StatefulWidget {
  const ConfirmImagePage({
    required this.appImageResult,
    this.preConfirmImageFunction,
    super.key,
  });

  final AppImageResult appImageResult;
  final Function()? preConfirmImageFunction;

  @override
  _ConfirmImagePageState createState() => _ConfirmImagePageState();
}

class _ConfirmImagePageState extends State<ConfirmImagePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
        constraints: BoxConstraints.expand(),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40,
                ),
                SizedBox(height: 32),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        4,
                      ),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(
                          File(widget.appImageResult.imageFile!),
                        ),
                      ),
                    ),
                    width: size.width * 0.6,
                    height: size.height / 2,
                  ),
                ),
                SizedBox(
                  height: 32,
                ),
                Divider(
                  height: 0,
                  color: Colors.grey,
                ),
                SizedBox(
                  height: 24,
                ),
                ButtonFull(
                    label: 'Confirmar Foto',
                    onPressed: () async {
                      if (widget.preConfirmImageFunction != null) {
                        await widget.preConfirmImageFunction!();
                      }
                      Navigator.pop(context);
                      Navigator.pop(context, widget.appImageResult);
                    }),
                // AncarxLargeButton.primary(
                //   key: Key('Enviar foto'),
                //   label: confirmImagePageModel.firstButton,
                //   onPressed: () async {
                //     if (widget.preConfirmImageFunction != null) {
                //       await widget.preConfirmImageFunction!();
                //     }
                //     Navigator.pop(context);
                //     Navigator.pop(context, widget.appImageResult);
                //   },
                // ),
                // AncarxLargeButton.primaryOutline(
                //   key: Key('Tentar novamente'),
                //   label: confirmImagePageModel.secondButton,
                //   borderColor: colorScheme.brand.primary.color,
                //   onPressed: () => Navigator.pop(context),
                //   border: true,
                // ),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppImageResult {
  final String? imageBase64;
  final String? imageFile;

  AppImageResult({this.imageBase64, this.imageFile});
}
