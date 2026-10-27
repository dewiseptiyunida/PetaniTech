import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CustomDropdown<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String hintText;
  final EdgeInsetsGeometry? padding;
  final Color? iconColor;

  const CustomDropdown({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.hintText = 'Pilih opsi',
    this.padding,
    this.iconColor,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            padding:
                widget.padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: CupertinoColors.white),
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Semua Lahan',
                  // widget.value != null
                  //     ? widget.items
                  //         .firstWhere(
                  //           (item) => item.value == widget.value,
                  //           orElse: () => widget.items.first,
                  //         )
                  //         .child
                  //         .toString()
                  //     : widget.hintText,
                  style: const TextStyle(fontSize: 16),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: _isExpanded ? 0.5 : 0,
                  child: Icon(
                    CupertinoIcons.chevron_down,
                    size: 16,
                    color: widget.iconColor ?? CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.extraLightBackgroundGray,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.systemGrey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children:
                  widget.items.map((item) {
                    return GestureDetector(
                      onTap: () {
                        widget.onChanged?.call(item.value);
                        setState(() {
                          _isExpanded = false;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: CupertinoColors.systemGrey.withOpacity(
                                0.2,
                              ),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: item.child,
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
