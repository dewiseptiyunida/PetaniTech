import 'package:flutter/material.dart';

class SliderDummy extends StatelessWidget {
  final int index;
  const SliderDummy({super.key, this.index = 0});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color:
                index == 0
                    ? Colors.blue
                    : index == 1
                    ? Colors.green
                    : Colors.red,
          ),
          child: Center(
            child: Text(
              'Slide ${index + 1}',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}
