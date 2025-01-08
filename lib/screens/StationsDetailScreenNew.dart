import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:blur/blur.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StationsDetailScreenNew extends StatefulWidget {
  final Map<String, dynamic> station;
  final bool isPlaying;
  final bool isFavorite;
  final VoidCallback onPlayPause;
  final VoidCallback onToggleFavorite;

  StationsDetailScreenNew({
    required this.station,
    required this.isPlaying,
    required this.isFavorite,
    required this.onPlayPause,
    required this.onToggleFavorite,
  });

  @override
  _StationDetailScreenState createState() => _StationDetailScreenState();
}

class _StationDetailScreenState extends State<StationsDetailScreenNew> {
  late bool _isPlaying;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.isPlaying;
    _isFavorite = widget.isFavorite;
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    widget.onPlayPause();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    widget.onToggleFavorite();
  }

  Future<void> _launchUrl(String? url) async {
    if (url != null && await canLaunch(url)) {
      await launch(url);
    } else {
      print('URL no válida o no se puede abrir: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final stationLogo =
        'https://radio.freepi.io${widget.station['station_image'] ?? '/placeholder.png'}';
    final stationName =
        widget.station['station_frequency'] ?? 'Estación desconocida';
    final stationState =
        widget.station['state']['state_name'] ?? 'Estado desconocido';

    // Enlaces desde el API
    final instagram = widget.station['station_instagram'];
    final phone = widget.station['station_phone'];
    final website = widget.station['station_website'];
    final facebook = widget.station['station_facebook'];
    final whatsapp = widget.station['station_whatsapp'];

    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo con desenfoque
          Image.network(
            stationLogo,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ).blurred(
            blur: 15, // Ajusta el nivel del desenfoque
            colorOpacity: 0.2,
          ),
          // Superposición de color gris oscuro
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Contenido principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo circular de la estación
                CircleAvatar(
                  backgroundImage: NetworkImage(stationLogo),
                  radius: 100,
                ),
                SizedBox(height: 20),
                // Nombre de la estación
                Text(
                  stationName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                // Estado de la estación
                Text(
                  stationState,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                // Botones interactivos
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botón de favoritos
                    IconButton(
                      icon: Icon(
                        _isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 36,
                        color: _isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                    SizedBox(width: 40),
                    // Botón de reproducción/pausa
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause_circle : Icons.play_circle,
                        size: 64,
                        color: Colors.white,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                    SizedBox(width: 40),
                    // Menú hamburguesa con opciones
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 36,
                        color: Colors.white,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'Instagram':
                            _launchUrl(instagram);
                            break;
                          case 'Llamar':
                            _launchUrl('tel:$phone');
                            break;
                          case 'Web':
                            _launchUrl(website);
                            break;
                          case 'Facebook':
                            _launchUrl(facebook);
                            break;
                          case 'WhatsApp':
                            _launchUrl(whatsapp);
                            break;
                          case 'Compartir':
                            print('Compartir seleccionado');
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: 'Instagram',
                          child: Row(
                            children: [
                              Icon(FontAwesomeIcons.instagram,
                                  color: Colors.purple),
                              SizedBox(width: 8),
                              Text('Instagram'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Llamar',
                          child: Row(
                            children: [
                              Icon(Icons.phone, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Llamar'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Web',
                          child: Row(
                            children: [
                              Icon(Icons.web, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Web'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Facebook',
                          child: Row(
                            children: [
                              Icon(FontAwesomeIcons.facebook,
                                  color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Facebook'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'WhatsApp',
                          child: Row(
                            children: [
                              Icon(FontAwesomeIcons.whatsapp,
                                  color: Colors.green),
                              SizedBox(width: 8),
                              Text('WhatsApp'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Compartir',
                          child: Row(
                            children: [
                              Icon(Icons.share, color: Colors.purple),
                              SizedBox(width: 8),
                              Text('Compartir'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Botón de regreso
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
