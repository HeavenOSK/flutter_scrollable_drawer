import 'package:flutter/material.dart';
import 'package:scrollable_drawer/scrollable_drawer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return ScrollableDrawerScaffold(
      body: Builder(
        builder: (context) {
          final drawerScaffold = ScrollableDrawerScaffold.of(context);
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  drawerScaffold.openDrawer();
                },
                icon: Icon(Icons.menu),
              ),
            ),
          );
        },
      ),
      bodyOverlayBuilder: (context, scrollingProgress, child) {
        final opacity = (1 - scrollingProgress) * 0.6;
        return Stack(
          children: [
            child,
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withOpacity(opacity),
                ),
              ),
            )
          ],
        );
      },
      drawer: Container(color: Colors.deepPurple),
    );
  }
}
