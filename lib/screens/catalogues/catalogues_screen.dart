import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/catalogue_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalogue_provider.dart';
import '../../utils/format_utils.dart';

class CataloguesScreen extends ConsumerWidget {
  const CataloguesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(catalogueListProvider);
    final asyncCats = ref.watch(catalogueCategoriesProvider);
    final selectedCat = ref.watch(selectedCatalogueCategoryProvider);
    final isAdmin = ref.watch(userRoleProvider) == 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogues'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.upload_file),
              tooltip: 'Upload Catalogue',
              onPressed: () => context.push('/catalogues/upload'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: asyncCats.when(
              loading: () => const SizedBox(
                height: 56,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (cats) => DropdownButtonFormField<String?>(
                initialValue: selectedCat,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Filter by Category',
                  prefixIcon: const Icon(Icons.filter_list),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('All Categories')),
                  ...cats.map(
                    (c) => DropdownMenuItem<String?>(value: c, child: Text(c)),
                  ),
                ],
                onChanged: (v) =>
                    ref.read(selectedCatalogueCategoryProvider.notifier).set(v),
              ),
            ),
          ),
          Expanded(
            child: asyncList.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 8),
                  Text('$e'),
                  TextButton(
                    onPressed: () => ref.invalidate(catalogueListProvider),
                    child: const Text('Retry'),
                  ),
                ]),
              ),
              data: (catalogues) {
                final filtered = selectedCat == null
                    ? catalogues
                    : catalogues.where((c) => c.category == selectedCat).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No catalogues available.'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(catalogueListProvider);
                    ref.invalidate(catalogueCategoriesProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) =>
                        _CatalogueCard(catalogue: filtered[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/catalogues/upload'),
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload PDF'),
            )
          : null,
    );
  }
}

class _CatalogueCard extends StatelessWidget {
  const _CatalogueCard({required this.catalogue});
  final CatalogueModel catalogue;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.picture_as_pdf,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(catalogue.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${catalogue.category} • ${catalogue.readableSize} • ${formatDate(catalogue.uploadedAt)}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(
          '/catalogues/view/${catalogue.id}',
          extra: catalogue,
        ),
      ),
    );
  }
}
