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


class Category {
  final String title;
  final Color color;

  Category(this.title, this.color);
}