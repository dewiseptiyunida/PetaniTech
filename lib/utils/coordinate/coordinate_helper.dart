import 'package:latlong2/latlong.dart';

class CoordinateHelper {
  static List<LatLng> convertToLatLng(List<List<double>> coordinates) {
    return coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
  }
}
