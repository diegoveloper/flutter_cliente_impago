import 'package:audioplayers/audioplayers.dart';
import 'package:cliente_impago/widgets/gravity.dart';
import 'package:cliente_impago/widgets/saw.dart';
import 'package:flutter/material.dart';
import 'package:snappable_thanos/snappable_thanos.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample by diegoveloper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: const Dashboard(),
    );
  }
}

enum AlertType {
  gravity,
  windows,
  snap,
  saw,
}

class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final gravityController = GravityController();
  bool _showWarning = false;
  bool _windowsError = false;
  final player = AudioPlayer();
  final extraPlayer = AudioPlayer();
  final key = GlobalKey<SnappableState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  AlertType type = AlertType.saw;

  void _selectOption(AlertType alertType) {
    setState(() {
      type = alertType;
    });
    scaffoldKey.currentState?.closeDrawer();
  }

  @override
  void dispose() {
    player.dispose();
    extraPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _windowsError
        ? Image.asset(
            'assets/extras/windows.jpg',
          )
        : Scaffold(
            key: scaffoldKey,
            drawer: Drawer(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MaterialButton(
                      color: Colors.blue,
                      child: const Text(
                        'Gravity',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        _selectOption(AlertType.gravity);
                      },
                    ),
                    MaterialButton(
                      color: Colors.blue,
                      child: const Text(
                        'Windows Error',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        _selectOption(AlertType.windows);
                      },
                    ),
                    MaterialButton(
                      color: Colors.blue,
                      child: const Text(
                        'Thanos Snap',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        _selectOption(AlertType.snap);
                      },
                    ),
                    MaterialButton(
                      color: Colors.blue,
                      child: const Text(
                        'Saw',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        _selectOption(AlertType.saw);
                      },
                    ),
                  ],
                ),
              ),
            ),
            appBar: AppBar(
              centerTitle: false,
              iconTheme: const IconThemeData(
                color: Colors.black,
              ),
              title: const Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 33,
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: [
                if (!_showWarning)
                  GravityWidget(
                    controller: gravityController,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: CircleAvatar(
                        foregroundImage: NetworkImage(
                            'https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50?s=200'),
                      ),
                    ),
                  ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Snappable(
                key: key,
                duration: const Duration(milliseconds: 3900),
                onSnapped: () {},
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GravityWidget(
                        controller: gravityController,
                        child: Image.asset('assets/ui/current_spend.png'),
                      ),
                      const SizedBox(height: 50),
                      GravityWidget(
                        controller: gravityController,
                        child: Image.asset(
                          'assets/ui/daily_spends.png',
                        ),
                      ),
                      const SizedBox(height: 20),
                      GravityWidget(
                        controller: gravityController,
                        child: Image.asset('assets/ui/whishlist.png'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            extendBody: true,
            bottomNavigationBar: const _MyBottomNavigation(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: _showWarning
                ? null
                : FloatingActionButton(
                    backgroundColor: Colors.blue[700],
                    child: const Icon(Icons.add),
                    onPressed: () async {
                      bool showAlertDialog = true;
                      if (type == AlertType.gravity) {
                        gravityController.start();
                        await Future.delayed(const Duration(milliseconds: 300));
                        await player.play(AssetSource('sounds/gravity.wav'));
                        await Future.delayed(const Duration(seconds: 3));
                      } else if (type == AlertType.snap) {
                        await extraPlayer
                            .seek(const Duration(milliseconds: 150));
                        await extraPlayer.play(AssetSource('sounds/snap.mp3'));
                        key.currentState?.snap();
                        await player.play(AssetSource('sounds/thanos.aac'));
                        await Future.delayed(const Duration(seconds: 4));
                      } else if (type == AlertType.windows) {
                        await player.seek(const Duration(milliseconds: 500));
                        await player
                            .play(AssetSource('sounds/error_windows.mp3'));
                        setState(() {
                          _windowsError = true;
                        });
                        await Future.delayed(const Duration(seconds: 3));
                      } else if (type == AlertType.saw) {
                        showAlertDialog = false;
                        if (mounted) {
                          Navigator.of(context).push(
                            PageRouteBuilder(pageBuilder: (_, animate, __) {
                              return const Saw();
                            }),
                          );
                        }
                      }
                      if (showAlertDialog) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          barrierColor: Colors.transparent,
                          builder: (_) => AlertDialog(
                            backgroundColor: Colors.transparent,
                            content: _PayYourDebt(() {
                              Navigator.of(context).pop();
                              setState(() {
                                key.currentState?.reset();
                                _showWarning = false;
                                _windowsError = false;
                              });
                            }),
                          ),
                        );
                      }
                    },
                  ),
          );
  }
}

class _MyBottomNavigation extends StatelessWidget {
  const _MyBottomNavigation({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: kToolbarHeight,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black38.withOpacity(0.1),
              offset: const Offset(0, -5),
              blurRadius: 5,
            ),
          ],
        ),
        child: Container(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Icon(Icons.home_outlined),
                    Icon(Icons.favorite_outlined),
                  ],
                ),
              ),
              const Spacer(
                flex: 2,
              ),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Icon(Icons.place_outlined),
                    Icon(Icons.person_outlined),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PayYourDebt extends StatelessWidget {
  const _PayYourDebt(
    this.onTap,
  );

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.red,
        ),
        height: 200,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Paga tu deuda!!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 33,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Plazo máximo: 2 horas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
