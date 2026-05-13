import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/zone.dart';

class ZonesPage extends StatefulWidget {
  final List<SilentZone> zones;
  final Function(List<SilentZone>) onZonesUpdated;

  const ZonesPage({
    Key? key,
    required this.zones,
    required this.onZonesUpdated,
  }) : super(key: key);

  @override
  _ZonesPageState createState() => _ZonesPageState();
}

class _ZonesPageState extends State<ZonesPage> {
  late List<SilentZone> _zones;

  @override
  void initState() {
    super.initState();
    _zones = List.from(widget.zones);
  }

  void _toggleZoneActive(int index) {
    setState(() {
      _zones[index].isActive = !_zones[index].isActive;
    });
    widget.onZonesUpdated(_zones);
  }

  void _deleteZone(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Zone'),
        content:
            Text('Are you sure you want to delete "${_zones[index].name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _zones.removeAt(index);
              });
              widget.onZonesUpdated(_zones);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
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
        title: const Text('Manage Silent Zones'),
      ),
      body: _zones.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Silent Zones Added',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first silent zone using the map',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _zones.length,
              itemBuilder: (context, index) {
                final zone = _zones[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: zone.isActive
                              ? AppTheme.primaryColor
                              : Colors.grey,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                zone.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${zone.latitude.toStringAsFixed(6)}, '
                                '${zone.longitude.toStringAsFixed(6)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Radius: ${zone.radius.toStringAsFixed(0)} meters',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _toggleZoneActive(index),
                          icon: Icon(
                            zone.isActive ? Icons.toggle_on : Icons.toggle_off,
                            color: zone.isActive
                                ? AppTheme.primaryColor
                                : Colors.grey,
                            size: 40,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _deleteZone(index),
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
