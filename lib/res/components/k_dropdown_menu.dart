library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../colors.dart';

typedef FilterCallback<T> = List<MyDropdownMenuEntry<T>> Function(
    List<MyDropdownMenuEntry<T>> entries, String filter);

typedef SearchCallback<T> = int? Function(
    List<MyDropdownMenuEntry<T>> entries, String query);

const double _kMinimumWidth = 112.0;

const double _kDefaultHorizontalPadding = 12.0;

class MyDropdownMenuEntry<T> {
  const MyDropdownMenuEntry({
    required this.value,
    required this.label,
    this.labelWidget,
    this.leadingIcon,
    this.trailingIcon,
    this.enabled = true,
    this.style,
  });

  final T value;
  final String label;
  final Widget? labelWidget;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool enabled;
  final ButtonStyle? style;
}

class MyDropdownMenu<T> extends StatefulWidget {
  const MyDropdownMenu({
    super.key,
    this.enabled = true,
    this.width,
    this.menuHeight,
    this.leadingIcon,
    this.trailingIcon,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.selectedTrailingIcon,
    this.enableFilter = false,
    this.enableSearch = true,
    this.keyboardType,
    this.textStyle,
    this.textAlign = TextAlign.start,
    this.inputDecorationTheme,
    this.menuStyle,
    this.controller,
    this.initialSelection,
    this.onSelected,
    this.focusNode,
    this.requestFocusOnTap,
    this.expandedInsets,
    this.filterCallback,
    this.searchCallback,
    this.alignmentOffset,
    required this.dropdownMenuEntries,
    this.inputFormatters,
    this.labelText,
  }) : assert(filterCallback == null || enableFilter);

  final bool enabled;
  final double? width;
  final double? menuHeight;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final Widget? label;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final String? errorText;
  final Widget? selectedTrailingIcon;
  final bool enableFilter;
  final bool enableSearch;
  final TextInputType? keyboardType;
  final TextStyle? textStyle;
  final TextAlign textAlign;
  final InputDecorationTheme? inputDecorationTheme;
  final MenuStyle? menuStyle;
  final TextEditingController? controller;
  final T? initialSelection;
  final ValueChanged<T?>? onSelected;
  final FocusNode? focusNode;
  final bool? requestFocusOnTap;
  final List<MyDropdownMenuEntry<T>> dropdownMenuEntries;
  final EdgeInsetsGeometry? expandedInsets;
  final FilterCallback<T>? filterCallback;
  final SearchCallback<T>? searchCallback;
  final List<TextInputFormatter>? inputFormatters;
  final Offset? alignmentOffset;

  @override
  State<MyDropdownMenu<T>> createState() => _MyDropdownMenuState<T>();
}

class _MyDropdownMenuState<T> extends State<MyDropdownMenu<T>> {
  final GlobalKey _anchorKey = GlobalKey();
  final GlobalKey _leadingKey = GlobalKey();
  late List<GlobalKey> buttonItemKeys;
  final MenuController _controller = MenuController();
  bool _enableFilter = false;
  late bool _enableSearch;
  late List<MyDropdownMenuEntry<T>> filteredEntries;
  List<Widget>? _initialMenu;
  int? currentHighlight;
  double? leadingPadding;
  bool _menuHasEnabledItem = false;
  TextEditingController? _localTextEditingController;

  TextEditingValue get _initialTextEditingValue {
    for (final MyDropdownMenuEntry<T> entry in filteredEntries) {
      if (entry.value == widget.initialSelection) {
        return TextEditingValue(
          text: entry.label,
          selection: TextSelection.collapsed(offset: entry.label.length),
        );
      }
    }
    return TextEditingValue.empty;
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _localTextEditingController = widget.controller;
    } else {
      _localTextEditingController = TextEditingController();
    }
    _enableSearch = widget.enableSearch;
    filteredEntries = widget.dropdownMenuEntries;
    buttonItemKeys = List<GlobalKey>.generate(
        filteredEntries.length, (int index) => GlobalKey());
    _menuHasEnabledItem =
        filteredEntries.any((MyDropdownMenuEntry<T> entry) => entry.enabled);
    _localTextEditingController?.value = _initialTextEditingValue;

