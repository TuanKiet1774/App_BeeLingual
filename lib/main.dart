import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view/account/log_in_page.dart';
import 'component/navigation.dart';
import 'component/profileProvider.dart';
import 'component/progressProvider.dart';
import 'controller/vocabController.dart';
import 'controller/authController.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserVocabulary>(
          create: (context) => UserVocabulary(context),
        ),
        ChangeNotifierProvider<UserProfileProvider>(
          create: (context) => UserProfileProvider()..reloadProfile(context),
        ),
        ChangeNotifierProvider<ProgressProvider>(
          create: (context) => ProgressProvider(context),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Beelingual",
        home: FutureBuilder<bool>(
          future: SessionManager().isLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Colors.amber),
                ),
              );
            }
            if (snapshot.hasData && snapshot.data == true) {
              return const home_navigation();
            } else {
              return const PageLogIn();
            }
          },
        ),
      ),
    );
  }
}