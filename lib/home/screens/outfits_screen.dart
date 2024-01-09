// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wardrobe/common/utils/apiUtils.dart';
import 'package:wardrobe/common/utils/imageUtils.dart';

import 'package:wardrobe/home/models/clothing_data.dart';
import 'package:wardrobe/home/screens/home_screen.dart';
import 'package:wardrobe/home/widgets/clothing_data_widgets.dart';

import 'package:dropdown_textfield/dropdown_textfield.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';

Map<String, dynamic> outfitSchema = {};
String? capturedImage;
Map<String, List<String>> outfitMapHints = {
  "occasion": [
    "Casual",
    "Formal",
    "Business Casual",
    "Party",
    "Outdoor",
    "Wedding",
    "Date Night",
    "Vacation",
    "Workout",
    "Cocktail",
    "Interview",
    "Beach Day",
    "BBQ",
    "Concert",
    "Picnic",
    "Hiking",
    "Brunch",
    "Shopping Spree",
    "Club Night",
    "Holiday Celebration"
  ],
  "style": [
    "Classic",
    "Bohemian",
    "Sporty",
    "Chic",
    "Vintage",
    "Preppy",
    "Gothic",
    "Casual Streetwear",
    "Minimalist",
    "Artsy",
    "Retro",
    "Eclectic",
    "Urban",
    "Edgy",
    "Romantic",
    "Western",
    "Surf Style",
    "Punk",
    "Business Professional",
    "Festival"
  ],
  "sex": ["M", "F", "U"],
  "weather": ["Any", "Sunny", "Rainy", "Snowy", "Windy", "Hot", "Cold"],
  "season": ["Any", "Spring", "Summer", "Fall", "Winter"]
};

