// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wardrobe/common/utils/apiUtils.dart';
import 'package:wardrobe/common/utils/imageUtils.dart';

import 'package:wardrobe/home/models/clothing_data.dart';
import 'package:wardrobe/home/screens/drawer_screen.dart';
import 'package:wardrobe/home/widgets/clothing_data_widgets.dart';

import 'package:dropdown_textfield/dropdown_textfield.dart';

Map<String, List<String>> clothingMapHints = {
  "category": [
    "Top",
    "Bottoms",
    "Dresses",
    "Outerwear",
    "Activewear",
    "Loungewear",
    "Formalwear",
    "Swimwear",
    "Sleepwear",
    "Sportswear",
    "Footwear",
    "Accessories",
    "Underwear",
    "Maternity Wear",
    "Workwear",
    "Ethnic Wear",
    "Casual Wear",
    "Vintage Clothing",
    "Streetwear",
    "Athleisure",
    "Partywear",
    "Business Casual",
    "Uniforms",
    "Smart Casual",
    "Seasonal Wear",
    "Costumes",
    "Rainwear",
    "Winter Wear",
    "Summer Wear",
    "Spring Fashion",
    "Autumn Fashion",
    "Active Casual",
    "Leisurewear",
    "Performance Wear",
    "Western Wear",
    "Eastern Wear",
    "Western Formal",
    "Eastern Formal",
    "Bohemian Style",
    "Minimalist Fashion",
    "Urban Chic",
    "Avant-Garde Fashion",
    "Retro Fashion",
    "Vintage-inspired Fashion",
    "Gothic Fashion",
    "Punk Fashion",
    "Boho Chic",
    "Casual Chic",
    "Sustainable Fashion",
    "Street Style",
    "Classic Style",
    "Eclectic Fashion",
    "Modern Elegance",
    "Classic Casual",
    "Festival Wear",
    "Travel Wear",
    "Lingerie",
    "Athletic Shoes",
    "Casual Shoes",
    "Formal Shoes",
    "Sandals",
    "Boots",
    "Sneakers",
    "Heels",
    "Flats",
    "Wedges",
    "Slippers"
  ],
  "size": [
    "XS",
    "S",
    "M",
    "L",
    "XL",
    "XXL",
    "XXXL",
  ],
  "material": [
    "Cotton",
    "Polyester",
    "Wool",
    "Silk",
    "Linen",
    "Denim",
    "Leather",
    "Spandex",
    "Nylon",
    "Rayon"
  ],
  "season": ["Any", "Spring", "Summer", "Fall", "Winter"],
  "sex": ["M", "F", "U"],
};

class ClothingListPage extends StatefulWidget {
  const ClothingListPage({super.key});

  @override
  State<ClothingListPage> createState() => _ClothingListPageState();
}

class _ClothingListPageState extends State<ClothingListPage> {
  List<ClothingItem> clothingItems = [];
  List<String> filterNames = ['name'];

  String searchQuery = '';
  Map<String, String> filterCategories = {
    "category": "",
    "material": "",
    "season": "",
    "sex": "",
    "size": "",
  };
  bool clothingItemsLoaded = false;
  ClothingItem clothingItemTemplate = ClothingItem(
    id: 0,
    color: '',
    name: '',
    category: '',
    size: '',
    features: [],
    season: '',
    sex: '',
    description: '',
  );

