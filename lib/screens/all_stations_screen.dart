import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'StationsDetailScreenNew.dart';
import 'station_detail_with_navigation_screen.dart';

class AllStationsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> stations;

  AllStationsScreen({required this.stations});

  @override
  _AllStationsScreenState createState() => _AllStationsScreenState();
}

class _AllStationsScreenState extends State<AllStationsScreen> {
  late List<Map<String, dynamic>> stations;
  List favoritesList = [];
  Map<String, dynamic>? currentStation;
  bool isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    stations = widget.stations;
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        // Handle loading/buffering state if needed
      } else if (!isPlaying) {
        setState(() {
          this.isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void playStation(Map<String, dynamic> station) async {
    final streamUrl = station['station_streaming'];
    if (streamUrl != null && streamUrl.isNotEmpty) {
      try {
        await _audioPlayer.setUrl(streamUrl);
        _audioPlayer.play();
        setState(() {
          currentStation = station;
          isPlaying = true;
        });
      } catch (e) {
        print("Error al reproducir la estación: $e");
      }
    }
  }

  void pauseStation() {
    _audioPlayer.pause();
    setState(() {
      isPlaying = false;
    });
  }

  void togglePlayPause() {
    if (isPlaying) {
      pauseStation();
    } else if (currentStation != null) {
      playStation(currentStation!);
    }
  }




  void toggleFavorite(Map<String, dynamic> station) {
    setState(() {
      if (favoritesList.contains(station)) {
        favoritesList.remove(station);
      } else {
        favoritesList.add(station);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nuestras Estaciones"),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 20,
                mainAxisSpacing: 10,
              ),
              itemCount: stations.length,
              itemBuilder: (context, index) {
                final station = stations[index];
                final stationName =
                    station['station_frequency'] ?? 'Estación desconocida';
                final shortenedStationName = stationName.length > 15
                    ? '${stationName.substring(0, 15)}...'
                    : stationName;
                final stationLogo =
                    'https://radio.freepi.io${station['station_image'] ?? '/placeholder.png'}';

                final isCurrentStation = currentStation != null &&
                    currentStation!['id'] == station['id'];
                final isPlayingStation = isCurrentStation && isPlaying;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StationsDetailScreenNew(
                          station: station,
                          isPlaying: isPlayingStation,
                          onPlayPause: () {
                            if (isCurrentStation) {
                              togglePlayPause();
                            } else {
                              playStation(station);
                            }
                          },
                          isFavorite: favoritesList.contains(station),
                          onToggleFavorite: () => toggleFavorite(station),
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            child: Image.network(
                              stationLogo,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    shortenedStationName,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
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
                                      togglePlayPause();
                                    } else {
                                      playStation(station);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // En el widget de reproducción dentro de AllStationsScreen
// En el widget de reproducción dentro de AllStationsScreen
          if (currentStation != null) // Widget de reproducción
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StationDetailWithNavigationScreen(
                      stations: stations,
                      initialIndex: stations.indexOf(currentStation!),
                      isPlaying: isPlaying,
                      isFavorite: favoritesList.contains(currentStation),
                      onPlayStation: (station) {
                        playStation(station);
                      },
                      onPlayPause: togglePlayPause,
                      onToggleFavorite: () => toggleFavorite(currentStation!), // Closure aquí
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.purple.shade700,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            'https://radio.freepi.io${currentStation!['station_image'] ?? '/placeholder.png'}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 200,
                              child: Text(
                                currentStation!['station_frequency'] ?? 'Sin frecuencia',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              child: Text(
                                currentStation!['station_acronym'] != null
                                    ? (currentStation!['station_acronym'].length > 15
                                    ? '${currentStation!['station_acronym'].substring(0, 15)}...'
                                    : currentStation!['station_acronym'])
                                    : 'Sin acrónimo',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            favoritesList.contains(currentStation)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: favoritesList.contains(currentStation)
                                ? Colors.red
                                : Colors.white,
                          ),
                          onPressed: () => toggleFavorite(currentStation!), // Closure aquí
                        ),
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: togglePlayPause,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}