    refreshLeadingPadding();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _localTextEditingController?.dispose();
      _localTextEditingController = null;
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(MyDropdownMenu<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (widget.controller != null) {
        _localTextEditingController?.dispose();
      }
      _localTextEditingController =
          widget.controller ?? TextEditingController();
    }
    if (oldWidget.enableFilter != widget.enableFilter) {
      if (!widget.enableFilter) {
        _enableFilter = false;
      }
    }
    if (oldWidget.enableSearch != widget.enableSearch) {
      if (!widget.enableSearch) {
        _enableSearch = widget.enableSearch;
        currentHighlight = null;
      }
    }
    if (oldWidget.dropdownMenuEntries != widget.dropdownMenuEntries) {
      currentHighlight = null;
      filteredEntries = widget.dropdownMenuEntries;
      buttonItemKeys = List<GlobalKey>.generate(
          filteredEntries.length, (int index) => GlobalKey());
      _menuHasEnabledItem =
          filteredEntries.any((MyDropdownMenuEntry<T> entry) => entry.enabled);
      final bool isCurrentSelectionValid = filteredEntries.any(
          (MyDropdownMenuEntry<T> entry) =>
              entry.label == _localTextEditingController?.text);
      if (!isCurrentSelectionValid) {
        _localTextEditingController?.value = _initialTextEditingValue;
      }
    }
    if (oldWidget.leadingIcon != widget.leadingIcon) {
      refreshLeadingPadding();
    }
    if (oldWidget.initialSelection != widget.initialSelection) {
      _localTextEditingController?.value = _initialTextEditingValue;
    }
  }

  bool canRequestFocus() {
    return widget.focusNode?.canRequestFocus ??
        widget.requestFocusOnTap ??
        switch (Theme.of(context).platform) {
          TargetPlatform.iOS ||
          TargetPlatform.android ||
          TargetPlatform.fuchsia =>
            false,
          TargetPlatform.macOS ||
          TargetPlatform.linux ||
          TargetPlatform.windows =>
            true,
        };
  }

  void refreshLeadingPadding() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        leadingPadding = getWidth(_leadingKey);
      });
    }, debugLabel: 'DropdownMenu.refreshLeadingPadding');
  }

  void scrollToHighlight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentHighlight != null &&
          currentHighlight! >= 0 &&
          currentHighlight! < buttonItemKeys.length) {
        final BuildContext? highlightContext =
            buttonItemKeys[currentHighlight!].currentContext;
        if (highlightContext != null) {
          Scrollable.ensureVisible(
            highlightContext,
            duration: const Duration(milliseconds: 100),
            alignment: 0.5,
          );
        }
      }
    });
  }

  double? getWidth(GlobalKey key) {
    final BuildContext? context = key.currentContext;
    if (context != null) {
      final RenderBox box = context.findRenderObject()! as RenderBox;
      return box.hasSize ? box.size.width : null;
    }
    return null;
  }

  List<MyDropdownMenuEntry<T>> filter(List<MyDropdownMenuEntry<T>> entries,
      TextEditingController textEditingController) {
    final String filterText = textEditingController.text.toLowerCase();
    List<MyDropdownMenuEntry<T>> filteredEntries = entries
        .where((MyDropdownMenuEntry<T> entry) =>
            entry.label.toLowerCase().contains(filterText))
        .toList();
    filteredEntries
        .sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    return filteredEntries;
  }

  bool _shouldUpdateCurrentHighlight(List<MyDropdownMenuEntry<T>> entries) {
    final String searchText =
        _localTextEditingController!.value.text.toLowerCase();
    if (searchText.isEmpty) {
      return true;
    }

    if (currentHighlight == null || currentHighlight! >= entries.length) {
      return true;
    }

    if (entries[currentHighlight!].label.toLowerCase().contains(searchText)) {
      return false;
    }

    return true;
  }

  int? search(List<MyDropdownMenuEntry<T>> entries,
      TextEditingController textEditingController) {
    final String searchText = textEditingController.value.text.toLowerCase();
    if (searchText.isEmpty) {
      return null;
    }

    final int index = entries.indexWhere((MyDropdownMenuEntry<T> entry) =>
        entry.label.toLowerCase().contains(searchText));

    return index != -1 ? index : null;
  }

  List<Widget> _buildButtons(
    List<MyDropdownMenuEntry<T>> filteredEntries,
    TextDirection textDirection, {
    int? focusedIndex,
    bool enableScrollToHighlight = true,
  }) {
    final List<Widget> result = <Widget>[];
    for (int i = 0; i < filteredEntries.length; i++) {
      final MyDropdownMenuEntry<T> entry = filteredEntries[i];

      final double padding = entry.leadingIcon == null
          ? (leadingPadding ?? _kDefaultHorizontalPadding)
          : _kDefaultHorizontalPadding;
      ButtonStyle effectiveStyle = entry.style ??
          switch (textDirection) {
            TextDirection.rtl => MenuItemButton.styleFrom(
                padding: EdgeInsets.only(
                    left: _kDefaultHorizontalPadding, right: padding)),
            TextDirection.ltr => MenuItemButton.styleFrom(
                padding: EdgeInsets.only(
                    left: padding, right: _kDefaultHorizontalPadding)),
          };

      final ButtonStyle? themeStyle = MenuButtonTheme.of(context).style;

      final WidgetStateProperty<Color?>? effectiveForegroundColor =
          entry.style?.foregroundColor ?? themeStyle?.foregroundColor;
      final WidgetStateProperty<Color?>? effectiveIconColor =
          entry.style?.iconColor ?? themeStyle?.iconColor;
      final WidgetStateProperty<Color?>? effectiveOverlayColor =
          entry.style?.overlayColor ?? themeStyle?.overlayColor;
      final WidgetStateProperty<Color?>? effectiveBackgroundColor =
          entry.style?.backgroundColor ?? themeStyle?.backgroundColor;

      if (entry.enabled && i == focusedIndex) {
        final ButtonStyle defaultStyle =
            const MenuItemButton().defaultStyleOf(context);

        Color? resolveFocusedColor(
            WidgetStateProperty<Color?>? colorStateProperty) {
          return colorStateProperty
              ?.resolve(<WidgetState>{WidgetState.focused});
        }

        final Color focusedForegroundColor = resolveFocusedColor(
            effectiveForegroundColor ?? defaultStyle.foregroundColor!)!;
        final Color focusedIconColor =
            resolveFocusedColor(effectiveIconColor ?? defaultStyle.iconColor!)!;
        final Color focusedOverlayColor = resolveFocusedColor(
            effectiveOverlayColor ?? defaultStyle.overlayColor!)!;
        final Color focusedBackgroundColor =
            resolveFocusedColor(effectiveBackgroundColor) ??
                Theme.of(context).colorScheme.onSurface.withOpacity(0.12);

        effectiveStyle = effectiveStyle.copyWith(
          backgroundColor:
              WidgetStatePropertyAll<Color>(focusedBackgroundColor),
          foregroundColor:
              WidgetStatePropertyAll<Color>(focusedForegroundColor),
          iconColor: WidgetStatePropertyAll<Color>(focusedIconColor),
          overlayColor: WidgetStatePropertyAll<Color>(focusedOverlayColor),
        );
      } else {
        effectiveStyle = effectiveStyle.copyWith(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveForegroundColor,
          iconColor: effectiveIconColor,
          overlayColor: effectiveOverlayColor,
        );
      }

      Widget label = entry.labelWidget ?? Text(entry.label);
      if (widget.width != null) {
        final double horizontalPadding = padding + _kDefaultHorizontalPadding;
        label = ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: widget.width! - horizontalPadding),
          child: label,
        );
      }

      final Widget menuItemButton = MenuItemButton(
        key: enableScrollToHighlight ? buttonItemKeys[i] : null,
        style: effectiveStyle,
        leadingIcon: entry.leadingIcon,
        trailingIcon: entry.trailingIcon,
        onPressed: entry.enabled && widget.enabled
            ? () {
                _localTextEditingController?.value = TextEditingValue(
                  text: entry.label,
                  selection:
                      TextSelection.collapsed(offset: entry.label.length),
                );
                currentHighlight = widget.enableSearch ? i : null;
                widget.onSelected?.call(entry.value);
                _enableFilter = false;
              }
            : null,
        requestFocusOnHover: false,
        child: label,
      );
      result.add(menuItemButton);
    }

    return result;
  }

  void handleUpKeyInvoke(_) {
    setState(() {
      if (!widget.enabled || !_menuHasEnabledItem || !_controller.isOpen) {
        return;
      }
      _enableFilter = false;
      _enableSearch = false;
      currentHighlight ??= 0;
      currentHighlight = (currentHighlight! - 1) % filteredEntries.length;
      while (!filteredEntries[currentHighlight!].enabled) {
        currentHighlight = (currentHighlight! - 1) % filteredEntries.length;
      }
      final String currentLabel = filteredEntries[currentHighlight!].label;
      _localTextEditingController?.value = TextEditingValue(
        text: currentLabel,
        selection: TextSelection.collapsed(offset: currentLabel.length),
      );
      scrollToHighlight();
    });
  }

  void handleDownKeyInvoke(_) {
    setState(() {
      if (!widget.enabled || !_menuHasEnabledItem || !_controller.isOpen) {
        return;
      }
      _enableFilter = false;
      _enableSearch = false;
      currentHighlight ??= -1;
      currentHighlight = (currentHighlight! + 1) % filteredEntries.length;
      while (!filteredEntries[currentHighlight!].enabled) {
        currentHighlight = (currentHighlight! + 1) % filteredEntries.length;
      }
      final String currentLabel = filteredEntries[currentHighlight!].label;
      _localTextEditingController?.value = TextEditingValue(
        text: currentLabel,
        selection: TextSelection.collapsed(offset: currentLabel.length),
      );
      scrollToHighlight();
    });
  }

  void handlePressed(MenuController controller) {
    if (controller.isOpen) {
      currentHighlight = null;
      controller.close();
    } else {
      // close to open
      if (_localTextEditingController!.text.isNotEmpty) {
        _enableFilter = false;
      }
      controller.open();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);
    _initialMenu ??= _buildButtons(widget.dropdownMenuEntries, textDirection,
        enableScrollToHighlight: false);
    final DropdownMenuThemeData theme = DropdownMenuTheme.of(context);
    final DropdownMenuThemeData defaults = _DropdownMenuDefaultsM3(context);

    if (_enableFilter) {
      filteredEntries = widget.filterCallback
              ?.call(filteredEntries, _localTextEditingController!.text) ??
          filter(widget.dropdownMenuEntries, _localTextEditingController!);
    } else {
      filteredEntries = widget.dropdownMenuEntries;
    }
    _menuHasEnabledItem =
        filteredEntries.any((MyDropdownMenuEntry<T> entry) => entry.enabled);

    if (_enableSearch) {
      if (widget.searchCallback != null) {
        currentHighlight = widget.searchCallback!(
            filteredEntries, _localTextEditingController!.text);
      } else {
        final bool shouldUpdateCurrentHighlight =
            _shouldUpdateCurrentHighlight(filteredEntries);
        if (shouldUpdateCurrentHighlight) {
          currentHighlight =
              search(filteredEntries, _localTextEditingController!);
        }
      }
      if (currentHighlight != null) {
        scrollToHighlight();
      }
    }

    final List<Widget> menu = _buildButtons(filteredEntries, textDirection,
        focusedIndex: currentHighlight);

    final TextStyle? effectiveTextStyle =
        widget.textStyle ?? theme.textStyle ?? defaults.textStyle;

    MenuStyle? effectiveMenuStyle =
        widget.menuStyle ?? theme.menuStyle ?? defaults.menuStyle!;

    final double? anchorWidth = getWidth(_anchorKey);
    if (widget.width != null) {
      effectiveMenuStyle = effectiveMenuStyle.copyWith(
          minimumSize: WidgetStatePropertyAll<Size?>(Size(widget.width!, 0.0)));
    } else if (anchorWidth != null) {
      effectiveMenuStyle = effectiveMenuStyle.copyWith(
          minimumSize: WidgetStatePropertyAll<Size?>(Size(anchorWidth, 0.0)));
    }

    if (widget.menuHeight != null) {
      effectiveMenuStyle = effectiveMenuStyle.copyWith(
          maximumSize: WidgetStatePropertyAll<Size>(
              Size(double.infinity, widget.menuHeight!)));
    }
    final InputDecorationTheme effectiveInputDecorationTheme =
        widget.inputDecorationTheme ??
            theme.inputDecorationTheme ??
            defaults.inputDecorationTheme!;

    final MouseCursor? effectiveMouseCursor = switch (widget.enabled) {
      true =>
        canRequestFocus() ? SystemMouseCursors.text : SystemMouseCursors.click,
      false => null,
    };

    Widget menuAnchor = MenuAnchor(
      style: effectiveMenuStyle,
      alignmentOffset: widget.alignmentOffset,
      controller: _controller,
      menuChildren: menu,
      crossAxisUnconstrained: false,
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        assert(_initialMenu != null);
        final Widget trailingButton = Padding(
          padding: const EdgeInsets.all(4.0),
          child: IconButton(
            isSelected: controller.isOpen,
            icon: widget.trailingIcon ?? const Icon(Icons.arrow_drop_down),
            selectedIcon:
                widget.selectedTrailingIcon ?? const Icon(Icons.arrow_drop_up),
            onPressed: !widget.enabled
                ? null
                : () {
                    handlePressed(controller);
                  },
          ),
        );

        final Widget leadingButton = Padding(
            padding: const EdgeInsets.all(8.0),
            child: widget.leadingIcon ?? const SizedBox.shrink());

        final Widget textField = TextField(
            key: _anchorKey,
            enabled: widget.enabled,
            mouseCursor: effectiveMouseCursor,
            focusNode: widget.focusNode,
            autofocus: false,

            canRequestFocus: canRequestFocus(),
            enableInteractiveSelection: canRequestFocus(),
            readOnly: !canRequestFocus(),
            keyboardType: widget.keyboardType,
            textAlign: widget.textAlign,
            textAlignVertical: TextAlignVertical.center,
            style: effectiveTextStyle,
            controller: _localTextEditingController,
            onEditingComplete: () {
              if (currentHighlight != null) {
                final MyDropdownMenuEntry<T> entry =
                    filteredEntries[currentHighlight!];
                if (entry.enabled) {
                  _localTextEditingController?.value = TextEditingValue(
                    text: entry.label,
                    selection:
                        TextSelection.collapsed(offset: entry.label.length),
                  );
                  widget.onSelected?.call(entry.value);
                }
              } else {
                widget.onSelected?.call(null);
              }
              if (!widget.enableSearch) {
                currentHighlight = null;
              }
              controller.close();
            },
            onTap: !widget.enabled
                ? null
                : () {
                    handlePressed(controller);
                  },
            onChanged: (String text) {
              controller.open();
              setState(() {
                filteredEntries = widget.dropdownMenuEntries;
                _enableFilter = widget.enableFilter;
                _enableSearch = widget.enableSearch;
              });
            },
            inputFormatters: widget.inputFormatters,
            decoration: InputDecoration(
              label: widget.label,
              labelText: widget.labelText,
              filled: true,
              fillColor: AppColors.textFieldBackground,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide:  BorderSide(
                      width: 0, color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide:  BorderSide(
                      width: 0, color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(width: 0, color: AppColors.primary)),
              hintText: widget.hintText,
              helperText: widget.helperText,
              errorText: widget.errorText,
              prefixIcon: widget.leadingIcon != null
                  ? SizedBox(key: _leadingKey, child: widget.leadingIcon)
                  : null,
              suffixIcon: trailingButton,
            ).applyDefaults(effectiveInputDecorationTheme));

        if (widget.expandedInsets != null) {
          return textField;
        }

        return Shortcuts(
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.arrowLeft):
                ExtendSelectionByCharacterIntent(
                    forward: false, collapseSelection: true),
            SingleActivator(LogicalKeyboardKey.arrowRight):
                ExtendSelectionByCharacterIntent(
                    forward: true, collapseSelection: true),
            SingleActivator(LogicalKeyboardKey.arrowUp): _ArrowUpIntent(),
            SingleActivator(LogicalKeyboardKey.arrowDown): _ArrowDownIntent(),
          },
          child: _DropdownMenuBody(
            width: widget.width,
            children: <Widget>[
              textField,
              ..._initialMenu!.map((Widget item) =>
                  ExcludeFocus(excluding: !controller.isOpen, child: item)),
              trailingButton,
              leadingButton,
            ],
          ),
        );
      },
    );

    if (widget.expandedInsets case final EdgeInsetsGeometry padding) {
      menuAnchor = Padding(
        padding: padding.clamp(
          EdgeInsets.zero,
          const EdgeInsets.only(
            left: double.infinity,
            right: double.infinity,
          ).add(
            const EdgeInsetsDirectional.only(
              end: double.infinity,
              start: double.infinity,
            ),
          ),
        ),
        child: menuAnchor,
      );
    }

    return Actions(
      actions: <Type, Action<Intent>>{
        _ArrowUpIntent: CallbackAction<_ArrowUpIntent>(
          onInvoke: handleUpKeyInvoke,
        ),
        _ArrowDownIntent: CallbackAction<_ArrowDownIntent>(
          onInvoke: handleDownKeyInvoke,
        ),
      },
      child: menuAnchor,
    );
  }
}

