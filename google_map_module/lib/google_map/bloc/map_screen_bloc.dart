import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_map_module/config_module/config_images.dart';
import 'package:google_map_module/google_map/state/google_map_state.dart';
import 'package:google_map_module/utils/drawing_painter.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class GGMapBloc extends Cubit<GGMapState> {
  late BuildContext mainContext;
  late BitmapDescriptor makerIcon;
  late BitmapDescriptor makerCurrentIcon;
  Color selectedColor = Colors.blue;
  double strokeWidth = 3.0;
  List<Offset> offsetLst = [];
  bool showBottomList = false;
  double opacity = 1.0;
  final CarouselController listScrollController = CarouselController();
  Map<MarkerId, Marker> listMarkers = <MarkerId, Marker>{};
  StrokeCap strokeCap = (Platform.isAndroid) ? StrokeCap.butt : StrokeCap.round;
  late GoogleMapController mapController;
  final Completer<GoogleMapController> controller = Completer();
  final CameraPosition initialPosition = CameraPosition(
    target: LatLng(10.776539913085681, 106.70099345538269),
    zoom: 14.4746,
  );
  Set<Marker> markers = new Set();
  bool open = false;
  List<PlaceModel> placeLst = [];
  List<PlaceModel> findPlaceLstTemp = [];

  GGMapBloc()
      : super(GGMapState(
            points: [],
            offsetLst: [],
            findPlaceLst: [],
            isOpenBottomLst: false,
            polygons: HashSet<Polygon>()));

  void initContext(BuildContext context) {
    this.mainContext = context;
    getIcons();
    getPLaceList();
  }

  void getPLaceList() {
    placeLst = [
      PlaceModel(
          location: LatLng(10.787711703810505, 106.70528498883685),
          acreage: 125.5,
          address: 'Quận 1 TPHCM',
          price: 8),
      PlaceModel(
          location: LatLng(10.783200879714286, 106.6936120162831),
          acreage: 110.8,
          address: 'Quận 2 TPHCM',
          price: 11.5),
      PlaceModel(
          location: LatLng(10.77999688873303, 106.70206633840382),
          acreage: 120,
          address: 'Quận 3 TPHCM',
          price: 10.1),
      PlaceModel(
          location: LatLng(10.776877180594791, 106.69708815893236),
          acreage: 120.8,
          address: 'Quận Phú Nhuận TPHCM',
          price: 10),
      PlaceModel(
          location: LatLng(10.773546645682693, 106.69296828626634),
          acreage: 111.7,
          address: 'Quận 7 TPHCM',
          price: 15),
      PlaceModel(
          location: LatLng(10.769710160974897, 106.6938265930876),
          acreage: 233,
          address: 'Quận Tân Phú TPHCM',
          price: 14),
      PlaceModel(
          location: LatLng(10.768656173130678, 106.70313922192643),
          acreage: 120.9,
          address: 'Quận Bình Chánh TPHCM',
          price: 10.8),
      PlaceModel(
          location: LatLng(10.761615439756318, 106.69313994764327),
          acreage: 120,
          address: 'Quận 1 TPHCM',
          price: 12),
      PlaceModel(
          location: LatLng(10.766590346259312, 106.70640078778706),
          acreage: 124,
          address: 'Quận Thủ Đức TPHCM',
          price: 13.9),
      PlaceModel(
          location: LatLng(10.754405895526816, 106.69854728047774),
          acreage: 145.6,
          address: 'Quận Nhà Bè TPHCM',
          price: 14),
      PlaceModel(
          location: LatLng(10.787711703810505, 106.70528498883685),
          acreage: 120,
          address: 'Quận Hóc Môn TPHCM',
          price: 10),
      PlaceModel(
          location: LatLng(10.762753772933207, 106.68829051415295),
          acreage: 129.8,
          address: 'Huyện Củ Chi TPHCM',
          price: 110.8),
    ];
  }

  void addPoint(DrawingPoints drawingPoints) {
    var newLst = state.points;
    newLst.add(drawingPoints);
    emit(state.copyWith(points: newLst));
  }

  void clearPoint() => emit(state.copyWith(points: []));

  void clearOffset() => emit(state.copyWith(offsetLst: []));

  void addOffset(Offset offset) {
    var newLst = state.offsetLst;
    newLst.add(offset);
    emit(state.copyWith(offsetLst: newLst));
  }

  void moveTolpcation(LatLng latLng) =>
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: latLng,
        zoom: 14,
      )));

  void toast({required String title, int? time}) {
    ScaffoldMessenger.of(this.mainContext).showSnackBar(SnackBar(
        content: Text(title),
        backgroundColor: Colors.blue,
        duration: Duration(milliseconds: time ?? 500)));
  }

  void clearPolygon() {
    var polygon = state.polygons;
    polygon.clear();
    emit(state.copyWith(polygons: polygon));
  }

  void handleBottomLst(bool isOpen) {
    clearPolygon();
    clearPoint();
    clearOffset();
    markers.clear();
    emit(state.copyWith(isOpenBottomLst: isOpen));
    if (isOpen) {
      toast(
          title:
              "Please use the default set position to test the polygon feature",
          time: 1000);
      mapController
          .animateCamera(CameraUpdate.newCameraPosition(initialPosition));
    }
  }

  void getIcons() async {
    final Uint8List markerIcon = await getBytesFromAsset(
        ConfigImages.realtyMarker ?? '', Platform.isAndroid ? 80 : 105);
    this.makerIcon = BitmapDescriptor.fromBytes(markerIcon);

    final Uint8List currentIcon = await getBytesFromAsset(
        ConfigImages.myLocationMaker ?? '', Platform.isAndroid ? 80 : 105);
    this.makerCurrentIcon = BitmapDescriptor.fromBytes(currentIcon);
  }

  void currentLocation() {
    getUserCurrentLocation().then((value) async {
      CameraPosition cameraPosition = new CameraPosition(
        target: LatLng(value.latitude, value.longitude),
        zoom: 14,
      );
      markers.add(Marker(
          markerId: MarkerId("1"),
          position: LatLng(value.latitude, value.longitude),
          icon: makerCurrentIcon));

      await mapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      toast(
          title:
              "Your current location: ${value.latitude} , ${value.longitude}",
          time: 1000);
      emit(state.copyWith(isOpenBottomLst: false));
    });
  }

  Future<Position> getUserCurrentLocation() async {
    if (await Permission.location.serviceStatus.isEnabled) {
      return Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
    } else {
      final status = await Permission.location.request();
      if (status.isGranted) {
        return Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
      } else {
        toast(title: "Property location not found");
        return Future.error('Location access denied');
      }
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> buildPolygon(List<Offset> shape) async {
    final List<LatLng> points = <LatLng>[];
    final devicePixelRatio = MediaQuery.of(this.mainContext).devicePixelRatio;
    await Future.forEach(shape, (Offset offset) async {
      LatLng point = await mapController.getLatLng(ScreenCoordinate(
          x: (offset.dx * devicePixelRatio).round(),
          y: (offset.dy * devicePixelRatio).round()));
      points.add(point);
    });
    var polygon = state.polygons;
    polygon.add(
      Polygon(
        fillColor: Colors.black.withOpacity(0.5),
        polygonId: const PolygonId('polygons'),
        holes: [if (points.length != 0) points],
        points: const [
          LatLng(-89, 0),
          LatLng(89, 0),
          LatLng(89, 179.999),
          LatLng(-89, 179.999),
        ],
        visible: true,
        geodesic: false,
        strokeWidth: 0,
      ),
    );
    polygon.add(
      Polygon(
        fillColor: Colors.black.withOpacity(0.5),
        polygonId: const PolygonId('polygons1'),
        points: const [
          LatLng(-89.9, 0),
          LatLng(89.9, 0),
          LatLng(89.9, -179.999),
          LatLng(-89.9, -179.999),
        ],
        visible: true,
        geodesic: false,
        strokeWidth: 0,
      ),
    );
    if (points.length != 0) {
      polygon.add(
        Polygon(
          fillColor: Colors.transparent,
          strokeColor: Colors.transparent,
          polygonId: const PolygonId('polygons2'),
          points: points,
          visible: true,
          geodesic: false,
          strokeWidth: 2,
        ),
      );
    }
    markers.clear();
    findPlaceLstTemp.clear();
    for (var i = 0; i < placeLst.length; i++) {
      if (_checkIfValidMarker(placeLst[i].location!, points)) {
        findPlaceLstTemp.add(placeLst[i]);
        markers.add(
          Marker(
              markerId: MarkerId(i.toString()),
              position: placeLst[i].location!,
              icon: makerIcon),
        );
      }
    }
    if (findPlaceLstTemp.length == 0) {
      toast(title: "Property location not found");
    }
    emit(state.copyWith(
        polygons: polygon,
        isOpenBottomLst: findPlaceLstTemp.length != 0,
        findPlaceLst: findPlaceLstTemp));
  }

  //////// Utils ////////
  bool _checkIfValidMarker(LatLng tap, List<LatLng> vertices) {
    int intersectCount = 0;
    for (int j = 0; j < vertices.length - 1; j++) {
      if (rayCastIntersect(tap, vertices[j], vertices[j + 1])) {
        intersectCount++;
      }
    }

    return ((intersectCount % 2) == 1); // odd = inside, even = outside;
  }

  bool rayCastIntersect(LatLng tap, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = tap.latitude;
    double pX = tap.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false; // a and b can't both be above or below pt.y, and a or
      // b must be east of pt.x
    }

    double m = (aY - bY) / (aX - bX); // Rise over run
    double bee = (-aX) * m + aY; // y = mx + b
    double x = (pY - bee) / m; // algebra is neat!

    return x > pX;
  }

  void dispose() {
    mapController.dispose();
  }
}
