import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;

import 'package:new_version/new_version.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Halal Business Platform',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  bool loader = true;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    camerapermission();
    _checkVersion();
    initConnectivity();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  camerapermission() async {
    await Permission.camera.request ();
  }

  void _checkVersion() async {
    final newVersion = NewVersion();

    final status = await newVersion.getVersionStatus();
    print(status?.localVersion.toString());
    print(status?.storeVersion.toString());

    if(status?.localVersion.toString() != status?.storeVersion.toString())
    {
      print("Update availabe");
      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status!,
        dialogTitle: "Update Available",
        dismissButtonText: "Skip",
        dialogText: "You're missing out something!",
        dismissAction: () {
          Get.back();
        },
        updateButtonText: "Update Now",
      );
    }
    else
    {print("Update not availabe");}
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.orange,
      statusBarIconBrightness: Brightness.light,
    ));
    return _connectionStatus.toString() != "ConnectivityResult.none" ?
      SafeArea(
        child: Scaffold(
        // appBar: AppBar(
        //   title: Center(child: Text("CarbonCodes")),
        // ),
        body: Stack(
          children: [
            Positioned.fill(
              child: WebView(
                initialUrl: 'http://muskanmartbd.com',
                javascriptMode: JavascriptMode.unrestricted,
                onProgress: (int progress) {
                  print("WebView is loading (progress : $progress%)");
                },
                navigationDelegate: (NavigationRequest request) {
                  if (request.url.startsWith('https://www.youtube.com/')) {
                    print('blocking navigation to $request}');
                    return NavigationDecision.prevent;
                  }
                  print('allowing navigation to $request');
                  return NavigationDecision.navigate;
                },
                onPageStarted: (String url) {
                  setState(() {
                    loader = true;
                  });
                },
                onPageFinished: (String url) {
                  setState(() {
                    loader = false;
                  });
                },
                gestureNavigationEnabled: true,
                geolocationEnabled: false,//support geolocation or not
              ),
            ),
            if (loader)
              Positioned.fill(
                child: Container(
                  color: Colors.white,
                  child: Center(child: CircularProgressIndicator(color: Colors.orange,)),
                ),
              ),
          ],
        ),
    ),
      )
        : Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(
          image: AssetImage("assets/nointernet.png"),
          height: 300,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
