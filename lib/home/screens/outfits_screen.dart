// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wardrobe/common/utils/apiUtils.dart';
import 'package:wardrobe/common/utils/imageUtils.dart';

import 'package:wardrobe/home/models/clothing_data.dart';
import 'package:wardrobe/home/screens/drawer_screen.dart';
import 'package:wardrobe/home/screens/home_screen.dart';
import 'package:wardrobe/home/widgets/clothing_data_widgets.dart';

import 'package:dropdown_textfield/dropdown_textfield.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';

Map<String, dynamic> outfitSchema = {};
Map<String, List<String>> outfitMapHints = {
  "occasion": [],
  "style": [],
  "weather": [],
  "season": ["Any", "Spring", "Summer", "Fall", "Winter"],
};

Map<String, dynamic> outfitCreated = Map.from(outfitSchema);

class OutfitListPage extends StatefulWidget {
  const OutfitListPage({super.key});

  @override
  State<OutfitListPage> createState() => _OutfitListPageState();
}

class _OutfitListPageState extends State<OutfitListPage> {
  List<Map<String, dynamic>> outfits = [];
  List<String> filterNames = ['name'];

  String searchQuery = '';
  Map<String, String> filterCategories = {
    "occasion": "",
    "weather": "",
    "season": "",
    "style": "",
  };
  bool outfitsLoaded = false;

  Future<void> _loadOutfits() async {
    if (!outfitsLoaded) {
      outfitSchema = await ApiService.getOutfitSchema();
      outfits = await ApiService.fetchOutfits();
      outfitsLoaded = true;
    }
    return;
  }

  bool filterFromSearchBar(Map<String, dynamic> elementMap, String query) {
    bool predicate = false;
    filterNames
        .map((filterName) => (elementMap[filterName] as String))
        .map((value) => value.toLowerCase().contains(query.toLowerCase()))
        .toList()
        .forEach((element) {
      predicate = predicate || element;
    });

    return predicate;
  }

