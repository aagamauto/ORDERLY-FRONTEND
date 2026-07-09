// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogue_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(catalogueList)
final catalogueListProvider = CatalogueListProvider._();

final class CatalogueListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CatalogueModel>>,
          List<CatalogueModel>,
          FutureOr<List<CatalogueModel>>
        >
    with
        $FutureModifier<List<CatalogueModel>>,
        $FutureProvider<List<CatalogueModel>> {
  CatalogueListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogueListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogueListHash();

  @$internal
  @override
  $FutureProviderElement<List<CatalogueModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CatalogueModel>> create(Ref ref) {
    return catalogueList(ref);
  }
}

String _$catalogueListHash() => r'aadcb000911715d42a88ff8cc17491a45b7995a6';

@ProviderFor(catalogueCategories)
final catalogueCategoriesProvider = CatalogueCategoriesProvider._();

final class CatalogueCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  CatalogueCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogueCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogueCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return catalogueCategories(ref);
  }
}

String _$catalogueCategoriesHash() =>
    r'50ecd95e32967fb4620c01a850b5d53a071fd375';

@ProviderFor(SelectedCatalogueCategory)
final selectedCatalogueCategoryProvider = SelectedCatalogueCategoryProvider._();

final class SelectedCatalogueCategoryProvider
    extends $NotifierProvider<SelectedCatalogueCategory, String?> {
  SelectedCatalogueCategoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedCatalogueCategoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedCatalogueCategoryHash();

  @$internal
  @override
  SelectedCatalogueCategory create() => SelectedCatalogueCategory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedCatalogueCategoryHash() =>
    r'4c6044a90270217e7dae4e97281e4a1d3e39a4e2';

abstract class _$SelectedCatalogueCategory extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
