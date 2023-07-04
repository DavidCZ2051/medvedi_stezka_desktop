// packages
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class _HourMinuteTextField extends StatefulWidget {
  const _HourMinuteTextField({
    required this.selectedTime,
    required this.isHour,
    required this.autofocus,
    required this.inputAction,
    required this.style,
    required this.semanticHintText,
    required this.validator,
    required this.onSavedSubmitted,
    this.restorationId,
    this.onChanged,
  });

  final TimeOfDay selectedTime;
  final bool isHour;
  final bool? autofocus;
  final TextInputAction inputAction;
  final TextStyle style;
  final String semanticHintText;
  final FormFieldValidator<String> validator;
  final ValueChanged<String?> onSavedSubmitted;
  final ValueChanged<String>? onChanged;
  final String? restorationId;

  @override
  _HourMinuteTextFieldState createState() => _HourMinuteTextFieldState();
}

class _HourMinuteTextFieldState extends State<_HourMinuteTextField>
    with RestorationMixin {
  final RestorableTextEditingController controller =
      RestorableTextEditingController();
  final RestorableBool controllerHasBeenSet = RestorableBool(false);
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode()
      ..addListener(() {
        setState(() {
          // Rebuild when focus changes.
        });
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only set the text value if it has not been populated with a localized
    // version yet.
    if (!controllerHasBeenSet.value) {
      controllerHasBeenSet.value = true;
      controller.value.text = _formattedValue;
    }
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(controller, 'text_editing_controller');
    registerForRestoration(controllerHasBeenSet, 'has_controller_been_set');
  }

  String get _formattedValue {
    final bool alwaysUse24HourFormat =
        MediaQuery.alwaysUse24HourFormatOf(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    return !widget.isHour
        ? localizations.formatMinute(widget.selectedTime)
        : localizations.formatHour(
            widget.selectedTime,
            alwaysUse24HourFormat: alwaysUse24HourFormat,
          );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TimePickerThemeData timePickerTheme = TimePickerTheme.of(context);
    final _TimePickerDefaults defaultTheme = _TimePickerDefaultsM3(context);

    final bool alwaysUse24HourFormat =
        MediaQuery.alwaysUse24HourFormatOf(context);

    final InputDecorationTheme inputDecorationTheme =
        timePickerTheme.inputDecorationTheme ??
            defaultTheme.inputDecorationTheme;
    InputDecoration inputDecoration =
        const InputDecoration().applyDefaults(inputDecorationTheme);
    // Remove the hint text when focused because the centered cursor
    // appears odd above the hint text.
    final String? hintText = focusNode.hasFocus ? null : _formattedValue;

    // Because the fill color is specified in both the inputDecorationTheme and
    // the TimePickerTheme, if there's one in the user's input decoration theme,
    // use that. If not, but there's one in the user's
    // timePickerTheme.hourMinuteColor, use that, and otherwise use the default.
    // We ignore the value in the fillColor of the input decoration in the
    // default theme here, but it's the same as the hourMinuteColor.
    final Color startingFillColor =
        timePickerTheme.inputDecorationTheme?.fillColor ??
            timePickerTheme.hourMinuteColor ??
            defaultTheme.hourMinuteColor;
    final Color fillColor;
    if (theme.useMaterial3) {
      fillColor = MaterialStateProperty.resolveAs<Color>(
        startingFillColor,
        <MaterialState>{
          if (focusNode.hasFocus) MaterialState.focused,
          if (focusNode.hasFocus) MaterialState.selected,
        },
      );
    } else {
      fillColor = focusNode.hasFocus ? Colors.transparent : startingFillColor;
    }

    inputDecoration = inputDecoration.copyWith(
      hintText: hintText,
      fillColor: fillColor,
    );

    final Set<MaterialState> states = <MaterialState>{
      if (focusNode.hasFocus) MaterialState.focused,
      if (focusNode.hasFocus) MaterialState.selected,
    };
    final Color effectiveTextColor = MaterialStateProperty.resolveAs<Color>(
      timePickerTheme.hourMinuteTextColor ?? defaultTheme.hourMinuteTextColor,
      states,
    );
    final TextStyle effectiveStyle =
        MaterialStateProperty.resolveAs<TextStyle>(widget.style, states)
            .copyWith(color: effectiveTextColor);

    return SizedBox.fromSize(
      size: alwaysUse24HourFormat
          ? defaultTheme.hourMinuteInputSize24Hour
          : defaultTheme.hourMinuteInputSize,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
        child: UnmanagedRestorationScope(
          bucket: bucket,
          child: Semantics(
            label: widget.semanticHintText,
            child: TextFormField(
              restorationId: 'hour_minute_text_form_field',
              autofocus: widget.autofocus ?? false,
              expands: true,
              maxLines: null,
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(2),
              ],
              focusNode: focusNode,
              textAlign: TextAlign.center,
              textInputAction: widget.inputAction,
              keyboardType: TextInputType.number,
              style: effectiveStyle,
              controller: controller.value,
              decoration: inputDecoration,
              validator: widget.validator,
              onEditingComplete: () =>
                  widget.onSavedSubmitted(controller.value.text),
              onSaved: widget.onSavedSubmitted,
              onFieldSubmitted: widget.onSavedSubmitted,
              onChanged: widget.onChanged,
            ),
          ),
        ),
      ),
    );
  }
}

class _MinuteTextField extends StatelessWidget {
  const _MinuteTextField({
    required this.selectedTime,
    required this.style,
    required this.autofocus,
    required this.inputAction,
    required this.validator,
    required this.onSavedSubmitted,
    required this.minuteLabelText,
    this.restorationId,
  });

  final TimeOfDay selectedTime;
  final TextStyle style;
  final bool? autofocus;
  final TextInputAction inputAction;
  final FormFieldValidator<String> validator;
  final ValueChanged<String?> onSavedSubmitted;
  final String? minuteLabelText;
  final String? restorationId;

  @override
  Widget build(BuildContext context) {
    return _HourMinuteTextField(
      restorationId: restorationId,
      selectedTime: selectedTime,
      isHour: false,
      autofocus: autofocus,
      inputAction: inputAction,
      style: style,
      semanticHintText: minuteLabelText ??
          MaterialLocalizations.of(context).timePickerMinuteLabel,
      validator: validator,
      onSavedSubmitted: onSavedSubmitted,
    );
  }
}

class _SecondsTextField extends StatelessWidget {
  const _SecondsTextField({
    required this.selectedTime,
    required this.style,
    required this.autofocus,
    required this.inputAction,
    required this.validator,
    required this.onSavedSubmitted,
    required this.minuteLabelText,
    this.restorationId,
  });

  final TimeOfDay selectedTime;
  final TextStyle style;
  final bool? autofocus;
  final TextInputAction inputAction;
  final FormFieldValidator<String> validator;
  final ValueChanged<String?> onSavedSubmitted;
  final String? minuteLabelText;
  final String? restorationId;

  @override
  Widget build(BuildContext context) {
    return _HourMinuteTextField(
      restorationId: restorationId,
      selectedTime: selectedTime,
      isHour: false,
      autofocus: autofocus,
      inputAction: inputAction,
      style: style,
      semanticHintText: minuteLabelText ??
          MaterialLocalizations.of(context).timePickerMinuteLabel,
      validator: validator,
      onSavedSubmitted: onSavedSubmitted,
    );
  }
}

class _HourTextField extends StatelessWidget {
  const _HourTextField({
    required this.selectedTime,
    required this.style,
    required this.autofocus,
    required this.inputAction,
    required this.validator,
    required this.onSavedSubmitted,
    required this.onChanged,
    required this.hourLabelText,
    this.restorationId,
  });

  final TimeOfDay selectedTime;
  final TextStyle style;
  final bool? autofocus;
  final TextInputAction inputAction;
  final FormFieldValidator<String> validator;
  final ValueChanged<String?> onSavedSubmitted;
  final ValueChanged<String> onChanged;
  final String? hourLabelText;
  final String? restorationId;

  @override
  Widget build(BuildContext context) {
    return _HourMinuteTextField(
      restorationId: restorationId,
      selectedTime: selectedTime,
      isHour: true,
      autofocus: autofocus,
      inputAction: inputAction,
      style: style,
      semanticHintText: hourLabelText ??
          MaterialLocalizations.of(context).timePickerHourLabel,
      validator: validator,
      onSavedSubmitted: onSavedSubmitted,
      onChanged: onChanged,
    );
  }
}

