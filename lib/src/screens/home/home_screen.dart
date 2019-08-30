import 'package:cocktailr/src/blocs/cocktail_bloc.dart';
import 'package:cocktailr/src/blocs/main_navigation_bloc.dart';
import 'package:cocktailr/src/models/cocktail.dart';
import 'package:cocktailr/src/models/ingredient.dart';
import 'package:cocktailr/src/screens/home/widgets/popular_ingredient_list_item.dart';
import 'package:cocktailr/src/screens/home/widgets/trending_cocktail_list_item.dart';
import 'package:cocktailr/src/utils/popular_ingredients.dart';
import 'package:cocktailr/src/widgets/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  Future<void> _onIngredientPressed(
    Ingredient ingredient,
    BuildContext context,
  ) async {
    CocktailBloc cocktailBloc = Provider.of<CocktailBloc>(context);
    cocktailBloc.fetchCocktailIdsByIngredient(ingredient.name);

    MainNavigationBloc mainNavigationBloc = Provider.of<MainNavigationBloc>(context);
    mainNavigationBloc.changeCurrentIndex(1);
  }

  Future<void> _onMysteryCocktailButtonPressed(
    CocktailBloc bloc,
    BuildContext context,
  ) async {
    Cocktail cocktail = await bloc.fetchRandomCocktail();
    bloc.fetchCocktail(cocktail.id);
    Navigator.pushNamed(
      context,
      '/cocktail',
      arguments: cocktail.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cocktailBloc = Provider.of<CocktailBloc>(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _sectionTitle("Trending Cocktails"),
          _buildTrendingCocktailsList(cocktailBloc),
          SizedBox(height: 16),
          _sectionTitle("Popular Ingredients"),
          _buildPopularIngredientsList(context),
          SizedBox(height: 16),
          _sectionTitle("Mystery Cocktail"),
          _buildMysteryCocktailButton(cocktailBloc, context),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: EdgeInsets.only(left: 19, bottom: 8, right: 16),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
      );

  Widget _buildTrendingCocktailsList(CocktailBloc bloc) => StreamBuilder(
        stream: bloc.popularCocktailIds,
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          if (!snapshot.hasData) {
            return loadingSpinner();
          }

          return Container(
            height: MediaQuery.of(context).size.height / 2.4,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              primary: false,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 16, right: 8),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                bloc.fetchCocktail(snapshot.data[index]);

                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: TrendingCocktailListItem(
                    cocktailId: snapshot.data[index],
                  ),
                );
              },
            ),
          );
        },
      );

  Widget _buildPopularIngredientsList(BuildContext context) => Container(
        height: MediaQuery.of(context).size.height / 6,
        child: ListView.builder(
          primary: false,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(left: 19, right: 8),
          itemCount: PopularIngredients.popularIngredients.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.only(right: 10),
              child: PopularIngredientListItem(
                ingredient: PopularIngredients.popularIngredients[index],
                onPressed: _onIngredientPressed,
              ),
            );
          },
        ),
      );

  Widget _buildMysteryCocktailButton(CocktailBloc bloc, BuildContext context) =>
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 19, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: RaisedButton(
                child: Text(
                  "I'm feeling lucky",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: () => _onMysteryCocktailButtonPressed(bloc, context),
                padding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      );
}