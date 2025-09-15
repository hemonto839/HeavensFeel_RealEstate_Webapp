import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  // Opens a map and lets the user pick a location
  static Future<LatLng?> pickLocation(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _LocationPickerPage(),
      ),
    );
  }

  // Returns a FlutterMap widget centered on a specific LatLng
  static Widget showMap(LatLng location, {double zoom = 15}) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: location,  // Changed from 'center' to 'initialCenter'
        initialZoom: zoom,        // Changed from 'zoom' to 'initialZoom'
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: "com.example.app",
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: location,
              width: 80,
              height: 80,
              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
          ],
        ),
      ],
    );
  }
}

// Internal page used for selecting location
class _LocationPickerPage extends StatefulWidget {
  @override
  State<_LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<_LocationPickerPage> {
  // Default starting location: Dhaka, Bangladesh
  LatLng _selectedLatLng = LatLng(23.8103, 90.4125);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _selectedLatLng); // Return chosen location
            },
          )
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _selectedLatLng,  // Fixed: changed from 'center'
          initialZoom: 15.0,               // Fixed: changed from 'zoom'
          onTap: (tapPosition, latlng) {
            setState(() {
              _selectedLatLng = latlng;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: "com.example.app",
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _selectedLatLng,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "Selected: Lat ${_selectedLatLng.latitude.toStringAsFixed(6)}, "
          "Lng ${_selectedLatLng.longitude.toStringAsFixed(6)}",
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}