class _ArrowUpIntent extends Intent {
  const _ArrowUpIntent();
}

class _ArrowDownIntent extends Intent {
  const _ArrowDownIntent();
}

class _DropdownMenuBody extends MultiChildRenderObjectWidget {
  const _DropdownMenuBody({
    super.children,
    this.width,
  });

  final double? width;

  @override
  _RenderDropdownMenuBody createRenderObject(BuildContext context) {
    return _RenderDropdownMenuBody(
      width: width,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderDropdownMenuBody renderObject) {
    renderObject.width = width;
  }
}

class _DropdownMenuBodyParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderDropdownMenuBody extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _DropdownMenuBodyParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox,
            _DropdownMenuBodyParentData> {
  _RenderDropdownMenuBody({
    double? width,
  }) : _width = width;

  double? get width => _width;
  double? _width;
  set width(double? value) {
    if (_width == value) {
      return;
    }
    _width = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _DropdownMenuBodyParentData) {
      child.parentData = _DropdownMenuBodyParentData();
    }
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    double maxWidth = 0.0;
    double? maxHeight;
    RenderBox? child = firstChild;

    final double intrinsicWidth =
        width ?? getMaxIntrinsicWidth(constraints.maxHeight);
    final double widthConstraint =
        math.min(intrinsicWidth, constraints.maxWidth);
    final BoxConstraints innerConstraints = BoxConstraints(
      maxWidth: widthConstraint,
      maxHeight: getMaxIntrinsicHeight(widthConstraint),
    );
    while (child != null) {
      if (child == firstChild) {
        child.layout(innerConstraints, parentUsesSize: true);
        maxHeight ??= child.size.height;
        final _DropdownMenuBodyParentData childParentData =
            child.parentData! as _DropdownMenuBodyParentData;
        assert(child.parentData == childParentData);
        child = childParentData.nextSibling;
        continue;
      }
      child.layout(innerConstraints, parentUsesSize: true);
      final _DropdownMenuBodyParentData childParentData =
          child.parentData! as _DropdownMenuBodyParentData;
      childParentData.offset = Offset.zero;
      maxWidth = math.max(maxWidth, child.size.width);
      maxHeight ??= child.size.height;
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }

    assert(maxHeight != null);
    maxWidth = math.max(_kMinimumWidth, maxWidth);
    size = constraints.constrain(Size(width ?? maxWidth, maxHeight!));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox? child = firstChild;
    if (child != null) {
      final _DropdownMenuBodyParentData childParentData =
          child.parentData! as _DropdownMenuBodyParentData;
      context.paintChild(child, offset + childParentData.offset);
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final BoxConstraints constraints = this.constraints;
    double maxWidth = 0.0;
    double? maxHeight;
    RenderBox? child = firstChild;
    final double intrinsicWidth =
        width ?? getMaxIntrinsicWidth(constraints.maxHeight);
    final double widthConstraint =
        math.min(intrinsicWidth, constraints.maxWidth);
    final BoxConstraints innerConstraints = BoxConstraints(
      maxWidth: widthConstraint,
      maxHeight: getMaxIntrinsicHeight(widthConstraint),
    );

    while (child != null) {
      if (child == firstChild) {
        final Size childSize = child.getDryLayout(innerConstraints);
        maxHeight ??= childSize.height;
        final _DropdownMenuBodyParentData childParentData =
            child.parentData! as _DropdownMenuBodyParentData;
        assert(child.parentData == childParentData);
        child = childParentData.nextSibling;
        continue;
      }
      final Size childSize = child.getDryLayout(innerConstraints);
      final _DropdownMenuBodyParentData childParentData =
          child.parentData! as _DropdownMenuBodyParentData;
      childParentData.offset = Offset.zero;
      maxWidth = math.max(maxWidth, childSize.width);
      maxHeight ??= childSize.height;
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }

    assert(maxHeight != null);
    maxWidth = math.max(_kMinimumWidth, maxWidth);
    return constraints.constrain(Size(width ?? maxWidth, maxHeight!));
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    RenderBox? child = firstChild;
    double width = 0;
    while (child != null) {
      if (child == firstChild) {
        final _DropdownMenuBodyParentData childParentData =
            child.parentData! as _DropdownMenuBodyParentData;
        child = childParentData.nextSibling;
        continue;
      }
      final double maxIntrinsicWidth = child.getMinIntrinsicWidth(height);
      if (child == lastChild) {
        width += maxIntrinsicWidth;
      }
      if (child == childBefore(lastChild!)) {
        width += maxIntrinsicWidth;
      }
      width = math.max(width, maxIntrinsicWidth);
      final _DropdownMenuBodyParentData childParentData =
          child.parentData! as _DropdownMenuBodyParentData;
      child = childParentData.nextSibling;
    }

    return math.max(width, _kMinimumWidth);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    RenderBox? child = firstChild;
    double width = 0;
    while (child != null) {
      if (child == firstChild) {
        final _DropdownMenuBodyParentData childParentData =
            child.parentData! as _DropdownMenuBodyParentData;
        child = childParentData.nextSibling;
        continue;
      }
      final double maxIntrinsicWidth = child.getMaxIntrinsicWidth(height);
      if (child == lastChild) {
        width += maxIntrinsicWidth;
      }
      if (child == childBefore(lastChild!)) {
        width += maxIntrinsicWidth;
      }
      width = math.max(width, maxIntrinsicWidth);
      final _DropdownMenuBodyParentData childParentData =
          child.parentData! as _DropdownMenuBodyParentData;
      child = childParentData.nextSibling;
    }

    return math.max(width, _kMinimumWidth);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final RenderBox? child = firstChild;
    double width = 0;
    if (child != null) {
      width = math.max(width, child.getMinIntrinsicHeight(width));
    }
    return width;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final RenderBox? child = firstChild;
    double width = 0;
    if (child != null) {
      width = math.max(width, child.getMaxIntrinsicHeight(width));
    }
    return width;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final RenderBox? child = firstChild;
    if (child != null) {
      final _DropdownMenuBodyParentData childParentData =
          child.parentData! as _DropdownMenuBodyParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
    }
    return false;
  }
}

class _DropdownMenuDefaultsM3 extends DropdownMenuThemeData {
  _DropdownMenuDefaultsM3(this.context);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);

  @override
  TextStyle? get textStyle => _theme.textTheme.bodyLarge;

  @override
  MenuStyle get menuStyle {
    return const MenuStyle(
      minimumSize: WidgetStatePropertyAll<Size>(Size(_kMinimumWidth, 0.0)),
      maximumSize: WidgetStatePropertyAll<Size>(Size.infinite),
      visualDensity: VisualDensity.standard,
    );
  }

  @override
  InputDecorationTheme get inputDecorationTheme {
    return const InputDecorationTheme(border: OutlineInputBorder());
  }
}
