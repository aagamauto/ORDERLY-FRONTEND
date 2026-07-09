// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(paymentList)
final paymentListProvider = PaymentListProvider._();

final class PaymentListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaymentWithCustomer>>,
          List<PaymentWithCustomer>,
          FutureOr<List<PaymentWithCustomer>>
        >
    with
        $FutureModifier<List<PaymentWithCustomer>>,
        $FutureProvider<List<PaymentWithCustomer>> {
  PaymentListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentListHash();

  @$internal
  @override
  $FutureProviderElement<List<PaymentWithCustomer>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaymentWithCustomer>> create(Ref ref) {
    return paymentList(ref);
  }
}

String _$paymentListHash() => r'eb4fe8b80766985c3fc53f7bebc603f93d6cb15e';

@ProviderFor(customerPayments)
final customerPaymentsProvider = CustomerPaymentsFamily._();

final class CustomerPaymentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaymentWithCustomer>>,
          List<PaymentWithCustomer>,
          FutureOr<List<PaymentWithCustomer>>
        >
    with
        $FutureModifier<List<PaymentWithCustomer>>,
        $FutureProvider<List<PaymentWithCustomer>> {
  CustomerPaymentsProvider._({
    required CustomerPaymentsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'customerPaymentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customerPaymentsHash();

  @override
  String toString() {
    return r'customerPaymentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PaymentWithCustomer>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaymentWithCustomer>> create(Ref ref) {
    final argument = this.argument as int;
    return customerPayments(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerPaymentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerPaymentsHash() => r'f4c19e31ad4f9cea5c9e0b1bcdac4857a92be780';

final class CustomerPaymentsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PaymentWithCustomer>>, int> {
  CustomerPaymentsFamily._()
    : super(
        retry: null,
        name: r'customerPaymentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomerPaymentsProvider call(int custId) =>
      CustomerPaymentsProvider._(argument: custId, from: this);

  @override
  String toString() => r'customerPaymentsProvider';
}

/// Current user's own payments — GET /User/Me/Payments (Employee / Salesman)

@ProviderFor(myPaymentList)
final myPaymentListProvider = MyPaymentListProvider._();

/// Current user's own payments — GET /User/Me/Payments (Employee / Salesman)

final class MyPaymentListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaymentWithCustomer>>,
          List<PaymentWithCustomer>,
          FutureOr<List<PaymentWithCustomer>>
        >
    with
        $FutureModifier<List<PaymentWithCustomer>>,
        $FutureProvider<List<PaymentWithCustomer>> {
  /// Current user's own payments — GET /User/Me/Payments (Employee / Salesman)
  MyPaymentListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myPaymentListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myPaymentListHash();

  @$internal
  @override
  $FutureProviderElement<List<PaymentWithCustomer>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaymentWithCustomer>> create(Ref ref) {
    return myPaymentList(ref);
  }
}

String _$myPaymentListHash() => r'4e3a3888313c0c9e43f34b88efbe90246b94090c';
