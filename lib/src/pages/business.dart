import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Business extends StatelessWidget {
  Business({Key? key}) : super(key: key);
  final db = FirebaseFirestore.instance;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Este es el listado de Negocios"),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: db.collection('negocios').snapshots(),
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
                      subtitle: Text(doc.get('direccion')),
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
