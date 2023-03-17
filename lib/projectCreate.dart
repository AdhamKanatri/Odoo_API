import 'package:alalameya_api/customWidget.dart';
import 'package:flutter/material.dart';
import 'package:alalameya_api/main.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class Project extends StatelessWidget {
  static String id = "Project";
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  TextEditingController? nameController;
  String? projectName;
  int? idCreater = 23;

  final orpc = OdooClient(orpcURL);
  bool initialized = false;
  dataLogin() async{
    await orpc.authenticate(database, username, password);
  }

  Future<dynamic> ProjectCreater(String projectName) async {
    return orpc.callKw({
      'model': 'project.project',
      'method': 'create',
      'args': [
        {
        'name': projectName,
          'partner_email': 'gitter@gmail.com',
          'task_count': 5
      }
      ],
      'kwargs': {},
    });
  }

  // Future<dynamic> fetchProjects(String projectName) async{
  //   return orpc.callKw({
  //     'model': 'project.project',
  //     'method': 'write',
  //     'args': [
  //       [1],
  //       {
  //       'name': projectName,
  //       }
  //     ],
  //     'kwargs': {},
  //   });
  // }
  Future<dynamic> fetchProjectsReader() async{
    await dataLogin();
    return orpc.callKw({
      'model': 'project.project',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'context': {'bin_size': true},
        'domain': [],
        'fields': ['id', 'name', 'partner_email', 'task_count'],
        'limit': 80,
      },
    });
  }

  Widget buildListItem(Map<String, dynamic> record) {
    return ListTile(
      title: Text(record['name'].toString()),
      subtitle: Text(record['partner_email'] is String ? '${record['partner_email']}\n${record['task_count'].toString()} Tasks\nid= ${record['id'].toString()}' : ''),
    );
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Add Project')),
          leading: IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back)
          ),
          backgroundColor: Colors.amber,
        ),
        body: Form(
          key: _globalKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Center(child:
                  Text('Please add name of project below',
                  style: TextStyle(fontWeight: FontWeight.bold),)
                ),
                CustomTextFiled(
                  controller: nameController,
                  onSaved: (value){
                    projectName = value!;
                  },
                  hintText: "Enter Project name",
                  icon: Icons.drive_file_rename_outline,
                ),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  color: Colors.amber,
                    onPressed: () async{
                      try {
                        if (_globalKey.currentState!.validate()) {
                          _globalKey.currentState!.save();
                          await ProjectCreater(projectName! );
                          Navigator.popAndPushNamed(context, Project.id);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Project added successflly"),
                          ));
                        }

                      } on OdooException catch (e) {
                        print("Odoo Exception $e");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Pleas enter correct project name"),
                        ));
                      }
                    },
                    child: Text("Add Now"),
                ),
          Expanded(
            child: Center(
              child: FutureBuilder(
                  future: fetchProjectsReader(),
                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
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
                  }
                  ),
            ),
          )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
