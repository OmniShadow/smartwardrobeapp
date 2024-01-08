// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';

import 'package:wardrobe/home/models/clothing_data.dart';

class ClothingItemExpandedTile extends StatelessWidget {
  final ClothingItem clothingItem;

  const ClothingItemExpandedTile({super.key, required this.clothingItem});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(10),
      child: ExpansionTile(
        title: ListTile(
          leading: Image.network(
            clothingItem.image!,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
          title: Text(
            clothingItem.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          trailing: Text(clothingItem.category),
        ),
        children: [
          ListTile(title: Text('Brand: ${clothingItem.brand}')),
          ListTile(title: Text('Size: ${clothingItem.size}')),
          ListTile(title: Text('Material: ${clothingItem.material}')),
          ListTile(title: Text('Features: ${clothingItem.features}')),
          ListTile(title: Text('Season: ${clothingItem.season}')),
          ListTile(title: Text('Sex: ${clothingItem.sex}')),
          ListTile(
              title: Text('Description: ${clothingItem.description ?? ''}')),
          // Add more Text widgets for other fields as needed
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class ClothingItemGridTile extends StatelessWidget {
  final ClothingItem clothingItem;

  const ClothingItemGridTile({super.key, required this.clothingItem});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              clothingItem.name,
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              clothingItem.category,
              style: TextStyle(
                  fontSize: 14.0,
                  color: Theme.of(context).colorScheme.onSecondaryContainer),
            ),
          ),
        ),
        child: Image.network(
          clothingItem.image ??
              '', // Provide a default image URL or handle null
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
