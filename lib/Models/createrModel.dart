import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:alalameya_api/Custom%20Widgets/TextWidget.dart';
import 'package:alalameya_api/main.dart';
import 'package:alalameya_api/Screens/products.dart';
import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class CreateModel extends StatelessWidget {
  static String id = 'CreateModel';
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  TextEditingController? productController, priceController;
  String? productName;
  String productCategory = 'Service';
  int productType = 0;
  double price = 0, cost = 0;
  List<String> categoryList = ['All'];
  Map<String, String> typeList = {'Service':'service', 'Consumable':'consu'};



  final orpc = OdooClient(orpcURL);

  dataLogin() async{
    await orpc.authenticate(database, username, password);
  }

  Future<dynamic> createMethod(String productName, String productCategory, int productType) async {
    await dataLogin();
    return orpc.callKw({
      'model': 'product.template',
      'method': 'create',
      'args': [
        {
          'name': productName,
          'detailed_type':  typeList[productCategory] ,
          'list_price': price,
          'categ_id': productType + 1,
          'standard_price': cost
        }
      ],
      'kwargs': {},
    });
  }
  Future<dynamic> readerMethod() async {
    try {
      await dataLogin();
      final List<dynamic> dataReader = await orpc.callKw({
        'model': 'product.category',
        'method': 'search_read',
        'args': [
        ],
        'kwargs': {
          'fields': ['display_name'],
        },
      });
      if (dataReader.isNotEmpty) {
        categoryList.clear();
        int i = 0 ;
        while( dataReader.length > i){
          categoryList.add(dataReader[i]['display_name']);
          i++;
        }
        return dataReader;
      }
    } on Exception catch (e) {
      // TODO
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:Scaffold(
        appBar: AppBar(
        ),
        body: Form(
          key: _globalKey,
          child: FutureBuilder(
              future: readerMethod(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      CustomTextFiled(
                        controller: productController,
                        onSaved: (value) {
                          productName = value!;
                        },
                        hintText: "Enter product name",
                        icon: Icons.drive_file_rename_outline,
                      ),
                      Wrap(
                        runAlignment: WrapAlignment.spaceAround,
                        children: [
                          SizedBox(
                            width: 150,
                            child: CustomDropList(
                              dropList: ['Service', 'Consumable'],
                              hintText: 'Service',
                              onSaved: (value) {
                                productCategory = value!;
                              },
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: CustomTextFiled(
                              controller: priceController,
                              onSaved: (value) {
                                cost = double.parse(value!);
                              },
                              hintText: "Cost",
                              icon: Icons.price_change,
                              isNumber: true,
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: CustomTextFiled(
                              controller: priceController,
                              onSaved: (value) {
                                price = double.parse(value!);
                              },
                              hintText: "Price",
                              icon: Icons.price_change,
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                      CustomDropList(
                        dropList: categoryList,
                        hintText: 'All',
                        onSaved: (value) {
                          productType = categoryList.indexOf(value!);
                        },
                        isExpanded: true,
                      ),
                      // CustomTextFiled(
                      //   controller: productController,
                      //   onSaved: (value){
                      //     productName = value!;
                      //   },
                      //   hintText: "Enter product name",
                      //   icon: Icons.drive_file_rename_outline,
                      // ),
                      // CustomTextFiled(
                      //   controller: productController,
                      //   onSaved: (value){
                      //     productName = value!;
                      //   },
                      //   hintText: "Enter product name",
                      //   icon: Icons.drive_file_rename_outline,
                      // ),
                      // CustomTextFiled(
                      //   controller: productController,
                      //   onSaved: (value){
                      //     productName = value!;
                      //   },
                      //   hintText: "Enter product name",
                      //   icon: Icons.drive_file_rename_outline,
                      // ),
                      MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        color: Colors.amber,
                        onPressed: () async {
                          try {
                            if (_globalKey.currentState!.validate()) {
                              _globalKey.currentState!.save();
                              await createMethod(productName!, productCategory, productType);
                              Navigator.popAndPushNamed(context, Products.id);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("product edited successflly"),
                              ));
                            }
                          } on OdooException catch (e) {
                            print("Odoo Exception $e");
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Pleas enter correct product name"),
                            ));
                          }
                        },
                        child: Text("Add Now"),
                      ),
                    ],
                  );
                }else {
                  if (snapshot.hasError) return Text('Unable to fetch data');
                  return Center(child: CircularProgressIndicator());
                }
              }
          ),
        ),
      )
    );
  }
}

class CustomDropList extends StatefulWidget {
  final void Function(String?)? onSaved;
  final List<String>? dropList;
  late String hintText;
  final bool isExpanded;
  CustomDropList({
    Key? key,
    required this.onSaved,
    required this.dropList,
    required this.hintText,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  State<CustomDropList> createState() => _CustomDropListState();
}

class _CustomDropListState extends State<CustomDropList> {
  // List of items in our dropdown menu
/*
  // Reading bytes from a network image
  Future<Int8List> readNetworkImage(String imageUrl) async {
    final ByteData data =
    await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl);
    final Int8List bytes = data.buffer.asInt8List();
    return bytes;
  }

  Future<Int8List> binaryImage() async {
    const String imageUrl =
        'https://i.postimg.cc/cCg0QyDN/E8215-D-WG.jpg';

    final bytes = await readNetworkImage(imageUrl);
    print(bytes);
    return bytes;
  }*/

    // final image = await binaryImage();
    // String url='https://i.postimg.cc/cCg0QyDN/E8215-D-WG.jpg';


  @override
  Widget build(BuildContext context) {
    setState(() {
      widget.dropList;
    });
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButton(
          isExpanded: widget.isExpanded,

          // Initial Value
          value: widget.hintText,

          // Down Arrow Icon
          icon: const Icon(Icons.keyboard_arrow_down),

          // Array list of items
          items: widget.dropList!.map((String items) {
            return DropdownMenuItem(
              value: items,
              child: Text(items),
            );
          }).toList(),
          // After selecting the desired option,it will
          // change button value to selected value
          onChanged: (String? newValue) {
            setState(() {
              widget.onSaved!(newValue!);
              widget.hintText = newValue!;
            });
          },
        ),
      ),
    );
  }
}