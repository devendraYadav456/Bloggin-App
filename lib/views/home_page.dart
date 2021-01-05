import 'package:blogging_app/custom_widgets/post.dart';
import 'package:blogging_app/helper_functions/helper_functions.dart';
import 'package:blogging_app/services/authentication_service.dart';
import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/views/search.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'about.dart';
import 'authenticate_page.dart';
import 'create_blog.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //get the info about logged in user
  final AuthService _authService = new AuthService();

  //variables
  FirebaseUser _user;
  String _userName = '';
  String _userEmail = '';
  Stream _blogPosts;

  // initState
  @override
  void initState() {
    super.initState();
    _getBlogPosts();
  }

  _getBlogPosts() async {
    //get the current user
    _user = await FirebaseAuth.instance.currentUser();
    //get the name of the user stored locally
    await Helper.getUserNameSharedPreference().then((value) {
      setState(() {
        _userName = value;
      });
    });
    //get the email of the user stored locally
    await Helper.getUserEmailSharedPreference().then((value) {
      setState(() {
        _userEmail = value;
      });
    });
    //get the blogs of the user
    DatabaseService(uid: _user.uid).getUserBlogPosts().then((snapshots) {
      setState(() {
        _blogPosts = snapshots;
      });
    });
  }

  Widget noBlogPostWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateBlogPage(
                      uid: _user.uid,
                      userName: _userName,
                      userEmail: _userEmail),
                ),
              ).then((value) => setState((){
                _getBlogPosts();
              }));
            },
            child: Icon(Icons.add_circle, color: Colors.grey[700], size: 100.0),
          ),
          SizedBox(height: 20.0),
          Text(
              "You have not created any blog posts, tap on the 'plus' icon present above or at the bottom-right to create your first blog post."),
        ],
      ),
    );
  }

  Widget blogPostsList() {
    return StreamBuilder(
      stream: _blogPosts,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.documents != null &&
              snapshot.data.documents.length != 0) {
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  // return ListTile(
                  //   title: Text(snapshot.data.documents[index].data['blogPostTitle']),
                  //   subtitle: Text(snapshot.data.documents[index].data['blogPostContent']),
                  //   trailing: Text(snapshot.data.documents[index].data['date']),
                  // );
                  return Column(
                    children: <Widget>[
                      PostTile(
                          userId: _user.uid,
                          blogPostId:
                              snapshot.data.documents[index].data['blogPostId'],
                          blogPostTitle: snapshot
                              .data.documents[index].data['blogPostTitle'],
                          blogPostContent: snapshot
                              .data.documents[index].data['blogPostContent'],
                          date: snapshot.data.documents[index].data['date']),
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Divider(height: 0.0)),
                    ],
                  );
                });
          } else {
            return noBlogPostWidget();
          }
        } else {
          return noBlogPostWidget();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Blogs',
          style: TextStyle(fontFamily: 'OpenSans'),
        ),
      ),
      drawer: Drawer(
        child: Container(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(
                  _userName,
                  style: TextStyle(fontFamily: 'OpenSans'),
                ),
                accountEmail: Text(
                  _userEmail,
                  style: TextStyle(fontFamily: 'OpenSans'),
                ),
                currentAccountPicture: new CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(
                    _userName[0],
                    style: TextStyle(fontFamily: 'OpenSans', fontSize: 30),
                  ),
                ),
              ),
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                leading: Icon(Icons.home, color: Colors.black),
                title: Text(
                  'Home',
                  style:
                      TextStyle(fontFamily: 'OpenSans', color: Colors.black54),
                ),
              ),
              Divider(),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchPage(),
                    ),
                  );
                },
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                leading: Icon(Icons.search, color: Colors.black),
                title: Text(
                  'Search',
                  style:
                      TextStyle(fontFamily: 'OpenSans', color: Colors.black54),
                ),
              ),
              Divider(),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutPage(),
                    ),
                  );
                },
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                leading: Icon(Icons.info, color: Colors.black),
                title: Text(
                  'About',
                  style:
                      TextStyle(fontFamily: 'OpenSans', color: Colors.black54),
                ),
              ),
              Divider(),
              ListTile(
                onTap: () async {
                  await _authService.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => Authenticate(),
                      ),
                      (Route<dynamic> route) => false);
                },
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                leading: Icon(
                  Icons.exit_to_app,
                  color: Colors.red,
                ),
                title: Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red[300], fontSize: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
      body: blogPostsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateBlogPage(
                  uid: _user.uid, userName: _userName, userEmail: _userEmail),
            ),
          ).then((value) => setState((){
            _getBlogPosts();
          }));
        },
        child: Icon(Icons.create, color: Colors.white, size: 30.0),
        backgroundColor: Colors.blue,
        elevation: 10,
      ),
    );
  }
}

// GestureDetector(
//           child: blogPostsList(),
//           onVerticalDragDown: (DragDownDetails details) {
//             _getBlogPosts();
//             print("==============================");
//           }),


/*
GestureDetector(
child: Column(
children: [
Container(
width: 200,
height: 200,
color: Colors.amber,
),
Flexible(
child: blogPostsList(),
)
],
),
onVerticalDragDown: (DragDownDetails details) {
_getBlogPosts();
print("=================================================");
},
),
*/


/*
GestureDetector(
        child: Column(
          children: [
            Container(
              width: 200,
              height: 200,
              color: Colors.amber,
            ),
            Flexible(
              child: blogPostsList(),
            )
          ],
        ),
        onVerticalDragDown: (DragDownDetails details) {
          _getBlogPosts();
          print("=================================================");
        },
      ),
*/