class _AmPmButton extends StatelessWidget {
  const _AmPmButton({
    required this.onPressed,
    required this.selected,
    required this.label,
  });

  final bool selected;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final Set<MaterialState> states = <MaterialState>{
      if (selected) MaterialState.selected
    };
    final TimePickerThemeData timePickerTheme =
        _TimePickerModel.themeOf(context);
    final _TimePickerDefaults defaultTheme =
        _TimePickerModel.defaultThemeOf(context);
    final Color resolvedBackgroundColor =
        MaterialStateProperty.resolveAs<Color>(
            timePickerTheme.dayPeriodColor ?? defaultTheme.dayPeriodColor,
            states);
    final Color resolvedTextColor = MaterialStateProperty.resolveAs<Color>(
        timePickerTheme.dayPeriodTextColor ?? defaultTheme.dayPeriodTextColor,
        states);
    final TextStyle? resolvedTextStyle =
        MaterialStateProperty.resolveAs<TextStyle?>(
                timePickerTheme.dayPeriodTextStyle ??
                    defaultTheme.dayPeriodTextStyle,
                states)
            ?.copyWith(color: resolvedTextColor);
    final double buttonTextScaleFactor =
        math.min(MediaQuery.textScaleFactorOf(context), 2);

    return Material(
      color: resolvedBackgroundColor,
      child: InkWell(
        onTap: Feedback.wrapForTap(onPressed, context),
        child: Semantics(
          checked: selected,
          inMutuallyExclusiveGroup: true,
          button: true,
          child: Center(
            child: Text(
              label,
              style: resolvedTextStyle,
              textScaleFactor: buttonTextScaleFactor,
            ),
          ),
        ),
      ),
    );
  }
}

class _RenderInputPadding extends RenderShiftedBox {
  _RenderInputPadding(this._minSize, this._orientation, [RenderBox? child])
      : super(child);

  Size get minSize => _minSize;
  Size _minSize;
  set minSize(Size value) {
    if (_minSize == value) {
      return;
    }
    _minSize = value;
    markNeedsLayout();
  }

  Orientation get orientation => _orientation;
  Orientation _orientation;
  set orientation(Orientation value) {
    if (_orientation == value) {
      return;
    }
    _orientation = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (child != null) {
      return math.max(child!.getMinIntrinsicWidth(height), minSize.width);
    }
    return 0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (child != null) {
      return math.max(child!.getMinIntrinsicHeight(width), minSize.height);
    }
    return 0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (child != null) {
      return math.max(child!.getMaxIntrinsicWidth(height), minSize.width);
    }
    return 0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (child != null) {
      return math.max(child!.getMaxIntrinsicHeight(width), minSize.height);
    }
    return 0;
  }

  Size _computeSize(
      {required BoxConstraints constraints,
      required ChildLayouter layoutChild}) {
    if (child != null) {
      final Size childSize = layoutChild(child!, constraints);
      final double width = math.max(childSize.width, minSize.width);
      final double height = math.max(childSize.height, minSize.height);
      return constraints.constrain(Size(width, height));
    }
    return Size.zero;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.dryLayoutChild,
    );
  }

  @override
  void performLayout() {
    size = _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.layoutChild,
    );
    if (child != null) {
      final BoxParentData childParentData = child!.parentData! as BoxParentData;
      childParentData.offset =
          Alignment.center.alongOffset(size - child!.size as Offset);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (super.hitTest(result, position: position)) {
      return true;
    }

    if (position.dx < 0 ||
        position.dx > math.max(child!.size.width, minSize.width) ||
        position.dy < 0 ||
        position.dy > math.max(child!.size.height, minSize.height)) {
      return false;
    }

    Offset newPosition = child!.size.center(Offset.zero);
    switch (orientation) {
      case Orientation.portrait:
        if (position.dy > newPosition.dy) {
          newPosition += const Offset(0, 1);
        } else {
          newPosition += const Offset(0, -1);
        }
      case Orientation.landscape:
        if (position.dx > newPosition.dx) {
          newPosition += const Offset(1, 0);
        } else {
          newPosition += const Offset(-1, 0);
        }
    }

    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(newPosition),
      position: newPosition,
      hitTest: (BoxHitTestResult result, Offset position) {
        assert(position == newPosition);
        return child!.hitTest(result, position: newPosition);
      },
    );
  }
}

/// A widget to pad the area around the [_DayPeriodControl]'s inner [Material].
class _DayPeriodInputPadding extends SingleChildRenderObjectWidget {
  const _DayPeriodInputPadding({
    required Widget super.child,
    required this.minSize,
    required this.orientation,
  });

  final Size minSize;
  final Orientation orientation;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderInputPadding(minSize, orientation);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderInputPadding renderObject) {
    renderObject
      ..minSize = minSize
      ..orientation = orientation;
  }
}

/// A widget to pad the area around the [_DayPeriodControl]'s inner [Material].
/* class _DayPeriodInputPadding extends SingleChildRenderObjectWidget {
  const _DayPeriodInputPadding({
    required Widget super.child,
    required this.minSize,
    required this.orientation,
  });

  final Size minSize;
  final Orientation orientation;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderInputPadding(minSize, orientation);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderInputPadding renderObject) {
    renderObject
      ..minSize = minSize
      ..orientation = orientation;
  }
} */

/// Displays the am/pm fragment and provides controls for switching between am
/// and pm.
class _DayPeriodControl extends StatelessWidget {
  const _DayPeriodControl({this.onPeriodChanged});

  final ValueChanged<TimeOfDay>? onPeriodChanged;

  void _togglePeriod(BuildContext context) {
    final TimeOfDay selectedTime = _TimePickerModel.selectedTimeOf(context);
    final int newHour =
        (selectedTime.hour + TimeOfDay.hoursPerPeriod) % TimeOfDay.hoursPerDay;
    final TimeOfDay newTime = selectedTime.replacing(hour: newHour);
    if (onPeriodChanged != null) {
      onPeriodChanged!.call(newTime);
    } else {
      _TimePickerModel.setSelectedTime(context, newTime);
    }
  }

  void _setAm(BuildContext context) {
    final TimeOfDay selectedTime = _TimePickerModel.selectedTimeOf(context);
    if (selectedTime.period == DayPeriod.am) {
      return;
    }
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _announceToAccessibility(context,
            MaterialLocalizations.of(context).anteMeridiemAbbreviation);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
    _togglePeriod(context);
  }

  void _setPm(BuildContext context) {
    final TimeOfDay selectedTime = _TimePickerModel.selectedTimeOf(context);
    if (selectedTime.period == DayPeriod.pm) {
      return;
    }
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _announceToAccessibility(context,
            MaterialLocalizations.of(context).postMeridiemAbbreviation);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
    _togglePeriod(context);
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations materialLocalizations =
        MaterialLocalizations.of(context);
    final TimePickerThemeData timePickerTheme =
        _TimePickerModel.themeOf(context);
    final _TimePickerDefaults defaultTheme =
        _TimePickerModel.defaultThemeOf(context);
    final TimeOfDay selectedTime = _TimePickerModel.selectedTimeOf(context);
    final bool amSelected = selectedTime.period == DayPeriod.am;
    final bool pmSelected = !amSelected;
    final BorderSide resolvedSide =
        timePickerTheme.dayPeriodBorderSide ?? defaultTheme.dayPeriodBorderSide;
    final OutlinedBorder resolvedShape =
        (timePickerTheme.dayPeriodShape ?? defaultTheme.dayPeriodShape)
            .copyWith(side: resolvedSide);

    final Widget amButton = _AmPmButton(
      selected: amSelected,
      onPressed: () => _setAm(context),
      label: materialLocalizations.anteMeridiemAbbreviation,
    );

    final Widget pmButton = _AmPmButton(
      selected: pmSelected,
      onPressed: () => _setPm(context),
      label: materialLocalizations.postMeridiemAbbreviation,
    );

    Size dayPeriodSize;
    final Orientation orientation;
    switch (_TimePickerModel.entryModeOf(context)) {
      case TimePickerEntryMode.dial:
      case TimePickerEntryMode.dialOnly:
        orientation = _TimePickerModel.orientationOf(context);
        switch (orientation) {
          case Orientation.portrait:
            dayPeriodSize = defaultTheme.dayPeriodPortraitSize;
          case Orientation.landscape:
            dayPeriodSize = defaultTheme.dayPeriodLandscapeSize;
        }
      case TimePickerEntryMode.input:
      case TimePickerEntryMode.inputOnly:
        orientation = Orientation.portrait;
        dayPeriodSize = defaultTheme.dayPeriodInputSize;
    }

    final Widget result;
    switch (orientation) {
      case Orientation.portrait:
        result = _DayPeriodInputPadding(
          minSize: dayPeriodSize,
          orientation: orientation,
          child: SizedBox.fromSize(
            size: dayPeriodSize,
            child: Material(
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              shape: resolvedShape,
              child: Column(
                children: <Widget>[
                  Expanded(child: amButton),
                  Container(
                    decoration:
                        BoxDecoration(border: Border(top: resolvedSide)),
                    height: 1,
                  ),
                  Expanded(child: pmButton),
                ],
              ),
            ),
          ),
        );
      case Orientation.landscape:
        result = _DayPeriodInputPadding(
          minSize: dayPeriodSize,
          orientation: orientation,
          child: SizedBox(
            height: dayPeriodSize.height,
            child: Material(
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              shape: resolvedShape,
              child: Row(
                children: <Widget>[
                  Expanded(child: amButton),
                  Container(
                    decoration:
                        BoxDecoration(border: Border(left: resolvedSide)),
                    width: 1,
                  ),
                  Expanded(child: pmButton),
                ],
              ),
            ),
          ),
        );
    }
    return result;
  }
}

