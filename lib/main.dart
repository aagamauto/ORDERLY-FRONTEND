import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'models/catalogue_model.dart';
import 'providers/auth_provider.dart';
import 'screens/admin/create_user_screen.dart';
import 'screens/admin/users_screen.dart';
import 'screens/catalogues/catalogue_upload_screen.dart';
import 'screens/catalogues/catalogue_viewer_screen.dart';
import 'screens/catalogues/catalogues_screen.dart';
import 'screens/customers/create_customer_screen.dart';
import 'screens/customers/customer_detail_screen.dart';
import 'screens/customers/customers_screen.dart';
import 'screens/dashboard/admin_dashboard_screen.dart';
import 'screens/dashboard/my_dashboard_screen.dart';
import 'screens/dispatch/dispatch_queue_screen.dart';
import 'screens/dispatch/pack_order_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/orders/create_order_screen.dart';
import 'screens/orders/edit_order_screen.dart';
import 'screens/orders/order_detail_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/payments/payments_screen.dart';
import 'screens/products/create_product_screen.dart';
import 'screens/products/products_screen.dart';
import 'screens/calls/follow_up_calls_screen.dart';
import 'screens/crm/crm_config_screen.dart';
import 'screens/crm/crm_dashboard_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/defaulters/defaulters_screen.dart';
import 'screens/short_orders/short_orders_screen.dart';
import 'screens/visits/visit_planner_screen.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'services/offline_queue.dart';

part 'main.g.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Push notifications — wrapped so a Firebase misconfig never blocks startup.
  try {
    await NotificationService.instance.init();
  } catch (_) {}
  // Restore & start syncing any orders queued while offline.
  await OfflineQueue.instance.init();
  runApp(const ProviderScope(child: MyApp()));
}

// ── Router Provider ───────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),

      // ── Orders ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/orders/mine',
        builder: (context, state) => const OrdersScreen(mineOnly: true),
      ),
      GoRoute(
        path: '/orders/create',
        builder: (context, state) => const CreateOrderScreen(),
      ),
      GoRoute(
        path: '/orders/edit/:orderId',
        builder: (context, state) {
          final orderId = int.parse(state.pathParameters['orderId']!);
          return EditOrderScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/orders/pack/:orderId',
        builder: (context, state) {
          final orderId = int.parse(state.pathParameters['orderId']!);
          return PackOrderScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/orders/:orderId',
        builder: (context, state) {
          final orderId = int.parse(state.pathParameters['orderId']!);
          return OrderDetailScreen(orderId: orderId);
        },
      ),

      // ── Customers ───────────────────────────────────────────────────────────
      GoRoute(
        path: '/customers',
        builder: (context, state) => const CustomersScreen(),
      ),
      GoRoute(
        path: '/customers/create',
        builder: (context, state) => const CreateCustomerScreen(),
      ),
      GoRoute(
        path: '/customers/:custId',
        builder: (context, state) {
          final custId = int.parse(state.pathParameters['custId']!);
          return CustomerDetailScreen(custId: custId);
        },
      ),
      GoRoute(
        path: '/customers/:custId/orders/:orderId',
        builder: (context, state) {
          final orderId = int.parse(state.pathParameters['orderId']!);
          return OrderDetailScreen(orderId: orderId);
        },
      ),

      // ── Payments ────────────────────────────────────────────────────────────
      GoRoute(
        path: '/payments',
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: '/payments/mine',
        builder: (context, state) => const PaymentsScreen(mineOnly: true),
      ),

      // ── Products ────────────────────────────────────────────────────────────
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        path: '/products/create',
        builder: (context, state) => const CreateProductScreen(),
      ),

      // ── Catalogues ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/catalogues',
        builder: (context, state) => const CataloguesScreen(),
      ),
      GoRoute(
        path: '/catalogues/upload',
        builder: (context, state) => const CatalogueUploadScreen(),
      ),
      GoRoute(
        path: '/catalogues/view/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CatalogueViewerScreen(
            id: id,
            preloaded: state.extra as CatalogueModel?,
          );
        },
      ),

      // ── Dispatch ────────────────────────────────────────────────────────────
      GoRoute(
        path: '/dispatch/queue',
        builder: (context, state) => const DispatchQueueScreen(),
      ),

      // ── Profile ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/create-user',
        builder: (context, state) => const CreateUserScreen(),
      ),

      // ── Dashboards ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/dashboard/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard/me',
        builder: (context, state) => const MyDashboardScreen(),
      ),

      // ── Admin ───────────────────────────────────────────────────────────────
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const UsersScreen(),
      ),

      // ── CRM / field-sales recommendation ────────────────────────────────────
      GoRoute(
        path: '/visits/planner',
        builder: (context, state) => const VisitPlannerScreen(),
      ),
      GoRoute(
        path: '/calls/today',
        builder: (context, state) => const FollowUpCallsScreen(),
      ),
      GoRoute(
        path: '/crm',
        builder: (context, state) => const CrmDashboardScreen(),
      ),
      GoRoute(
        path: '/crm/config',
        builder: (context, state) => const CrmConfigScreen(),
      ),

      // ── Defaulters + Short orders ───────────────────────────────────────────
      GoRoute(
        path: '/defaulters',
        builder: (context, state) => const DefaultersScreen(),
      ),
      GoRoute(
        path: '/short-orders',
        builder: (context, state) => const ShortOrdersScreen(),
      ),
    ],
  );
}

/// Bridges Riverpod auth state + 401 failure events into GoRouter's
/// [ChangeNotifier]-based refresh mechanism.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    // Re-evaluate redirect whenever auth state changes.
    _ref.listen(authProvider, (_, _) => notifyListeners());

    // Re-evaluate redirect when the Dio interceptor fires a 401.
    authFailureNotifier.addListener(notifyListeners);
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final authAsync = _ref.read(authProvider);

    // While the initial session check is loading, don't redirect.
    if (authAsync.isLoading) return null;

    final isAuth = _ref.read(isAuthenticatedProvider);
    final onLoginPage = state.matchedLocation == '/login';

    if (!isAuth && !onLoginPage) return '/login'; // Unauthenticated → login
    if (isAuth && onLoginPage) return '/home';    // Already logged in → home
    return null;                                   // No redirect needed
  }
}

// ── App Root ──────────────────────────────────────────────────────────────────

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Orderly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0), // Deep blue brand color
        ),
        useMaterial3: true,
      ),
      routerConfig: goRouter,
    );
  }
}
