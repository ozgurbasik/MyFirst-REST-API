import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ItemPage extends StatefulWidget {
  final String username;

  ItemPage({required this.username});

  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  late Future<List<String>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = Provider.of<ApiService>(context, listen: false)
        .getItems(widget.username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Items')),
      body: FutureBuilder<List<String>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No items found'));
          } else {
            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]),
                );
              },
            );
          }
        },
      ),
    );
  }
}
