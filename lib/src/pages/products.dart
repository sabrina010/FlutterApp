import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Products extends StatelessWidget {
  Products({Key? key}) : super(key: key);
  final db = FirebaseFirestore.instance;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Este es el listado de Personas"),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: db.collection('productos').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return ListView(
                children: snapshot.data!.docs.map((doc) {
                  return Card(
                    child: ListTile(
                      title: Text(doc.get('nombre')),
                      subtitle: Text(doc.get('precio')),
                    ),
                  );
                }).toList(),
              );
            }
          },
        ),
      ),
    );
  }
}
