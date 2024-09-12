import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ApiService with ChangeNotifier {
  final String apiUrl = 'http://127.0.0.1:5500/api'; // Corrected port and URL

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  Future<bool> signup(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error during signup: $e');
      return false;
    }
  }

  Future<List<String>> getItems(String owner) async {
    try {
      final response =
          await http.get(Uri.parse('$apiUrl/user/item/get/$owner'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> items = jsonDecode(response.body);
        return items.values.cast<String>().toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error during getItems: $e');
      return [];
    }
  }

  Future<bool> addItem(String owner, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/user/item/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'owner': owner, 'name': name}),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error during addItem: $e');
      return false;
    }
  }

  Future<bool> editItem(String owner, String itemId, String newName) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/user/item/edit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'owner': owner, 'item_id': itemId, 'name': newName}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error during editItem: $e');
      return false;
    }
  }

  Future<bool> deleteItem(String owner, String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/user/item/delete/$itemId'),
        headers: {'Content-Type': 'application/json'},
        // No body for DELETE request
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error during deleteItem: $e');
      return false;
    }
  }
}
