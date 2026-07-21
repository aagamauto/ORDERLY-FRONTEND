// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crm_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// CRM analytics for one business — GET /CRM/Analytics/?shop=

@ProviderFor(crmAnalytics)
final crmAnalyticsProvider = CrmAnalyticsFamily._();

/// CRM analytics for one business — GET /CRM/Analytics/?shop=

final class CrmAnalyticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CrmAnalytics>>,
          List<CrmAnalytics>,
          FutureOr<List<CrmAnalytics>>
        >
    with
        $FutureModifier<List<CrmAnalytics>>,
        $FutureProvider<List<CrmAnalytics>> {
  /// CRM analytics for one business — GET /CRM/Analytics/?shop=
  CrmAnalyticsProvider._({
    required CrmAnalyticsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'crmAnalyticsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$crmAnalyticsHash();

  @override
  String toString() {
    return r'crmAnalyticsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CrmAnalytics>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CrmAnalytics>> create(Ref ref) {
    final argument = this.argument as String;
    return crmAnalytics(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CrmAnalyticsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$crmAnalyticsHash() => r'dd500af31af93063f76b8f15f657fb715cc6533e';

/// CRM analytics for one business — GET /CRM/Analytics/?shop=

final class CrmAnalyticsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CrmAnalytics>>, String> {
  CrmAnalyticsFamily._()
    : super(
        retry: null,
        name: r'crmAnalyticsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// CRM analytics for one business — GET /CRM/Analytics/?shop=

  CrmAnalyticsProvider call(String shop) =>
      CrmAnalyticsProvider._(argument: shop, from: this);

  @override
  String toString() => r'crmAnalyticsProvider';
}

/// All per-business config rows — GET /CRM/Config/

@ProviderFor(crmConfigList)
final crmConfigListProvider = CrmConfigListProvider._();

/// All per-business config rows — GET /CRM/Config/

final class CrmConfigListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CrmConfig>>,
          List<CrmConfig>,
          FutureOr<List<CrmConfig>>
        >
    with $FutureModifier<List<CrmConfig>>, $FutureProvider<List<CrmConfig>> {
  /// All per-business config rows — GET /CRM/Config/
  CrmConfigListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crmConfigListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crmConfigListHash();

  @$internal
  @override
  $FutureProviderElement<List<CrmConfig>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CrmConfig>> create(Ref ref) {
    return crmConfigList(ref);
  }
}

String _$crmConfigListHash() => r'f28dd31062fac9c93b843047247933d24db4c642';