Map<String, dynamic> outfitCreated = Map.from(outfitSchema);
List<ClothingItem> chosenItems = [];

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
      extendBody: false,
      appBar: AppBar(
        title: Text(outfit['name']),
        titleTextStyle: Theme.of(context).textTheme.headlineSmall,
      ),
      bottomNavigationBar: SafeArea(
        child: GridTileBar(
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          title: Container(),
          leading: Row(
            children: [
              Tooltip(
                message: 'Open drawers containing outfit components',
                child: IconButton(
                  onPressed: () async {
                    Set<int> addresses = {};
                    print(outfit['components']);
                    (outfit['components'] as List<dynamic>)
                        .forEach((element) async {
                      Map<String, dynamic> clothingItem =
                          element as Map<String, dynamic>;
                      print(clothingItem);

                      int address = (await ApiService.getAssociatedDrawer(
                          clothingItem['id']))['address'];
                      if (!addresses.contains(address)) {
                        ApiService.openDrawer(address, 15, 2);
                        addresses.add(address);
                      }
                    });
                  },
                  icon: Icon(Icons.density_medium_outlined),
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),
              Tooltip(
                message: 'Close drawers containing outfit components',
                child: IconButton(
                  onPressed: () async {
                    Set<int> addresses = {};
                    print(outfit['components']);
                    (outfit['components'] as List<dynamic>)
                        .forEach((element) async {
                      Map<String, dynamic> clothingItem =
                          element as Map<String, dynamic>;
                      print(clothingItem);

                      int address = (await ApiService.getAssociatedDrawer(
                          clothingItem['id']))['address'];
                      if (!addresses.contains(address)) {
                        ApiService.closeDrawer(address, 15, 2);
                        addresses.add(address);
                      }
                    });
                  },
                  icon: Icon(Icons.density_large),
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            color: Theme.of(context).colorScheme.onTertiaryContainer,
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
                              response = ApiService.deleteOutfit(outfit['id']);
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
                  Navigator.of(context).pop();
                },
              );
            },
            icon: const Icon(Icons.delete),
          ),
        ),
      ),
      body: Card(
        child: GridTile(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display image to the side
              if (outfit['image'] != null)
                Expanded(
                  flex: 2, // Adjust the flex value as needed
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Image.network(
                        '${ApiService.serverIp}/smartwardrobeapi/${outfit['image']!}',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              Expanded(
                flex: 2, // Adjust the flex value as needed
                child: ListView(
                    children: outfit.entries
                        .where((element) =>
                            element.key != 'image' &&
                            element.key != 'components')
                        .map((entry) {
                  // ignore: unnecessary_cast
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      border: Border.all(
                          style: BorderStyle.solid,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer
                              .withAlpha(127)),
                    ),
                    child: ListTile(
                      leading: AutoSizeText(
                        entry.key,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          fontStyle:
                              Theme.of(context).textTheme.bodyMedium?.fontStyle,
                        ),
                      ),
                      title: AutoSizeText(entry.value.toString()),
                    ),
                  );
                }).toList()),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    border: Border.all(
                        style: BorderStyle.solid,
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer
                            .withAlpha(127)),
                  ),
                  child: ListTile(
                    leading: AutoSizeText('components'),
                    title: ListView(
                      scrollDirection: Axis.horizontal,
                      children:
                          (outfit['components'] as List<dynamic>).map((e) {
                        Map<String, dynamic> clothingItem =
                            e as Map<String, dynamic>;
                        return Image.network(
                          '${ApiService.serverIp}/smartwardrobeapi/${clothingItem['image']}',
                          fit: BoxFit.contain,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddOutfitDialog extends StatefulWidget {
  AddOutfitDialog({super.key}) {
    chosenItems.clear();
  }

  @override
  State<AddOutfitDialog> createState() => _AddOutfitDialogState();
}

class _AddOutfitDialogState extends State<AddOutfitDialog> {
  _AddOutfitDialogState();

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
          // Expanded(
          //   flex: 3,
          //   child: Padding(
          //     padding: const EdgeInsets.all(20),
          //     child: DottedBorder(
          //       dashPattern: [6, 3, 2, 3],
          //       color:
          //           Theme.of(context).colorScheme.onBackground.withAlpha(127),
          //       child: Center(child: _buildImagePicker(context)),
          //     ),
          //   ),
          // ),
          Expanded(
            flex: 5,
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
                        child: ClothingItemGridTile(clothingItem: e) as Widget,
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
                                titleTextStyle:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              body: FutureBuilder(
                                future: ApiService.fetchClothingItems(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return ResponsiveGridView(
                                        children: snapshot.data!
                                            .where((element) =>
                                                !chosenItems.contains(element))
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
                        )).then((value) {
                          setState(
                            () {},
                          );
                        });
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
        ],
      ),
      bottomSheet: ListTile(
        tileColor: Theme.of(context).colorScheme.tertiaryContainer,
        leading: MaterialButton(
          onPressed: () {
            Navigator.of(context).push(RawDialogRoute(
              pageBuilder: (context, animation, secondaryAnimation) {
                outfitCreated['components'] = chosenItems;
                capturedImage = null;

                return InsertOutfitDetailsWidget();
              },
            )).then(
              (value) {},
            );
          },
          child: const Text('Insert info'),
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
              outfit['occasion'] ?? '',
              style: TextStyle(
                  fontSize: 14.0,
                  color: Theme.of(context).colorScheme.onSecondaryContainer),
            ),
          ),
        ),
        child: Image.network(
          outfit['image'] != null
              ? '${ApiService.serverIp}/smartwardrobeapi/${outfit['image']}'
              : '', // Provide a default image URL or handle null
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class InsertOutfitDetailsWidget extends StatefulWidget {
  const InsertOutfitDetailsWidget({super.key});

  @override
  State<InsertOutfitDetailsWidget> createState() =>
      _InsertOutfitDetailsWidgetState();
}

class _InsertOutfitDetailsWidgetState extends State<InsertOutfitDetailsWidget> {
  final _formKey = GlobalKey<FormState>();

  bool plasticPeople = true;

  void _generateImage() async {
    var capturedImageFuture = ApiService.generateOutfitImage(outfitCreated, plasticPeople);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: Duration(seconds: 300),
            content: FutureBuilder(
              future: capturedImageFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  capturedImage = snapshot.data!;
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  return Text(
                    'Image generated',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary),
                  );
                } else {
                  return ListTile(
                      leading: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.onSecondary),
                      title: Text('Generating image',
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onSecondary)));
                }
              },
            )))
        .closed
        .then(
      (value) {
        setState(() {});
      },
    );
  }

  Widget _buildImagePicker() {
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
              onPressed: _generateImage,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {});
        },
        child: Icon(Icons.refresh),
      ),
      appBar: AppBar(
        title: Text('Insert outfit info'),
        titleTextStyle: Theme.of(context).textTheme.headlineMedium,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: DottedBorder(
                    dashPattern: [6, 3, 2, 3],
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withAlpha(127),
                    child: _buildImagePicker()),
              ),
            ),
            ListTile(
              leading: Switch(
                value: plasticPeople,
                onChanged: (bool value) {
                  setState(() {
                    plasticPeople = value;
                  });
                },
              ),
              title: Text('Generate mannequins'),
            ),
            Expanded(
              flex: 8,
              child: ListView(
                // ignore: unnecessary_cast
                children: [
                      // ignore: unnecessary_cast
                      TextFormField(
                        onChanged: (value) {
                          outfitCreated["name"] = value;
                        },
                        controller:
                            TextEditingController(text: outfitCreated["name"]),
                        decoration: InputDecoration(labelText: "name"),
                        validator: (input) {
                          if (input == null || input.isEmpty) {
                            return 'Please enter a name';
                          }
                          outfitCreated["name"] = input;
                          return null;
                        },
                      ) as Widget,
                      // ignore: unnecessary_cast
                      TextFormField(
                        onChanged: (value) {
                          outfitCreated["description"] = value;
                        },
                        controller: TextEditingController(
                            text: outfitCreated["description"]),
                        decoration: InputDecoration(labelText: "description"),
                        validator: (input) {
                          // if (input == null || input.isEmpty) {
                          //   return 'Please enter a description';
                          // }
                          outfitCreated["description"] = input;
                          return null;
                        },
                      ) as Widget,
                    ] +
                    outfitSchema.entries
                        .where((element) =>
                            element.key != "image" &&
                            element.key != "name" &&
                            element.key != 'id' &&
                            element.key != 'description' &&
                            element.value is String)
                        .map(
                          // ignore: unnecessary_cast
                          (outfitSchemaEntry) => DropDownTextField(
                            textFieldDecoration: InputDecoration(
                                hintText: outfitSchemaEntry.key),
                            enableSearch: true,
                            clearOption: true,
                            searchAutofocus: true,
                            onChanged: (selectedValue) {
                              outfitCreated[outfitSchemaEntry.key] =
                                  (selectedValue as DropDownValueModel).value;
                            },
                            validator: (input) {
                              if (outfitSchemaEntry.key == "occasion" ||
                                  outfitSchemaEntry.key == "sex") {
                                if (input == null || input.isEmpty) {
                                  return 'Please enter a ${outfitSchemaEntry.key}';
                                }
                                outfitCreated[outfitSchemaEntry.key] = input;
                                return null;
                              }
                              outfitCreated[outfitSchemaEntry.key] = input;
                              return null;
                            },
                            dropDownList: outfitMapHints
                                    .containsKey(outfitSchemaEntry.key)
                                ? outfitMapHints[outfitSchemaEntry.key]!
                                    .map((hint) => DropDownValueModel(
                                        name: hint, value: hint))
                                    .toList()
                                : [],
                          ) as Widget,
                        )
                        .toList(),
              ),
            ),
            Expanded(
              flex: 1,
              child: GridTileBar(
                backgroundColor:
                    Theme.of(context).colorScheme.tertiaryContainer,
                title: MaterialButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      outfitCreated["components"] = chosenItems;
                      outfitCreated['image'] = capturedImage;

                      var insertFuture = ApiService.insertOutfit(outfitCreated);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          duration: Duration(
                            seconds: 300,
                          ),
                          content: FutureBuilder(
                            future: insertFuture,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data!) {
                                  return Text('Outfit created successfully',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondary));
                                } else {
                                  return Text('Error creating outfit',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondary));
                                }
                              } else {
                                return ListTile(
                                  leading: CircularProgressIndicator(),
                                  title: Text('Inserting outfit',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondary)),
                                );
                              }
                            },
                          ),
                        ),
                      );
                      insertFuture.then(
                        (value) => Future.delayed(Duration(seconds: 1)).then(
                          (value) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    }
                  },
                  child: Text('Submit outfit'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
