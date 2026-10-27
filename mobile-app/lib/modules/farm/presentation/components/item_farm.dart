import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:latlong2/latlong.dart';

class ItemFarm extends StatelessWidget {
  final String title;
  final String address;
  final String size;
  final String unit;
  final List<LatLng> polygon;

  const ItemFarm({
    super.key,
    required this.title,
    required this.address,
    required this.size,
    required this.unit,
    required this.polygon,
  });

  @override
  Widget build(BuildContext context) {
    final MapController controller = MapController();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey[400]!, width: 1),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(2.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FlutterMap(
                  mapController: controller,
                  options: MapOptions(
                    initialCenter:
                        polygon.length >= 3
                            ? FlutterMapMath().midpointBetween(
                              polygon[2],
                              polygon[0],
                            )
                            : (polygon.isNotEmpty ? polygon[0] : const LatLng(-6.2088, 106.8456)),
                    initialZoom: 17,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "http://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}",
                      subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
                    ),
                    if (polygon.isNotEmpty)
                      PolygonLayer(
                        polygons: [
                          Polygon(
                            points: polygon,
                            color: const Color(0xFFE0FF15).withAlpha(100),
                            borderStrokeWidth: 3,
                            borderColor: const Color(0xFFE0FF15),
                            strokeCap: StrokeCap.round,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 11,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.square_foot,
                        size: 11,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: 4),
                      Text(
                        '$size $unit',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//         ItemFarm(
//           title: 'Lahan Kongsijaya',
//           polygon: [
//             LatLng(-6.462905, 108.286173),
//             LatLng(-6.462281, 108.287255),
//             LatLng(-6.462379, 108.287299),
//             LatLng(-6.462983, 108.286232),
//           ],
//         ),
