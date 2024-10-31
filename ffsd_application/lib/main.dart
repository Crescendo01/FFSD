import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  //build method states that this is what the widget contains
  Widget build(BuildContext context) {
    
    //Every build method must return a widget of a nested tree of widgets
    //Here ChangeNotifierProvider is returned
    return ChangeNotifierProvider(
      //MyAppState is created here in the myApp class and provided by ChangeNotifierProvider to every widget in the app
      create: (context) => MyAppState(),
      //What the state contains is listed in here
      child: MaterialApp(
        title: 'FFSD Application', 
        theme: ThemeData(
          //Material3 changes the look of the button
          useMaterial3: true,
          //Changes the color of the button
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        //Homepage of the app
        home: MyHomePage(),
      ),
    );
  }
}

//MyAppState defines the data the app requires to function
//ChangeNotifier basically notifies appstate if something changes in the app and is used to manage the app state
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  
  //Function to reload the name
  //When NotifyAllListeners method is called in the class, the context will be rebuilt
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  //wordPair generic catches any variables that enter the array which are not wordPair type
  var favorites = <WordPair>[];

  void toggleFavorite() {
    //Removes the word from the favorite list if its already there
    if (favorites.contains(current)) {
      favorites.remove(current);
    }
    else {
      favorites.add(current);
    }
    //Must notify listeners in case any widget needs to know about this change on a rebuild
    notifyListeners();
  }

  //HTTP functions
  //Future is a core dart class for working with async operations. Represents a potential error/value that may occur in the future.
  //http.Response contains the data from a successful http call
  //Will convert http.Response to a dart object for convenience
  Future<http.Response> fetchAlbum() {
    return http.get(Uri.parse(""));
  }

}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// _ before a class indicates that the class is private
class _MyHomePageState extends State<MyHomePage> {
  //selectedIndex belongs to the _MyHomePageState class and not the scaffhold widget
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    //New variable "page" is a widget
    Widget page;
      switch (selectedIndex) {
        case 0:
          page = GeneratorPage();
          break;
        case 1:
          //Placeholder is a widget that comes with flutter that draws a little box as a placeholder
          page = FavoritesPage();
          break;
        //Without default, it may cause a null error if the selectedIndex somehow manages to not be 0 or 1
        default:
          throw UnimplementedError('no widget for $selectedIndex');

      }

    return Scaffold(
      //Row covers the whole screen
      body: Row(
        children: [
          //First child is the SafeArea which is a special widget which is meant for mobile phones where some parts of the screen can be covered by cameras etc.
          //Essentially adds padding to widgets if it is necessary
          SafeArea(
            //NavigationRail has destinations
            child: NavigationRail(
              //Parameter can toggle the railDestinations between states
              //For example, here the extended state contains an icon and a label
              //The non extended state contains just an icon
              extended: false,
              //Two destinations are defined by an icon and a label
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favorites'),
                ),
              ],
              //Index that indicates which widget is currently selected
              selectedIndex: selectedIndex,
              //calls back to navigation rail and is called anytime the navigation destination is changed
              onDestinationSelected: (value) {
                //Anytime that code is run that changes the state, the setState function must be run
                //This tells Flutter that something important has changed and the widget must be rebuilt
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          //Special widget used in rows and columns that says, give me as much space as possible
          Expanded(
            //Container has a color
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              //Child of the container is the entire generator page
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //This widget watches the state of the app
    //Any widget will be able to watch the appState since MyAppState context is created in myApp
    //Will also rebuild any time myAppState context changes
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    //Logic for the like icon
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    }  else {
      icon = Icons.favorite_border;
    }

    //Center is a structural widget
    return Center(
      //Body of the widget is given by column which puts all widgets in a column, placing children at the top
      //Column by default takes up as much space as its largest child does
      child: Column(
        //Centers all children of column in the center of the main axis which is the vertical axis of the column
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //This line represents an extracted Text widget which is a stateless widget at the bottom using the refactor widget
          BigCard(pair: pair),
          SizedBox(height: 20),
          //ElevatedButton is another widget which is nested inside the column
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                  print('button pressed and favorited current word');
                },
                //Button contains the icon which uses the icon data from before
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  //print function prints to debug console
                  appState.getNext();
                  print('button pressed!');
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text("No favorites yet."),
      );
    }

    //Listview allows for scrollable widget
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          //Curly brackets are required when accessing properties of objects in strings
          child: Text("You have ${appState.favorites.length} favorites."),
        ),
        for (var pair in appState.favorites)
          //ListTile uses the padding set above unlike a simple text widget
          ListTile (
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

//This will return the random generated pair name in all lowercase
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    //Theme.of watches the ThemeData and makes sure that we know if the state of the theme changes
    var theme = Theme.of(context);
    //textTheme contains fonts
    //displayMedium is a medium sized display font
    //! indicates a null aware operator
    //copyWith method returns a copy of the text style with changes you define. Will only change the text color.
    var style = theme.textTheme.displayMedium!.copyWith(
      //The text color will be the color that is clearly visible on the primary color
      color: theme.colorScheme.onPrimary,
    );

    //Card surrounds the child widgets with a border
    return Card(      
      color: theme.colorScheme.primary,
      child: Padding(
        //Adds padding pixel space around the button
        padding: const EdgeInsets.all(20),
        //Style is assigned to the defined style
        child: Text(pair.asLowerCase, style: style, semanticsLabel: pair.asPascalCase),
      ),
    );
  }
}