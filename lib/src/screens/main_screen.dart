import 'package:cocktailr/src/blocs/main_navigation_bloc.dart';
import 'package:cocktailr/src/screens/cocktail_list/cocktail_list_screen.dart';
import 'package:cocktailr/src/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PageController _controller;

  final Map<String, Widget> _screens = Map.fromEntries([
    MapEntry<String, Widget>(
      "Explore",
      HomeScreen(),
    ),
    MapEntry<String, Widget>(
      "Cocktails",
      CocktailListScreen(),
    ),
  ]);

  void _onPageChanged(int index, MainNavigationBloc bloc) =>
      bloc.changeCurrentIndex(index);

  void _animateToPage(int index) => _controller.animateToPage(
        index,
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      );

  Future<void> _onSearchIconPressed(BuildContext context) async =>
      Navigator.pushNamed(context, '/search');

  Future<bool> _onWillPop(int index, MainNavigationBloc bloc) {
    if (index == 0) {
      return Future.value(true);
    } else {
      _animateToPage(0);
      bloc.changeCurrentIndex(0);
      return Future.value(false);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainNavigationBloc = Provider.of<MainNavigationBloc>(context);

    return StreamBuilder(
      stream: mainNavigationBloc.currentIndex,
      initialData: 0,
      builder: (context, snapshot) {
        if (snapshot.data != 0) _animateToPage(snapshot.data);

        return WillPopScope(
          onWillPop: () => _onWillPop(snapshot.data, mainNavigationBloc),
          child: Scaffold(
            appBar: AppBar(
              title: Text(_screens.keys.toList()[snapshot.data]),
              centerTitle: true,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _onSearchIconPressed(context),
                  tooltip: "Search cocktails",
                )
              ],
            ),
            body: PageView(
              controller: _controller,
              children: _screens.values.toList(),
              onPageChanged: (int index) => _onPageChanged(
                index,
                mainNavigationBloc,
              ),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(snapshot.data),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(int index) => BottomNavigationBar(
        currentIndex: index,
        items: [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.compass),
            title: Text("Explore"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_bar),
            title: Text("Cocktails"),
          ),
        ],
        onTap: _animateToPage,
        type: BottomNavigationBarType.fixed,
      );
}