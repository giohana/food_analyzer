import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraComponent extends StatefulWidget {
  const CameraComponent({
    required this.cameraController,
    required this.onTakePhoto,
    super.key,
  });

  final CameraController cameraController;
  final void Function() onTakePhoto;

  @override
  State<CameraComponent> createState() => _CameraComponentState();
}

class _CameraComponentState extends State<CameraComponent> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          _buildCameraArea(),
          _buildTakeButton(),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildCameraArea() {
    final scale = 1 / (widget.cameraController.value.aspectRatio * MediaQuery.of(context).size.aspectRatio);
    return Center(
      child: Transform.scale(
        scale: scale,
        child: CameraPreview(widget.cameraController),
      ),
    );
  }


  Widget _buildTakeButton() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 38,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: IconButton.filled(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
          ),
          iconSize: 48,
          padding: EdgeInsets.all(16),
          icon: Icon(Icons.camera),
          color: Colors.green,
          onPressed: widget.onTakePhoto,
        ),
      ),
    );
  }



  Widget _buildBackButton() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 36,
        horizontal: 16,
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: IconButton(
          key: Key('Voltar da camera'),
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: Colors.white,
        ),
      ),
    );
  }
}