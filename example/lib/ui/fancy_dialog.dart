import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class FancyDialog extends StatefulWidget {
  const FancyDialog({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.padding = const EdgeInsets.all(20),
  });

  final String title;
  final Widget child;
  final List<Widget> actions;
  final EdgeInsets padding;

  @override
  State<StatefulWidget> createState() => _FancyDialogState();
}

class _FancyDialogState extends State<FancyDialog> {
  @override
  Widget build(BuildContext context) {
    final any = widget.actions.isNotEmpty;

    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const Gap(16),
          Expanded(child: widget.child),
          if (any)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: ButtonBar(
                children: widget.actions,
              ),
            ),
        ],
      ),
    );
  }
}