class _TimePickerInputState extends State<_TimePickerInput>
    with RestorationMixin {
  late final RestorableTimeOfDay _selectedTime =
      RestorableTimeOfDay(widget.initialSelectedTime);
  final RestorableBool hourHasError = RestorableBool(false);
  final RestorableBool minuteHasError = RestorableBool(false);

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedTime, 'selected_time');
    registerForRestoration(hourHasError, 'hour_has_error');
    registerForRestoration(minuteHasError, 'minute_has_error');
  }

  int? _parseHour(String? value) {
    if (value == null) {
      return null;
    }

    int? newHour = int.tryParse(value);
    if (newHour == null) {
      return null;
    }

    if (MediaQuery.alwaysUse24HourFormatOf(context)) {
      if (newHour >= 0 && newHour < 24) {
        return newHour;
      }
    } else {
      if (newHour > 0 && newHour < 13) {
        if ((_selectedTime.value.period == DayPeriod.pm && newHour != 12) ||
            (_selectedTime.value.period == DayPeriod.am && newHour == 12)) {
          newHour =
              (newHour + TimeOfDay.hoursPerPeriod) % TimeOfDay.hoursPerDay;
        }
        return newHour;
      }
    }
    return null;
  }

  int? _parseMinute(String? value) {
    if (value == null) {
      return null;
    }

    final int? newMinute = int.tryParse(value);
    if (newMinute == null) {
      return null;
    }

    if (newMinute >= 0 && newMinute < 60) {
      return newMinute;
    }
    return null;
  }

  void _handleHourSavedSubmitted(String? value) {
    final int? newHour = _parseHour(value);
    if (newHour != null) {
      _selectedTime.value =
          TimeOfDay(hour: newHour, minute: _selectedTime.value.minute);
      _TimePickerModel.setSelectedTime(context, _selectedTime.value);
      FocusScope.of(context).requestFocus();
    }
  }

  void _handleHourChanged(String value) {
    final int? newHour = _parseHour(value);
    if (newHour != null && value.length == 2) {
      // If a valid hour is typed, move focus to the minute TextField.
      FocusScope.of(context).nextFocus();
    }
  }

  void _handleMinuteSavedSubmitted(String? value) {
    final int? newMinute = _parseMinute(value);
    if (newMinute != null) {
      _selectedTime.value =
          TimeOfDay(hour: _selectedTime.value.hour, minute: int.parse(value!));
      _TimePickerModel.setSelectedTime(context, _selectedTime.value);
      FocusScope.of(context).unfocus();
    }
  }

  void _handleDayPeriodChanged(TimeOfDay value) {
    _selectedTime.value = value;
    _TimePickerModel.setSelectedTime(context, _selectedTime.value);
  }

  String? _validateHour(String? value) {
    final int? newHour = _parseHour(value);
    setState(() {
      hourHasError.value = newHour == null;
    });
    // This is used as the validator for the [TextFormField].
    // Returning an empty string allows the field to go into an error state.
    // Returning null means no error in the validation of the entered text.
    return newHour == null ? '' : null;
  }

  String? _validateMinute(String? value) {
    final int? newMinute = _parseMinute(value);
    setState(() {
      minuteHasError.value = newMinute == null;
    });
    // This is used as the validator for the [TextFormField].
    // Returning an empty string allows the field to go into an error state.
    // Returning null means no error in the validation of the entered text.
    return newMinute == null ? '' : null;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final TimeOfDayFormat timeOfDayFormat = MaterialLocalizations.of(context)
        .timeOfDayFormat(
            alwaysUse24HourFormat: _TimePickerModel.use24HourFormatOf(context));
    final bool use24HourDials = hourFormat(of: timeOfDayFormat) != HourFormat.h;
    final ThemeData theme = Theme.of(context);
    final TimePickerThemeData timePickerTheme =
        _TimePickerModel.themeOf(context);
    final _TimePickerDefaults defaultTheme =
        _TimePickerModel.defaultThemeOf(context);
    final TextStyle hourMinuteStyle =
        timePickerTheme.hourMinuteTextStyle ?? defaultTheme.hourMinuteTextStyle;

    return Padding(
      padding: _TimePickerModel.useMaterial3Of(context)
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsetsDirectional.only(
                bottom: _TimePickerModel.useMaterial3Of(context) ? 20 : 24),
            child: Text(
              widget.helpText,
              style: _TimePickerModel.themeOf(context).helpTextStyle ??
                  _TimePickerModel.defaultThemeOf(context).helpTextStyle,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (!use24HourDials &&
                  timeOfDayFormat ==
                      TimeOfDayFormat.a_space_h_colon_mm) ...<Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: _DayPeriodControl(
                      onPeriodChanged: _handleDayPeriodChanged),
                ),
              ],
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Hour/minutes should not change positions in RTL locales.
                  textDirection: TextDirection.ltr,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _HourTextField(
                              restorationId: 'hour_text_field',
                              selectedTime: _selectedTime.value,
                              style: hourMinuteStyle,
                              autofocus: widget.autofocusHour,
                              inputAction: TextInputAction.next,
                              validator: _validateHour,
                              onSavedSubmitted: _handleHourSavedSubmitted,
                              onChanged: _handleHourChanged,
                              hourLabelText: widget.hourLabelText,
                            ),
                          ),
                          if (!hourHasError.value && !minuteHasError.value)
                            ExcludeSemantics(
                              child: Text(
                                widget.hourLabelText ??
                                    MaterialLocalizations.of(context)
                                        .timePickerHourLabel,
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _StringFragment(timeOfDayFormat: timeOfDayFormat),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _MinuteTextField(
                              restorationId: 'minute_text_field',
                              selectedTime: _selectedTime.value,
                              style: hourMinuteStyle,
                              autofocus: widget.autofocusMinute,
                              inputAction: TextInputAction.done,
                              validator: _validateMinute,
                              onSavedSubmitted: _handleMinuteSavedSubmitted,
                              minuteLabelText: widget.minuteLabelText,
                            ),
                          ),
                          if (!hourHasError.value && !minuteHasError.value)
                            ExcludeSemantics(
                              child: Text(
                                widget.minuteLabelText ??
                                    MaterialLocalizations.of(context)
                                        .timePickerMinuteLabel,
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _StringFragment(timeOfDayFormat: timeOfDayFormat),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _SecondsTextField(
                              restorationId: 'second_text_field',
                              selectedTime: _selectedTime.value,
                              style: hourMinuteStyle,
                              autofocus: widget.autofocusMinute,
                              inputAction: TextInputAction.done,
                              validator: _validateMinute,
                              onSavedSubmitted: _handleMinuteSavedSubmitted,
                              minuteLabelText: widget.minuteLabelText,
                            ),
                          ),
                          if (!hourHasError.value && !minuteHasError.value)
                            ExcludeSemantics(
                              child: Text(
                                widget.minuteLabelText ??
                                    MaterialLocalizations.of(context)
                                        .timePickerMinuteLabel,
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!use24HourDials &&
                  timeOfDayFormat !=
                      TimeOfDayFormat.a_space_h_colon_mm) ...<Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12),
                  child: _DayPeriodControl(
                      onPeriodChanged: _handleDayPeriodChanged),
                ),
              ],
            ],
          ),
          if (hourHasError.value || minuteHasError.value)
            Text(
              widget.errorInvalidText ??
                  MaterialLocalizations.of(context).invalidTimeLabel,
              style: theme.textTheme.bodyMedium!
                  .copyWith(color: theme.colorScheme.error),
            )
          else
            const SizedBox(height: 2),
        ],
      ),
    );
  }
}

