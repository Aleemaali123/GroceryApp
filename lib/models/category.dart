import 'package:flutter/material.dart';


//enum means  fixed and predefined..
enum Categories{
  vegitables,
  fruit,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  convenience,
  hygine,
  other, vegetables
}


class CategoryModel {
  final String title;
  final Color color;

  CategoryModel(this.title, this.color);
}