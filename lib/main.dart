import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'src/shared/helpers/hive_helper.dart';

late final FirebaseApp firebaseApp;
late final FirebaseAuth firebaseAuth;

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper.instance.init();
  firebaseApp = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  firebaseAuth = FirebaseAuth.instanceFor(app: firebaseApp);

  // This allows your app to store a copy of the data locally on the device
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  FlutterNativeSplash.remove();
  runApp(const MyApp());
}