// Which kind of hour dial being presented.
enum _HourDialType {
  twentyFourHour,
  twentyFourHourDoubleRing,
  twelveHour,
}

class _TimePickerInput extends StatefulWidget {
  const _TimePickerInput({
    required this.initialSelectedTime,
    required this.errorInvalidText,
    required this.hourLabelText,
    required this.minuteLabelText,
    required this.helpText,
    required this.autofocusHour,
    required this.autofocusMinute,
    this.restorationId,
  });

  /// The time initially selected when the dialog is shown.
  final TimeOfDay initialSelectedTime;

  /// Optionally provide your own validation error text.
  final String? errorInvalidText;

  /// Optionally provide your own hour label text.
  final String? hourLabelText;

  /// Optionally provide your own minute label text.
  final String? minuteLabelText;

  final String helpText;

  final bool? autofocusHour;

  final bool? autofocusMinute;

  /// Restoration ID to save and restore the state of the time picker input
  /// widget.
  ///
  /// If it is non-null, the widget will persist and restore its state
  ///
  /// The state of this widget is persisted in a [RestorationBucket] claimed
  /// from the surrounding [RestorationScope] using the provided restoration ID.
  final String? restorationId;

  @override
  _TimePickerInputState createState() => _TimePickerInputState();
}

// Whether the dial-mode time picker is currently selecting the hour or the
// minute.
enum _HourMinuteMode {
  hour,
  minute
} // Aspects of _TimePickerModel that can be depended upon.

enum _TimePickerAspect {
  use24HourFormat,
  useMaterial3,
  entryMode,
  hourMinuteMode,
  onHourMinuteModeChanged,
  onHourDoubleTapped,
  onMinuteDoubleTapped,
  hourDialType,
  selectedTime,
  onSelectedTimeChanged,
  orientation,
  theme,
  defaultTheme,
}

class _TimePickerModel extends InheritedModel<_TimePickerAspect> {
  const _TimePickerModel({
    required this.entryMode,
    required this.hourMinuteMode,
    required this.onHourMinuteModeChanged,
    required this.onHourDoubleTapped,
    required this.onMinuteDoubleTapped,
    required this.selectedTime,
    required this.onSelectedTimeChanged,
    required this.use24HourFormat,
    required this.useMaterial3,
    required this.hourDialType,
    required this.orientation,
    required this.theme,
    required this.defaultTheme,
    required super.child,
  });

  final TimePickerEntryMode entryMode;
  final _HourMinuteMode hourMinuteMode;
  final ValueChanged<_HourMinuteMode> onHourMinuteModeChanged;
  final GestureTapCallback onHourDoubleTapped;
  final GestureTapCallback onMinuteDoubleTapped;
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> onSelectedTimeChanged;
  final bool use24HourFormat;
  final bool useMaterial3;
  final _HourDialType hourDialType;
  final Orientation orientation;
  final TimePickerThemeData theme;
  final _TimePickerDefaults defaultTheme;

  static _TimePickerModel of(BuildContext context,
          [_TimePickerAspect? aspect]) =>
      InheritedModel.inheritFrom<_TimePickerModel>(context, aspect: aspect)!;
  static TimePickerEntryMode entryModeOf(BuildContext context) =>
      of(context, _TimePickerAspect.entryMode).entryMode;
  static _HourMinuteMode hourMinuteModeOf(BuildContext context) =>
      of(context, _TimePickerAspect.hourMinuteMode).hourMinuteMode;
  static TimeOfDay selectedTimeOf(BuildContext context) =>
      of(context, _TimePickerAspect.selectedTime).selectedTime;
  static bool use24HourFormatOf(BuildContext context) =>
      of(context, _TimePickerAspect.use24HourFormat).use24HourFormat;
  static bool useMaterial3Of(BuildContext context) =>
      of(context, _TimePickerAspect.useMaterial3).useMaterial3;
  static _HourDialType hourDialTypeOf(BuildContext context) =>
      of(context, _TimePickerAspect.hourDialType).hourDialType;
  static Orientation orientationOf(BuildContext context) =>
      of(context, _TimePickerAspect.orientation).orientation;
  static TimePickerThemeData themeOf(BuildContext context) =>
      of(context, _TimePickerAspect.theme).theme;
  static _TimePickerDefaults defaultThemeOf(BuildContext context) =>
      of(context, _TimePickerAspect.defaultTheme).defaultTheme;

  static void setSelectedTime(BuildContext context, TimeOfDay value) =>
      of(context, _TimePickerAspect.onSelectedTimeChanged)
          .onSelectedTimeChanged(value);
  static void setHourMinuteMode(BuildContext context, _HourMinuteMode value) =>
      of(context, _TimePickerAspect.onHourMinuteModeChanged)
          .onHourMinuteModeChanged(value);

  @override
  bool updateShouldNotifyDependent(
      _TimePickerModel oldWidget, Set<_TimePickerAspect> dependencies) {
    if (use24HourFormat != oldWidget.use24HourFormat &&
        dependencies.contains(_TimePickerAspect.use24HourFormat)) {
      return true;
    }
    if (useMaterial3 != oldWidget.useMaterial3 &&
        dependencies.contains(_TimePickerAspect.useMaterial3)) {
      return true;
    }
    if (entryMode != oldWidget.entryMode &&
        dependencies.contains(_TimePickerAspect.entryMode)) {
      return true;
    }
    if (hourMinuteMode != oldWidget.hourMinuteMode &&
        dependencies.contains(_TimePickerAspect.hourMinuteMode)) {
      return true;
    }
    if (onHourMinuteModeChanged != oldWidget.onHourMinuteModeChanged &&
        dependencies.contains(_TimePickerAspect.onHourMinuteModeChanged)) {
      return true;
    }
    if (onHourMinuteModeChanged != oldWidget.onHourDoubleTapped &&
        dependencies.contains(_TimePickerAspect.onHourDoubleTapped)) {
      return true;
    }
    if (onHourMinuteModeChanged != oldWidget.onMinuteDoubleTapped &&
        dependencies.contains(_TimePickerAspect.onMinuteDoubleTapped)) {
      return true;
    }
    if (hourDialType != oldWidget.hourDialType &&
        dependencies.contains(_TimePickerAspect.hourDialType)) {
      return true;
    }
    if (selectedTime != oldWidget.selectedTime &&
        dependencies.contains(_TimePickerAspect.selectedTime)) {
      return true;
    }
    if (onSelectedTimeChanged != oldWidget.onSelectedTimeChanged &&
        dependencies.contains(_TimePickerAspect.onSelectedTimeChanged)) {
      return true;
    }
    if (orientation != oldWidget.orientation &&
        dependencies.contains(_TimePickerAspect.orientation)) {
      return true;
    }
    if (theme != oldWidget.theme &&
        dependencies.contains(_TimePickerAspect.theme)) {
      return true;
    }
    if (defaultTheme != oldWidget.defaultTheme &&
        dependencies.contains(_TimePickerAspect.defaultTheme)) {
      return true;
    }
    return false;
  }

  @override
  bool updateShouldNotify(_TimePickerModel oldWidget) {
    return use24HourFormat != oldWidget.use24HourFormat ||
        useMaterial3 != oldWidget.useMaterial3 ||
        entryMode != oldWidget.entryMode ||
        hourMinuteMode != oldWidget.hourMinuteMode ||
        onHourMinuteModeChanged != oldWidget.onHourMinuteModeChanged ||
        onHourDoubleTapped != oldWidget.onHourDoubleTapped ||
        onMinuteDoubleTapped != oldWidget.onMinuteDoubleTapped ||
        hourDialType != oldWidget.hourDialType ||
        selectedTime != oldWidget.selectedTime ||
        onSelectedTimeChanged != oldWidget.onSelectedTimeChanged ||
        orientation != oldWidget.orientation ||
        theme != oldWidget.theme ||
        defaultTheme != oldWidget.defaultTheme;
  }
}

/// Signature for when the time picker entry mode is changed.
typedef EntryModeChangeCallback = void Function(TimePickerEntryMode);

void _announceToAccessibility(BuildContext context, String message) {
  SemanticsService.announce(message, Directionality.of(context));
}

// An abstract base class for the M2 and M3 defaults below, so that their return
// types can be non-nullable.
abstract class _TimePickerDefaults extends TimePickerThemeData {
  @override
  Color get backgroundColor;

