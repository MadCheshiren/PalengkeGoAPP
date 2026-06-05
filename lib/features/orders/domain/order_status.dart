enum OrderStatus {
  pending('Pending'),
  confirmed('Confirmed'),
  completed('Completed'),
  cancelled('Cancelled');

  const OrderStatus(this.label);

  final String label;
}
