import 'package:flutter/material.dart';

class TemperatureSwapButton extends StatelessWidget {
  final VoidCallback onSwap;

  const TemperatureSwapButton({
    super.key,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.swap_horiz),
      onPressed: onSwap,
      tooltip: 'Switch between °F and °C',
    );
  }
}