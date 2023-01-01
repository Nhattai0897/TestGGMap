import 'package:flutter/material.dart';
import 'package:google_map_module/utils/drawing_painter.dart';
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GGMapState {
  List<PlaceModel> findPlaceLst;
  List<DrawingPoints> points = [];
  List<Offset> offsetLst;
  Set<Polygon> polygons;
  bool isOpenBottomLst;
  GGMapState(
      {required this.findPlaceLst,
      required this.points,
      required this.offsetLst,
      required this.polygons,
      required this.isOpenBottomLst});
  GGMapState copyWith(
      {List<PlaceModel>? findPlaceLst,
      List<DrawingPoints>? points,
      List<Offset>? offsetLst,
      Set<Polygon>? polygons,
      bool? isOpenBottomLst}) {
    return GGMapState(
        points: points ?? this.points,
        offsetLst: offsetLst ?? this.offsetLst,
        polygons: polygons ?? this.polygons,
        isOpenBottomLst: isOpenBottomLst ?? this.isOpenBottomLst,
        findPlaceLst: findPlaceLst ?? this.findPlaceLst);
  }
}

class PlaceModel {
  LatLng? location;
  double? price;
  double? acreage;
  String? address;

  PlaceModel({this.location, this.price, this.acreage, this.address});
}
