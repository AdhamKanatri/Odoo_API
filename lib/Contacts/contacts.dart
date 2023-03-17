import 'package:alalameya_api/Models/AddContactsModel.dart';
import 'package:alalameya_api/main.dart';
import 'package:alalameya_api/projectCreate.dart';
import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class Contacts extends StatelessWidget {
  static String id = "Contacts";
  final orpc = OdooClient(orpcURL);
  dataLogin() async{
    await orpc.authenticate(database, username, password);
  }


  Future<dynamic> fetchContacts() async{
    await dataLogin();
    return orpc.callKw({
      'model': 'res.partner',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'context': {'bin_size': true},
        'domain': [],
        'fields': ['id', 'name', 'email', '__last_update','is_company','image_128'],
        'limit': 80,
      },
    });
  }


  Widget buildListItem(Map<String, dynamic> record) {
    var unique = record['__last_update'] as String;
    unique = unique.replaceAll(RegExp(r'[^0-9]'), '');
    final avatarUrl =
        '${orpcURL}web/image?model=res.partner&id=${record["id"]}&field=avatar_128&unique=$unique';
    return ListTile(
      leading: Icon(Icons.person_pin),
      title: Text(record['name']),
      subtitle: Text(record['email'] is String ? '${record['email']}\n${isCompany(record['is_company'])}' : ''),
    );
  }

  String isCompany(bool state){
    if(state == true){
      return "Company";
    }else{
      return "Individual";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Contacts')),
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.logout)
        ),
        actions: [
          GestureDetector(
            onTap: (){
              Navigator.pushNamed(context, Project.id);
            },
            child: Row(
              children: [
                Text("Add project"),
                Icon(Icons.publish_rounded),
              ],
            ),
          )
        ],
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: FutureBuilder(
            future: fetchContacts(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                  AddContactsModel.companyNameList.clear();
                  int i = 0 ;
                  while( snapshot.data.length > i){
                    AddContactsModel.companyNameList.add(snapshot.data[i]['name']);
                    i++;
                  }
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      final record =
                      snapshot.data[index] as Map<String, dynamic>;
                      return buildListItem(record);
                    });
              } else {
                if (snapshot.hasError) return Text('Unable to fetch data');
                return CircularProgressIndicator();
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pushNamed(context, AddContactsModel.id);
        },
        child: Icon(Icons.person_add),
      ),
    );
  }
}