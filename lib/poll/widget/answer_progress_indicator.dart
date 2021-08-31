import 'package:flutter/material.dart';

class AnswerProgressIndicator extends StatelessWidget {
  const AnswerProgressIndicator(
      {Key? key,
      this.child,
      this.height,
      this.radius = 0.0,
      this.isSelected = false,
      this.padding = 5.0,
      this.onTap,
      required this.progressValue})
      : super(key: key);
  final Function? onTap;
  final Widget? child;
  final double? height;
  final double radius;
  final bool isSelected;
  final double progressValue;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final tap = onTap == null ? null : () => onTap!();
    return GestureDetector(
      onTap: tap,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: isSelected ? Colors.grey : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(radius)),
              height: height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: LinearProgressIndicator(
                  value: progressValue,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.greenAccent.shade200),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.all(8),
                height: height,
                alignment: Alignment.centerLeft,
                child: child)
          ],
        ),
      ),
    );
  }
}
