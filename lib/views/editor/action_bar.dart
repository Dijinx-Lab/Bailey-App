import 'package:bailey/views/editor/aspect_ratio_dropdown.dart';
import 'package:flutter/material.dart';

class ActionBar extends StatefulWidget implements PreferredSizeWidget {
  final bool? canUndo;
  final double? aspectRatio;
  final Function? onReset;
  final Function onBack;
  final Function onOk;
  final Function? onUndo;
  final Function(double?)? onAspectRatio;
  const ActionBar({
    super.key,
    required this.onBack,
    required this.onOk,
    this.canUndo,
    this.onReset,
    this.onUndo,
    this.onAspectRatio,
    this.aspectRatio,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<ActionBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Padding(
        padding: EdgeInsets.only(
            left: 15, right: 15, top: MediaQuery.of(context).padding.top + 3),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => widget.onBack(),
            ),
            const Spacer(),
            if (widget.canUndo != null && widget.onUndo != null)
              Opacity(
                opacity: widget.canUndo! ? 1 : 0.4,
                child: AbsorbPointer(
                  absorbing: !widget.canUndo!,
                  child: IconButton(
                    icon: const Icon(Icons.undo),
                    onPressed: () => widget.onUndo!(),
                  ),
                ),
              ),
            if (widget.onReset != null)
              IconButton(
                icon: const Icon(Icons.restart_alt),
                onPressed: () => widget.onReset!(),
              ),
            if (widget.onAspectRatio != null)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: AspectRatioDropdown(
                  aspectRatio: widget.aspectRatio,
                  onChanged: (value) {
                    widget.onAspectRatio!(value);
                  },
                ),
              ),
            IconButton(
              icon: const Icon(Icons.check_rounded),
              onPressed: () => widget.onOk(),
            ),
          ],
        ),
      ),
    );
  }
}
