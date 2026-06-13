enum OrderStatus {
  pending('Pending'),
  confirmed('Confirmed'),
  preparing('Preparing'),
  ready('Ready'),
  completed('Completed'),
  cancelled('Cancelled');

  const OrderStatus(this.label);

  final String label;
}
