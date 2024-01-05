import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wardrobe/common/utils/apiUtils.dart';
import 'package:http/http.dart' as http;
import 'package:wardrobe/home/models/clothing_data.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connected drawers'),
        titleTextStyle: Theme.of(context).textTheme.headlineMedium,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {});
        },
        child: const Icon(Icons.refresh),
      ),
      body: FutureBuilder(
        future: ApiService.fetchDrawers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              children: snapshot.data!
                  .map((drawer) => GridTile(
                        footer: Card(
                          child: GridTileBar(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            title: Text(
                              'Drawer: ${drawer['serial_id']}',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer),
                            ),
                            leading: Row(
                              children: [
                                Tooltip(
                                  message: 'Open drawer',
                                  child: IconButton(
                                    icon: const Icon(Icons.open_in_full),
                                    onPressed: () async {
                                      Map<String, dynamic> requestBody = {
                                        "address": drawer['address'],
                                        "operation": "SetSpeed",
                                        "parameters": [
                                          [
                                            drawer['speed'] ?? 10,
                                          ],
                                        ],
                                      };
                                      await ApiService.sendOperation(
                                          requestBody);
                                      requestBody = {
                                        "address": drawer['address'],
                                        "operation": "OpenDrawer",
                                        "parameters": [
                                          [
                                            drawer['number_of_turns'] ?? 1,
                                          ],
                                        ],
                                      };
                                      await ApiService.sendOperation(
                                          requestBody);
                                    },
                                  ),
                                ),
                                Tooltip(
                                  message: 'Close drawer',
                                  child: IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () async {
                                        Map<String, dynamic> requestBody = {
                                          "address": drawer['address'],
                                          "operation": "SetSpeed",
                                          "parameters": [
                                            [
                                              drawer['speed'] ?? 10,
                                            ],
                                          ],
                                        };
                                        await ApiService.sendOperation(
                                            requestBody);
                                        requestBody = {
                                          "address": drawer['address'],
                                          "operation": "CloseDrawer",
                                          "parameters": [
                                            [
                                              drawer['number_of_turns'] ?? 1,
                                            ],
                                          ],
                                        };

                                        await ApiService.sendOperation(
                                            requestBody);
                                      }),
                                ),
                                Tooltip(
                                  message: 'Stop drawer',
                                  child: IconButton(
                                      icon: Icon(
                                        Icons.stop,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                      onPressed: () async {
                                        Map<String, dynamic> requestBody = {
                                          "address": drawer['address'],
                                          "operation": "StopDrawer",
                                          "parameters": [
                                            [],
                                          ],
                                        };
                                        await ApiService.sendOperation(
                                            requestBody);
                                      }),
                                ),
                              ],
                            ),
                            trailing: Tooltip(
                              message: 'Drawer settings',
                              child: IconButton(
                                icon: const Icon(
                                    Icons.settings_applications_rounded),
                                onPressed: () {
                                  Navigator.of(context).push(RawDialogRoute(
                                    pageBuilder: (context, animation,
                                        secondaryAnimation) {
                                      {
                                        return Dialog(
                                          child: DrawerSettings(drawer: drawer),
                                        );
                                      }
                                    },
                                  )).then(
                                    (value) {
                                      // setState(() {});
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        child: const Card(
                            child: Icon(Icons.density_medium_rounded)),
                      ))
                  .toList(),
            );
          } else {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
        },
      ),
    );
  }
}

class DrawerSelectionScreen extends StatefulWidget {
  int clothingItem;
  DrawerSelectionScreen({super.key, required this.clothingItem});

  @override
  State<DrawerSelectionScreen> createState() =>
      _DrawerSelectionScreenState(clothingItem: clothingItem);
}

class _DrawerSelectionScreenState extends State<DrawerSelectionScreen> {
  int clothingItem;
  _DrawerSelectionScreenState({required this.clothingItem});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a drawer'),
        titleTextStyle: Theme.of(context).textTheme.headlineSmall,
      ),
      body: FutureBuilder(
        future: ApiService.fetchDrawers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              children: snapshot.data!
                  .map(
                    (drawer) => Card(
                      child: InkWell(
                        onTap: () {
                          ApiService.insertClothingIntoDrawer(
                                  clothingItem, drawer['serial_id'])
                              .then(
                            (value) {
                              print('VALUE RETURNED FROM INSERTION $value');
                              return ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                    SnackBar(
                                      content: value
                                          ? const Text(
                                              'Item inserted successfully')
                                          : const Text('Error inserting item'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  )
                                  .closed
                                  .then((value) => Navigator.of(context).pop());
                            },
                          );
                        },
                        child: GridTile(
                          child: Icon(Icons.density_medium),
                          footer: GridTileBar(
                              title: Text('${drawer['serial_id']}')),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          }
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        },
      ),
    );
  }
}

class DrawerSettings extends StatefulWidget {
  Map<String, dynamic> drawer;
  DrawerSettings({super.key, required this.drawer});

  @override
  State<DrawerSettings> createState() => _DrawerSettingsState(drawer: drawer);
}

class _DrawerSettingsState extends State<DrawerSettings> {
  Map<String, dynamic> drawer;
  double speed = 1;

  _DrawerSettingsState({required this.drawer}) {
    drawer['speed'] = 10;
    drawer['number_of_turns'] = 2;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drawer ${drawer['serial_id']} settings'),
      ),
      body: GridTile(
        footer: GridTileBar(
            title: MaterialButton(
          child: Text('Confirm settings'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )),
        child: ListView(children: [
          ListTile(
            leading: Text('Speed'),
            title: Slider(
              label: drawer['speed'] == 5
                  ? 'low'
                  : drawer['speed'] == 10
                      ? 'medium'
                      : 'fast',
              divisions: 2,
              value: drawer['speed'],
              onChanged: (value) {
                setState(() {
                  drawer['speed'] = value.round();
                });
              },
              min: 5,
              max: 15,
            ),
          ),
          ListTile(
            leading: Text('Number of turns'),
            title: Slider(
              label: '${drawer['number_of_turns']}',
              divisions: 16,
              value: drawer['number_of_turns'],
              onChanged: (value) {
                setState(() {
                  drawer['number_of_turns'] = value.round();
                });
              },
              min: 1,
              max: 16,
            ),
          )
        ]),
      ),
    );
  }
}
