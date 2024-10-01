//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/data/local/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController titleControler = TextEditingController();
  TextEditingController descControler = TextEditingController();

  List<Map<String, dynamic>> allNotes = [];
  DbHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = DbHelper.getInstance;
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    print('All Notes: $allNotes');
    setState(() {});
  }

  void deleteNoteFromDb(int sno) async {
    bool result = await dbRef!.deleteNote(sno: sno);
    if (result) {
      getNotes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete note')),
      );
    }
  }

  void showUpdateDialog(Map<String, dynamic> note) {
    titleControler.text = note[DbHelper.COLUMN_NOTE_TITLE];
    descControler.text = note[DbHelper.COLUMN_NOTE_DESC];

    showModalBottomSheet(
      isScrollControlled: true,
        context: context,
        builder: (context) {
          return Container(
            
            padding: EdgeInsets.all(11),
            width: double.infinity,
            child: Column(
              children: [
                Text('Update Note',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                SizedBox(height: 21),
                TextField(
                  controller: titleControler,
                  decoration: InputDecoration(
                    hintText: 'Enter title here',
                    label: Text('Title'),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
                SizedBox(height: 11),
                TextField(
                  controller: descControler,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter description here',
                    label: Text('Desc'),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
                SizedBox(height: 11),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          var title = titleControler.text.toString();
                          var desc = descControler.text.toString();
                          if (title.isNotEmpty && desc.isNotEmpty) {
                            bool check = await dbRef!.updateNode(
                                title: title,
                                desc: desc,
                                sno: note[DbHelper.COLUMN_NOTE_SNO]);

                            if (check == true) {
                              getNotes();
                              titleControler.clear();
                              descControler.clear();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Note updated successfully')));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Something went wrong')));
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please fill all the fields')));
                          }
                        },
                        child: Text('Update Note'),
                      ),
                    ),
                    SizedBox(width: 11),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: allNotes.isNotEmpty
          ? ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text(allNotes[index][DbHelper.COLUMN_NOTE_SNO].toString()),
                  title: Text(allNotes[index][DbHelper.COLUMN_NOTE_TITLE]),
                  subtitle: Text(allNotes[index][DbHelper.COLUMN_NOTE_DESC]),
                  trailing: SizedBox(
                    width: 60,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showUpdateDialog(allNotes[index]);
                          },
                          child: Icon(Icons.edit),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                      title: Text('Delete Note'),
                                      content: Text(
                                          'Are you sure you want to delete this note?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            deleteNoteFromDb(
                                                allNotes[index][DbHelper.COLUMN_NOTE_SNO]);
                                          },
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    ));
                          },
                          child: Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Text('No Notes yet'),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          titleControler.clear();
          descControler.clear();
          showModalBottomSheet(
            isScrollControlled: true,
              context: context,
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(11),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text('Add Note',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold)),
                      SizedBox(height: 21),
                      TextField(
                        controller: titleControler,
                        decoration: InputDecoration(
                          hintText: 'Enter title here',
                          label: Text('Title'),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                      ),
                      SizedBox(height: 11),
                      TextField(
                        controller: descControler,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Enter description here',
                          label: Text('Desc'),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                      ),
                      SizedBox(height: 11),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                                onPressed: () async {
                                  var title = titleControler.text.toString();
                                  var desc = descControler.text.toString();
                                  if (title.isNotEmpty && desc.isNotEmpty) {
                                    bool check = await dbRef!
                                        .addNote(mTitle: title, mDesc: desc);

                                    if (check == true) {
                                      getNotes();
                                      titleControler.clear();
                                      descControler.clear();
                                      Navigator.pop(context);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Something went wrong')));
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Please fill all the fields')));
                                  }
                                },
                                child: Text('Add Notes')),
                          ),
                          SizedBox(width: 11),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel'),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
