import 'package:flutter/material.dart';

abstract class ButtonStyleBuilder {
  ButtonStyle buildStyle(BuildContext context, {double? height});
}

class PrimaryButtonStyleBuilder implements ButtonStyleBuilder {
  @override
  ButtonStyle buildStyle(BuildContext context, {double? height}) {
    return ElevatedButton.styleFrom(
      minimumSize: Size(double.infinity, height ?? 48.0),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    );
  }
}

class SecondaryButtonStyleBuilder implements ButtonStyleBuilder {
  @override
  ButtonStyle buildStyle(BuildContext context, {double? height}) {
    return ElevatedButton.styleFrom(
      minimumSize: Size(double.infinity, height ?? 48.0),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    );
  }
}

class OutlinedButtonStyleBuilder implements ButtonStyleBuilder {
  @override
  ButtonStyle buildStyle(BuildContext context, {double? height}) {
    return OutlinedButton.styleFrom(
      minimumSize: Size(double.infinity, height ?? 48.0),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: Theme.of(context).colorScheme.secondary,
        width: 2.0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    );
  }
}

class PTButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonStyleBuilder styleBuilder;
  final double? height;
  final double? fontSize;
  final Widget? icon;

  const PTButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.styleBuilder,
    this.height,
    this.fontSize,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final style = styleBuilder.buildStyle(context, height: height);

    if (styleBuilder is OutlinedButtonStyleBuilder) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        style: style,
        icon: icon ?? const SizedBox.shrink(),
        label: Text(
          label,
          style: TextStyle(
            color: Colors.black87,
            fontSize: fontSize ?? 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child:
          icon != null
              ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon!,
                  const SizedBox(width: 8.0),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize ?? 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
              : Text(
                label,
                style: TextStyle(
                  fontSize: fontSize ?? 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
    );
  }
}
