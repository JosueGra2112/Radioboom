import 'package:flutter/material.dart';
import 'news_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> favoritesList;
  final Map<String, dynamic>? currentStation;
  final bool isPlaying;
  final Function(Map<String, dynamic>) onPlayStation;
  final Function(Map<String, dynamic>) onToggleFavorite;
  final VoidCallback onTogglePlayPause;

  const FavoritesScreen({
    Key? key,
    required this.favoritesList,
    required this.currentStation,
    required this.isPlaying,
    required this.onPlayStation,
    required this.onToggleFavorite,
    required this.onTogglePlayPause,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favoritos"),
        backgroundColor: Colors.purple,
      ),
      body: favoritesList.isEmpty
          ? Center(child: Text("No tienes estaciones favoritas."))
          : ListView.builder(
        itemCount: favoritesList.length,
        itemBuilder: (context, index) {
          final station = favoritesList[index];
          final isCurrentStation = currentStation != null &&
              currentStation!['id'] == station['id'];
          final isPlayingStation = isCurrentStation && isPlaying;
          return ListTile(
            leading: Image.network(
              'https://radio.freepi.io${station['station_image'] ?? '/placeholder.png'}',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(station['station_frequency'] ?? 'Estación desconocida'),
            subtitle: Text(station['station_acronym'] ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isPlayingStation
                        ? Icons.pause_circle
                        : Icons.play_circle,
                    color: Colors.purple,
                    size: 30,
                  ),
                  onPressed: () {
                    if (isCurrentStation) {
                      onTogglePlayPause();
                    } else {
                      onPlayStation(station);
                    }
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () => onToggleFavorite(station),
                ),
              ],
            ),
            onTap: () => onPlayStation(station),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewsScreen(
                  favoritesList: favoritesList,
                  currentStation: currentStation,
                  isPlaying: isPlaying,
                  onPlayStation: onPlayStation,
                  onToggleFavorite: onToggleFavorite,
                  onTogglePlayPause: onTogglePlayPause,
                ),
              ),
            );
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.radio), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: "Noticias"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favoritos"),
        ],
      ),
    );
  }
}