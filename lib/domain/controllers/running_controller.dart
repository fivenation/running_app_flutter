import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:running_app_flutter/domain/services/location_service.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';


class RunController with ChangeNotifier {
  // CONSTANTS
  static const double _fixedZoom = 17.0;
  static const animation = MapAnimation(type: MapAnimationType.smooth, duration: 1.0);
  static const MapObjectId _pathId = MapObjectId('pathPolyline');
  static const MapObjectId _posId = MapObjectId('positionMark');
  static const MapObjectId _kmPosId = MapObjectId('kmPositionCollection');

  // CONTROLLERS AND REPOSITORIES
  final LocationService _locationRepository = LocationService();
  late YandexMapController? _controller;
  final timerController = TimerController();

  // CHANGEABLE STATE PARAMS
  final List<Point> _points = [];
  final List<Point> _kmPoints = [];
  final List<Placemark> _placemarkList = [];
  final List<int> _kmTime = [];
  final List<MapObject> _objectsList = [];
  double _length = 0.0;

  // GETTERS
  List<Point> get points => _points;
  List<Point> get kmPoints => _kmPoints;
  List<int> get kmTime => _kmTime;
  double get distance => _length;
  List<MapObject> get mapObjects => _objectsList;

  // OPEN METHODS

  @override
  void dispose() {
    timerController.dispose();
    _controller!.dispose();
    _locationRepository.close();
    super.dispose();
  }

  void onMapCreated(YandexMapController controller) {
    _controller = controller;
    _getPosition();
    _initPolyline();
    _initKmPositionMarks();
    _fetchPosition();
    timerController.start();
  }

  // LOCATION AND DISTANCE CONTROLLING METHODS

  void _fetchPosition() {
    _locationRepository.initLocation();
    _locationRepository.fetchLocation();
    _locationRepository.points.listen((event) async {
      _points.add(event);
      _kmControl();
      _moveCamera(event.latitude, event.longitude);
      _updateMapObjects();
    });
  }

  void _kmControl() async {
    if (points.length > 2) _length += _calculateDistance(points[points.length - 2], points.last);
    if (_length.toInt() / 1000 >= _kmPoints.length) {
      _kmPoints.add(points.last);
      _kmTime.add(timerController.getLastTime);
      final placemark = Placemark(
        mapId: MapObjectId('placemark_'+_kmPoints.length.toString()),
        point: _kmPoints.last,
        opacity: 0.75,
        icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
                image: BitmapDescriptor.fromBytes(await _rawPointPlacemark()))
        ),
      );
      if (_kmPoints.length > 1) _placemarkList.add(placemark);
    }
  }

  void _moveCamera(double lat, double long) {
    _controller?.moveCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
            target: Point(
                latitude: lat,
                longitude: long),
            zoom: _fixedZoom)),
        animation: animation);
  }

  void _getPosition() {
    _locationRepository.getCurrentLocation().then((value) async {
      _points.add(value);
      _initPositionMark();
    });
  }

  // MAP OBJECTS METHODS - FOR INIT AND UPDATE

  void _initPolyline() async {
    if (_objectsList.any((el) => el.mapId == _pathId)) {
      return;
    }
    final polyline = Polyline(
      mapId: _pathId,
      coordinates: points,
      strokeColor: Colors.blue[700]!,
      strokeWidth: 7.5,
    );
    _objectsList.add(polyline);
  }

  void _initPositionMark() async {
    if (_objectsList.any((el) => el.mapId == _posId)) {
      return;
    }
    final placemark = Placemark(
      mapId: _posId,
      point: points.last,
      opacity: 0.75,
      icon: PlacemarkIcon.single(PlacemarkIconStyle(
          image: BitmapDescriptor.fromBytes(await _rawPositionPlacemark())
      )),
    );
    _objectsList.add(placemark);
  }

  void _initKmPositionMarks() async {
    if (_objectsList.any((el) => el.mapId == _kmPoints)) {
      return;
    }
    final kmPointsCollection = ClusterizedPlacemarkCollection(
        mapId: _kmPosId,
        placemarks: [],
        radius: 100,
        minZoom: 20
    );
    _objectsList.add(kmPointsCollection);
  }

  void _updatePolyline() async {
    if (!_objectsList.any((el) => el.mapId == _pathId)) {
      return;
    }
    final polyline = _objectsList.firstWhere((el) => el.mapId == _pathId) as Polyline;
    _objectsList[_objectsList.indexOf(polyline)] = polyline.copyWith(
        coordinates: points,
        strokeWidth: 7.5 + Random().nextInt(100) * 0.0001, // NOT BUG, FEECHA
    );
  }

  void _updatePositionMark() async {
    if (!_objectsList.any((el) => el.mapId == _posId)) {
      return;
    }
    final placemark = _objectsList.firstWhere((el) => el.mapId == _posId) as Placemark;
    _objectsList[_objectsList.indexOf(placemark)] = placemark.copyWith(
      point: points.last,
    );
  }

  void _updateKmPointsCollection() async {
    if (!_objectsList.any((el) => el.mapId == _kmPosId)) {
      return;
    }
    final collection = _objectsList.firstWhere((el) => el.mapId == _kmPosId) as ClusterizedPlacemarkCollection;
    _objectsList[_objectsList.indexOf(collection)] = collection.copyWith(
      placemarks: _placemarkList,
      radius: 100,
      minZoom: 20
    );
  }

  void _updateMapObjects() async {
    _updatePositionMark();
    _updatePolyline();
    _updateKmPointsCollection();
    notifyListeners();
  }

  // DRAWING METHODS FOR PLACE MARKERS

  Future<Uint8List> _rawPositionPlacemark() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(40, 40);
    final fillPaint = Paint()
      ..color = Colors.blue[300]!
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final radius = 20.0;
    final circleOffset = Offset(size.height / 2, size.width / 2);
    canvas.drawCircle(circleOffset, radius, fillPaint);
    canvas.drawCircle(circleOffset, radius, strokePaint);
    final image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
    final pngBytes = await image.toByteData(format: ImageByteFormat.png);
    return pngBytes!.buffer.asUint8List();
  }

  Future<Uint8List> _rawPointPlacemark() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(32, 32);
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final radius = 14.0;
    final circleOffset = Offset(size.height / 2, size.width / 2);
    canvas.drawCircle(circleOffset, radius, fillPaint);
    canvas.drawCircle(circleOffset, radius, strokePaint);
    final image = await recorder.endRecording().toImage(size.width.toInt(), size.height.toInt());
    final pngBytes = await image.toByteData(format: ImageByteFormat.png);
    return pngBytes!.buffer.asUint8List();
  }

  // CALCULATIONS

  double _calculateDistance(Point pointA, Point pointB) {
    const double r = 6363564;
    const double pi = 3.14159265359;
    final lat1 = pointA.latitude * pi / 180;
    final lat2 = pointB.latitude * pi / 180;
    final long1 = pointA.longitude * pi / 180;
    final long2 = pointB.longitude * pi / 180;
    final delta = long2 - long1;

    final y = sqrt(pow(cos(lat2)*sin(delta),2) + pow(cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(delta), 2));
    final x = sin(lat1)*sin(lat2)+cos(lat1)*cos(lat2)*delta;
    final ad = atan2(y,x);
    final dist = ad*r;

    return dist;
  }

}

// TIMER CLASS

class TimerController {
  late Timer _timer;

  final _controller = StreamController<int>();

  Stream<int> get getTime => _controller.stream;
  int get getLastTime => _timer.tick;

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _controller.sink.add(timer.tick);
    });
  }

  void dispose() {
    _timer.cancel();
    _controller.close();
  }
}