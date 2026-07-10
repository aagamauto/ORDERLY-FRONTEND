import 'package:flutter/material.dart';

import 'format_utils.dart';

/// Canonical order statuses — these strings MUST match the backend
/// db_models constants (STATUS_ORDERED, STATUS_PACKED, ...).
const String kStatusOrdered = 'Ordered';
const String kStatusPacked = 'Packed';
const String kStatusDispatched = 'Dispatched';
const String kStatusPartial = 'Partially Dispatched';

bool isDispatchedStatus(String s) =>
    s == kStatusDispatched || s == kStatusPartial;
bool isPackedStatus(String s) => s == kStatusPacked;

/// Visual style (label + colour + icon) for an order status chip/badge.
class OrderStatusStyle {
  const OrderStatusStyle(this.label, this.color, this.icon);
  final String label;
  final MaterialColor color;
  final IconData icon;
}

OrderStatusStyle orderStatusStyle(String status) {
  switch (status) {
    case kStatusPacked:
      return const OrderStatusStyle(
          'Packed', Colors.blue, Icons.inventory_2_outlined);
    case kStatusDispatched:
      return const OrderStatusStyle(
          'Dispatched', Colors.green, Icons.local_shipping_outlined);
    case kStatusPartial:
      return const OrderStatusStyle('Partially Dispatched', Colors.teal,
          Icons.local_shipping_outlined);
    case kStatusOrdered:
    default:
      return const OrderStatusStyle(
          'Ordered', Colors.amber, Icons.pending_outlined);
  }
}

/// Formats a rupee value with Indian digit grouping, dropping a trailing `.0`.
String formatMoney(num? v) {
  if (v == null) return '—';
  final d = v.toDouble();
  return d == d.roundToDouble()
      ? '₹${groupIndian(d.toInt())}'
      : '₹${d.toStringAsFixed(2)}';
}