  @override
  ButtonStyle get cancelButtonStyle;

  @override
  ButtonStyle get confirmButtonStyle;

  @override
  BorderSide get dayPeriodBorderSide;

  @override
  Color get dayPeriodColor;

  @override
  OutlinedBorder get dayPeriodShape;

  Size get dayPeriodInputSize;
  Size get dayPeriodLandscapeSize;
  Size get dayPeriodPortraitSize;

  @override
  Color get dayPeriodTextColor;

  @override
  TextStyle get dayPeriodTextStyle;

  @override
  Color get dialBackgroundColor;

  @override
  Color get dialHandColor;

  // Sizes that are generated from the tokens, but these aren't ones we're ready
  // to expose in the theme.
  Size get dialSize;
  double get handWidth;
  double get dotRadius;
  double get centerRadius;

  @override
  Color get dialTextColor;

  @override
  TextStyle get dialTextStyle;

  @override
  double get elevation;

  @override
  Color get entryModeIconColor;

  @override
  TextStyle get helpTextStyle;

  @override
  Color get hourMinuteColor;

  @override
  ShapeBorder get hourMinuteShape;

  Size get hourMinuteSize;
  Size get hourMinuteSize24Hour;
  Size get hourMinuteInputSize;
  Size get hourMinuteInputSize24Hour;

  @override
  Color get hourMinuteTextColor;

  @override
  TextStyle get hourMinuteTextStyle;

  @override
  InputDecorationTheme get inputDecorationTheme;

  @override
  EdgeInsetsGeometry get padding;

  @override
  ShapeBorder get shape;
}

// BEGIN GENERATED TOKEN PROPERTIES - TimePicker

// Do not edit by hand. The code between the "BEGIN GENERATED" and
// "END GENERATED" comments are generated from data in the Material
// Design token database by the script:
//   dev/tools/gen_defaults/bin/gen_defaults.dart.

// Token database version: v0_162

class _TimePickerDefaultsM3 extends _TimePickerDefaults {
  _TimePickerDefaultsM3(this.context);

  final BuildContext context;

  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color get backgroundColor {
    return _colors.surface;
  }

  @override
  ButtonStyle get cancelButtonStyle {
    return TextButton.styleFrom();
  }

  @override
  ButtonStyle get confirmButtonStyle {
    return TextButton.styleFrom();
  }

  @override
  BorderSide get dayPeriodBorderSide {
    return BorderSide(color: _colors.outline);
  }

  @override
  Color get dayPeriodColor {
    return MaterialStateColor.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return _colors.tertiaryContainer;
      }
      // The unselected day period should match the overall picker dialog color.
      // Making it transparent enables that without being redundant and allows
      // the optional elevation overlay for dark mode to be visible.
      return Colors.transparent;
    });
  }

  @override
  OutlinedBorder get dayPeriodShape {
    return const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)))
        .copyWith(side: dayPeriodBorderSide);
  }

  @override
  Size get dayPeriodPortraitSize {
    return const Size(52, 80);
  }

  @override
  Size get dayPeriodLandscapeSize {
    return const Size(216, 38);
  }

  @override
  Size get dayPeriodInputSize {
    // Input size is eight pixels smaller than the portrait size in the spec,
    // but there's not token for it yet.
    return Size(dayPeriodPortraitSize.width, dayPeriodPortraitSize.height - 8);
  }

  @override
  Color get dayPeriodTextColor {
    return MaterialStateColor.resolveWith((Set<MaterialState> states) {
      return _dayPeriodForegroundColor.resolve(states);
    });
  }

  MaterialStateProperty<Color> get _dayPeriodForegroundColor {
    return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      Color? textColor;
      if (states.contains(MaterialState.selected)) {
        if (states.contains(MaterialState.pressed)) {
          textColor = _colors.onTertiaryContainer;
        } else {
          // not pressed
          if (states.contains(MaterialState.focused)) {
            textColor = _colors.onTertiaryContainer;
          } else {
            // not focused
            if (states.contains(MaterialState.hovered)) {
              textColor = _colors.onTertiaryContainer;
            }
          }
        }
      } else {
        // unselected
        if (states.contains(MaterialState.pressed)) {
          textColor = _colors.onSurfaceVariant;
        } else {
          // not pressed
          if (states.contains(MaterialState.focused)) {
            textColor = _colors.onSurfaceVariant;
          } else {
            // not focused
            if (states.contains(MaterialState.hovered)) {
              textColor = _colors.onSurfaceVariant;
            }
          }
        }
      }
      return textColor ?? _colors.onTertiaryContainer;
    });
  }

  @override
  TextStyle get dayPeriodTextStyle {
    return _textTheme.titleMedium!.copyWith(color: dayPeriodTextColor);
  }

  @override
  Color get dialBackgroundColor {
    return _colors.surfaceVariant
        .withOpacity(_colors.brightness == Brightness.dark ? 0.12 : 0.08);
  }

  @override
  Color get dialHandColor {
    return _colors.primary;
  }

  @override
  Size get dialSize {
    return const Size.square(256.0);
  }

  @override
  double get handWidth {
    return const Size(2, double.infinity).width;
  }

  @override
  double get dotRadius {
    return const Size.square(48.0).width / 2;
  }

  @override
  double get centerRadius {
    return const Size.square(8.0).width / 2;
  }

  @override
  Color get dialTextColor {
    return MaterialStateColor.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return _colors.onPrimary;
      }
      return _colors.onSurface;
    });
  }

  @override
  TextStyle get dialTextStyle {
    return _textTheme.bodyLarge!;
  }

  @override
  double get elevation {
    return 6.0;
  }

  @override
  Color get entryModeIconColor {
    return _colors.onSurface;
  }

  @override
  TextStyle get helpTextStyle {
    return MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
      final TextStyle textStyle = _textTheme.labelMedium!;
      return textStyle.copyWith(color: _colors.onSurfaceVariant);
    });
  }

  @override
  EdgeInsetsGeometry get padding {
    return const EdgeInsets.all(24);
  }

  @override
  Color get hourMinuteColor {
    return MaterialStateColor.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        Color overlayColor = _colors.primaryContainer;
        if (states.contains(MaterialState.pressed)) {
          overlayColor = _colors.onPrimaryContainer;
        } else if (states.contains(MaterialState.focused)) {
          const double focusOpacity = 0.12;
          overlayColor = _colors.onPrimaryContainer.withOpacity(focusOpacity);
        } else if (states.contains(MaterialState.hovered)) {
          const double hoverOpacity = 0.08;
          overlayColor = _colors.onPrimaryContainer.withOpacity(hoverOpacity);
        }
        return Color.alphaBlend(overlayColor, _colors.primaryContainer);
      } else {
        Color overlayColor = _colors.surfaceVariant;
        if (states.contains(MaterialState.pressed)) {
          overlayColor = _colors.onSurface;
        } else if (states.contains(MaterialState.focused)) {
          const double focusOpacity = 0.12;
          overlayColor = _colors.onSurface.withOpacity(focusOpacity);
        } else if (states.contains(MaterialState.hovered)) {
          const double hoverOpacity = 0.08;
          overlayColor = _colors.onSurface.withOpacity(hoverOpacity);
        }
        return Color.alphaBlend(overlayColor, _colors.surfaceVariant);
      }
    });
  }

  @override
  ShapeBorder get hourMinuteShape {
    return const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)));
  }

  @override
  Size get hourMinuteSize {
    return const Size(96, 80);
  }

  @override
  Size get hourMinuteSize24Hour {
    return Size(const Size(114, double.infinity).width, hourMinuteSize.height);
  }

  @override
  Size get hourMinuteInputSize {
    // Input size is eight pixels smaller than the regular size in the spec, but
    // there's not token for it yet.
    return Size(hourMinuteSize.width, hourMinuteSize.height - 8);
  }

  @override
  Size get hourMinuteInputSize24Hour {
    // Input size is eight pixels smaller than the regular size in the spec, but
    // there's not token for it yet.
    return Size(hourMinuteSize24Hour.width, hourMinuteSize24Hour.height - 8);
  }

  @override
  Color get hourMinuteTextColor {
    return MaterialStateColor.resolveWith((Set<MaterialState> states) {
      return _hourMinuteTextColor.resolve(states);
    });
  }

  MaterialStateProperty<Color> get _hourMinuteTextColor {
    return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        if (states.contains(MaterialState.pressed)) {
          return _colors.onPrimaryContainer;
        }
        if (states.contains(MaterialState.focused)) {
          return _colors.onPrimaryContainer;
        }
        if (states.contains(MaterialState.hovered)) {
          return _colors.onPrimaryContainer;
        }
        return _colors.onPrimaryContainer;
      } else {
        // unselected
        if (states.contains(MaterialState.pressed)) {
          return _colors.onSurface;
        }
        if (states.contains(MaterialState.focused)) {
          return _colors.onSurface;
        }
        if (states.contains(MaterialState.hovered)) {
          return _colors.onSurface;
        }
        return _colors.onSurface;
      }
    });
  }

  @override
  TextStyle get hourMinuteTextStyle {
    return MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
      return _textTheme.displayLarge!
          .copyWith(color: _hourMinuteTextColor.resolve(states));
    });
  }

  @override
  InputDecorationTheme get inputDecorationTheme {
    // This is NOT correct, but there's no token for
    // 'time-input.container.shape', so this is using the radius from the shape
    // for the hour/minute selector. It's a BorderRadiusGeometry, so we have to
    // resolve it before we can use it.
    final BorderRadius selectorRadius = const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)))
        .borderRadius
        .resolve(Directionality.of(context));
    return InputDecorationTheme(
      contentPadding: EdgeInsets.zero,
      filled: true,
      // This should be derived from a token, but there isn't one for 'time-input'.
      fillColor: hourMinuteColor,
      // This should be derived from a token, but there isn't one for 'time-input'.
      focusColor: _colors.primaryContainer,
      enabledBorder: OutlineInputBorder(
        borderRadius: selectorRadius,
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: selectorRadius,
        borderSide: BorderSide(color: _colors.error, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: selectorRadius,
        borderSide: BorderSide(color: _colors.primary, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: selectorRadius,
        borderSide: BorderSide(color: _colors.error, width: 2),
      ),
      hintStyle: hourMinuteTextStyle.copyWith(
          color: _colors.onSurface.withOpacity(0.36)),
      // Prevent the error text from appearing.
      // TODO(rami-a): Remove this workaround once
      // https://github.com/flutter/flutter/issues/54104
      // is fixed.
      errorStyle: const TextStyle(fontSize: 0, height: 0),
    );
  }

  @override
  ShapeBorder get shape {
    return const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28.0)));
  }
}

