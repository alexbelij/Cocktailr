import 'package:cocktailr/src/blocs/cocktail_bloc.dart';
import 'package:cocktailr/src/blocs/ingredient_bloc.dart';
import 'package:cocktailr/src/blocs/main_navigation_bloc.dart';
import 'package:cocktailr/src/blocs/search_bloc.dart';
import 'package:cocktailr/src/utils/platform_utils.dart';
import 'package:cocktailr/src/widgets/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  SearchBloc _searchBloc;
  TextEditingController _textEditingController;

  List<String> _filterIngredients(List<String> ingredients, String keyword) {
    List<String> filteredIngredients = [...ingredients];

    if (keyword != null && keyword.isNotEmpty) {
      filteredIngredients = filteredIngredients
          .where((i) => i.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }

    if (PlatformUtils.isMobileDevice() && filteredIngredients.length > 10) {
      filteredIngredients = filteredIngredients.sublist(0, 10);
    }

    return filteredIngredients;
  }

  Future<void> _onIngredientPressed(String ingredient) async {
    final cocktailBloc = Provider.of<CocktailBloc>(context);
    cocktailBloc.fetchCocktailIdsByIngredient(ingredient);

    final mainNavigationBloc = Provider.of<MainNavigationBloc>(context);
    mainNavigationBloc.changeCurrentIndex(1);

    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _searchBloc = SearchBloc();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _searchBloc?.dispose();
    _textEditingController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _searchBloc.keyword,
      builder: (context, AsyncSnapshot<String> snapshot) {
        return Scaffold(
          appBar: _buildAppBar(snapshot.data),
          body: _buildBody(snapshot.data),
        );
      },
    );
  }

  Widget _buildAppBar(String keyword) => AppBar(
        title: TextField(
          autofocus: true,
          controller: _textEditingController,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: "Search by ingredient...",
            hintStyle: TextStyle(
              color: Colors.white70,
              fontSize: 20,
            ),
          ),
          onChanged: _searchBloc.changeKeyword,
        ),
        actions: keyword == null || keyword == ""
            ? <Widget>[]
            : <Widget>[
                IconButton(
                  icon: Icon(Icons.clear),
                  tooltip: "Clear entry",
                  onPressed: () {
                    _textEditingController.text = "";
                    _searchBloc.changeKeyword("");
                  },
                ),
              ],
      );

  Widget _buildBody(String keyword) => StreamBuilder(
        stream: Provider.of<IngredientBloc>(context).ingredientNames,
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          if (!snapshot.hasData) {
            return LoadingSpinner();
          }

          List<String> ingredients = _filterIngredients(
            snapshot.data,
            keyword,
          );

          return ListView.builder(
            shrinkWrap: true,
            itemCount: ingredients.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => _onIngredientPressed(ingredients[index]),
                child: ListTile(
                  leading: Icon(Icons.local_bar),
                  title: Text(ingredients[index]),
                ),
              );
            },
          );
        },
      );
}
