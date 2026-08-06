import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'label')
enum PaymentStatus {
  pending('Pending'),
  paid('Paid'),
  failed('Failed');

  const PaymentStatus(this.label);
  final String label;
}