// END GENERATED TOKEN PROPERTIES - TimePicker

/// A passive fragment showing a string value.
///
/// Used to display the appropriate separator between the input fields.
class _StringFragment extends StatelessWidget {
  const _StringFragment({required this.timeOfDayFormat});

  final TimeOfDayFormat timeOfDayFormat;

  String _stringFragmentValue(TimeOfDayFormat timeOfDayFormat) {
    switch (timeOfDayFormat) {
      case TimeOfDayFormat.h_colon_mm_space_a:
      case TimeOfDayFormat.a_space_h_colon_mm:
      case TimeOfDayFormat.H_colon_mm:
      case TimeOfDayFormat.HH_colon_mm:
        return ':';
      case TimeOfDayFormat.HH_dot_mm:
        return '.';
      case TimeOfDayFormat.frenchCanadian:
        return 'h';
    }
  }

  @override
  Widget build(BuildContext context) {
    final TimePickerThemeData timePickerTheme = TimePickerTheme.of(context);
    final _TimePickerDefaults defaultTheme = _TimePickerDefaultsM3(context);
    final Set<MaterialState> states = <MaterialState>{};

    final Color effectiveTextColor = MaterialStateProperty.resolveAs<Color>(
      timePickerTheme.hourMinuteTextColor ?? defaultTheme.hourMinuteTextColor,
      states,
    );
    final TextStyle effectiveStyle = MaterialStateProperty.resolveAs<TextStyle>(
      timePickerTheme.hourMinuteTextStyle ?? defaultTheme.hourMinuteTextStyle,
      states,
    ).copyWith(color: effectiveTextColor);

    final double height;
    switch (_TimePickerModel.entryModeOf(context)) {
      case TimePickerEntryMode.dial:
      case TimePickerEntryMode.dialOnly:
        height = defaultTheme.hourMinuteSize.height;
      case TimePickerEntryMode.input:
      case TimePickerEntryMode.inputOnly:
        height = defaultTheme.hourMinuteInputSize.height;
    }

    return ExcludeSemantics(
      child: SizedBox(
        width: timeOfDayFormat == TimeOfDayFormat.frenchCanadian ? 36 : 24,
        height: height,
        child: Text(
          _stringFragmentValue(timeOfDayFormat),
          style: effectiveStyle,
          textScaleFactor: 1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// The _TimePicker widget is constructed so that in the future we could expose
// this as a public API for embedding time pickers into other non-dialog
// widgets, once we're sure we want to support that.

/// A Time Picker widget that can be embedded into another widget.
class _TimePicker extends StatefulWidget {
  /// Creates a const Material Design time picker.
  const _TimePicker({
    required this.time,
    required this.onTimeChanged,
    this.helpText,
    this.cancelText,
    this.confirmText,
    this.errorInvalidText,
    this.hourLabelText,
    this.minuteLabelText,
    this.restorationId,
    this.entryMode = TimePickerEntryMode.dial,
    this.orientation,
    this.onEntryModeChanged,
  });

  /// Optionally provide your own text for the help text at the top of the
  /// control.
  ///
  /// If null, the widget uses [MaterialLocalizations.timePickerDialHelpText]
  /// when the [entryMode] is [TimePickerEntryMode.dial], and
  /// [MaterialLocalizations.timePickerInputHelpText] when the [entryMode] is
  /// [TimePickerEntryMode.input].
  final String? helpText;

  /// Optionally provide your own text for the cancel button.
  ///
  /// If null, the button uses [MaterialLocalizations.cancelButtonLabel].
  final String? cancelText;

  /// Optionally provide your own text for the confirm button.
  ///
  /// If null, the button uses [MaterialLocalizations.okButtonLabel].
  final String? confirmText;

  /// Optionally provide your own validation error text.
  final String? errorInvalidText;

  /// Optionally provide your own hour label text.
  final String? hourLabelText;

  /// Optionally provide your own minute label text.
  final String? minuteLabelText;

  /// Restoration ID to save and restore the state of the [TimePickerDialog].
  ///
  /// If it is non-null, the time picker will persist and restore the
  /// dialog's state.
  ///
  /// The state of this widget is persisted in a [RestorationBucket] claimed
  /// from the surrounding [RestorationScope] using the provided restoration ID.
  ///
  /// See also:
  ///
  ///  * [RestorationManager], which explains how state restoration works in
  ///    Flutter.
  final String? restorationId;

  /// The initial entry mode for the picker. Whether it's text input or a dial.
  final TimePickerEntryMode entryMode;

  /// The currently selected time of day.
  final TimeOfDay time;

  final ValueChanged<TimeOfDay>? onTimeChanged;

  /// The optional [orientation] parameter sets the [Orientation] to use when
  /// displaying the dialog.
  ///
  /// By default, the orientation is derived from the [MediaQueryData.size] of
  /// the ambient [MediaQuery]. If the aspect of the size is tall, then
  /// [Orientation.portrait] is used, if the size is wide, then
  /// [Orientation.landscape] is used.
  ///
  /// Use this parameter to override the default and force the dialog to appear
  /// in either portrait or landscape mode regardless of the aspect of the
  /// [MediaQueryData.size].
  final Orientation? orientation;

  /// Callback called when the selected entry mode is changed.
  final EntryModeChangeCallback? onEntryModeChanged;

  @override
  State<_TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<_TimePicker> with RestorationMixin {
  Timer? _vibrateTimer;
  late MaterialLocalizations localizations;
  final RestorableEnum<_HourMinuteMode> _hourMinuteMode =
      RestorableEnum<_HourMinuteMode>(_HourMinuteMode.hour,
          values: _HourMinuteMode.values);
  final RestorableEnumN<_HourMinuteMode> _lastModeAnnounced =
      RestorableEnumN<_HourMinuteMode>(null, values: _HourMinuteMode.values);
  final RestorableBoolN _autofocusHour = RestorableBoolN(null);
  final RestorableBoolN _autofocusMinute = RestorableBoolN(null);
  final RestorableBool _announcedInitialTime = RestorableBool(false);
  late final RestorableEnumN<Orientation> _orientation =
      RestorableEnumN<Orientation>(widget.orientation,
          values: Orientation.values);
  RestorableTimeOfDay get selectedTime => _selectedTime;
  late final RestorableTimeOfDay _selectedTime =
      RestorableTimeOfDay(widget.time);

  @override
  void dispose() {
    _vibrateTimer?.cancel();
    _vibrateTimer = null;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
    _announceInitialTimeOnce();
    _announceModeOnce();
  }

  @override
  void didUpdateWidget(_TimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orientation != widget.orientation) {
      _orientation.value = widget.orientation;
    }
    if (oldWidget.time != widget.time) {
      _selectedTime.value = widget.time;
    }
  }

  void _setEntryMode(TimePickerEntryMode mode) {
    widget.onEntryModeChanged?.call(mode);
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_hourMinuteMode, 'hour_minute_mode');
    registerForRestoration(_lastModeAnnounced, 'last_mode_announced');
    registerForRestoration(_autofocusHour, 'autofocus_hour');
    registerForRestoration(_autofocusMinute, 'autofocus_minute');
    registerForRestoration(_announcedInitialTime, 'announced_initial_time');
    registerForRestoration(_selectedTime, 'selected_time');
    registerForRestoration(_orientation, 'orientation');
  }

  void _handleHourMinuteModeChanged(_HourMinuteMode mode) {
    setState(() {
      _hourMinuteMode.value = mode;
      _announceModeOnce();
    });
  }

  void _handleEntryModeToggle() {
    setState(() {
      TimePickerEntryMode newMode = widget.entryMode;
      switch (widget.entryMode) {
        case TimePickerEntryMode.dial:
          newMode = TimePickerEntryMode.input;
        case TimePickerEntryMode.input:
          _autofocusHour.value = false;
          _autofocusMinute.value = false;
          newMode = TimePickerEntryMode.dial;
        case TimePickerEntryMode.dialOnly:
        case TimePickerEntryMode.inputOnly:
          FlutterError('Can not change entry mode from ${widget.entryMode}');
      }
      _setEntryMode(newMode);
    });
  }

  void _announceModeOnce() {
    if (_lastModeAnnounced.value == _hourMinuteMode.value) {
      // Already announced it.
      return;
    }

    switch (_hourMinuteMode.value) {
      case _HourMinuteMode.hour:
        _announceToAccessibility(
            context, localizations.timePickerHourModeAnnouncement);
      case _HourMinuteMode.minute:
        _announceToAccessibility(
            context, localizations.timePickerMinuteModeAnnouncement);
    }
    _lastModeAnnounced.value = _hourMinuteMode.value;
  }

  void _announceInitialTimeOnce() {
    if (_announcedInitialTime.value) {
      return;
    }

    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    _announceToAccessibility(
      context,
      localizations.formatTimeOfDay(_selectedTime.value,
          alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context)),
    );
    _announcedInitialTime.value = true;
  }

  void _handleTimeChanged(TimeOfDay value) {
    setState(() {
      _selectedTime.value = value;
      widget.onTimeChanged?.call(value);
    });
  }

  void _handleHourDoubleTapped() {
    _autofocusHour.value = true;
    _handleEntryModeToggle();
  }

  void _handleMinuteDoubleTapped() {
    _autofocusMinute.value = true;
    _handleEntryModeToggle();
  }

  void _handleHourSelected() {
    setState(() {
      _hourMinuteMode.value = _HourMinuteMode.minute;
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final TimeOfDayFormat timeOfDayFormat = localizations.timeOfDayFormat(
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context));
    final ThemeData theme = Theme.of(context);
    final _TimePickerDefaults defaultTheme = _TimePickerDefaultsM3(context);
    final Orientation orientation =
        _orientation.value ?? MediaQuery.orientationOf(context);
    final HourFormat timeOfDayHour = hourFormat(of: timeOfDayFormat);
    final _HourDialType hourMode;
    switch (timeOfDayHour) {
      case HourFormat.HH:
      case HourFormat.H:
        hourMode = _HourDialType.twentyFourHourDoubleRing;
      case HourFormat.h:
        hourMode = _HourDialType.twelveHour;
    }

    final String helpText;
    final Widget picker;
    switch (widget.entryMode) {
      case TimePickerEntryMode.dial:
      case TimePickerEntryMode.dialOnly:
        helpText = widget.helpText ??
            (theme.useMaterial3
                ? localizations.timePickerDialHelpText
                : localizations.timePickerDialHelpText.toUpperCase());

        final EdgeInsetsGeometry dialPadding;
        switch (orientation) {
          case Orientation.portrait:
            dialPadding = const EdgeInsets.only(left: 12, right: 12, top: 36);
          case Orientation.landscape:
            switch (theme.materialTapTargetSize) {
              case MaterialTapTargetSize.padded:
                dialPadding = const EdgeInsetsDirectional.only(start: 64);
              case MaterialTapTargetSize.shrinkWrap:
                dialPadding = const EdgeInsetsDirectional.only(start: 64);
            }
        }

        switch (orientation) {
          case Orientation.portrait:
            picker = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: theme.useMaterial3 ? 0 : 16),
                  child: Placeholder(), //_TimePickerHeader(helpText: helpText),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Dial grows and shrinks with the available space.
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: theme.useMaterial3 ? 0 : 16),
                          child: Placeholder(), //_Dial(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          case Orientation.landscape:
            picker = Column(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: theme.useMaterial3 ? 0 : 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Placeholder(), //_TimePickerHeader(helpText: helpText),
                        Expanded(child: Placeholder()), // _Dial(),
                      ],
                    ),
                  ),
                ),
              ],
            );
        }
      case TimePickerEntryMode.input:
      case TimePickerEntryMode.inputOnly:
        final String helpText = widget.helpText ??
            (theme.useMaterial3
                ? localizations.timePickerInputHelpText
                : localizations.timePickerInputHelpText.toUpperCase());

        picker = Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _TimePickerInput(
              initialSelectedTime: _selectedTime.value,
              errorInvalidText: widget.errorInvalidText,
              hourLabelText: widget.hourLabelText,
              minuteLabelText: widget.minuteLabelText,
              helpText: helpText,
              autofocusHour: _autofocusHour.value,
              autofocusMinute: _autofocusMinute.value,
              restorationId: 'time_picker_input',
            ),
          ],
        );
    }
    return _TimePickerModel(
      entryMode: widget.entryMode,
      selectedTime: _selectedTime.value,
      hourMinuteMode: _hourMinuteMode.value,
      orientation: orientation,
      onHourMinuteModeChanged: _handleHourMinuteModeChanged,
      onHourDoubleTapped: _handleHourDoubleTapped,
      onMinuteDoubleTapped: _handleMinuteDoubleTapped,
      hourDialType: hourMode,
      onSelectedTimeChanged: _handleTimeChanged,
      useMaterial3: theme.useMaterial3,
      use24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      theme: TimePickerTheme.of(context),
      defaultTheme: defaultTheme,
      child: picker,
    );
  }
}

