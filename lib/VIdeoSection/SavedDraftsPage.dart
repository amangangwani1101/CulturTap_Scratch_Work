import 'package:flutter/material.dart';
import 'dart:io';
import 'package:learn_flutter/VIdeoSection/Draft_Local_Database/database_helper.dart';
import 'package:learn_flutter/VIdeoSection/Draft_Local_Database/draft.dart';

class SavedDraftsPage extends StatefulWidget {
  @override
  _SavedDraftsPageState createState() => _SavedDraftsPageState();
}

class _SavedDraftsPageState extends State<SavedDraftsPage> {
  List<Draft> drafts = [];

  @override
  void initState() {
    super.initState();
    // Fetch saved drafts from the local database
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    final database = await DatabaseHelper.instance.database;
    final draftList = await database.query('drafts');
    setState(() {
      drafts = draftList.map((e) => Draft.fromMap(e)).toList().cast<Draft>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Drafts'),
      ),
      body: drafts.isEmpty
          ? Center(child: Text('No saved drafts found.'))
          : ListView.builder(
        itemCount: drafts.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Image.file(File(drafts[index].videoPaths.split(',')[0])), // Use the first video as a thumbnail
              title: Text(drafts[index].storyTitle),
              subtitle: Text('Location: ${drafts[index].latitude}, ${drafts[index].longitude}'),
              onTap: () {
                // Handle tap on a draft, navigate to draft details page
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => DraftDetailsPage(draft: drafts[index]),
                //   ),
                // );
              },
            ),
          );
        },
      ),
    );
  }
}
