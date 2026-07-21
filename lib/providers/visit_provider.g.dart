// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Ranked customers to visit for a business + set of cities.
/// [citiesCsv] is a comma-joined, sorted list so the family key stays stable.

@ProviderFor(visitPlan)
final visitPlanProvider = VisitPlanFamily._();

/// Ranked customers to visit for a business + set of cities.
/// [citiesCsv] is a comma-joined, sorted list so the family key stays stable.

final class VisitPlanProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VisitCandidate>>,
          List<VisitCandidate>,
          FutureOr<List<VisitCandidate>>
        >
    with
        $FutureModifier<List<VisitCandidate>>,
        $FutureProvider<List<VisitCandidate>> {
  /// Ranked customers to visit for a business + set of cities.
  /// [citiesCsv] is a comma-joined, sorted list so the family key stays stable.
  VisitPlanProvider._({
    required VisitPlanFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'visitPlanProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$visitPlanHash();

  @override
  String toString() {
    return r'visitPlanProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<VisitCandidate>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VisitCandidate>> create(Ref ref) {
    final argument = this.argument as (String, String);
    return visitPlan(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is VisitPlanProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$visitPlanHash() => r'38063287068698bc4b55b62d1d874511cabb5df0';

/// Ranked customers to visit for a business + set of cities.
/// [citiesCsv] is a comma-joined, sorted list so the family key stays stable.

final class VisitPlanFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<VisitCandidate>>,
          (String, String)
        > {
  VisitPlanFamily._()
    : super(
        retry: null,
        name: r'visitPlanProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Ranked customers to visit for a business + set of cities.
  /// [citiesCsv] is a comma-joined, sorted list so the family key stays stable.

  VisitPlanProvider call(String shop, String citiesCsv) =>
      VisitPlanProvider._(argument: (shop, citiesCsv), from: this);

  @override
  String toString() => r'visitPlanProvider';
}

/// Distinct cities that have customers for the given business — derived from the
/// already-loaded customer list (no extra endpoint needed).

@ProviderFor(visitCities)
final visitCitiesProvider = VisitCitiesFamily._();

/// Distinct cities that have customers for the given business — derived from the
/// already-loaded customer list (no extra endpoint needed).

final class VisitCitiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Distinct cities that have customers for the given business — derived from the
  /// already-loaded customer list (no extra endpoint needed).
  VisitCitiesProvider._({
    required VisitCitiesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'visitCitiesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$visitCitiesHash();

  @override
  String toString() {
    return r'visitCitiesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as String;
    return visitCities(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VisitCitiesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$visitCitiesHash() => r'd5b6230898de0d926a1b0839d8c06c8e8e8c57d7';

/// Distinct cities that have customers for the given business — derived from the
/// already-loaded customer list (no extra endpoint needed).

final class VisitCitiesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<String>>, String> {
  VisitCitiesFamily._()
    : super(
        retry: null,
        name: r'visitCitiesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Distinct cities that have customers for the given business — derived from the
  /// already-loaded customer list (no extra endpoint needed).

  VisitCitiesProvider call(String shop) =>
      VisitCitiesProvider._(argument: shop, from: this);

  @override
  String toString() => r'visitCitiesProvider';
}
