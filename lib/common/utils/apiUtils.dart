import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wardrobe/common/utils/utils.dart';
import 'package:wardrobe/home/models/clothing_data.dart';
import 'package:color_parser/color_parser.dart';

class ApiService {
  static String serverIp = "http://79.30.219.117:8080";
  static int controllerId = -1;
  static String espLocalIp = "192.168.1.83";
  static bool espWifiConnected = false;
  static bool espApiConnected = false;
  static Future<String> makeRequest({
    required String method,
    required String url,
    Object? payload,
    Map<String, String>? headers,
  }) async {
    var uri = Uri.parse(url);
    var headers = {'Content-Type': 'application/json'};

    try {
      http.Response response;

      if (method == 'GET') {
        response = await http.get(uri);
      } else if (method == 'POST') {
        response =
            await http.post(uri, body: jsonEncode(payload), headers: headers);
      } else if (method == 'PUT') {
        response =
            await http.put(uri, headers: headers, body: jsonEncode(payload));
      } else if (method == 'DELETE') {
        response = await http.delete(uri, headers: headers);
      } else {
        throw Exception('Invalid HTTP method');
      }

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to make API request: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during API request: $e');
    }
  }

  static Future<Map<String, dynamic>> getWeatherData(
      double latitude, double longitude) async {
    String jsonString = await ApiService.makeRequest(
        method: 'GET',
        url:
            'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,rain,showers,snowfall&forecast_days=1');
    return json.decode(jsonString);
  }

  static Future<bool> fetchEspLocalIp() async {
    String jsonString = await ApiService.makeRequest(
      method: 'GET',
      url: '${ApiService.serverIp}/smartwardrobeapi/api/drawer/controller/list',
    );
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    List<dynamic> controllers = jsonMap['data'];
    for (var controller in controllers) {
      espLocalIp = controller['local_ip'];
      controllerId = controller['id'];
      bool status = (await checkEspStatus()).isNotEmpty;
      if (status) return true;
    }
    espLocalIp = "Not set";
    controllerId = -1;
    return false;
  }

  static Future<void> updateDrawerName(String name, String serialId) async {
    String jsonString = await ApiService.makeRequest(
      method: 'POST',
      url: '${ApiService.serverIp}/smartwardrobeapi/api/drawer/name',
      payload: {
        'name': name,
        'serial_id': serialId,
      },
    );
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  }

