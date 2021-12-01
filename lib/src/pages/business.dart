import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class Business extends StatefulWidget {
  const Business({Key? key}) : super(key: key);

  @override
  _BusinessState createState() => _BusinessState();
}

class _BusinessState extends State<Business> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  final CollectionReference _products =
      FirebaseFirestore.instance.collection('negocios');

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _nombreController.text = documentSnapshot['nombre'];
      _direccionController.text = documentSnapshot['direccion'].toString();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: _direccionController,
                  decoration: const InputDecoration(
                    labelText: 'direccion',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? nombre = _nombreController.text;
                    final double? direccion =
                        double.tryParse(_direccionController.text);
                    if (nombre != null && direccion != null) {
                      if (action == 'create') {
                        await _products
                            .add({"nombre": nombre, "direccion": direccion});
                      }

                      if (action == 'update') {
                        await _products
                            .doc(documentSnapshot!.id)
                            .update({"nombre": nombre, "direccion": direccion});
                      }

                      _nombreController.text = '';
                      _direccionController.text = '';

                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> _deleteProduct(String productId) async {
    await _products.doc(productId).delete();

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Negocio eliminado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado De Negocios'),
      ),
      body: StreamBuilder(
        stream: _products.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['nombre']),
                    subtitle: Text(documentSnapshot['direccion'].toString()),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _createOrUpdate(documentSnapshot)),
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteProduct(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );

            
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
