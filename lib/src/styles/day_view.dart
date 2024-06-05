import 'package:flutter/material.dart';
import 'package:flutter_week_view/src/styles/zoomable_header_widget.dart';
import 'package:flutter_week_view/src/utils/hour_minute.dart';
import 'package:flutter_week_view/src/utils/utils.dart';
import 'package:flutter_week_view/src/widgets/day_view.dart';
import 'package:flutter_week_view/src/widgets/hours_column.dart';
import 'package:flutter_week_view/src/widgets/zoomable_header_widget.dart';

class DayViewStyle extends ZoomableHeaderWidgetStyle {
  final double hourRowHeight;
  final Color? backgroundColor;
  final Color? backgroundRulesColor;
  final Color? currentTimeRuleColor;
  final double currentTimeRuleHeight;
  final Color? currentTimeCircleColor;
  final double currentTimeCircleRadius;
  final CurrentTimeCirclePosition currentTimeCirclePosition;

  // Nuevos parámetros
  final List<TimeBlock> timeBlocks;

  const DayViewStyle({
    double? headerSize,
    double? hourRowHeight,
    Color? backgroundColor,
    this.backgroundRulesColor = const Color(0x1A000000),
    this.currentTimeRuleColor = Colors.pink,
    double? currentTimeRuleHeight,
    this.currentTimeCircleColor,
    double? currentTimeCircleRadius,
    CurrentTimeCirclePosition? currentTimeCirclePosition,
    this.timeBlocks = const [],
  })  : hourRowHeight = (hourRowHeight ?? 60) < 0 ? 0 : (hourRowHeight ?? 60),
        backgroundColor = backgroundColor ?? const Color(0xFFF2F2F2),
        currentTimeRuleHeight =
            (currentTimeRuleHeight ?? 1) < 0 ? 0 : (currentTimeRuleHeight ?? 1),
        currentTimeCircleRadius = (currentTimeCircleRadius ?? 7.5) < 0
            ? 0
            : (currentTimeCircleRadius ?? 7.5),
        currentTimeCirclePosition =
            currentTimeCirclePosition ?? CurrentTimeCirclePosition.right,
        super(headerSize: headerSize);

  DayViewStyle.fromDate({
    required DateTime date,
    double? headerSize,
    double? hourRowHeight,
    Color backgroundRulesColor = const Color(0x1A000000),
    Color currentTimeRuleColor = Colors.pink,
    double? currentTimeRuleHeight,
    Color? currentTimeCircleColor,
    double? currentTimeCircleRadius,
    CurrentTimeCirclePosition? currentTimeCirclePosition,
    List<TimeBlock> timeBlocks = const [],
  }) : this(
          headerSize: headerSize,
          hourRowHeight: hourRowHeight,
          backgroundColor: Utils.sameDay(date) ? Colors.white : null,
          backgroundRulesColor: backgroundRulesColor,
          currentTimeRuleColor: currentTimeRuleColor,
          currentTimeRuleHeight: currentTimeRuleHeight,
          currentTimeCircleColor: currentTimeCircleColor,
          currentTimeCircleRadius: currentTimeCircleRadius,
          currentTimeCirclePosition: currentTimeCirclePosition,
          timeBlocks: timeBlocks,
        );

  DayViewStyle copyWith({
    double? headerSize,
    double? hourRowHeight,
    Color? backgroundColor,
    Color? backgroundRulesColor,
    Color? currentTimeRuleColor,
    double? currentTimeRuleHeight,
    Color? currentTimeCircleColor,
    double? currentTimeCircleRadius,
    CurrentTimeCirclePosition? currentTimeCirclePosition,
    List<TimeBlock>? timeBlocks,
  }) =>
      DayViewStyle(
        headerSize: headerSize ?? this.headerSize,
        hourRowHeight: hourRowHeight ?? this.hourRowHeight,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        backgroundRulesColor: backgroundRulesColor ?? this.backgroundRulesColor,
        currentTimeRuleColor: currentTimeRuleColor ?? this.currentTimeRuleColor,
        currentTimeRuleHeight:
            currentTimeRuleHeight ?? this.currentTimeRuleHeight,
        currentTimeCircleColor:
            currentTimeCircleColor ?? this.currentTimeCircleColor,
        currentTimeCircleRadius:
            currentTimeCircleRadius ?? this.currentTimeCircleRadius,
        currentTimeCirclePosition:
            currentTimeCirclePosition ?? this.currentTimeCirclePosition,
        timeBlocks: timeBlocks ?? this.timeBlocks,
      );