  static Future<List<Map<String, dynamic>>> fetchDrawers() async {
    String jsonString = await ApiService.makeRequest(
      method: 'GET',
      url: '${ApiService.serverIp}/smartwardrobeapi/api/drawer/list',
    );
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    List<dynamic> drawers = jsonMap['data'];
    return drawers
        .where((element) => element['status'] == 'Connected')
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  static Future<List<ClothingItem>> fetchClothingItems() async {
    String jsonString = await ApiService.makeRequest(
      method: "GET",
      url: '${ApiService.serverIp}/smartwardrobeapi/api/clothing/list',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    List<ClothingItem> clothingItems = [];
    for (var clothingMap in (jsonMap["data"] as List)) {
      clothingItems
          .add(ClothingItem.fromMap(clothingMap as Map<String, dynamic>));
    }

    return clothingItems;
  }

  static Future<Map<String, dynamic>> getOutfitSchema() async {
    String jsonString = await ApiService.makeRequest(
      method: "GET",
      url: '${ApiService.serverIp}/smartwardrobeapi/api/outfit/schema',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    return jsonMap['data'];
  }

  static Future<List<Map<String, dynamic>>> fetchOutfits() async {
    String jsonString = await ApiService.makeRequest(
      method: "GET",
      url: '${ApiService.serverIp}/smartwardrobeapi/api/outfit/list',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    List<dynamic> outfits = jsonMap['data'];

    return outfits.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<bool> insertOutfit(Map<String, dynamic> outfit) async {
    outfit["components"] =
        (outfit["components"] as List<ClothingItem>).map((e) => e.id).toList();
    String jsonString = await ApiService.makeRequest(
      method: 'POST',
      url: '${ApiService.serverIp}/smartwardrobeapi/api/outfit/add',
      payload: outfit,
    );
    var jsonMap = jsonDecode(jsonString);
    return jsonMap['data'];
  }

  static Future<bool> deleteOutfit(int id) async {
    String jsonString = await ApiService.makeRequest(
      method: 'POST',
      url: '${ApiService.serverIp}/smartwardrobeapi/api/outfit/delete',
      payload: {'id': id},
    );
    var jsonMap = jsonDecode(jsonString);
    return jsonMap['data'];
  }

  static Future<String> generateOutfitImage(Map<String, dynamic> outfit) async {
    Object payload = {};
    String sex = outfit['sex'] == 'M' ? 'man' : 'woman';
    List<ClothingItem> outfitComponents =
        outfit['components'] as List<ClothingItem>;
    String prompt =
        '<lora:PlasticPeople:2> full body of a $sex, bald, posing, wearing a ${outfitComponents.fold(
              '',
              (previousItem, currentItem) => previousItem +=
                  '${ColorParser.color(Color(int.parse(currentItem.color))).toName()},${currentItem.category}, ${currentItem.features.fold("", (previousValue, element) => previousValue += ',$element')}',
            ).toString()}';
    print(prompt);
    outfit['components'] =
        (outfit['components'] as List<ClothingItem>).map((e) => e.id).toList();
    String jsonString = await ApiService.makeRequest(
      method: 'POST',
      url: '${ApiService.serverIp}/smartwardrobeapi/api/imagegen/generate',
      payload: {
        'prompt': prompt,
      },
    );
    var jsonMap = jsonDecode(jsonString);
    return jsonMap['data'];
  }

  static Future<bool> insertClothingIntoDrawer(
      int item, String drawerId) async {
    try {
      String jsonString = await ApiService.makeRequest(
          method: "POST",
          url:
              '${ApiService.serverIp}/smartwardrobeapi/api/drawer/insertclothing',
          payload: {
            'clothing': item,
            'drawer': drawerId,
          });
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      return jsonMap['data'];
    } on Exception {
      return false;
    }
  }

  static Future<int> submitClothingItem(Map<String, dynamic> payload) async {
    String jsonString = await ApiService.makeRequest(
      method: 'POST',
      url: '${ApiService.serverIp}/smartwardrobeapi/api/clothing/add',
      payload: payload,
    );
    print(jsonString);
    var jsonMap = jsonDecode(jsonString);
    return jsonMap['data'];
  }

  static Future<bool> checkConnection() async {
    try {
      String body = await ApiService.makeRequest(
        method: 'GET',
        url: '${ApiService.serverIp}/smartwardrobeapi/hello',
      );
    } on Exception catch (e) {
      return false;
    }
    return true;
  }

  static Future<String> sendOperation(Object operationData) async {
    String body;
    try {
      body = await ApiService.makeRequest(
          method: 'POST',
          url: 'http://${ApiService.espLocalIp}/sendoperation',
          payload: operationData,
          headers: {
            'User-Agent': 'PostmanRuntime/7.33.0',
            'Accept': '*/*',
            'Accept-Encoding': 'gzip, deflate, br',
            'Content-Type': 'application/json',
          });
    } on Exception catch (e) {
      return e.toString();
    }
    return body;
  }

  static Future<void> openDrawer(
      int address, int speed, int numberOfRevolutions) async {
    Map<String, dynamic> requestBody = {
      "address": address,
      "operation": "SetSpeed",
      "parameters": {
        "speed": speed,
      }
    };
    await ApiService.sendOperation(requestBody);
    requestBody = {
      "address": address,
      "operation": "OpenDrawer",
      "parameters": {
        "numberOfRevolutions": numberOfRevolutions,
      }
    };
    await ApiService.sendOperation(requestBody);
  }

  static Future<void> closeDrawer(
      int address, int speed, int numberOfRevolutions) async {
    Map<String, dynamic> requestBody = {
      "address": address,
      "operation": "SetSpeed",
      "parameters": {
        "speed": speed,
      }
    };
    await ApiService.sendOperation(requestBody);
    requestBody = {
      "address": address,
      "operation": "CloseDrawer",
      "parameters": {
        "numberOfRevolutions": numberOfRevolutions,
      }
    };
    await ApiService.sendOperation(requestBody);
  }

  static Future<String> checkEspStatus() async {
    String body = "";
    try {
      body = await ApiService.makeRequest(
        method: 'GET',
        url: 'http://${ApiService.espLocalIp}/statusJson',
      );
      Map<String, dynamic> jsonMap = json.decode(body);
      espWifiConnected = jsonMap['wifi'];
      espApiConnected = jsonMap['api'];
    } on Exception catch (e) {
      print(e);
      return "";
    }
    return body;
  }

  static Future<bool> updateAssociatedDrawer(
      int clothingId, String drawerId) async {
    String jsonString = await ApiService.makeRequest(
        method: 'POST',
        url:
            '${ApiService.serverIp}/smartwardrobeapi/api/drawer/updateclothing',
        payload: {
          'clothing': clothingId,
          'drawer': drawerId,
        });
    var jsonMap = jsonDecode(jsonString);

    return jsonMap['data'];
  }

  static Future<Map<String, dynamic>> getAssociatedDrawer(
      int clothingId) async {
    String jsonString = await ApiService.makeRequest(
      method: 'GET',
      url:
          '${ApiService.serverIp}/smartwardrobeapi/api/clothing/drawer?id=$clothingId',
    );
    var jsonMap = jsonDecode(jsonString);

    return jsonMap['data'];
  }

  static Future<bool> deleteClothingItem(int id) async {
    try {
      await ApiService.makeRequest(
        method: 'POST',
        url: '${ApiService.serverIp}/smartwardrobeapi/api/clothing/$id',
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> autofillFromImage(
      String base64Image) async {
    String description = "";
    List<String> features = [];
    Map<String, dynamic> clothingMap = {
      "name": "",
      "color": "",
      "category": "",
      "material": "",
      "features": [],
      "season": "",
      "sex": "",
    };
    String json = await ApiService.makeRequest(
      method: 'POST',
      url: '${ApiService.serverIp}/smartwardrobeapi/api/imagegen/description',
      payload: {
        'image': base64Image,
      },
    );
    json = removeSpecialCharacters(json);

    Map<String, dynamic> jsonMap = jsonDecode(json);
    description = jsonMap['data'] as String;

    json = await ApiService.makeRequest(
      method: 'POST',
      url: '${ApiService.serverIp}/smartwardrobeapi/api/imagegen/suggestion',
      payload: {
        'description': description,
      },
    );

    json = removeSpecialCharacters(json);

    jsonMap = jsonDecode(
      json,
    );

    jsonMap = jsonMap['data'];

    jsonMap.forEach((key, value) {
      if (clothingMap.containsKey(key)) {
        clothingMap[key] = value;
      }
    });

    clothingMap['color'] = '0xFF${(jsonMap['color'] as String).substring(1)}';
    features = (jsonMap['features'] as List<dynamic>)
        .map(
          (e) => e as String,
        )
        .toList();
    clothingMap['features'] = features;
    return clothingMap;
  }
}
