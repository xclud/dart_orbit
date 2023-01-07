import 'package:example/utils/tile_servers.dart';

abstract class MapStyle {
  const MapStyle({
    required this.name,
    this.minZoom = 2,
    this.maxZoom = 18,
  });

  final String name;
  final int minZoom;
  final int maxZoom;

  const factory MapStyle.google() = Google._;

  String url(int z, int x, int y);
}

class Google extends MapStyle {
  const Google._() : super(name: 'Google');

  @override
  String url(int z, int x, int y) {
    return google(z, x, y);
  }
}

const mapStyles = [
  MapStyle.google(),
];