  @override
  CustomPainter createBackgroundPainter({
    required DayView dayView,
    required TopOffsetCalculator topOffsetCalculator,
  }) =>
      _EventsColumnBackgroundPainter(
        minimumTime: dayView.minimumTime,
        maximumTime: dayView.maximumTime,
        topOffsetCalculator: topOffsetCalculator,
        dayViewStyle: this,
        interval: dayView.hoursColumnStyle.interval,
      );
}

class TimeBlock {
  final HourMinute startTime;
  final HourMinute endTime;
  final Color color;

  TimeBlock({
    required this.startTime,
    required this.endTime,
    required this.color,
  });
}

/// The current time circle position enum.
enum CurrentTimeCirclePosition {
  /// Whether it should be placed at the start of the current time rule.
  left,

  /// Whether it should be placed at the end of the current time rule.
  right,
}

class _EventsColumnBackgroundPainter extends CustomPainter {
  final HourMinute minimumTime;
  final HourMinute maximumTime;
  final TopOffsetCalculator topOffsetCalculator;
  final DayViewStyle dayViewStyle;
  final Duration interval;

  const _EventsColumnBackgroundPainter({
    required this.minimumTime,
    required this.maximumTime,
    required this.topOffsetCalculator,
    required this.dayViewStyle,
    required this.interval,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dayViewStyle.backgroundColor != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = dayViewStyle.backgroundColor!,
      );
    }

    if (dayViewStyle.timeBlocks.isNotEmpty) {
      for (TimeBlock block in dayViewStyle.timeBlocks) {
        double startOffset = topOffsetCalculator(block.startTime);
        double endOffset = topOffsetCalculator(block.endTime);

        // Pintar fondo gris con mayor opacidad
        canvas.drawRect(
          Rect.fromLTRB(0, startOffset, size.width, endOffset),
          Paint()..color = Colors.grey.withOpacity(0.1),
        );

        // Dibujar divisiones diagonales en una capa separada
        Paint diagonalPaint = Paint()
          ..color = Colors.grey
          ..strokeWidth = 1;

        double xStep = 20.0;
        for (double x = -size.height; x < size.width; x += xStep) {
          canvas.drawLine(
            Offset(x, startOffset),
            Offset(x + size.height * 0.15, endOffset),
            diagonalPaint,
          );
        }
      }
    }

    if (dayViewStyle.backgroundRulesColor != null) {
      final List<HourMinute> sideTimes =
          HoursColumn.getSideTimes(minimumTime, maximumTime, interval);
      for (HourMinute time in sideTimes) {
        double topOffset = topOffsetCalculator(time);
        canvas.drawLine(
          Offset(0, topOffset),
          Offset(size.width, topOffset),
          Paint()..color = dayViewStyle.backgroundRulesColor!,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_EventsColumnBackgroundPainter oldDelegate) {
    return dayViewStyle.backgroundColor !=
            oldDelegate.dayViewStyle.backgroundColor ||
        dayViewStyle.backgroundRulesColor !=
            oldDelegate.dayViewStyle.backgroundRulesColor ||
        topOffsetCalculator != oldDelegate.topOffsetCalculator ||
        dayViewStyle.timeBlocks != oldDelegate.dayViewStyle.timeBlocks;
  }
}
