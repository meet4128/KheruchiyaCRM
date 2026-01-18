import 'package:flutter/material.dart';

class CounterWidget extends StatefulWidget {
  final int initialValue;
  final int minValue;
  final int maxValue;
  final ValueChanged<int>? onChanged;

  const CounterWidget({
    Key? key,
    this.initialValue = 0,
    this.minValue = 0,
    this.maxValue = 100,
    this.onChanged,
  }) : super(key: key);

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  late int _counter;

  @override
  void initState() {
    super.initState();
    _counter = widget.initialValue;
  }

  void _increment() {
    if (_counter < widget.maxValue) {
      setState(() {
        _counter++;
      });
      widget.onChanged?.call(_counter);
    }
  }

  void _decrement() {
    if (_counter > widget.minValue) {
      setState(() {
        _counter--;
      });
      widget.onChanged?.call(_counter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus Button
          IconButton(
            onPressed: _counter > widget.minValue ? _decrement : null,
            icon: const Icon(Icons.remove),
            color: Colors.blue,
            disabledColor: Colors.grey,
          ),
          
          // Counter Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$_counter',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Plus Button
          IconButton(
            onPressed: _counter < widget.maxValue ? _increment : null,
            icon: const Icon(Icons.add),
            color: Colors.blue,
            disabledColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}
