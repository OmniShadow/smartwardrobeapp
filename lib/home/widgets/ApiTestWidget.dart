import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wardrobe/common/utils/apiUtils.dart';
import 'package:wardrobe/common/utils/imageUtils.dart';

class GenerateImage extends StatefulWidget {
  String prompt;
  GenerateImage({super.key, required this.prompt});

  @override
  State<GenerateImage> createState() => _GenerateImageState(prompt: prompt);
}

class _GenerateImageState extends State<GenerateImage> {
  String prompt;
  late Future<String> response = ApiService.makeRequest(
            "POST",
            'http://87.17.151.186:8080/smartwardrobeapi/api/imagegen/generate',
            {
              "prompt": prompt,
            });

  _GenerateImageState({required this.prompt});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: response,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            String json = snapshot.data!;
            Map<String, dynamic> jsonMap = jsonDecode(json);
            return Image.memory(
              Uint8List.fromList(base64Decode(jsonMap['data'] as String)),
              width: 150,
              height: 150,
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}

class ApiTestWidget extends StatefulWidget {
  const ApiTestWidget({super.key});

  @override
  State<ApiTestWidget> createState() => _ApiTestWidgetState();
}

class _ApiTestWidgetState extends State<ApiTestWidget> {
  String base64String = '';
  String responsePrompt = '';

  Future<void> _pickImage() async {
    XFile? imgFile = await ImageUtils.captureImage(ImageSource.camera);
    if (imgFile != null) {
      base64String = await ImageUtils.imageToBase64(imgFile);
    }
    final clothingJsonString =
        await _sendDescToApi(await _sendImageToApi(base64String));
    setState(() {
      responsePrompt = clothingJsonString;
    });
  }

  Future<String> _sendImageToApi(String base64Image) async {
    const apiUrl = 'http://87.11.187.78:8081/interrogator/prompt';
    final requestBody = {
      "image": base64Image,
      "clip_model_name": "ViT-L-14/openai",
      "mode": "fast",
    };
    return await ApiService.makeRequest('POST', apiUrl, requestBody);
  }

  Future<String> _sendDescToApi(String imgDesc) async {
    const url = 'http://87.11.187.78:5000/v1/chat/completions';

    // Your payload data
    final payload = {
      "messages": [
        {"role": "user", "content": imgDesc}
      ],
      "mode": "instruct",
      "instruction_template": "0ClothingItemJson",
      "temperature": 1.31,
      "top_p": 0.14,
      "repetition_penalty": 1.17,
      "top_k": 49
    };

    final responseBody = await ApiService.makeRequest("POST", url, payload);
    final responseBodyJson = jsonDecode(responseBody);

    return responseBodyJson['choices'][0]["message"]["content"].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image to Base64 Converter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (base64String.isNotEmpty)
              Image.memory(
                Uint8List.fromList(base64Decode(base64String)),
                width: 150,
                height: 150,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image (Camera)'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Base64 String:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'API Response Prompt:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              responsePrompt,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
