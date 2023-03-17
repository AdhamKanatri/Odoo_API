import 'dart:io';
import 'package:alalameya_api/Models/AddContactsModel.dart';
import 'package:alalameya_api/Models/createrModel.dart';
import 'package:alalameya_api/Contacts/contacts.dart';
import 'package:alalameya_api/customWidget.dart';
import 'package:alalameya_api/products.dart';
import 'package:alalameya_api/projectCreate.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:flutter/material.dart';

//Home: 192.168.1.111
//Mobile: 192.168.43.132
String orpcURL = 'http://192.168.1.11:8069';
String database = 'AdhamDB', username = 'admin', password = '0509659659';

void main()  {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        HomePage.id : (context) => HomePage(),
        Project.id : (context) => Project(),
        Contacts.id : (context) => Contacts(),
        Products.id : (context) => Products(),
        CreateModel.id : (context) => CreateModel(),
        AddContactsModel.id : (context) => AddContactsModel(),
      },
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  static String id = "HomePage";
  TextEditingController? ipController, databaseController, userController, passwordController;
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  showLoaderDialog(BuildContext context){
    AlertDialog alert=AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amberAccent),),
          Container(margin: EdgeInsets.only(left: 7),child:Text("Loading..." )),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
        ),
        body: Form(
          key: _globalKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CustomTextFiled(
                    controller: ipController,
                    onSaved: (value){
                      if (value!.trim().isNotEmpty) {
                        orpcURL = "http://${value.trim()}:8069";
                      } else if (value.trim().isEmpty){
                        orpcURL = "http://192.168.1.11:8069";
                      }
                    },
                    hintText: "Default IP: 192.168.1.11",
                    icon: Icons.http,
                  ),
                  CustomTextFiled(
                    controller: databaseController,
                    onSaved: (value){
                      if (value!.trim().isNotEmpty) {
                        database = value!;
                      } else if (value.trim().isEmpty){
                        database = "AdhamDB";
                      }
                    },
                    hintText: "Default Database: AdhamDB",
                    icon: Icons.data_array,

                  ),
                  CustomTextFiled(
                    controller: userController,
                    onSaved: (value){
                      username = value!;
                    },
                    hintText: "Enter User Name",
                    icon: Icons.person,
                  ),
                  CustomTextFiled(
                    controller: passwordController,
                    onSaved: (value){
                      password = value!;
                    },
                    hintText: "Enter Password",
                    icon: Icons.password,
                  ),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    color: Colors.amber,
                    onPressed: () async{
                        if (_globalKey.currentState!.validate()) {
                          showLoaderDialog(context);
                          _globalKey.currentState!.save();
                          try {
                            final orpc = await OdooClient(orpcURL);
                            try {
                              await orpc.authenticate(database, username, password);
                              Navigator.popAndPushNamed(context, Contacts.id);
                            } on OdooException catch (e) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Pleas enter correct Username or Password"),
                              ));
                            }
                          } on Exception catch (e) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Pleas check your Odoo IP"),
                            ));
                          }

                        }
                    },
                    child: Text("Add Now"),
                  ),
                ],
              ),
            )
          ),
        ),
      ),
    );
  }
}