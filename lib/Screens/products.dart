import 'package:alalameya_api/Custom%20Widgets/BottomBarWidget.dart';
import 'package:alalameya_api/Models/createrModel.dart';
import 'package:alalameya_api/Custom%20Widgets/TextWidget.dart';
import 'package:flutter/material.dart';
import 'package:alalameya_api/main.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class Products extends StatelessWidget {
  static String id = "Products";
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  TextEditingController? productController;
  String? productName;

  final orpc = OdooClient(orpcURL);
  bool initialized = false;
  dataLogin() async{
    await orpc.authenticate(database, username, password);
  }

  Future<dynamic> ProductCreater(String productName) async {
    return orpc.callKw({
      'model': 'product.template',
      'method': 'create',
      'args': [
        {
          'name': productName,
          'partner_email': 'gitter@gmail.com',
          'task_count': 5
        }
      ],
      'kwargs': {},
    });
  }

  Future<dynamic> searchForID(String name) async {
    return orpc.callKw({
      'model': 'product.template',
      'method': 'search',
      'args': [
        [['name', '=' ,name]]
      ],
      'kwargs': {},
    });
  }

  Future<dynamic> productsEditor(String name,double cost) async{
    final productID = await searchForID(name);
    return orpc.callKw({
      'model': 'product.template',
      'method': 'write',
      'args': [
        productID,
        {
        'standard_price': cost,
        }
      ],
      'kwargs': {},
    });
  }
  Future<dynamic> fetchProductsReader() async{
    await dataLogin();
    return orpc.callKw({
      'model': 'product.template',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'context': {'bin_size': true},
        'domain': [],
        'fields': ['id', 'name', 'standard_price', 'default_code'],
        'limit': 80,
      },
    });
  }

  Widget buildListItem(Map<String, dynamic> record) {
    return ListTile(
      title: Text(record['name'].toString()),
      subtitle: Text(record['default_code'] is String ? '${record['default_code']}\n${record['standard_price'].toString()} Tasks\nid= ${record['id'].toString()}' : ''),
    );
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Product list')),
          // leading: IconButton(
          //     onPressed: (){
          //       Navigator.pop(context);
          //     },
          //     icon: Icon(Icons.arrow_back)
          // ),
          backgroundColor: Colors.amber,
        ),
        body: Form(
          key: _globalKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: FutureBuilder(
                        future: fetchProductsReader(),
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
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.pushNamed(context, CreateModel.id);
          },
          child: Icon(Icons.add_business),
        ),
        bottomNavigationBar: BottomBar(bottmBarIndex: 0,),
      ),
    );
  }
}
