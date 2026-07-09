// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminDashboard)
final adminDashboardProvider = AdminDashboardProvider._();

final class AdminDashboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<AdminDashboard>,
          AdminDashboard,
          FutureOr<AdminDashboard>
        >
    with $FutureModifier<AdminDashboard>, $FutureProvider<AdminDashboard> {
  AdminDashboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminDashboardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminDashboardHash();

  @$internal
  @override
  $FutureProviderElement<AdminDashboard> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AdminDashboard> create(Ref ref) {
    return adminDashboard(ref);
  }
}

String _$adminDashboardHash() => r'2b69477ab361a47172d5e0712d84dd5e92226981';

@ProviderFor(myDashboard)
final myDashboardProvider = MyDashboardProvider._();

final class MyDashboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserDashboard>,
          UserDashboard,
          FutureOr<UserDashboard>
        >
    with $FutureModifier<UserDashboard>, $FutureProvider<UserDashboard> {
  MyDashboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myDashboardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myDashboardHash();

  @$internal
  @override
  $FutureProviderElement<UserDashboard> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UserDashboard> create(Ref ref) {
    return myDashboard(ref);
  }
}

String _$myDashboardHash() => r'1805231659d142893df1421c10079ea2e195817a';
