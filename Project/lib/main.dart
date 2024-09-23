// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'myRESTAPI ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

// HomePage for Login and Signup
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = ''; // Response message from the API

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _message = jsonDecode(response.body)['message'];
      });
      await Future.delayed(Duration(seconds: 1));
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserPage(username: _usernameController.text)),
      );
    } else {
      setState(() {
        _message = jsonDecode(response.body)['error'];
      });
    }
  }

  Future<void> _signup() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/api/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        _message = jsonDecode(response.body)['message'];
      });
    } else {
      setState(() {
        _message = jsonDecode(response.body)['error'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the column
          children: <Widget>[
            Text(
              'Item Management System', // Title text
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold), // Style for the title
            ),
            SizedBox(height: 20), // Space between the title and the container
            Container(
              padding: EdgeInsets.all(16.0),
              width: 300, // Adjust the width as needed
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue, // Change the color as needed
                  width: 2, // Adjust the width of the border
                ),
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // To wrap content tightly
                children: <Widget>[
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(onPressed: _login, child: Text('Login')),
                      ElevatedButton(
                          onPressed: _signup, child: Text('Sign up')),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Response message section
                  Text(
                    _message,
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// UserPage for managing items
class UserPage extends StatefulWidget {
  final String username;
  const UserPage({super.key, required this.username});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final TextEditingController _itemNameController = TextEditingController();
  String _message = ''; // Response message from the API
  List<String> _items = []; // Display list of items
  List<String> _itemIds = []; // Store item IDs
  String? _selectedItemId; // Store selected item ID for editing or deleting

  @override
  void initState() {
    super.initState();
    _getItems();
  }

  Future<void> _getItems() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:5000/api/${widget.username}/item/get'),
      headers: <String, String>{'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        _items = List<String>.from(
            (data['items'] as List).map((item) => item['name']));
        _itemIds = List<String>.from((data['items'] as List).map((item) =>
            item['item_id'])); // Assuming each item has a unique 'item_id'
        _message = "Items retrieved successfully.";
      });
    } else {
      setState(() {
        _message = jsonDecode(response.body)['error'];
      });
    }
  }

  Future<void> _addItem() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/api/${widget.username}/item/add'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode({
        'name': _itemNameController.text,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        _message = "Item added successfully";
        _itemNameController.clear(); // Clear the input field
        _getItems(); // Update items after adding
      });
    } else {
      setState(() {
        _message = jsonDecode(response.body)['error'];
      });
    }
  }

  Future<void> _deleteItem() async {
    if (_selectedItemId == null) {
      setState(() {
        _message = "Select an item for deletion.";
      });
      return;
    }

    final response = await http.delete(
      Uri.parse('http://127.0.0.1:5000/api/${widget.username}/item/delete'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode({'item_id': _selectedItemId}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _message = "Item deleted successfully";
        _selectedItemId = null; // Clear selection
        _getItems(); // Update items after deleting
      });
    } else {
      setState(() {
        _message = jsonDecode(response.body)['error'];
      });
    }
  }

  Future<void> _editItem(String newName) async {
    if (_selectedItemId == null) {
      setState(() {
        _message = "No item selected for editing.";
      });
      return;
    }

    final response = await http.put(
      Uri.parse('http://127.0.0.1:5000/api/${widget.username}/item/edit'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode({'item_id': _selectedItemId, 'name': newName}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _message = "Item edited successfully";
        _getItems(); // Update items after editing
      });
    } else {
      setState(() {
        _message = jsonDecode(response.body)['error'];
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome, ${widget.username}', // Title text
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold), // Style for the title
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text("Your Items",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedItemId =
                                    _itemIds[index]; // Store the actual item ID
                              });
                            },
                            child: Container(
                              color: _selectedItemId == _itemIds[index]
                                  ? const Color.fromARGB(255, 178, 176, 176)
                                  : Colors.transparent,
                              child: ListTile(
                                title: Text(
                                  _items[index],
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 240, 6, 6)),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 350,
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _itemNameController,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _getItems,
                    child: Text('Get Items'),
                  ),
                  ElevatedButton(onPressed: _addItem, child: Text('Add Item')),
                  ElevatedButton(
                    onPressed: _deleteItem,
                    child: Text('Delete Item'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _editItem(_itemNameController.text);
                    },
                    child: Text('Edit Item'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Log Off'),
              ),
              SizedBox(height: 20),
              Text(
                _message,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