class MyTimePicker extends StatefulWidget {
  const MyTimePicker({super.key});

  @override
  State<MyTimePicker> createState() => _MyTimePickerState();
}

class _MyTimePickerState extends State<MyTimePicker> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300, maxHeight: 500),
      child: Container(
        color: Colors.red,
        child: _TimePicker(
          entryMode: TimePickerEntryMode.inputOnly,
          time: TimeOfDay.now(),
          onTimeChanged: (value) {
            print(value);
          },
        ),
      ),
    );
  }
}

class MyTimePicker2 extends StatefulWidget {
  const MyTimePicker2({super.key});

  @override
  State<MyTimePicker2> createState() => _MyTimePicker2State();
}

class _MyTimePicker2State extends State<MyTimePicker2> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [],
    );
  }
}

//

//

//

//

//

//

//

//

//

//

//

//

//

/* class _TimePickerHeader extends StatelessWidget {
  const _TimePickerHeader({required this.helpText});

  final String helpText;

  @override
  Widget build(BuildContext context) {
    final TimeOfDayFormat timeOfDayFormat =
        MaterialLocalizations.of(context).timeOfDayFormat(
      alwaysUse24HourFormat: _TimePickerModel.use24HourFormatOf(context),
    );

    final _HourDialType hourDialType = _TimePickerModel.hourDialTypeOf(context);
    switch (_TimePickerModel.orientationOf(context)) {
      case Orientation.portrait:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsetsDirectional.only(
                  bottom: _TimePickerModel.useMaterial3Of(context) ? 20 : 24),
              child: Text(
                helpText,
                style: _TimePickerModel.themeOf(context).helpTextStyle ??
                    _TimePickerModel.defaultThemeOf(context).helpTextStyle,
              ),
            ),
            Row(
              children: <Widget>[
                if (hourDialType == _HourDialType.twelveHour &&
                    timeOfDayFormat == TimeOfDayFormat.a_space_h_colon_mm)
                  const _DayPeriodControl(),
                Expanded(
                  child: Row(
                    // Hour/minutes should not change positions in RTL locales.
                    textDirection: TextDirection.ltr,
                    children: <Widget>[
                      const Expanded(child: _HourControl()),
                      _StringFragment(timeOfDayFormat: timeOfDayFormat),
                      const Expanded(child: _MinuteControl()),
                    ],
                  ),
                ),
                if (hourDialType == _HourDialType.twelveHour &&
                    timeOfDayFormat !=
                        TimeOfDayFormat.a_space_h_colon_mm) ...<Widget>[
                  const SizedBox(width: 12),
                  const _DayPeriodControl(),
                ],
              ],
            ),
          ],
        );
      case Orientation.landscape:
        return SizedBox(
          width: _kTimePickerHeaderLandscapeWidth,
          child: Stack(
            children: <Widget>[
              Text(
                helpText,
                style: _TimePickerModel.themeOf(context).helpTextStyle ??
                    _TimePickerModel.defaultThemeOf(context).helpTextStyle,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (hourDialType == _HourDialType.twelveHour &&
                      timeOfDayFormat == TimeOfDayFormat.a_space_h_colon_mm)
                    const _DayPeriodControl(),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom:
                            hourDialType == _HourDialType.twelveHour ? 12 : 0),
                    child: Row(
                      // Hour/minutes should not change positions in RTL locales.
                      textDirection: TextDirection.ltr,
                      children: <Widget>[
                        const Expanded(child: _HourControl()),
                        _StringFragment(timeOfDayFormat: timeOfDayFormat),
                        const Expanded(child: _MinuteControl()),
                      ],
                    ),
                  ),
                  if (hourDialType == _HourDialType.twelveHour &&
                      timeOfDayFormat != TimeOfDayFormat.a_space_h_colon_mm)
                    const _DayPeriodControl(),
                ],
              ),
            ],
          ),
        );
    }
  }
} */

