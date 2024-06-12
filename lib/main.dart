import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: "My Wise Word",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 34, 34)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var history = <WordPair>[];
  // Add This
  void getNext() {
    current = WordPair.random();
    history.add(current);
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorites() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  
  }

  void removeFav(WordPair pair){
    favorites.remove(pair);
    notifyListeners();
  }

  void removeAllFavorites(){
    favorites.clear();
    notifyListeners();
  }

  void removeFromHistory(WordPair wordPair) {
    history.remove(wordPair); // untuk menghapus kata dari history
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // Add this property.

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritePage();
      case 2:
        page = HistoryPage();
      default:
        page = Placeholder();
    }

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        selectedIndex: selectedIndex, // Change to this.
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home'),
          NavigationDestination(
            selectedIcon: Icon(Icons.favorite),
            icon: Icon(Icons.favorite_border_outlined),
            label: 'Favorite'),
          NavigationDestination(
            selectedIcon: Icon(Icons.book),
            icon: Icon(Icons.book_outlined),
            label: 'History'),
        ],
      ),
      body: Container(child: page),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({
    super.key,    
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    
    // Add This.
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Let's Get Started!"),
          BigCard(pair: pair),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorites();

                  //Snackbar
                  ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text("it's ${appState.current}"),
                    ),
                  );
                },
                icon: Icon(icon),
                label: Text("Favorites"),
              ),
              const SizedBox( width: 20),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: const Text("Next"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Add this.
    // Add this.
    final pairTextStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.primary,
      fontSize: 15.0,
    );

    return Card(
      color: Color.fromARGB(255, 253, 236, 83),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Text(
          pair.asLowerCase,
          style: pairTextStyle,
        ),
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Container(
      child: ListView(
        children: [
          Text(
            "You have ${appState.favorites.length} favorite words:",
            style: Theme.of(context).textTheme.titleLarge,
          ),

          ...appState.favorites.map(
            (wp)=> ListTile(
              title: Text(wp.asCamelCase),
              onTap: (){
                ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('My Favorite Word is ${wp.asCamelCase}'),
                  ),
                );                
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key});

  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    return Container(
      child: ListView(
        children: [
          Text('You have ${appState.history.length} History of Random Words: ',
          style: Theme.of(context).textTheme.titleLarge),

          ...appState.history.map(
            (wp)=> ListTile(
              title: Text(wp.asCamelCase),
              onTap: (){
                ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('It`s ${wp.asCamelCase}'),
                  ),
                );
                appState.removeFromHistory(wp); // fungsi untuk menghilangkan history yang ditekan
              },
            ),
          ),
        ],
      ),
    );
  }
}
