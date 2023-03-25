import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFiled extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String?)? onSaved;
  final String? hintText;
  final IconData? icon;
  final bool isNumber;
  CustomTextFiled(
      { Key? key,
        required this.controller,
        required this.onSaved,
        required this.hintText,
        required this.icon,
        this.isNumber = false,
      }
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: TextFormField(
        validator: (value) {
          if (value!.isEmpty && hintText == "Enter Project name") {
            return "Please enter name of project";
          }
          if (value!.isEmpty && hintText == "Enter User Name") {
            return "Please enter your user name";
          }
          if (value!.isEmpty && hintText == "Enter Password") {
            return "Please enter password";
          }
          if (value!.isEmpty && hintText == "Enter product name") {
            return "Please enter name of product";
          }if (value!.isEmpty && hintText == "Price") {
            return "Please enter Price";
          }if (value!.isEmpty && hintText == "Cost") {
            return "Please enter Cost";
          }if (value!.isEmpty && hintText == "Enter name") {
            return "Please enter name";
          }if (value!.isEmpty && hintText == "Enter email") {
            return "Please enter email";
          }if (value!.isEmpty && hintText == "Enter Mobile Number") {
            return "Please enter Mobile Number";
          }
        },
        controller: controller,
        onSaved: onSaved,
        cursorColor: Colors.amberAccent,
        keyboardType: isNumber ? TextInputType.number: TextInputType.name,
        inputFormatters: isNumber ? [
          FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
          TextInputFormatter.withFunction((oldValue, newValue) {
            try {
              final text = newValue.text;
              if (text.isNotEmpty) double.parse(text);
              return newValue;
            } catch (e) {}
            return oldValue;
          }),
        ]: [],
        decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(
              icon,
              color: Colors.lightBlueAccent,
            ),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide(color: Colors.white)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide(color: Colors.red)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide(color: Colors.red)),
            errorStyle:
            TextStyle(color: Colors.redAccent[100], fontWeight: FontWeight.w700,)),
        obscureText: hintText == "Enter Password" ? true : false,
      ),
    );
  }
}

