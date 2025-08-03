// lib/core/widgets/responsive_builder.dart

import 'package:flutter/material.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget portrait;
  final Widget landscape;

  const ResponsiveBuilder({
    super.key,
    required this.portrait,
    required this.landscape,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait ? portrait : landscape;
  }
}