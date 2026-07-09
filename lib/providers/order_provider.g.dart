// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(orderList)
final orderListProvider = OrderListProvider._();

final class OrderListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OrderSummary>>,
          List<OrderSummary>,
          FutureOr<List<OrderSummary>>
        >
    with
        $FutureModifier<List<OrderSummary>>,
        $FutureProvider<List<OrderSummary>> {
  OrderListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderListHash();

  @$internal
  @override
  $FutureProviderElement<List<OrderSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<OrderSummary>> create(Ref ref) {
    return orderList(ref);
  }
}

String _$orderListHash() => r'ea6cdc393ee62ca8d70eceee477cf432be265a0a';

@ProviderFor(orderDetail)
final orderDetailProvider = OrderDetailFamily._();

final class OrderDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<OrderDetail>,
          OrderDetail,
          FutureOr<OrderDetail>
        >
    with $FutureModifier<OrderDetail>, $FutureProvider<OrderDetail> {
  OrderDetailProvider._({
    required OrderDetailFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'orderDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderDetailHash();

  @override
  String toString() {
    return r'orderDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<OrderDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OrderDetail> create(Ref ref) {
    final argument = this.argument as int;
    return orderDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderDetailHash() => r'565ebafdc7da240d130b9d743b90b4be5c60f86b';

final class OrderDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<OrderDetail>, int> {
  OrderDetailFamily._()
    : super(
        retry: null,
        name: r'orderDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OrderDetailProvider call(int orderId) =>
      OrderDetailProvider._(argument: orderId, from: this);

  @override
  String toString() => r'orderDetailProvider';
}

@ProviderFor(orderPreload)
final orderPreloadProvider = OrderPreloadProvider._();

final class OrderPreloadProvider
    extends
        $FunctionalProvider<
          AsyncValue<OrderPreload>,
          OrderPreload,
          FutureOr<OrderPreload>
        >
    with $FutureModifier<OrderPreload>, $FutureProvider<OrderPreload> {
  OrderPreloadProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderPreloadProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderPreloadHash();

  @$internal
  @override
  $FutureProviderElement<OrderPreload> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OrderPreload> create(Ref ref) {
    return orderPreload(ref);
  }
}

String _$orderPreloadHash() => r'b6bf3a89f5d384a694f20ff9606aef7e23756687';

/// Current user's own orders — GET /User/Me/Orders (Employee / Salesman)

@ProviderFor(myOrderList)
final myOrderListProvider = MyOrderListProvider._();

/// Current user's own orders — GET /User/Me/Orders (Employee / Salesman)

final class MyOrderListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OrderSummary>>,
          List<OrderSummary>,
          FutureOr<List<OrderSummary>>
        >
    with
        $FutureModifier<List<OrderSummary>>,
        $FutureProvider<List<OrderSummary>> {
  /// Current user's own orders — GET /User/Me/Orders (Employee / Salesman)
  MyOrderListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myOrderListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myOrderListHash();

  @$internal
  @override
  $FutureProviderElement<List<OrderSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<OrderSummary>> create(Ref ref) {
    return myOrderList(ref);
  }
}

String _$myOrderListHash() => r'cbe14ac65f5217475014de535e5c609b93c88491';

/// Dispatch queue — orders still needing action (Ordered + Packed), oldest
/// first. Employee/Admin only — GET /Orders/queue/

@ProviderFor(dispatchQueue)
final dispatchQueueProvider = DispatchQueueProvider._();

/// Dispatch queue — orders still needing action (Ordered + Packed), oldest
/// first. Employee/Admin only — GET /Orders/queue/

final class DispatchQueueProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<QueueOrder>>,
          List<QueueOrder>,
          FutureOr<List<QueueOrder>>
        >
    with $FutureModifier<List<QueueOrder>>, $FutureProvider<List<QueueOrder>> {
  /// Dispatch queue — orders still needing action (Ordered + Packed), oldest
  /// first. Employee/Admin only — GET /Orders/queue/
  DispatchQueueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dispatchQueueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dispatchQueueHash();

  @$internal
  @override
  $FutureProviderElement<List<QueueOrder>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<QueueOrder>> create(Ref ref) {
    return dispatchQueue(ref);
  }
}

String _$dispatchQueueHash() => r'1d8f239851e2d7474c7b662201f556b078f6b052';
