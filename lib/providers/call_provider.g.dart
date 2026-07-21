// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Today's follow-up call list for a business (server caps at the daily target).

@ProviderFor(callToday)
final callTodayProvider = CallTodayFamily._();

/// Today's follow-up call list for a business (server caps at the daily target).

final class CallTodayProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CallCandidate>>,
          List<CallCandidate>,
          FutureOr<List<CallCandidate>>
        >
    with
        $FutureModifier<List<CallCandidate>>,
        $FutureProvider<List<CallCandidate>> {
  /// Today's follow-up call list for a business (server caps at the daily target).
  CallTodayProvider._({
    required CallTodayFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'callTodayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$callTodayHash();

  @override
  String toString() {
    return r'callTodayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CallCandidate>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CallCandidate>> create(Ref ref) {
    final argument = this.argument as String;
    return callToday(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CallTodayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$callTodayHash() => r'f3bca76ebfc013dedf56299b33ab87b24d282a0b';

/// Today's follow-up call list for a business (server caps at the daily target).

final class CallTodayFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CallCandidate>>, String> {
  CallTodayFamily._()
    : super(
        retry: null,
        name: r'callTodayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Today's follow-up call list for a business (server caps at the daily target).

  CallTodayProvider call(String shop) =>
      CallTodayProvider._(argument: shop, from: this);

  @override
  String toString() => r'callTodayProvider';
}
