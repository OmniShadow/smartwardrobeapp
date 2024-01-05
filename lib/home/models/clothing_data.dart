// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';

class ClothingItem {
  int id;
  String color;
  String name;
  String? brand;
  String category;
  String size;
  String? material;
  List<String> features;
  String? image;
  String season;
  String sex;
  String? description;

  ClothingItem({
    required this.id,
    required this.color,
    required this.name,
    this.brand,
    required this.category,
    required this.size,
    this.material,
    required this.features,
    this.image,
    required this.season,
    required this.sex,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'color': color,
      'name': name,
      'brand': brand,
      'category': category,
      'size': size,
      'material': material,
      'features': features,
      'image': image,
      'season': season,
      'sex': sex,
      'description': description,
    };
  }

  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'] as int,
      color: map['color'] as String,
      name: map['name'] as String,
      brand: map['brand'] != null ? map['brand'] as String : "",
      category: map['category'] as String,
      size: map['size'] as String,
      material: map['material'] != null ? map['material'] as String : "",
      features: (map['features'] as List).map((e) => e as String).toList(),
      image: map['image'] != null ? map['image'] as String : "",
      season: map['season'] as String,
      sex: map['sex'] as String,
      description:
          map['description'] != null ? map['description'] as String : "",
    );
  }

  String toJson() => json.encode(toMap());

  factory ClothingItem.fromJson(String source) =>
      ClothingItem.fromMap(json.decode(source) as Map<String, dynamic>);

  ClothingItem copyWith({
    int? id,
    String? color,
    String? name,
    String? brand,
    String? category,
    String? size,
    String? material,
    List<String>? features,
    String? image,
    String? season,
    String? sex,
    String? description,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      color: color ?? this.color,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      size: size ?? this.size,
      material: material ?? this.material,
      features: features ?? this.features,
      image: image ?? this.image,
      season: season ?? this.season,
      sex: sex ?? this.sex,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'ClothingItem(id: $id, color: $color, name: $name, brand: $brand, category: $category, size: $size, material: $material, features: $features, image: $image, season: $season, sex: $sex, description: $description)';
  }

  @override
  bool operator ==(covariant ClothingItem other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.color == color &&
        other.name == name &&
        other.brand == brand &&
        other.category == category &&
        other.size == size &&
        other.material == material &&
        listEquals(other.features, features) &&
        other.image == image &&
        other.season == season &&
        other.sex == sex &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        color.hashCode ^
        name.hashCode ^
        brand.hashCode ^
        category.hashCode ^
        size.hashCode ^
        material.hashCode ^
        features.hashCode ^
        image.hashCode ^
        season.hashCode ^
        sex.hashCode ^
        description.hashCode;
  }
}

class Outfit {
  int id;
  String name;
  List<ClothingItem> components;
  String occasion;
  String image;
  Outfit({
    required this.id,
    required this.name,
    required this.components,
    required this.occasion,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'components': components.map((x) => x.toMap()).toList(),
      'occasion': occasion,
      'image': image,
    };
  }

  factory Outfit.fromMap(Map<String, dynamic> map) {
    return Outfit(
      id: map['id'] as int,
      name: map['name'] as String,
      components: List<ClothingItem>.from(
        (map['components'] as List<int>).map<ClothingItem>(
          (x) => ClothingItem.fromMap(x as Map<String, dynamic>),
        ),
      ),
      occasion: map['occasion'] as String,
      image: map['image'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Outfit.fromJson(String source) =>
      Outfit.fromMap(json.decode(source) as Map<String, dynamic>);

  Outfit copyWith({
    int? id,
    String? name,
    List<ClothingItem>? components,
    String? occasion,
    String? image,
  }) {
    return Outfit(
      id: id ?? this.id,
      name: name ?? this.name,
      components: components ?? this.components,
      occasion: occasion ?? this.occasion,
      image: image ?? this.image,
    );
  }

  @override
  String toString() {
    return 'Outfit(id: $id, name: $name, components: $components, occasion: $occasion, image: $image)';
  }

  @override
  bool operator ==(covariant Outfit other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        listEquals(other.components, components) &&
        other.occasion == occasion &&
        other.image == image;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        components.hashCode ^
        occasion.hashCode ^
        image.hashCode;
  }
}
