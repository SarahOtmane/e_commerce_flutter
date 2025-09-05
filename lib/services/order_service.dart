import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';

class OrderService {
  static const _ordersKey = 'orders';

  Future<void> saveOrder(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final orders = await loadOrders();
    orders.add(order);
    final encoded = jsonEncode(orders.map((o) => o.toJson()).toList());
    await prefs.setString(_ordersKey, encoded);
  }

  Future<List<Order>> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_ordersKey);
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((e) => Order.fromJson(e)).toList();
  }

  Future<void> clearOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ordersKey);
  }
}