  bool filterFromCategories(Map<String, dynamic> itemMap) {
    for (var e in filterCategories.entries
        .where((element) => element.value.isNotEmpty)) {
      if (itemMap[e.key] != e.value) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          MaterialButton(
            onPressed: () {
              setState(() {
                outfitsLoaded = false;
              });
            },
            child: const Icon(Icons.refresh),
          )
        ],
        title: const Text('Outfits'),
        centerTitle: true,
        titleTextStyle: Theme.of(context).textTheme.headlineMedium,
      ),
      body: Column(
        children: [
          SearchBar(
            hintText: 'Search through your outfits',
            onSubmitted: (query) {
              setState(() {
                searchQuery = query;
              });
            },
          ),
          ExpansionTile(
            title: const Text('Filters'),
            initiallyExpanded: false,
            children: [
              Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Text(
                      'Search filters: ',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Wrap(
                      children: outfitSchema.keys
                          .map(
                            (filterName) => FilterChip(
                              label: Text(filterName),
                              selected: filterNames.contains(filterName),
                              onSelected: (value) {
                                if (value) {
                                  filterNames.add(filterName);
                                } else {
                                  filterNames.remove(filterName);
                                }
                                setState(() {});
                              },
                              selectedColor:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
              Wrap(
                children: outfitMapHints.entries.map(
                  (hintEntry) {
                    return DropdownMenu(
                        inputDecorationTheme: InputDecorationTheme(
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          constraints:
                              BoxConstraints.tight(const Size.fromHeight(60)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        menuHeight: 500,
                        enableSearch: true,
                        enableFilter: false,
                        helperText: 'Filter by ${hintEntry.key}',
                        onSelected: (value) {
                          setState(() {
                            filterCategories[hintEntry.key] = value ?? '';
                          });
                        },
                        hintText: hintEntry.key,
                        dropdownMenuEntries: [
                              const DropdownMenuEntry(
                                value: '',
                                label: '',
                              )
                            ] +
                            hintEntry.value
                                .map(
                                  (hint) => DropdownMenuEntry(
                                      label: hint, value: hint),
                                )
                                .toList());
                  },
                ).toList(),
              ),
            ],
          ),
          Expanded(
            flex: 1,
            child: RefreshIndicator.adaptive(
              onRefresh: () {
                setState(() {
                  outfitsLoaded = false;
                });
                return Future(() => null);
              },
              child: FutureBuilder(
                future: _loadOutfits(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    List<Map<String, dynamic>> filteredItems = outfits
                        .where((element) =>
                            filterFromSearchBar(element, searchQuery))
                        .where(
                          (element) => filterFromCategories(element),
                        )
                        .toList();
                    return OrientationBuilder(builder: (context, orientation) {
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              orientation == Orientation.portrait ? 2 : 4,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(RawDialogRoute(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) {
                                  {
                                    return Dialog(
                                      child: OutfitDetails(
                                        outfit: filteredItems[index],
                                      ),
                                    );
                                  }
                                },
                              )).then(
                                (value) {
                                  setState(() {});
                                },
                              );
                            },
                            child: OutfitGridTile(outfit: filteredItems[index]),
                          );
                        },
                      );
                    });
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(RawDialogRoute(
              pageBuilder: (context, animation, secondaryAnimation) {
                {
                  return AddOutfitDialog();
                }
              },
            )).then(
              (value) {
                setState(() {});
              },
            );
          },
          child: const Icon(Icons.add)),
    );
  }
}

class OutfitDetails extends StatefulWidget {
  Map<String, dynamic> outfit;
  OutfitDetails({
    super.key,
    required this.outfit,
  });

  @override
  State<OutfitDetails> createState() => _OutfitDetailsState(
        outfit: outfit,
      );
}

class _OutfitDetailsState extends State<OutfitDetails> {
  Map<String, dynamic> outfit;
  _OutfitDetailsState({
    required this.outfit,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(outfit['name']),
        titleTextStyle: Theme.of(context).textTheme.headlineSmall,
      ),
      body: Card(
        child: GridTile(
          footer: GridTileBar(
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              trailing: IconButton(
                onPressed: () {
                  late Future<bool> response;
                  Navigator.of(context).push(
                    RawDialogRoute(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        {
                          return AlertDialog(
                            title: const Text("Delete outfit"),
                            actions: [
                              MaterialButton(
                                onPressed: () {
                                  response =
                                      ApiService.deleteOutfit(outfit['id']);
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Yes"),
                              ),
                              MaterialButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel"),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ).then(
                    (value) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 2),
                              content: FutureBuilder(
                                future: response,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Row(
                                      children: [
                                        Text("Submitting request"),
                                        CircularProgressIndicator()
                                      ],
                                    );
                                  } else {
                                    return Text(
                                      snapshot.data!
                                          ? "Item deleted"
                                          : "Error: item not deleted",
                                    );
                                  }
                                },
                              ),
                            ),
                          )
                          .closed
                          .then((value) => Navigator.of(context).pop());
                    },
                  );
                },
                icon: const Icon(Icons.delete),
              )),
          child: OrientationBuilder(builder: (context, orientation) {
            if (orientation == Orientation.landscape) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display image to the side
                  if (outfit['image'] != null)
                    Expanded(
                      flex: 1, // Adjust the flex value as needed
                      child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: Image.network(
                          outfit['image']!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  Expanded(
                    flex: 1, // Adjust the flex value as needed
                    child: ListView(
                        children: outfit.entries
                            .where((element) => element.key != 'image')
                            .map((entry) {
                      // ignore: unnecessary_cast
                      return Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          border: Border.all(
                              style: BorderStyle.solid,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer
                                  .withAlpha(127)),
                        ),
                        // ignore: unnecessary_cast
                        child: ListTile(
                          leading: AutoSizeText(
                            entry.key,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                              fontStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.fontStyle,
                            ),
                          ),
                          title: entry.key == 'color'
                              ? SizedBox(
                                  width: 42.0,
                                  height: 42.0,
                                  child: DecoratedBox(
                                      decoration: BoxDecoration(
                                          color:
                                              Color(int.parse(entry.value)))),
                                )
                              : entry.value.runtimeType == (List<String>)
                                  ? Wrap(
                                      children: (entry.value as List)
                                          .map((e) => Chip(
                                                label: AutoSizeText(
                                                  e,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSecondary),
                                                ),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                              ))
                                          .toList(),
                                    )
                                  : AutoSizeText(entry.value.toString()),
                        ),
                      );
                    }).toList()),
                  ),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display image to the side
                  if (outfit['image'] != null)
                    Expanded(
                      flex: 1, // Adjust the flex value as needed
                      child: Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: Center(
                          child: Image.network(
                            outfit['image']!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    flex: 2, // Adjust the flex value as needed
                    child: ListView(
                        children: outfit.entries
                            .where((element) => element.key != 'image')
                            .map((entry) {
                      // ignore: unnecessary_cast
                      return Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          border: Border.all(
                              style: BorderStyle.solid,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer
                                  .withAlpha(127)),
                        ),
                        // ignore: unnecessary_cast
                        child: ListTile(
                          leading: AutoSizeText(
                            entry.key,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                              fontStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.fontStyle,
                            ),
                          ),
                          title: entry.key == 'color'
                              ? SizedBox(
                                  width: 42.0,
                                  height: 42.0,
                                  child: DecoratedBox(
                                      decoration: BoxDecoration(
                                          color:
                                              Color(int.parse(entry.value)))),
                                )
                              : entry.value.runtimeType == (List<String>)
                                  ? Wrap(
                                      children: (entry.value as List)
                                          .map((e) => Chip(
                                                label: AutoSizeText(
                                                  e,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSecondary),
                                                ),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                              ))
                                          .toList(),
                                    )
                                  : AutoSizeText(entry.value.toString()),
                        ),
                      );
                    }).toList()),
                  ),
                ],
              );
            }
          }),
        ),
      ),
    );
  }
}

class AddOutfitDialog extends StatefulWidget {
  const AddOutfitDialog({super.key});

  @override
  State<AddOutfitDialog> createState() => _AddOutfitDialogState();
}

