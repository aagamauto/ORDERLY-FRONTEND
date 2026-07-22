// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shortfall_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A customer's pending short items — order-taking + customer detail.

@ProviderFor(pendingShorts)
final pendingShortsProvider = PendingShortsFamily._();

/// A customer's pending short items — order-taking + customer detail.

final class PendingShortsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PendingShort>>,
          List<PendingShort>,
          FutureOr<List<PendingShort>>
        >
    with
        $FutureModifier<List<PendingShort>>,
        $FutureProvider<List<PendingShort>> {
  /// A customer's pending short items — order-taking + customer detail.
  PendingShortsProvider._({
    required PendingShortsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'pendingShortsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pendingShortsHash();

  @override
  String toString() {
    return r'pendingShortsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PendingShort>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PendingShort>> create(Ref ref) {
    final argument = this.argument as int;
    return pendingShorts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PendingShortsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pendingShortsHash() => r'31473759c7b0e812c2ea6c169bd89c5b31007938';

/// A customer's pending short items — order-taking + customer detail.

final class PendingShortsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PendingShort>>, int> {
  PendingShortsFamily._()
    : super(
        retry: null,
        name: r'pendingShortsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A customer's pending short items — order-taking + customer detail.

  PendingShortsProvider call(int custId) =>
      PendingShortsProvider._(argument: custId, from: this);

  @override
  String toString() => r'pendingShortsProvider';
}

/// All pending shorts across customers — the global short-orders list.

@ProviderFor(allPendingShorts)
final allPendingShortsProvider = AllPendingShortsProvider._();

/// All pending shorts across customers — the global short-orders list.

final class AllPendingShortsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PendingShort>>,
          List<PendingShort>,
          FutureOr<List<PendingShort>>
        >
    with
        $FutureModifier<List<PendingShort>>,
        $FutureProvider<List<PendingShort>> {
  /// All pending shorts across customers — the global short-orders list.
  AllPendingShortsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allPendingShortsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allPendingShortsHash();

  @$internal
  @override
  $FutureProviderElement<List<PendingShort>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PendingShort>> create(Ref ref) {
    return allPendingShorts(ref);
  }
}

String _$allPendingShortsHash() => r'7a6cb3026299db27c1e3907e3af5a3789bb46dd7';

/// Per-product short analytics — which products keep going short.

@ProviderFor(shortfallAnalytics)
final shortfallAnalyticsProvider = ShortfallAnalyticsProvider._();

/// Per-product short analytics — which products keep going short.

final class ShortfallAnalyticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ShortProduct>>,
          List<ShortProduct>,
          FutureOr<List<ShortProduct>>
        >
    with
        $FutureModifier<List<ShortProduct>>,
        $FutureProvider<List<ShortProduct>> {
  /// Per-product short analytics — which products keep going short.
  ShortfallAnalyticsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shortfallAnalyticsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shortfallAnalyticsHash();

  @$internal
  @override
  $FutureProviderElement<List<ShortProduct>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ShortProduct>> create(Ref ref) {
    return shortfallAnalytics(ref);
  }
}

String _$shortfallAnalyticsHash() =>
    r'b0b9f381e9701f94bd2c7d98907a83f30ca2c02e';
