import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:mime/mime.dart';

Future<String> uploadImageToCloudinary(
    File imageFile, String cloudName, String uploadPreset) async {
  final url =
  Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

  final mimeType = lookupMimeType(imageFile.path) ?? "image/jpeg";

  final request = http.MultipartRequest("POST", url)
    ..fields['upload_preset'] = uploadPreset
    ..files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: MediaType.parse(mimeType),
    ));

  final response = await request.send();

  if (response.statusCode == 200) {
    final resStr = await response.stream.bytesToString();
    final data = jsonDecode(resStr);
    return data["secure_url"]; // URL pública da imagem
  } else {
    throw Exception("Erro ao enviar: ${response.statusCode}");
  }


}

Future<String> saveImage(String? filePath) async {
  File file = File(filePath!);

  String imageUrl = await uploadImageToCloudinary(
    file,
    "dzmyf4s0r",       // vem do dashboard
    "unsigned_preset",      // criado no painel
  );

  return imageUrl;
}
