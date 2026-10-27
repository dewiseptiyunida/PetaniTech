class NominatimModel {
  final int placeId;
  final String licence;
  final String osmType;
  final int osmId;
  final double lat;
  final double lon;
  final String displayName;
  final Address address;
  final List<double> boundingBox;

  NominatimModel({
    required this.placeId,
    required this.licence,
    required this.osmType,
    required this.osmId,
    required this.lat,
    required this.lon,
    required this.displayName,
    required this.address,
    required this.boundingBox,
  });

  factory NominatimModel.fromJson(Map<String, dynamic> json) {
    return NominatimModel(
      placeId: json['place_id'],
      licence: json['licence'],
      osmType: json['osm_type'],
      osmId: json['osm_id'],
      lat: double.parse(json['lat']),
      lon: double.parse(json['lon']),
      displayName: json['display_name'],
      address: Address.fromJson(json['address']),
      boundingBox: List<double>.from(
        (json['boundingbox'] as List).map((e) => double.parse(e)),
      ),
    );
  }
}

class Address {
  final String road;
  final String village;
  final String county;
  final String state;
  final String region;
  final String postcode;
  final String country;
  final String countryCode;

  Address({
    required this.road,
    required this.village,
    required this.county,
    required this.state,
    required this.region,
    required this.postcode,
    required this.country,
    required this.countryCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      road: json['road'] ?? '',
      village: json['village'] ?? '',
      county: json['county'] ?? '',
      state: json['state'] ?? '',
      region: json['region'] ?? '',
      postcode: json['postcode'] ?? '',
      country: json['country'] ?? '',
      countryCode: json['country_code'] ?? '',
    );
  }
}
