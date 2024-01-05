import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wardrobe/common/utils/apiUtils.dart';
import 'package:app_settings/app_settings.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool apiIpEnabled = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Settings'),
        titleTextStyle: Theme.of(context).textTheme.headlineMedium,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 100,
          vertical: 50,
        ),
        child: Column(children: [
          MaterialButton(
            onPressed: () {},
          ),
          ListTile(
            leading: Text(
              'Api IP',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            title: TextField(
                enabled: apiIpEnabled,
                autofocus: apiIpEnabled,
                controller: TextEditingController(
                  text: ApiService.serverIp,
                ),
                onSubmitted: (value) {
                  setState(() {
                    ApiService.serverIp = value;
                    apiIpEnabled = !apiIpEnabled;
                  });
                }),
            trailing: IconButton(
              icon: Tooltip(
                  message: 'Edit API IP',
                  child: Icon(apiIpEnabled ? Icons.check : Icons.edit)),
              onPressed: () {
                setState(() {
                  apiIpEnabled = !apiIpEnabled;
                });
              },
            ),
            subtitle: FutureBuilder(
              future: ApiService.checkConnection(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!
                      ? Row(
                          children: [
                            const Icon(
                              Icons.check,
                              color: Colors.greenAccent,
                            ),
                            Text(
                              'Connected',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const Icon(
                              Icons.close,
                              color: Colors.redAccent,
                            ),
                            Text(
                              'Ip not valid',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        );
                } else {
                  return Wrap(children: [
                    Text(
                      'Checking ip',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const RefreshProgressIndicator()
                  ]);
                }
              },
            ),
          ),
          Text(
            'Make sure you are connected to the same network',
            style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
          ),
          ListTile(
            leading: Text(
              'EspLocalIp',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            title: TextField(
              controller: TextEditingController(text: ApiService.espLocalIp),
              readOnly: true,
            ),
            trailing: Wrap(
              children: [
                IconButton(
                  onPressed: () async {
                    bool result = await ApiService.fetchEspLocalIp();
                    if (result) {
                      setState(() {
                        print(ApiService.controllerId);
                      });
                    }
                  },
                  icon: const Tooltip(
                      message: 'Fetch IP from API',
                      child: Icon(Icons.download)),
                ),
                IconButton(
                  onPressed: () async {
                    if (Platform.isAndroid) {
                      AppSettings.openAppSettings(type: AppSettingsType.wifi);
                    } else {
                      final Uri url = Uri.parse('https://192.168.4.1');
                      if (!await launchUrl(url)) {
                        throw Exception('Could not launch $url');
                      }
                    }
                  },
                  icon: const Tooltip(
                      message:
                          'Open WiFi settings and connect to SmartWardrobe_AP',
                      child: Icon(Icons.wifi)),
                ),
              ],
            ),
            subtitle: FutureBuilder(
              future: ApiService.checkEspStatus(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data != ""
                      ? Row(
                          children: [
                            const Icon(
                              Icons.check,
                              color: Colors.greenAccent,
                            ),
                            Text(
                              'Connected',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const Icon(
                              Icons.close,
                              color: Colors.redAccent,
                            ),
                            Text(
                              'Ip not valid',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        );
                } else {
                  return Row(children: [
                    const RefreshProgressIndicator(),
                    Text(
                      'Checking ip',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ]);
                }
              },
            ),
          ),
          ListTile(
            leading: Text(
              'Esp WiFi Connection',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            title: Align(
              alignment: Alignment.topLeft,
              child: ApiService.espWifiConnected
                  ? const Icon(
                      Icons.check,
                      color: Colors.greenAccent,
                    )
                  : const Icon(
                      Icons.close,
                      color: Colors.redAccent,
                    ),
            ),
          ),
          ListTile(
            leading: Text(
              'Esp API Connection',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            title: Align(
              alignment: Alignment.topLeft,
              child: ApiService.espApiConnected
                  ? const Icon(
                      Icons.check,
                      color: Colors.greenAccent,
                    )
                  : const Icon(
                      Icons.close,
                      color: Colors.redAccent,
                    ),
            ),
          ),
        ]),
      ),
    );
  }
}
