class AdminDashboard {
  const AdminDashboard({
    required this.totalUsers,
    required this.totalCustomers,
    required this.totalSystemOrders,
    required this.totalSystemRevenue,
  });

  final int totalUsers;
  final int totalCustomers;
  final int totalSystemOrders;
  final int totalSystemRevenue;

  factory AdminDashboard.fromJson(Map<String, dynamic> j) => AdminDashboard(
        totalUsers: j['total_users'] as int,
        totalCustomers: j['total_customers'] as int,
        totalSystemOrders: j['total_system_orders'] as int,
        totalSystemRevenue: j['total_system_revenue'] as int,
      );
}

class UserDashboard {
  const UserDashboard({
    required this.totalOrders,
    required this.totalItemsSold,
    required this.totalRevenue,
  });

  final int totalOrders;
  final int totalItemsSold;
  final int totalRevenue;

  factory UserDashboard.fromJson(Map<String, dynamic> j) => UserDashboard(
        totalOrders: j['total_orders'] as int,
        totalItemsSold: j['total_items_sold'] as int,
        totalRevenue: j['total_revenue'] as int,
      );
}
