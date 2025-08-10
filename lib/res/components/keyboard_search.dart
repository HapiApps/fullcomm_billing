import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../colors.dart';

class KeyboardDropdownField<T extends Object> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final String Function(T item) labelBuilder;
  final void Function(T item)? onSelected;
  final String? initialText;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final double borderRadius;
  final TextEditingController? textEditingController;
  final bool Function(String input, T item)? filterFn;
  final VoidCallback? onClear;


  const KeyboardDropdownField({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.labelBuilder,
    this.onSelected,
    this.initialText,
    this.filterFn,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.textEditingController,
    this.onClear, required this.borderRadius,
  });

  @override
  State<KeyboardDropdownField<T>> createState() =>
      _KeyboardDropdownFieldState<T>();
}

class _KeyboardDropdownFieldState<T extends Object>
    extends State<KeyboardDropdownField<T>> {
  late TextEditingController controller;
  late FocusNode focusNode;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    controller = widget.textEditingController ?? TextEditingController();
    focusNode = widget.focusNode ?? FocusNode();
    scrollController = ScrollController();

    if (widget.initialText != null && controller.text.isEmpty) {
      controller.text = widget.initialText!;
    }
  }

  @override
  void dispose() {
    if (widget.textEditingController == null) controller.dispose();
    if (widget.focusNode == null) focusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<T>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: (TextEditingValue value) {
        final input = value.text.trim().toLowerCase();
        if (input.isEmpty) return widget.items;

        return widget.items.where((item) {
          final label = widget.labelBuilder(item).toLowerCase();
          if (widget.filterFn != null) {
            return widget.filterFn!(input, item);
          }
          return label.contains(input);
        });
      },
      displayStringForOption: widget.labelBuilder,
      onSelected: widget.onSelected,
      fieldViewBuilder: (context, ctrl, focus, onSubmit) {
        return TextField(
          controller: ctrl,
          focusNode: focus,
          onSubmitted: (_) => onSubmit(),
          style: GoogleFonts.lato(fontSize: 15),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            filled: true,
            fillColor: AppColors.textFieldBackground,
            labelText: widget.labelText,
            hintText: widget.hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(
                width: 0,
                color: AppColors.textFieldBackground,
              ),
            ),
            suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    ctrl.clear();
                    controller.clear();
                  });
                  if (widget.onClear != null) {
                    widget.onClear!();
                  }
                },
                icon: const Icon(
                  Icons.clear,
                  color: AppColors.black,
                  size: 14,
                )),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(
                width: 0,
                color: Color(0xff9E9E9E),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(
                width: 0,
                color:Color(0xff9E9E9E),
              ),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final highlightedIndex = AutocompleteHighlightedOption.of(context);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients && highlightedIndex >= 0) {
            scrollController.animateTo(
              highlightedIndex * 48.0,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
            );
          }
        });

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              width: 450,
              child: options.isEmpty
                  ? const ListTile(title: Text("No results found"))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        final isHighlighted = index == highlightedIndex;
                        return InkWell(
                          onTap: () => onSelected(option),
                          child: Container(
                            color: isHighlighted
                                ? Theme.of(context).highlightColor
                                : null,
                            height: 50,
                            width: 450,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: widget.itemBuilder(option),
                          ),
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }
}
