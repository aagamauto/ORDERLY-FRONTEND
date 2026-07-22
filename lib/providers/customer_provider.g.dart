// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(customerList)
final customerListProvider = CustomerListProvider._();

final class CustomerListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CustomerModel>>,
          List<CustomerModel>,
          FutureOr<List<CustomerModel>>
        >
    with
        $FutureModifier<List<CustomerModel>>,
        $FutureProvider<List<CustomerModel>> {
  CustomerListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'customerListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customerListHash();

  @$internal
  @override
  $FutureProviderElement<List<CustomerModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CustomerModel>> create(Ref ref) {
    return customerList(ref);
  }
}

String _$customerListHash() => r'9ee71d7cada2662440c232b8c4053f60474f635c';

/// Only customers flagged as defaulters.

@ProviderFor(defaulterList)
final defaulterListProvider = DefaulterListProvider._();

/// Only customers flagged as defaulters.

final class DefaulterListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CustomerModel>>,
          List<CustomerModel>,
          FutureOr<List<CustomerModel>>
        >
    with
        $FutureModifier<List<CustomerModel>>,
        $FutureProvider<List<CustomerModel>> {
  /// Only customers flagged as defaulters.
  DefaulterListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'defaulterListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$defaulterListHash();

  @$internal
  @override
  $FutureProviderElement<List<CustomerModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CustomerModel>> create(Ref ref) {
    return defaulterList(ref);
  }
}

String _$defaulterListHash() => r'9c1410f5e2b92b6fa332e45839990896da319b6f';

@ProviderFor(customerById)
final customerByIdProvider = CustomerByIdFamily._();

final class CustomerByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<CustomerModel>,
          CustomerModel,
          FutureOr<CustomerModel>
        >
    with $FutureModifier<CustomerModel>, $FutureProvider<CustomerModel> {
  CustomerByIdProvider._({
    required CustomerByIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'customerByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customerByIdHash();

  @override
  String toString() {
    return r'customerByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CustomerModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CustomerModel> create(Ref ref) {
    final argument = this.argument as int;
    return customerById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerByIdHash() => r'e21410ba7ca481d569d4c2e9d12ce2f241e6d710';

final class CustomerByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CustomerModel>, int> {
  CustomerByIdFamily._()
    : super(
        retry: null,
        name: r'customerByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomerByIdProvider call(int custId) =>
      CustomerByIdProvider._(argument: custId, from: this);

  @override
  String toString() => r'customerByIdProvider';
}

@ProviderFor(customerOrders)
final customerOrdersProvider = CustomerOrdersFamily._();

final class CustomerOrdersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CustomerOrderSummary>>,
          List<CustomerOrderSummary>,
          FutureOr<List<CustomerOrderSummary>>
        >
    with
        $FutureModifier<List<CustomerOrderSummary>>,
        $FutureProvider<List<CustomerOrderSummary>> {
  CustomerOrdersProvider._({
    required CustomerOrdersFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'customerOrdersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customerOrdersHash();

  @override
  String toString() {
    return r'customerOrdersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CustomerOrderSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CustomerOrderSummary>> create(Ref ref) {
    final argument = this.argument as int;
    return customerOrders(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerOrdersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerOrdersHash() => r'c62df3b6cc1c83a0d431f42a3a36281a8f49df05';

final class CustomerOrdersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CustomerOrderSummary>>, int> {
  CustomerOrdersFamily._()
    : super(
        retry: null,
        name: r'customerOrdersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomerOrdersProvider call(int custId) =>
      CustomerOrdersProvider._(argument: custId, from: this);

  @override
  String toString() => r'customerOrdersProvider';
}

@ProviderFor(customerOrderDetail)
final customerOrderDetailProvider = CustomerOrderDetailFamily._();

final class CustomerOrderDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<OrderDetail>,
          OrderDetail,
          FutureOr<OrderDetail>
        >
    with $FutureModifier<OrderDetail>, $FutureProvider<OrderDetail> {
  CustomerOrderDetailProvider._({
    required CustomerOrderDetailFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'customerOrderDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customerOrderDetailHash();

  @override
  String toString() {
    return r'customerOrderDetailProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<OrderDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OrderDetail> create(Ref ref) {
    final argument = this.argument as (int, int);
    return customerOrderDetail(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerOrderDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerOrderDetailHash() =>
    r'5635c5371272cf8d0bfc6bfc7eae759ec5360640';

final class CustomerOrderDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<OrderDetail>, (int, int)> {
  CustomerOrderDetailFamily._()
    : super(
        retry: null,
        name: r'customerOrderDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomerOrderDetailProvider call(int custId, int orderId) =>
      CustomerOrderDetailProvider._(argument: (custId, orderId), from: this);

  @override
  String toString() => r'customerOrderDetailProvider';
}
