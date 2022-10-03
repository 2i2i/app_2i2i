import 'package:flutter/material.dart';

class FAQDataModel {
  const FAQDataModel({
    required this.title,
    this.description,
    this.descriptionTextSpan,
    this.tags,
  });

  final String title;
  final TextSpan? descriptionTextSpan;
  final String? description;
  final List<String>? tags;
}
