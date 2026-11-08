import '../models/shipping_estimate_model.dart';

class ShippingEstimateRequest {
  final String origin;
  final String destination;

  const ShippingEstimateRequest({
    required this.origin,
    required this.destination,
  });
}

class ShippingEstimateService {
  const ShippingEstimateService();

  // Dummy until a shipping or map API is available in the backend.
  List<ShippingEstimate> estimate(ShippingEstimateRequest request) {
    return const [
      ShippingEstimate(
        serviceName: 'Reguler',
        deliveryWindow: '3–5 hari',
        minimumCost: 9000,
        maximumCost: 15000,
      ),
      ShippingEstimate(
        serviceName: 'Hemat',
        deliveryWindow: '5–8 hari',
        minimumCost: 0,
        maximumCost: 8000,
      ),
    ];
  }
}
