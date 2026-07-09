// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuthNotifier)
final authProvider = AuthNotifierProvider._();

final class AuthNotifierProvider
    extends $AsyncNotifierProvider<AuthNotifier, AuthState> {
  AuthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authNotifierHash();

  @$internal
  @override
  AuthNotifier create() => AuthNotifier();
}

String _$authNotifierHash() => r'c70d7b28fc4359f8ab4eaceb5e51e9cd74138583';

abstract class _$AuthNotifier extends $AsyncNotifier<AuthState> {
  FutureOr<AuthState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthState>, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthState>, AuthState>,
              AsyncValue<AuthState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// `true` when a valid session exists. Used by GoRouter redirect.

@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = IsAuthenticatedProvider._();

/// `true` when a valid session exists. Used by GoRouter redirect.

final class IsAuthenticatedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// `true` when a valid session exists. Used by GoRouter redirect.
  IsAuthenticatedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAuthenticatedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAuthenticatedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAuthenticated(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAuthenticatedHash() => r'c6408701eaca9b1cd5f3f808651e8f76fde2d8f1';

/// The current user's role string ("Admin", "Salesman", "Employee", or null).
/// Used by screens to show/hide role-specific UI elements.

@ProviderFor(userRole)
final userRoleProvider = UserRoleProvider._();

/// The current user's role string ("Admin", "Salesman", "Employee", or null).
/// Used by screens to show/hide role-specific UI elements.

final class UserRoleProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// The current user's role string ("Admin", "Salesman", "Employee", or null).
  /// Used by screens to show/hide role-specific UI elements.
  UserRoleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userRoleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userRoleHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return userRole(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$userRoleHash() => r'61a6b6e5fcf37d799fde0fbaac3baf41ea813c9c';

/// The current user's display name.

@ProviderFor(userName)
final userNameProvider = UserNameProvider._();

/// The current user's display name.

final class UserNameProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// The current user's display name.
  UserNameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userNameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userNameHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return userName(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$userNameHash() => r'93ea8c945d3a5b65a13012ccf6082e174fa97da5';

/// The current user's numeric ID. Used when creating orders.

@ProviderFor(userId)
final userIdProvider = UserIdProvider._();

/// The current user's numeric ID. Used when creating orders.

final class UserIdProvider extends $FunctionalProvider<int?, int?, int?>
    with $Provider<int?> {
  /// The current user's numeric ID. Used when creating orders.
  UserIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userIdHash();

  @$internal
  @override
  $ProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int? create(Ref ref) {
    return userId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$userIdHash() => r'a2b3d7374c41bba2b24cb76bff9d6b77065df9a8';
