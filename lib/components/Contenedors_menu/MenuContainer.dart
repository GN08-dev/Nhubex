import 'package:flutter/material.dart';

class MenuContainer extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const MenuContainer({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          onTap: () {
            // Acción a realizar cuando se toca el elemento
            print('Tocaste ${item['title']}');
          },
          leading: Icon(
            item['icon'],
            color: Colors.black,
          ),
          title: Text(
            item['title'],
            style: const TextStyle(color: Colors.black),
          ),
        );
      },
    );
  }
}
