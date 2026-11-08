class ShippingEstimate {
  final String serviceName;
  final String deliveryWindow;
  final int minimumCost;
  final int maximumCost;

  const ShippingEstimate({
    required this.serviceName,
    required this.deliveryWindow,
    required this.minimumCost,
    required this.maximumCost,
  });
}
