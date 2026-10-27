import 'package:flutter/material.dart';
import 'package:petanitech_mobile/core/app_theme.dart';
import 'slider/slider.dart';

class HomeSlider extends StatefulWidget {
  const HomeSlider({super.key});

  @override
  HomeSliderState createState() => HomeSliderState();
}

class HomeSliderState extends State<HomeSlider> {
  int _currentPage = 0;
  final List<Widget> _items = [
    SliderWeather(),
    // SliderDummy(index: 1),
    // SliderDummy(index: 2),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            itemCount: _items.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) => _items[index],
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _items.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: _currentPage == index ? 12.0 : 8.0,
              height: _currentPage == index ? 12.0 : 8.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _currentPage == index
                        ? Colors.white
                        : AppTheme.primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }
}
