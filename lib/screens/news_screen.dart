import 'package:flutter/material.dart';

import 'favorites_screen.dart';

class NewsScreen extends StatelessWidget {
  final Map<String, dynamic>? currentStation;
  final List<Map<String, dynamic>> favoritesList;
  final bool isPlaying;
  final Function(Map<String, dynamic>) onPlayStation;
  final Function(Map<String, dynamic>) onToggleFavorite;

  const NewsScreen({
    Key? key,
    required this.currentStation,
    required this.favoritesList,
    required this.isPlaying,
    required this.onPlayStation,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Noticias"),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Text(
          "Aquí aparecerán las noticias",
          style: TextStyle(fontSize: 18),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Noticias es la segunda pestaña
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context); // Regresar a Inicio
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FavoritesScreen(
                  favoritesList: favoritesList,
                  isPlaying: isPlaying,
                  currentStation: currentStation,
                  onPlayStation: onPlayStation,
                  onToggleFavorite: onToggleFavorite,
                ),
              ),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.radio),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: "Noticias",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favoritos",
          ),
        ],
      ),
    );
  }
}
