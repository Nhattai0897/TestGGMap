import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_map_module/google_map/bloc/map_screen_bloc.dart';
import 'package:google_map_module/google_map/state/google_map_state.dart';
import 'package:google_map_module/utils/animation_custom.dart';
import 'package:google_map_module/utils/drawing_painter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_map_module/config_module/config_images.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GGMapMain extends StatefulWidget {
  GGMapMain({
    Key? key,
  }) : super(key: key);

  @override
  _GGMapMainState createState() => _GGMapMainState();
}

class _GGMapMainState extends State<GGMapMain> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<GGMapBloc>(
      create: (context) => GGMapBloc(),
      child: GGMapPage(),
    );
  }
}

class GGMapPage extends StatefulWidget {
  GGMapPage({Key? key}) : super(key: key);

  @override
  _GGMapPageState createState() => _GGMapPageState();
}

class _GGMapPageState extends State<GGMapPage> {
  late double screenWidth;
  late double screenHeight;
  late GGMapBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<GGMapBloc>(context);
    bloc.initContext(context);
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
          top: false,
          child: BlocBuilder<GGMapBloc, GGMapState>(builder: (context, state) {
            return Stack(children: [
              buildGGMap(state),
              buildGestureFind(state),
              buildFeatureButton(state)
            ]);
          })),
    );
  }

  Widget buildGGMap(GGMapState state) {
    return GoogleMap(
      myLocationEnabled: false,
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      markers: Set<Marker>.of(bloc.markers),
      initialCameraPosition: bloc.initialPosition,
      polygons: state.polygons,
      onMapCreated: (GoogleMapController controller) {
        bloc.mapController = controller;
        bloc.controller.complete(controller);
      },
    );
  }

  Widget buildFeatureButton(GGMapState state) {
    return Column(
      children: [
        const Spacer(),
        Row(
          children: [
            const Spacer(),
            Column(
              children: [
                buildButtonFrame(
                    function: bloc.currentLocation,
                    icon: Icon(
                      Icons.my_location_rounded,
                      color: Colors.grey,
                      size: 27.0,
                    )),
                buildButtonFrame(
                    function: () {},
                    icon: Icon(
                      Icons.list,
                      color: Colors.grey,
                      size: 27.0,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15.0)),
              ],
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              buildButtonFrame(
                  function: () => bloc.handleBottomLst(false),
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.grey,
                    size: 27.0,
                  )),
              const Spacer(),
              buildButtonFrame(
                  function: () => bloc.handleBottomLst(true),
                  icon: Icon(Icons.search, color: Colors.white70, size: 29.0),
                  fillColor: Color.fromRGBO(1, 78, 129, 1))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: AnimatedClipRect(
              open: state.isOpenBottomLst,
              horizontalAnimation: false,
              verticalAnimation: true,
              alignment: Alignment.center,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              reverseCurve: Curves.easeOut,
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(0),
                child: state.findPlaceLst.length != 0
                    ? CarouselSlider.builder(
                        carouselController: bloc.listScrollController,
                        itemCount: state.findPlaceLst.length,
                        itemBuilder: (context, index, pageViewIndex) {
                          var placeInfo = state.findPlaceLst[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          width: screenWidth * 0.90,
                                          child: Image.asset(
                                              ConfigImages.committeeImage ?? '',
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 6.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('${placeInfo.price} tỷ',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.green,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('${placeInfo.acreage}m',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.normal)),
                                                Text(placeInfo.address ?? "",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.normal)),
                                              ],
                                            ),
                                            Row(children: [
                                              Spacer(),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 4, top: 2),
                                                child: Text('Xem chi tiết',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.blue[600],
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        fontWeight:
                                                            FontWeight.normal)),
                                              )
                                            ])
                                          ],
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                          );
                        },
                        options: CarouselOptions(
                            reverse: false,
                            disableCenter: true,
                            aspectRatio: 2,
                            enableInfiniteScroll: false,
                            enlargeCenterPage: false,
                            viewportFraction:
                                state.findPlaceLst.length == 1 ? 0.90 : 0.87,
                            height: screenHeight / 4.5,
                            onPageChanged: (index, reason) =>
                                bloc.moveTolpcation(
                                    state.findPlaceLst[index].location!)),
                      )
                    : Container(
                        color: Colors.white,
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            "Property information not found!",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        )),
                      ),
              )),
        ),
      ],
    );
  }

  Widget buildGestureFind(GGMapState state) {
    return GestureDetector(
        onPanUpdate: (details) {
          RenderBox renderBox = context.findRenderObject() as RenderBox;
          bloc.addOffset(details.globalPosition);
          bloc.addPoint(DrawingPoints(
              points: renderBox.globalToLocal(details.globalPosition),
              paint: Paint()
                ..strokeCap = bloc.strokeCap
                ..isAntiAlias = true
                ..color = bloc.selectedColor.withOpacity(bloc.opacity)
                ..strokeWidth = bloc.strokeWidth));
        },
        onPanStart: (details) {
          bloc.clearPolygon();
          bloc.clearOffset();
          RenderBox renderBox = context.findRenderObject() as RenderBox;
          bloc.addOffset(details.globalPosition);
          bloc.addPoint(DrawingPoints(
              points: renderBox.globalToLocal(details.globalPosition),
              paint: Paint()
                ..strokeCap = bloc.strokeCap
                ..isAntiAlias = true
                ..color = bloc.selectedColor.withOpacity(bloc.opacity)
                ..strokeWidth = bloc.strokeWidth));
        },
        onPanEnd: (details) async {
          bloc.addPoint(state.points[0]);
          await bloc.buildPolygon(state.offsetLst);
          bloc.clearPoint();
        },
        child: CustomPaint(
            size: Size.infinite,
            painter: DrawingPainter(pointsList: state.points)));
  }

  Padding buildButtonFrame(
      {Function()? function,
      required Icon icon,
      Color? fillColor,
      EdgeInsetsGeometry? padding}) {
    return Padding(
      padding: padding ?? EdgeInsets.all(0.0),
      child: RawMaterialButton(
        onPressed: function,
        elevation: 5.0,
        fillColor: fillColor ?? Colors.white,
        child: icon,
        padding: EdgeInsets.all(10.0),
        shape: CircleBorder(),
      ),
    );
  }
}
