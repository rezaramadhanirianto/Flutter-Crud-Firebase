import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //
  bool showTextField = false;
  TextEditingController controller = TextEditingController();
  String collectionName = "Users";
  bool isEditing = false;
  User curUser;

  button() {
    return SizedBox(
      width: double.infinity,
      child: OutlineButton(
        child: Text(isEditing ? "UPDATE" : "ADD DATA"),
        onPressed: () {
          add();
          setState(() {

           showTextField = false; 
          });
        },
      ),
    );
  }

  getUsers() {
    return Firestore.instance.collection(collectionName).snapshots();
  }

  addUser() {
    User user = User(name: controller.text);
    try {
      Firestore.instance.runTransaction((Transaction transaction) async {
        Firestore.instance
            .collection(collectionName)
            .document()
            .setData(user.toJson());
      });
    } catch (e) {
      print(e.toString());
    }
  }

  add() {
    if (isEditing) {
      update(curUser, controller.text);
      setState(() {
       isEditing = false; 
      });
    } else {
      addUser();
    }
    controller.text = "";
  }

  update(User user, String newName) {
    Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.update(user.reference, {'name': newName});
    });
  }

  delete(User user) {
      
      Firestore.instance.runTransaction((Transaction transaction) async{
        await transaction.delete(user.reference);
      });
    
  }

  Widget buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error");
        }
        if (snapshot.hasData) {
          print("Documents ${snapshot.data.documents.length}");
          return buildList(context, snapshot.data.documents);
        }
        return CircularProgressIndicator();
      },
    );
  }

  Widget buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      children: snapshot.map((data) => buildListItem(context, data)).toList(),
    );
  }

  Widget buildListItem(BuildContext context, DocumentSnapshot data) {
    final user = User.fromSnapshot(data);
    return Padding(
      key: ValueKey(user.name),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0)),
          child: ListTile(
            title: Text(user.name),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                delete(user);
              },
            ),
            onTap: () {
              setUpdateUI(user);
            },
          )),
    );
  }
setUpdateUI(User user){
  controller.text = user.name;
  setState(() {
   showTextField = true;
   isEditing = true;
   curUser = user;
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("CloudFireStore Demo"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                showTextField = !showTextField;
              });
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            showTextField
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                            labelText: "Name", hintText: "Name"),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      button(),
                    ],
                  )
                : Container(),
            SizedBox(
              height: 20,
            ),
            Text(
              "Users",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            SizedBox(
              height: 20,
            ),
            Flexible(
              child: buildBody(context),
            )
          ],
        ),
      ),
    );
  }
}