  Future<void> _loadClothingItems() async {
    if (!clothingItemsLoaded) {
      clothingItems = await ApiService.fetchClothingItems();
      clothingItemsLoaded = true;
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
                clothingItemsLoaded = false;
              });
            },
            child: const Icon(Icons.refresh),
          )
        ],
        title: const Text('Your wardrobe'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SearchBar(
            hintText: 'Search through your wardrobe',
            onSubmitted: (query) {
              setState(() {
                searchQuery = query;
              });
            },
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: const Text(
                  'Search filters: ',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Expanded(
                flex: 3,
                child: Wrap(
                  children: clothingItemTemplate
                      .toMap()
                      .keys
                      .where((key) => (key != 'features' &&
                          key != 'description' &&
                          key != 'id' &&
                          key != 'color'))
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
            children: clothingMapHints.entries.map(
              (hintEntry) {
                return DropdownMenu(
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
                              (hint) =>
                                  DropdownMenuEntry(label: hint, value: hint),
                            )
                            .toList());
              },
            ).toList(),
          ),
          Expanded(
            flex: 1,
            child: RefreshIndicator.adaptive(
              onRefresh: () {
                setState(() {
                  clothingItemsLoaded = false;
                });
                return Future(() => null);
              },
              child: FutureBuilder(
                future: _loadClothingItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    List<ClothingItem> filteredItems = clothingItems
                        .where((element) =>
                            filterFromSearchBar(element.toMap(), searchQuery))
                        .where(
                          (element) => filterFromCategories(element.toMap()),
                        )
                        .toList();
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
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
                                    child: ClothingItemDetails(
                                      clothingItem: filteredItems[index],
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
                          child: ClothingItemGridTile(
                              clothingItem: filteredItems[index]),
                        );
                      },
                    );
                  } else {
                    return Center(child: const CircularProgressIndicator());
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
                  return const Dialog(
                    child: AddClothingItemPage(),
                  );
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

class ClothingItemDetails extends StatefulWidget {
  ClothingItem clothingItem;
  ClothingItemDetails({
    super.key,
    required this.clothingItem,
  });

  @override
  State<ClothingItemDetails> createState() => _ClothingItemDetailsState(
        clothingItem: clothingItem,
      );
}

class _ClothingItemDetailsState extends State<ClothingItemDetails> {
  ClothingItem clothingItem;
  _ClothingItemDetailsState({
    required this.clothingItem,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(clothingItem.name),
        titleTextStyle: Theme.of(context).textTheme.headlineSmall,
      ),
      body: Card(
        child: GridTile(
          footer: GridTileBar(
              title: FutureBuilder(
                future: ApiService.getAssociatedDrawer(clothingItem.id),
                builder: (context, drawerSnapshot) {
                  if (drawerSnapshot.hasData) {
                    return ListTile(
                      title: Text(
                          'Drawer name: ${drawerSnapshot.data!['name']} id:${drawerSnapshot.data!['serial_id']}'),
                      trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.of(context).push(RawDialogRoute(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) {
                                String drawerId = '';
                                return AlertDialog(
                                  title: Text('Change drawer'),
                                  actions: [
                                    IconButton(
                                        onPressed: () async {
                                          ApiService.updateAssociatedDrawer(
                                                  clothingItem.id, drawerId)
                                              .then(
                                            (value) {
                                              Navigator.of(context).pop();
                                            },
                                          );
                                        },
                                        icon: Icon(Icons.check_sharp)),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        icon: Icon(Icons.close))
                                  ],
                                  content: FutureBuilder(
                                    future: ApiService.fetchDrawers(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return DropdownMenu(
                                          initialSelection: drawerSnapshot.data!['serial_id'],
                                          hintText:'Select a drawer' ,
                                          dropdownMenuEntries: snapshot.data!
                                              .map((drawer) =>
                                                  DropdownMenuEntry(
                                                    label: drawer['name'],
                                                    value: drawer['serial_id'],
                                                  ))
                                              .toList(),
                                          onSelected: (value) {
                                            setState(() {
                                              drawerId = value!;
                                            });
                                          },
                                        );
                                      } else {
                                        return CircularProgressIndicator
                                            .adaptive();
                                      }
                                    },
                                  ),
                                );
                              },
                            )).then((value) => setState(
                                  () {},
                                ));
                          }),
                    );
                  } else {
                    return CircularProgressIndicator.adaptive();
                  }
                },
              ),
              leading: IconButton(
                icon: Tooltip(
                  message: 'Open associated drawer',
                  child: const Icon(Icons.density_small),
                ),
                onPressed: () async {
                  int address = (await ApiService.getAssociatedDrawer(
                      clothingItem.id))['address'];
                  ApiService.openDrawer(address, 15, 2);
                },
              ),
              trailing: IconButton(
                onPressed: () {
                  late Future<bool> response;
                  Navigator.of(context).push(
                    RawDialogRoute(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        {
                          return AlertDialog(
                            title: const Text("Delete item"),
                            actions: [
                              MaterialButton(
                                onPressed: () {
                                  response = ApiService.deleteClothingItem(
                                      clothingItem.id);
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display image to the side
                if (clothingItem.image != null)
                  Expanded(
                    flex: 2, // Adjust the flex value as needed
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: Image.network(
                        clothingItem.image!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                Expanded(
                  flex: 1, // Adjust the flex value as needed
                  child: ListView(
                      children: clothingItem
                          .toMap()
                          .entries
                          .where((element) => element.key != 'image')
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
                      // ignore: unnecessary_cast
                      child: ListTile(
                        leading: Text(
                          entry.key,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                            fontStyle: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.fontStyle,
                            fontSize: 20,
                          ),
                        ),
                        title: entry.key == 'color'
                            ? SizedBox(
                                width: 42.0,
                                height: 42.0,
                                child: DecoratedBox(
                                    decoration: BoxDecoration(
                                        color: Color(int.parse(entry.value)))),
                              )
                            : entry.value.runtimeType == (List<String>)
                                ? Wrap(
                                    children: (entry.value as List)
                                        .map((e) => Chip(
                                              label: Text(
                                                e,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSecondary),
                                              ),
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ))
                                        .toList(),
                                  )
                                : Text(entry.value.toString()),
                      ),
                    );
                  }).toList()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddClothingItemPage extends StatefulWidget {
  const AddClothingItemPage({super.key});

  @override
  State<AddClothingItemPage> createState() => _AddClothingItemPageState();
}

class _AddClothingItemPageState extends State<AddClothingItemPage> {
  Map<String, dynamic> clothingMap = {
    "name": "",
    "brand": null,
    "features": [],
    "color": "0xFF000000",
    "category": "",
    "size": "",
    "material": "",
    "season": "",
    "sex": "",
    "description": "",
  };

  final _formKey = GlobalKey<FormState>();
  List<Widget> textFormFields = [];
  List<Widget> featureChips = [];
  String? capturedImage;
  String feature = '';
  _AddClothingItemPageState() {
    _buildFormFields();
  }

  void _buildFormFields() {
    _buildTextFormFields();
    _buildFeatureChips();
  }

  void _buildTextFormFields() {
    textFormFields = [];
    clothingMap.forEach(
      (key, value) {
        if (key == 'color') {
          return;
        }
        if (value is String || value == null) {
          if (clothingMapHints.containsKey(key)) {
            textFormFields.add(
              DropDownTextField(
                controller: value.isNotEmpty
                    ? SingleValueDropDownController(
                        data: DropDownValueModel(name: value, value: value))
                    : null,
                textFieldDecoration: InputDecoration(hintText: key),
                enableSearch: true,
                clearOption: true,
                searchAutofocus: true,
                onChanged: (selectedValue) {
                  value = (selectedValue as DropDownValueModel).value;
                  clothingMap[key] = (selectedValue).value;
                },
                validator: (input) {
                  if (input == null || input.isEmpty) {
                    return 'Please enter a $key';
                  }
                  clothingMap[key] = input;
                  return null;
                },
                dropDownList: clothingMapHints.containsKey(key)
                    ? clothingMapHints[key]!
                        .map((hint) =>
                            DropDownValueModel(name: hint, value: hint))
                        .toList()
                    : [],
              ),
            );
          } else {
            textFormFields.add(
              TextFormField(
                controller: TextEditingController(text: value),
                decoration: InputDecoration(labelText: key),
                validator: (input) {
                  if (input == null || input.isEmpty) {
                    return 'Please enter a $key';
                  }
                  clothingMap[key] = input;
                  return null;
                },
              ),
            );
          }
        }
      },
    );
  }

  void _buildFeatureChips() {
    featureChips = (clothingMap["features"] as List<dynamic>)
        .map((e) => Chip(
              label: Text(e),
              backgroundColor: Colors.amber,
              onDeleted: () {
                setState(() {
                  (clothingMap["features"] as List<dynamic>).remove(e);
                  _buildFeatureChips();
                });
              },
            ))
        .toList();
  }

  Widget _buildImagePicker() {
    return Builder(builder: (context) {
      if (capturedImage == null) {
        return InkWell(
          onTap: () async {
            capturedImage = await ImageUtils.imageToBase64(
                (await ImageUtils.captureImage(ImageSource.camera))!);
            setState(() {});
          },
          child: const Icon(
            Icons.add_a_photo,
          ),
        );
      } else {
        return Column(
          children: [
            Expanded(
              flex: 20,
              child: Image.memory(base64Decode(capturedImage!)),
            ),
            Expanded(
                child: Row(
              children: [
                Expanded(
                  child: MaterialButton(
                    child: const Text('Autofill from image'),
                    onPressed: () async {
                      clothingMap.addAll(
                          await ApiService.autofillFromImage(capturedImage!));

                      setState(() {
                        _buildFormFields();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: MaterialButton(
                    child: const Text('Pick another'),
                    onPressed: () async {
                      capturedImage = await ImageUtils.imageToBase64(
                          (await ImageUtils.captureImage(ImageSource.camera))!);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ))
          ],
        );
      }
    });
  }

  List<Widget> _buildInputFields() {
    return textFormFields +
        [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Insert a new feature',
            ),
            controller: TextEditingController(text: feature),
            onSubmitted: (value) {
              (clothingMap['features']).add(value);
              setState(() {
                _buildFeatureChips();
              });
              feature = '';
            },
          ),
          Wrap(
            children: featureChips,
          ),
          ExpansionTile(
              leading: SizedBox(
                width: 42.0,
                height: 42.0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: Color(int.parse(clothingMap['color']))),
                ),
              ),
              title: const Text(
                'Pick your color',
              ),
              children: [
                ColorPicker(
                  color: Color(int.parse(clothingMap['color'])),
                  onColorChanged: (color) {
                    setState(() {
                      clothingMap["color"] = '0x${color.hexAlpha}';
                    });
                  },
                ),
              ]),
        ] +
        [
          Row(
            children: [
              MaterialButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Map<String, dynamic> data =
                        Map<String, dynamic>.from(clothingMap);
                    data['image'] = capturedImage;
                    data['color'] = clothingMap['color'];

                    Future<int> response = ApiService.submitClothingItem(data);
                    int itemId = -1;
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
                                  itemId = snapshot.data!;
                                  print(itemId);
                                  return Text(
                                    snapshot.data != null
                                        ? "Item inserted"
                                        : "Error: item not inserted",
                                  );
                                }
                              },
                            ),
                          ),
                        )
                        .closed
                        .then((value) {
                      Navigator.of(context).push(RawDialogRoute(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          {
                            return AlertDialog(
                              title: Text('Insert into drawer?'),
                              actions: [
                                MaterialButton(
                                  onPressed: () {
                                    Navigator.of(context).push(RawDialogRoute(
                                      pageBuilder: (context, animation,
                                          secondaryAnimation) {
                                        {
                                          print(itemId);
                                          return Dialog(
                                            child: DrawerSelectionScreen(
                                              clothingItem: itemId,
                                            ),
                                          );
                                        }
                                      },
                                    )).then(
                                      (value) {
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  },
                                  child: Text('Yes'),
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('No'),
                                ),
                              ],
                            );
                          }
                        },
                      )).then((value) => Navigator.of(context).pop());
                    });
                  }
                },
                child: const Text('Submit'),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('cancel'),
              ),
            ],
          ),
        ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Insert clothing data"),
        titleTextStyle: Theme.of(context).textTheme.displaySmall,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _buildImagePicker(),
                ),
              ),
              Expanded(
                child: ListView(children: _buildInputFields()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
