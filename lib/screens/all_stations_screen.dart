import 'package:flutter/material.dart';
import 'radio_player_screen.dart';

class AllStationsScreen extends StatelessWidget {
  final List stations;

  AllStationsScreen({required this.stations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nuestras Estaciones"),
        backgroundColor: Colors.purple,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Dos estaciones por fila
          childAspectRatio: 3 / 2, // Ajustar proporción de las tarjetas
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: stations.length,
        itemBuilder: (context, index) {
          final station = stations[index];
          // Ajustando los datos de la API a los campos reales
          final stationName = station['station_frequency'] ?? 'Estación desconocida';
          final stationSlogan = station['station_slogan'] ?? '';
          final stationLogo = 'https://radio.freepi.io${station['station_image']}' ?? 'https://via.placeholder.com/100x100.png?text=Sin+Logo';
          final streamUrl = station['station_streaming'] ?? '';

          return GestureDetector(
            onTap: streamUrl.isNotEmpty
                ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RadioPlayerScreen(
                    stationName: stationName,
                    streamUrl: streamUrl,
                  ),
                ),
              );
            }
                : null,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Imagen del logotipo de la estación
                  Image.network(
                    stationLogo,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 5),
                  // Nombre de la estación
                  Text(
                    stationName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  // Eslogan de la estación
                  Text(
                    stationSlogan,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 5),
                  // Icono de reproducción
                  Icon(Icons.play_circle_fill, color: Colors.purple),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
