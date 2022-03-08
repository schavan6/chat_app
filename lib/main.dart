import 'package:fanpage/services/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'app/landing_page.dart';
//flutter run -d chrome --web-port=7357
Future<void> main() async {

  if(Firebase.apps.isEmpty){
    try{
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(// Replace with actual values
        options: const FirebaseOptions(
          apiKey: "AIzaSyD-NdImhD6yMJJ-DIXrcS4qN1zlRD5MVdI",
          appId: "1:513467503421:web:ed82e135b0d12df928eb54",
          messagingSenderId: "513467503421",
          projectId: "fanpage-12ec4",
        ),);


    }catch(e){
      print(e);
    }
  }
  else{
    Firebase.app();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fanpage',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: Splash2(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Splash2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 3,
      navigateAfterSeconds: SecondScreen(),
      image: Image.asset('images/me.png',fit:BoxFit.contain),
      loadingText: const Text("Loading"),
      photoSize: 100.0,
      loaderColor: Colors.blue,
    );
  }
}

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fanpage',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: LandingPage(
        auth: Auth(),
      ),
    );
  }
}
