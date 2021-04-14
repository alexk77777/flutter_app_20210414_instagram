import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreatePage extends StatefulWidget {
  final FirebaseUser user;

  CreatePage(this.user);

  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  File _image;

  Future _getImage() async {
    print('클릭 되나');
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새 게시물'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            tooltip: '다음',
            onPressed: () {
              _postBuild(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildBody(),
            TextField(
              decoration: InputDecoration(hintText: '내용을 입력하세요'),
              controller: textEditingController,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  void _postBuild(BuildContext context) {

    print('클릭');

    final firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('post')
        .child('${DateTime.now().millisecondsSinceEpoch}.png');

    final task = firebaseStorageRef.putFile(
        _image, StorageMetadata(contentType: 'image/png'));

    final value = await task;

    task.onComplete.then((value) {
      var downloadUrl = value.ref.getDownloadURL();

      downloadUrl.then((uri) {
        var doc = Firestore.instance.collection('post').document();
        await doc.set({
          'id': doc.documentID,
          'photoUrl': uri.toString(),
          'contents': textEditingController.text,
          'email': widget.user.email,
          'displayName': widget.user.displayName,
          'userPhotoUrl': widget.user.photoUrl
        })
          // 완료 후 앞 화면으로 이동
          Navigator.pop(context);
        });
      });
    });
  }

  Widget _buildBody() {
    return _image == null ? Text('No Image') : Image.file(_image);
  }
}