class _AddOutfitDialogState extends State<AddOutfitDialog> {
  final _formKey = GlobalKey<FormState>();
  List<Widget> textFormFields = [];
  List<Widget> featureChips = [];
  String? capturedImage;
  String feature = '';
  List<ClothingItem> chosenItems = [];
  _AddOutfitDialogState();

  Widget _buildImagePicker(context) {
    return Builder(builder: (context) {
      if (capturedImage == null) {
        return Row(
          children: [
            MaterialButton(
              onPressed: () async {
                capturedImage = await ImageUtils.imageToBase64(
                    (await ImageUtils.captureImage(ImageSource.camera))!);
                setState(() {});
              },
              child: const Icon(
                Icons.add_a_photo,
              ),
            ),
            MaterialButton(
              onPressed: () async {
                capturedImage = await ImageUtils.imageToBase64(
                    (await ImageUtils.captureImage(ImageSource.gallery))!);
                setState(() {});
              },
              child: const Icon(
                Icons.collections,
              ),
            ),
            MaterialButton(
              onPressed: () async {
                capturedImage = await ApiService.generateOutfitImage({});
                setState(() {});
              },
              child: const Icon(
                Icons.download_for_offline_outlined,
              ),
            ),
          ],
        );
      } else {
        return Column(
          children: [
            Expanded(
              flex: 10,
              child: Image.memory(base64Decode(capturedImage!)),
            ),
          ],
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Create your outfit"),
        titleTextStyle: Theme.of(context).textTheme.headlineSmall,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: DottedBorder(
                dashPattern: [6, 3, 2, 3],
                color:
                    Theme.of(context).colorScheme.onBackground.withAlpha(127),
                child: Center(child: _buildImagePicker(context)),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Form(
              key: _formKey,
              child: InkWell(
                child: Builder(builder: (context) {
                  List<Widget> gridTiles = chosenItems
                      .map(
                        (e) => InkWell(
                          onLongPress: () {
                            setState(() {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  duration: Duration(seconds: 1),
                                  content: Text('Item removed'),
                                ),
                              );
                              chosenItems.remove(e);
                            });
                          },
                          child:
                              ClothingItemGridTile(clothingItem: e) as Widget,
                        ),
                      )
                      .toList();
                  gridTiles.insert(
                      0,
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(RawDialogRoute(
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return Scaffold(
                                appBar: AppBar(
                                  title: Text('Add item to outfit'),
                                  titleTextStyle: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                                body: FutureBuilder(
                                  future: ApiService.fetchClothingItems(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return ResponsiveGridView(
                                          children: snapshot.data!
                                              .where((element) => !chosenItems
                                                  .contains(element))
                                              .map((e) => InkWell(
                                                    onTap: () {
                                                      chosenItems.add(e);
                                                      Navigator.pop(context);
                                                    },
                                                    child: ClothingItemGridTile(
                                                      clothingItem: e,
                                                    ),
                                                  ))
                                              .toList());
                                    } else {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          )).then((value) => setState(
                                () {},
                              ));
                        },
                        child: GridTile(
                          child: DottedBorder(
                              dashPattern: [6, 3, 2, 3],
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withAlpha(127),
                              child: Center(
                                child: Icon(Icons.add),
                              )),
                        ),
                      ));
                  return Column(
                    children: [
                      Expanded(child: AutoSizeText('Selected Items')),
                      Expanded(
                        flex: 20,
                        child: ResponsiveGridView(
                          children: gridTiles,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: ListTile(
        tileColor: Theme.of(context).colorScheme.tertiaryContainer,
        leading: MaterialButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Future<bool> response = ApiService.insertOutfit(outfitCreated);
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                    SnackBar(
                      content: FutureBuilder(
                        future: response,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Row(
                              children: [
                                Text("Submitting data"),
                                CircularProgressIndicator()
                              ],
                            );
                          } else {
                            return Text(
                              snapshot.data!
                                  ? "Outfit created"
                                  : "Error: outfit not created",
                            );
                          }
                        },
                      ),
                    ),
                  )
                  .closed
                  .then(
                (value) {
                  Navigator.of(context).pop();
                },
              );
            }
          },
          child: const Text('Submit'),
        ),
        trailing: MaterialButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('cancel'),
        ),
      ),
    );
  }
}

class OutfitGridTile extends StatelessWidget {
  final Map<String, dynamic> outfit;

  const OutfitGridTile({super.key, required this.outfit});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              outfit['name'],
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              outfit['occasion'],
              style: TextStyle(
                  fontSize: 14.0,
                  color: Theme.of(context).colorScheme.onSecondaryContainer),
            ),
          ),
        ),
        child: Image.network(
          outfit['image'] ?? '', // Provide a default image URL or handle null
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class ClothingItemDetailsWidget extends StatefulWidget {
  const ClothingItemDetailsWidget({super.key});

  @override
  State<ClothingItemDetailsWidget> createState() =>
      _ClothingItemDetailsWidgetState();
}

class _ClothingItemDetailsWidgetState extends State<ClothingItemDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
