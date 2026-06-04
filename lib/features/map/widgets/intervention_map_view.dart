import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/config/mapbox_config.dart';
import '../../../data/models/intervention_area.dart';
import '../utils/map_style.dart';
import '../viewmodels/intervention_map_view_model.dart';

class InterventionMapView extends StatefulWidget {
  const InterventionMapView({
    super.key,
    required this.viewModel,
    required this.onAreaTap,
  });

  final InterventionMapViewModel viewModel;
  final ValueChanged<InterventionArea> onAreaTap;

  @override
  State<InterventionMapView> createState() => _InterventionMapViewState();
}

class _InterventionMapViewState extends State<InterventionMapView> {
  final _mapController = MapController();
  bool _fitted = false;

  @override
  void didUpdateWidget(InterventionMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel.areas.length != widget.viewModel.areas.length) {
      _fitted = false;
      _fitBounds();
    }
  }

  void _fitBounds() {
    final points = widget.viewModel.visiblePoints;
    if (points.isEmpty || points.length == 1) {
      final c = widget.viewModel.center ?? const LatLng(40.72, 14.85);
      _mapController.move(c, points.isEmpty ? 8 : 11);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(56),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final areas = widget.viewModel.areas;
    final selected = widget.viewModel.selected;

    if (!_fitted && areas.isNotEmpty) {
      _fitted = true;
      _fitBounds();
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.viewModel.center ?? const LatLng(40.72, 14.85),
        initialZoom: 9,
        onTap: (_, __) => widget.viewModel.selectArea(null),
      ),
      children: [
        _buildTileLayer(),
        CircleLayer(
          circles: areas
              .map(
                (a) => CircleMarker(
                  point: a.impianto.coordinate,
                  radius: a.radiusMeters,
                  useRadiusInMeter: true,
                  color: MapStyle.areaFill(a),
                  borderColor: MapStyle.areaBorder(a),
                  borderStrokeWidth: selected?.impianto.codice == a.impianto.codice
                      ? 3
                      : 2,
                ),
              )
              .toList(),
        ),
        MarkerLayer(
          markers: areas
              .map(
                (a) => Marker(
                  point: a.impianto.coordinate,
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    onTap: () {
                      widget.viewModel.selectArea(a);
                      widget.onAreaTap(a);
                    },
                    child: _MapPin(
                      area: a,
                      selected: selected?.impianto.codice == a.impianto.codice,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTileLayer() {
    if (MapboxConfig.isConfigured) {
      return TileLayer(
        urlTemplate: MapboxConfig.tileUrlTemplate,
        userAgentPackageName: 'com.siem.gestionaleticket',
        additionalOptions: const {},
      );
    }
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.siem.gestionaleticket',
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.area, required this.selected});

  final InterventionArea area;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = MapStyle.areaBorder(area);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: selected ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(MapStyle.markerIcon(area), color: color, size: 20),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            area.impianto.codice,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
