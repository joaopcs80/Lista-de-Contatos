import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'people_list_screen.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 3000,
      splash: const Column(
        mainAxisAlignment: MainAxisAlignment.center, // Alinha o conteúdo verticalmente no centro
        children: [
          Icon(
            FontAwesomeIcons.addressBook,
            size: 100,
            color: Colors.white,
          ),
          SizedBox(height: 20),
          Text(
            'Cadastro de Contatos',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ],
      ),
      nextScreen: PeopleListScreen(),
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Colors.blue,
    );
  }
}
