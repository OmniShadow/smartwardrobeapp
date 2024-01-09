import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:wardrobe/common/utils/apiUtils.dart';
import 'package:http/http.dart' as http;
import 'package:wardrobe/home/models/clothing_data.dart';
import 'package:wardrobe/home/screens/home_screen.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  Future<List<ClothingItem>> _getDrawerContents(String serialId) async {
    List<ClothingItem> items = await ApiService.fetchClothingItems();
    List<ClothingItem> contents = [];

    for (var item in items) {
      var associatedDrawer = await ApiService.getAssociatedDrawer(item.id);

      if (associatedDrawer.isNotEmpty) {
        if (associatedDrawer['serial_id'] == serialId) {
          contents.add(item);
        }
      }
    }

    return contents;
  }

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
            return ResponsiveGridView(
              children: snapshot.data!
                  .map((drawer) => InkWell(
                        onTap: () {
                          Navigator.of(context).push(RawDialogRoute(
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return Dialog(
                                child: Scaffold(
                                    appBar:
                                        AppBar(title: const Text('Drawer contents')),
                                    body: FutureBuilder(
                                      future: _getDrawerContents(
                                          drawer['serial_id']),
                                      builder: (context, contentsSnapshot) {
                                        if (contentsSnapshot.connectionState ==
                                            ConnectionState.done) {
                                          return ResponsiveGridView(
                                            children: contentsSnapshot.data!
                                                .map(
                                                  (clothingItem) => Card(
                                                    child: GridTile(
                                                      footer: GridTileBar(
                                                        backgroundColor: Theme
                                                                .of(context)
                                                            .colorScheme
                                                            .secondaryContainer,
                                                        title: Text(
                                                          clothingItem.name,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onSecondaryContainer),
                                                        ),
                                                      ),
                                                      child: Image.network(
                                                        clothingItem.image ?? '',
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          );
                                        } else {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                      },
                                    )),
                              );
                            },
                          ));
                        },
                        child: GridTile(
                          header: GridTileBar(
                            title: Text(drawer['name']),
                            leading: CircleAvatar(backgroundColor: drawer['status'] == 'Connected'? Colors.greenAccent : Colors.red,maxRadius: 10),
                            trailing: Tooltip(
                              message: 'Edit name',
                              child: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.of(context).push(RawDialogRoute(
                                    pageBuilder: (context, animation,
                                        secondaryAnimation) {
                                      return AlertDialog.adaptive(
                                        title: const Text('Insert new name'),
                                        content: TextField(
                                          controller: TextEditingController(
                                              text: drawer['name']),
                                          onSubmitted: (value) {
                                            ApiService.updateDrawerName(
                                                    value, drawer['serial_id'])
                                                .then((value) =>
                                                    Navigator.of(context)
                                                        .pop());
                                          },
                                        ),
                                        actions: [
                                          IconButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              icon: const Icon(Icons.close))
                                        ],
                                      );
                                    },
                                  )).then((value) => setState(
                                        () {},
                                      ));
                                },
                              ),
                            ),
                          ),
                          footer: Card(
                            child: GridTileBar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              subtitle: AutoSizeText(
                                'Drawer: ${drawer['serial_id']}',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer),
                              ),
                              leading: PopupMenuButton<int>(
                                itemBuilder: (context) {
                                  return [
                                    PopupMenuItem(
                                      onTap: () async {
                                        await ApiService.openDrawer(
                                            drawer['address'],
                                            drawer['speed'] ?? 10,
                                            drawer['number_of_turns'] ?? 2);
                                      },
                                      child: const Text('Open'),
                                    ),
                                    PopupMenuItem(
                                      onTap: () async {
                                        await ApiService.closeDrawer(
                                            drawer['address'],
                                            drawer['speed'] ?? 10,
                                            drawer['number_of_turns'] ?? 2);
                                      },
                                      child: const Text('Close'),
                                    ),
                                    PopupMenuItem(
                                      onTap: () async {
                                        Map<String, dynamic> requestBody = {
                                          "address": drawer['address'],
                                          "operation": "StopDrawer",
                                          "parameters": [
                                            [],
                                          ],
                                        };
                                        await ApiService.sendOperation(
                                            requestBody);
                                      },
                                      child: const Text('Stop'),
                                    ),
                                  ];
                                },
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
                                            child:
                                                DrawerSettings(drawer: drawer),
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
                        ),
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
        title: const Text('Select a drawer'),
        titleTextStyle: Theme.of(context).textTheme.headlineSmall,
      ),
      body: FutureBuilder(
        future: ApiService.fetchDrawers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return OrientationBuilder(builder: (context, orientation) {
              return GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
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
                                return ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                      SnackBar(
                                        content: value
                                            ? const Text(
                                                'Item inserted successfully')
                                            : const Text(
                                                'Error inserting item'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    )
                                    .closed
                                    .then(
                                        (value) => Navigator.of(context).pop());
                              },
                            );
                          },
                          child: GridTile(
                            header: Text(drawer['name']),
                            child: const Icon(Icons.density_medium),
                            footer: GridTileBar(
                                title: Text('${drawer['serial_id']}')),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            });
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
    drawer['speed'] = 10.0;
    drawer['number_of_turns'] = 2.0;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Drawer ${drawer['serial_id']} settings',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: GridTile(
        footer: GridTileBar(
            title: MaterialButton(
          child: const Text('Confirm settings'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )),
        child: ListView(children: [
          ListTile(
            leading: const Text('Speed'),
            title: Slider(
              label: drawer['speed'] <= 5
                  ? 'low'
                  : drawer['speed'] <= 10
                      ? 'medium'
                      : 'fast',
              divisions: 2,
              value: drawer['speed'],
              onChanged: (value) {
                setState(() {
                  drawer['speed'] = value;
                });
              },
              min: 5,
              max: 15,
            ),
          ),
          ListTile(
            leading: const Text('Number of turns'),
            title: Slider(
              label: '${drawer['number_of_turns'].round()}',
              divisions: 16,
              value: drawer['number_of_turns'],
              onChanged: (value) {
                setState(() {
                  drawer['number_of_turns'] = value;
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
