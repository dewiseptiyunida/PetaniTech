import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:petanitech_mobile/core/assets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(PTAsset.bgLogin, fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.3),
            ), // kalau menggunakan fungsi lain seperti .withAlpha((0.6 * 255).toInt()) maka akan error --> aneh padahal withOpacity sudah deprecated
          ),
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 70, bottom: 30),
                child: Image.asset(PTAsset.logo, width: 150),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.8 * 255).toInt()),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: EdgeInsets.only(top: 10),
                  child: RouterOutlet(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
