import 'package:blogging_app/views/edit_post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:randomizer/randomizer.dart';


class EditPostView extends StatefulWidget {
  final String userId;
  final String blogPostId;
  final String blogPostTitle;
  final String blogPostContent;
  final String date;
  final String postImage;

  EditPostView({
    this.userId,
    this.blogPostId,
    this.blogPostTitle,
    this.blogPostContent,
    this.date,
    this.postImage,
  });

  @override
  _EditPostViewState createState() => _EditPostViewState();
}

class _EditPostViewState extends State<EditPostView> {
  FirebaseUser _user;

  Randomizer randomizer = Randomizer();
  List<Color> colorsList = [Color(0xFF083663), Color(0xFFFE161D), Color(0xFF682D27),
    Color(0xFF61538D), Color(0xFF08363B), Color(0xFF319B4B), Color(0xFFF4D03F)];

  // initState
  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  _getCurrentUser() async {
    _user = await FirebaseAuth.instance.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditPost(userId: _user.uid, blogPostId: widget.blogPostId,postImage: widget.postImage)));
      },
      child: Column(
        children: [
          header(),
          Container(
            constraints: BoxConstraints.expand(height: height * 0.3),
            child: Image.network(widget.postImage),
          ),
        ],
      ),
    );
  }

  header (){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30.0,
          backgroundColor: randomizer.getspecifiedcolor(colorsList),
          child: Text(widget.blogPostTitle.substring(0, 1).toUpperCase(), textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
        ),
        title: Text(
          widget.blogPostTitle,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: Text(widget.date, style: TextStyle(color: Colors.grey, fontSize: 12.0)),
      ),
    );

  }
}
