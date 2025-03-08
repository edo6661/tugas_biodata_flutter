import 'package:biodata/entity/biodata.dart';
import 'package:biodata/features/auth/pages/login_page.dart';
import 'package:biodata/features/biodata/pages/upsert_biodata_page.dart';
import 'package:biodata/features/camera/pages/camera_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  static route() => MaterialPageRoute(builder: (context) => const HomePage());
  const HomePage({super.key});

  Stream<QuerySnapshot> _fetchBiodata() {
    return FirebaseFirestore.instance
        .collection('biodata')
        .where(
          'userId',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
        .snapshots();
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biodata'),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(CameraScreen.route());
                },
                icon: const Icon(Icons.camera_alt),
              ),
              IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(LoginPage.route());
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            UpsertBiodataPage.route(),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchBiodata(),
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
            return const Center(child: Text('Data not found'));
          }
          final docs = snapshots.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final biodata = Biodata.fromMap(data, docId: docs[index].id);
              return Dismissible(
                key: ValueKey(biodata.docId),
                onDismissed: (direction) {
                  FirebaseFirestore.instance
                      .collection('biodata')
                      .doc(biodata.docId)
                      .delete();
                },
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Are you sure?'),
                        content:
                            const Text('Do you want to delete this biodata?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: const Text('Yes'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      UpsertBiodataPage.route(biodata: biodata),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 100,
                              backgroundImage: NetworkImage(biodata.avatarUrl),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Username: ${biodata.username}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Age: ${biodata.age}',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Address: ${biodata.address}',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(
                            'Created At: ${biodata.createdAt != null ? _formatTimestamp(biodata.createdAt!) : '-'}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
