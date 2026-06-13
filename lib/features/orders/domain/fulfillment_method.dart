enum FulfillmentMethod {
  delivery('Delivery'),
  pickup('Pick-up');

  const FulfillmentMethod(this.label);
  final String label;
}
