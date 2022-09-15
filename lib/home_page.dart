import 'package:flutter/material.dart';
import 'package:bluedot_point_sdk/bluedot_point_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _installRef = '';
  String _sdkVersion = '';
  String _projectId = '';

  @override
  void initState() {
    super.initState();
    BluedotPointSdk.instance.getInstallRef().then((value) {
      setState(() {
        _installRef = value;
      });
    });
    BluedotPointSdk.instance.getSDKVersion().then((value) {
      setState(() {
        _sdkVersion = value;
      });
    });

    _retrieveProjectId();
  }

  void _openGeoTriggeringPage() {
    Navigator.pushNamed(context, '/geo-triggering');
  }

  void _openTempoPage() {
    Navigator.pushNamed(context, '/tempo');
  }

  void _resetSdk() {
    // Reset Bluedot Point SDK
    BluedotPointSdk.instance.reset().then((value) {
      Navigator.pop(context);
      _clearSharedPreferences();
    });
  }

  void _retrieveProjectId() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    var projectId = sharedPrefs.getString('projectId') ?? '';
    setState(() {
      _projectId = projectId;
    });
  }

  void _clearSharedPreferences() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.remove('destinationId');
    await sharedPrefs.remove('projectId');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(
          child: Scaffold(
              appBar: AppBar(
                title: const Text('Home Page'),
                automaticallyImplyLeading: false,
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Flutter Bluedot Point SDK',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const Text(
                        'Project Id:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(_projectId),
                      const Text(
                        'Install Reference',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(_installRef),
                      const Text(
                        'SDK Version',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(_sdkVersion),
                      ElevatedButton(
                          onPressed: _openGeoTriggeringPage,
                          child: const Text('GEO-TRIGGERING')),
                      ElevatedButton(
                          onPressed: _openTempoPage, child: const Text('TEMPO')),
                      ElevatedButton(
                          onPressed: _resetSdk, child: const Text('RESET SDK')),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
