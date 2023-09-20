import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future _checkConnection() async {
    return await InternetConnectionChecker().hasConnection;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(100, 16, 15, 22),
      body: FutureBuilder(
        future: _checkConnection(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.data == false) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.hasConnectionFalse,
                  style: const TextStyle(
                      color: Color.fromARGB(100, 224, 224, 224),
                      fontSize: 24,
                      fontWeight: FontWeight.w500),
                ),
              );
            } else {
              return const Text('data');
            }
          }
        },
      ),
    );
  }
}
