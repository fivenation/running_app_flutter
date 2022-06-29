import 'package:yandex_mapkit/yandex_mapkit.dart';

class Post {
  final String author;
  final String title;
  final String datetime;
  final double distance;
  final int time;
  final List<Point> points;
  final List<Point> kmPoints;
  final List<int> kmTime;

  Post({
    required this.author,
    required this.title,
    required this.datetime,
    required this.distance,
    required this.time,
    required this.points,
    required this.kmPoints,
    required this.kmTime
  });

  Map<String, dynamic> toJson() => {
    'author' : author,
    'title' : title,
    'datetime' : datetime,
    'distance' : distance,
    'time' : time,
    'points' : points.map((e) => e.toJson()).toList(),
    'kmPoints' : kmPoints.map((e) => e.toJson()).toList(),
    'kmTime' : kmTime
  };
}