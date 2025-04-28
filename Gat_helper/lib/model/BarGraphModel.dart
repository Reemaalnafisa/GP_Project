
import 'package:flutter/material.dart';


class BarGraphModel {
  final String label;
  final Color color;
  final List<GraphModel> graph;

  const BarGraphModel(
      {required this.label, required this.color, required this.graph});
}
class GraphModel {
  final double x;
  final double y;

  const GraphModel({required this.x, required this.y});
}