import 'dart:async';

import 'package:example/satellite.dart';
import 'package:flutter/material.dart';

import 'ui/fancy_dialog.dart';
import 'ui/intrinsic_button.dart';

class SatelliteSelectionDialog extends StatefulWidget {
  const SatelliteSelectionDialog({
    super.key,
    required this.model,
  });

  final MapModel model;

  @override
  State<StatefulWidget> createState() => _SatelliteSelectionDialogState();
}

class _SatelliteSelectionDialogState extends State<SatelliteSelectionDialog> {
  List<bool> _selection = [];
  Timer? _timer;

  @override
  void initState() {
    _selection = List<bool>.filled(widget.model.satellites.length, false);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      widget.model.updateSatellites();
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.model;

    return Form(
      child: FancyDialog(
        actions: [
          IntrinsicButton(
            disabled: !_selection.any((element) => element),
            child: const Text('Select'),
            onPressed: () {
              final sats = <SatelliteModel>[];

              for (int i = 0; i < _selection.length; i++) {
                if (_selection[i]) {
                  sats.add(data.satellites[i]);
                }
              }

              Navigator.of(context).pop(sats);
            },
          )
        ],
        title: 'TLEs',
        child: ListView.builder(
          itemCount: data.satellites.length,
          itemBuilder: (context, index) {
            final e = data.satellites[index];
            final elev = ((e.lookAngle?.elevation.degrees ?? -90) * 100)
                    .roundToDouble() /
                100.0;
            final azim =
                ((e.lookAngle?.azimuth.degrees ?? -90) * 100).roundToDouble() /
                    100.0;

            Widget? icon;

            if (e.rising) {
              icon = Icon(
                Icons.arrow_upward,
                color: e.color,
              );
            } else if (e.setting) {
              icon = Icon(
                Icons.arrow_downward,
                color: e.color,
              );
            }

            return CheckboxListTile(
              secondary: icon,
              selectedTileColor: e.color.withOpacity(0.2),
              dense: true,
              selected: _selection[index],
              value: _selection[index],
              title: Text(e.gp.name),
              subtitle: Text('Elevation: $elev°, Azimuth: $azim°'),
              onChanged: (v) {
                _selection[index] = v ?? false;
                setState(() {});
              },
            );
          },
        ),
      ),
    );
  }
}
