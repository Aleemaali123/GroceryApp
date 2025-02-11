import 'package:flutter/material.dart';

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
  other
}


class CategoryModel {
  final String title;
  final Color color;

  CategoryModel(this.title, this.color);
}