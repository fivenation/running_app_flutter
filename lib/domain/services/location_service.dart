import 'dart:async';

import 'package:location/location.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class LocationService {
  final Location location = Location();
  late StreamSubscription<LocationData> locationSubscription;

  final _pointsController = StreamController<Point>();
  Stream<Point> get points => _pointsController.stream;
  
  void fetchLocation() {
    locationSubscription = location.onLocationChanged
        .listen((LocationData locationData) {
          _pointsController.sink.add(Point(longitude: locationData.longitude!, latitude: locationData.latitude!));
        });
  }

  void close() async {
    _pointsController.close();
    await locationSubscription.cancel();
    location.enableBackgroundMode(enable: false);
  }

  void initLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionStatus;
    location.enableBackgroundMode(enable: true);

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        throw 'Unable to enable Service';
      }
    }

    _permissionStatus = await location.hasPermission();
    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await location.requestPermission();
      if(_permissionStatus != PermissionStatus.granted) {
        throw 'Unable to enable Permission';
      }
    }
  }

  Future<Point> getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionStatus;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        throw 'Unable to enable Service';
      }
    }

    _permissionStatus = await location.hasPermission();
    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await location.requestPermission();
      if(_permissionStatus != PermissionStatus.granted) {
        throw 'Unable to enable Permission';
      }
    }

    _locationData = await location.getLocation();
    return Point(
        latitude: _locationData.latitude!,
        longitude: _locationData.longitude!
    );
  }
}