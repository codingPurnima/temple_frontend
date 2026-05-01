import 'package:flutter/material.dart';

class QuoteScreen extends StatelessWidget {
  const QuoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("सुविचार"),
      ),
      body: Center(
        child: Container(
          height: 450,
          width: 275,
          decoration: BoxDecoration(
            color: const Color(0xFFDCE6F1),
            borderRadius: BorderRadius.circular(15)
          ),
          child: Center(child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text("हरि मिले तो वैकुंठ दिलवे। \nहरिजन मिले तो हरि सौं मिलावे।।", style: TextStyle(
              fontSize: 40, 
              fontWeight: FontWeight.w700,
              color: const Color.fromARGB(255, 6, 24, 39),
            ),),
          ))
        ),
      ),
    );
  }
}