/* class _HourMinuteControl extends StatelessWidget {
  const _HourMinuteControl({
    required this.text,
    required this.onTap,
    required this.onDoubleTap,
    required this.isSelected,
  });

  final String text;
  final GestureTapCallback onTap;
  final GestureTapCallback onDoubleTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final TimePickerThemeData timePickerTheme =
        _TimePickerModel.themeOf(context);
    final _TimePickerDefaults defaultTheme =
        _TimePickerModel.defaultThemeOf(context);
    final Color backgroundColor =
        timePickerTheme.hourMinuteColor ?? defaultTheme.hourMinuteColor;
    final ShapeBorder shape =
        timePickerTheme.hourMinuteShape ?? defaultTheme.hourMinuteShape;

    final Set<MaterialState> states = <MaterialState>{
      if (isSelected) MaterialState.selected,
    };
    final Color effectiveTextColor = MaterialStateProperty.resolveAs<Color>(
      _TimePickerModel.themeOf(context).hourMinuteTextColor ??
          _TimePickerModel.defaultThemeOf(context).hourMinuteTextColor,
      states,
    );
    final TextStyle effectiveStyle = MaterialStateProperty.resolveAs<TextStyle>(
      timePickerTheme.hourMinuteTextStyle ?? defaultTheme.hourMinuteTextStyle,
      states,
    ).copyWith(color: effectiveTextColor);

    final double height;
    switch (_TimePickerModel.entryModeOf(context)) {
      case TimePickerEntryMode.dial:
      case TimePickerEntryMode.dialOnly:
        height = defaultTheme.hourMinuteSize.height;
      case TimePickerEntryMode.input:
      case TimePickerEntryMode.inputOnly:
        height = defaultTheme.hourMinuteInputSize.height;
    }

    return SizedBox(
      height: height,
      child: Material(
        color: MaterialStateProperty.resolveAs(backgroundColor, states),
        clipBehavior: Clip.antiAlias,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          onDoubleTap: isSelected ? onDoubleTap : null,
          child: Center(
            child: Text(
              text,
              style: effectiveStyle,
              textScaleFactor: 1,
            ),
          ),
        ),
      ),
    );
  }
} */

/// Displays the hour fragment.
///
/// When tapped changes time picker dial mode to [_HourMinuteMode.hour].
/* class _HourControl extends StatelessWidget {
  const _HourControl();

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final bool alwaysUse24HourFormat =
        MediaQuery.alwaysUse24HourFormatOf(context);
    final TimeOfDay selectedTime = _TimePickerModel.selectedTimeOf(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final String formattedHour = localizations.formatHour(
      selectedTime,
      alwaysUse24HourFormat: _TimePickerModel.use24HourFormatOf(context),
    );

    TimeOfDay hoursFromSelected(int hoursToAdd) {
      switch (_TimePickerModel.hourDialTypeOf(context)) {
        case _HourDialType.twentyFourHour:
        case _HourDialType.twentyFourHourDoubleRing:
          final int selectedHour = selectedTime.hour;
          return selectedTime.replacing(
            hour: (selectedHour + hoursToAdd) % TimeOfDay.hoursPerDay,
          );
        case _HourDialType.twelveHour:
          // Cycle 1 through 12 without changing day period.
          final int periodOffset = selectedTime.periodOffset;
          final int hours = selectedTime.hourOfPeriod;
          return selectedTime.replacing(
            hour:
                periodOffset + (hours + hoursToAdd) % TimeOfDay.hoursPerPeriod,
          );
      }
    }

    final TimeOfDay nextHour = hoursFromSelected(1);
    final String formattedNextHour = localizations.formatHour(
      nextHour,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
    );
    final TimeOfDay previousHour = hoursFromSelected(-1);
    final String formattedPreviousHour = localizations.formatHour(
      previousHour,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
    );

    return Semantics(
      value: '${localizations.timePickerHourModeAnnouncement} $formattedHour',
      excludeSemantics: true,
      increasedValue: formattedNextHour,
      onIncrease: () {
        _TimePickerModel.setSelectedTime(context, nextHour);
      },
      decreasedValue: formattedPreviousHour,
      onDecrease: () {
        _TimePickerModel.setSelectedTime(context, previousHour);
      },
      child: _HourMinuteControl(
        isSelected:
            _TimePickerModel.hourMinuteModeOf(context) == _HourMinuteMode.hour,
        text: formattedHour,
        onTap: Feedback.wrapForTap(
            () => _TimePickerModel.setHourMinuteMode(
                context, _HourMinuteMode.hour),
            context)!,
        onDoubleTap:
            _TimePickerModel.of(context, _TimePickerAspect.onHourDoubleTapped)
                .onHourDoubleTapped,
      ),
    );
  }
} */

/// Displays the minute fragment.
///
/// When tapped changes time picker dial mode to [_HourMinuteMode.minute].
/* class _MinuteControl extends StatelessWidget {
  const _MinuteControl();

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final TimeOfDay selectedTime = _TimePickerModel.selectedTimeOf(context);
    final String formattedMinute = localizations.formatMinute(selectedTime);
    final TimeOfDay nextMinute = selectedTime.replacing(
      minute: (selectedTime.minute + 1) % TimeOfDay.minutesPerHour,
    );
    final String formattedNextMinute = localizations.formatMinute(nextMinute);
    final TimeOfDay previousMinute = selectedTime.replacing(
      minute: (selectedTime.minute - 1) % TimeOfDay.minutesPerHour,
    );
    final String formattedPreviousMinute =
        localizations.formatMinute(previousMinute);

    return Semantics(
      excludeSemantics: true,
      value:
          '${localizations.timePickerMinuteModeAnnouncement} $formattedMinute',
      increasedValue: formattedNextMinute,
      onIncrease: () {
        _TimePickerModel.setSelectedTime(context, nextMinute);
      },
      decreasedValue: formattedPreviousMinute,
      onDecrease: () {
        _TimePickerModel.setSelectedTime(context, previousMinute);
      },
      child: _HourMinuteControl(
        isSelected: _TimePickerModel.hourMinuteModeOf(context) ==
            _HourMinuteMode.minute,
        text: formattedMinute,
        onTap: Feedback.wrapForTap(
            () => _TimePickerModel.setHourMinuteMode(
                context, _HourMinuteMode.minute),
            context)!,
        onDoubleTap:
            _TimePickerModel.of(context, _TimePickerAspect.onMinuteDoubleTapped)
                .onMinuteDoubleTapped,
      ),
    );
  }
} */


