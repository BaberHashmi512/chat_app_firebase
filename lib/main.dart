// import 'package:chat_app/Models/FirebaseHelper.dart';
// import 'package:chat_app/screens/auth.dart';
// import 'package:chat_app/screens/home_list_screen.dart';
// import 'package:chat_app/screens/splash.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'Models/UserModel.dart';
// import 'firebase_options.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp( MyApp());
// }
//
// class MyApp extends StatelessWidget {
//
//   const MyApp({super.key,});
//
//   @override
//   Widget build(BuildContext context) {
//     final UserModel userModel;
//     final User firebaseUser;
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Chat App',
//       theme: ThemeData().copyWith(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color.fromARGB(255, 63, 17, 177),
//         ),
//       ),
//       home: StreamBuilder(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (ctx, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const SplashScreen();
//           }
//           if (snapshot.hasData) {
//             return  HomeChat(
//                 userModel: userModel,
//                 firebaseUser: firebaseuser,
//             );
//           }
//           return const AuthScreen();
//         },
//       ),
//     );
//   }
// }

import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/screens/auth.dart';
import 'package:chat_app/screens/home_list_screen.dart';
import 'package:chat_app/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'Models/FirebaseHelper.dart';
import 'Models/UserModel.dart';

var uuid = const Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    // Logged In
    UserModel? thisUserModel =
        await FirebaseHelper.getGroupUserModelById(currentUser.uid);
    if (thisUserModel != null) {
      runApp(
          MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));
    } else {
    runApp(const MyApp());
    }
  } else {
      runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthScreen()
      // StreamBuilder(
      //   stream: FirebaseAuth.instance.authStateChanges(),
      //   builder: (ctx, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const SplashScreen();
      //     }
      //     if (snapshot.hasData) {
      //       return  HomeChat(
      //           userModel: UserModel(),
      //           firebaseUser: snapshot.data as User,.3-
      //       );
      //     }
      //     return const AuthScreen();
      //   },
      // ),
    );
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn(
      {Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 63, 17, 177),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: HomeChat(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
