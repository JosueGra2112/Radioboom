import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'dart:convert';
import 'StationDetailScreen.dart';
import 'all_stations_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'station_detail_with_navigation_screen.dart';

import 'news_screen.dart';
import 'favorites_screen.dart';

import 'package:http/http.dart' as http;


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> stations = [];

  List ads = [];
  List favoritesList = [];
  List broadcasters = [];
  Map<String, dynamic>? currentStation;
  bool isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int currentAdIndex = 0;
  late PageController _pageController;
  late PageController _bannerPageController;
  int _currentBannerIndex = 0;


  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _bannerPageController = PageController();
    fetchStations();
    fetchAds();
    fetchBroadcasters();
    startAdAutoScroll();
    startBannerAutoScroll();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _pageController.dispose();
    _bannerPageController.dispose();
    super.dispose();
  }

// Fetch Stations API
  Future<void> fetchStations() async {
    final url = Uri.parse(
        'https://radio.freepi.io/broadcast/radio/Api/stations/company/Boom%20FM/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        stations = List<Map<String, dynamic>>.from(data); // Casting explícito
      });
    } else {
      print("Error al cargar las estaciones: ${response.statusCode}");
    }
  }



  // Fetch Ads API
  Future<void> fetchAds() async {
    final url = Uri.parse(
        'https://radio.freepi.io/broadcast/radio/Api/anuncios/company/Boom%20FM/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        ads = data.where((ad) => ad['media'] != null).toList();
      });
    } else {
      print("Error al cargar los anuncios: ${response.statusCode}");
    }
  }

  // Fetch Broadcasters API
  Future<void> fetchBroadcasters() async {
    final url = Uri.parse(
        'https://radio.freepi.io/broadcast/radio/Api/broadcasters/Boom%20FM/6808/');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        broadcasters = data;
      });
    } else {
      print("Error al cargar los locutores: ${response.statusCode}");
    }
  }
  // Auto scroll for ads
  void startAdAutoScroll() {
    Future.delayed(Duration(seconds: 4), () {
      if (_pageController.hasClients && ads.isNotEmpty) {
        setState(() {
          currentAdIndex = (currentAdIndex + 1) % ads.length;
        });
        _pageController.animateToPage(
          currentAdIndex,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        startAdAutoScroll();
      }
    });
  }

  // Auto scroll for banners
  void startBannerAutoScroll() {
    Future.delayed(Duration(seconds: 3), () {
      if (_bannerPageController.hasClients && ads.isNotEmpty) {
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % ads.length;
        });
        _bannerPageController.animateToPage(
          _currentBannerIndex,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        startBannerAutoScroll();
      }
    });
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

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('No se pudo abrir el enlace: $url');
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

  // Banner Carousel
  Widget _buildBannerCarousel() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        height: 120,
        child: ads.isEmpty
            ? Center(child: CircularProgressIndicator())
            : PageView.builder(
          itemCount: ads.length.clamp(0, 6),
          controller: _bannerPageController,
          itemBuilder: (context, index) {
            final ad = ads[index];
            final imageUrl =
                'https://radio.freepi.io${ad['media'] ?? '/placeholder.png'}';
            final actionUrl = ad['accion_url'] ?? '';

            return GestureDetector(
              onTap: actionUrl.isNotEmpty
                  ? () => _launchURL(actionUrl)
                  : null,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  // Locutores Section
  Widget _buildBroadcastersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Locutores",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Acción para "Ver Más"
                },
                child: Text("Ver más"),
              ),
            ],
          ),
          Container(
            height: 180,
            child: broadcasters.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: broadcasters.length,
              itemBuilder: (context, index) {
                final broadcaster = broadcasters[index];
                final name =
                    broadcaster['broadcaster_name'] ?? 'Sin nombre';
                final shortenedName = name.length > 10
                    ? '${name.substring(0, 10)}..'
                    : name;
                final imageUrl =
                    'https://radio.freepi.io${broadcaster['broadcaster_image'] ?? '/placeholder.png'}';
                final programUrl =
                    broadcaster['broadcaster_programation'] ?? null;

                return GestureDetector(
                  onTap: () {
                    if (programUrl != null) {
                      _launchURL(programUrl);
                    }
                  },
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(imageUrl),
                          radius: 50,
                        ),
                        SizedBox(height: 5),
                        Text(
                          shortenedName,
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Row(
          children: [
            Image.network(
              'https://play-lh.googleusercontent.com/dG1DQSG5pxULCjQ8_7Ep3cyUSO0OmyF3fRuum2UxdNpC5FVeCwev3iTqtaHc2DnmUA',
              height: 40,
            ),
            SizedBox(width: 10),
            Text(
              "Boom FM",
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.menu),
            onSelected: (value) {
              // Acciones del menú desplegable
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'Configuración',
                child: Text('Configuración'),
              ),
              PopupMenuItem(
                value: 'Acerca de',
                child: Text('Acerca de'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Carrusel de Anuncios
            Container(
              height: 150,
              child: ads.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : PageView.builder(
                controller: _pageController,
                itemCount: ads.length.clamp(0, 12),
                onPageChanged: (index) {
                  setState(() {
                    currentAdIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final ad = ads[index];
                  final imageUrl =
                      'https://radio.freepi.io${ad['media'] ?? '/placeholder.png'}';
                  final actionUrl = ad['accion_url'] ?? '';

                  return GestureDetector(
                    onTap: actionUrl.isNotEmpty
                        ? () => _launchURL(actionUrl)
                        : null,
                    child: Container(
                      margin:
                      EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Sección de Estaciones
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Nuestras Estaciones",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllStationsScreen(
                            stations: stations,
                          ),
                        ),
                      );
                    },
                    child: Text("Ver más"),
                  ),
                ],
              ),
            ),
            Container(
              height: 200,
              child: stations.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: stations.length.clamp(0, 6),
                itemBuilder: (context, index) {
                  final station = stations[index];
                  final stationName =
                      station['station_frequency'] ?? 'Estación desconocida';
                  final stationLogo =
                      'https://radio.freepi.io${station['station_image'] ?? '/placeholder.png'}';

                  final isCurrentStation = currentStation != null &&
                      currentStation!['id'] == station['id'];
                  final isPlayingStation = isCurrentStation && isPlaying;

                  return GestureDetector(
                    onTap: () {
                      // Navegar a la pantalla de detalles de la estación
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StationDetailScreen(
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
                    child: Container(
                      width: 160,
                      margin: EdgeInsets.only(right: 10),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Imagen de la estación
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: Image.network(
                                stationLogo,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Texto y botón de reproducción/pausa
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Nombre de la estación
                                    Expanded(
                                      child: Text(
                                        stationName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    // Botón de reproducción/pausa
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
                    ),
                  );
                },
              ),
            ),
            // Carrusel de Banners
            _buildBannerCarousel(),
            // Sección de Locutores
            _buildBroadcastersSection(),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentStation != null)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StationDetailWithNavigationScreen(
                      stations: stations.cast<Map<String, dynamic>>(),
                      initialIndex: stations.indexWhere(
                            (station) => station['id'] == currentStation!['id'],
                      ),
                      isPlaying: isPlaying,
                      isFavorite: favoritesList.contains(currentStation),
                      onPlayPause: togglePlayPause, // Pasamos la función togglePlayPause
                      onPlayStation: (station) {
                        setState(() {
                          currentStation = station;
                          isPlaying = true;
                        });
                        playStation(station);
                      },
                      onToggleFavorite: () => toggleFavorite(currentStation!),
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
                            // Abreviar el título de la estación
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
                          onPressed: () => toggleFavorite(currentStation!),
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



          BottomNavigationBar(
            currentIndex: 0, // Cambia el índice según la pantalla activa
            selectedItemColor: Colors.purple,
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              if (index == 0) {
                // Navegar a Inicio
              } else if (index == 1) {
                // Navegar a Noticias
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsScreen(
                      favoritesList: favoritesList.cast<Map<String, dynamic>>(),

                      currentStation: currentStation,
                      isPlaying: isPlaying,
                      onPlayStation: (station) {
                        setState(() {
                          currentStation = station;
                          isPlaying = true;
                        });
                        playStation(station);
                      },
                      onToggleFavorite: (station) {
                        toggleFavorite(station);
                      },
                    ),
                  ),
                );
              } else if (index == 2) {
                // Navegar a Favoritos
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritesScreen(
                      favoritesList: favoritesList.cast<Map<String, dynamic>>(),
                      isPlaying: isPlaying,
                      currentStation: currentStation,
                      onPlayStation: (station) {
                        setState(() {
                          currentStation = station;
                          isPlaying = true;
                        });
                        playStation(station);
                      },
                      onToggleFavorite: (station) {
                        toggleFavorite(station);
                      },
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
        ],
      ),
    );
  }
}
