import 'package:flutter/material.dart';

class MonthlyCalendar extends StatefulWidget {
  final Color cardColor;
  final Color textColor;
  final Color accentColor;
  final Function(DateTime) onDateSelected;
  final List<DateTime> contestDates;

  const MonthlyCalendar({
    super.key,
    required this.cardColor,
    required this.textColor,
    required this.accentColor,
    required this.onDateSelected,
    this.contestDates = const [],
  });

  @override
  State<MonthlyCalendar> createState() => _MonthlyCalendarState();
}

class _MonthlyCalendarState extends State<MonthlyCalendar> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;

  final List<String> _monthNames = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC'
  ];

  final List<String> _weekdays = [
    'S',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
    _selectedDate = now;
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    });
  }

  List<DateTime> _generateCalendarDays() {
    final firstDay =
    DateTime(_displayedMonth.year, _displayedMonth.month, 1);

    final startOffset = firstDay.weekday % 7;

    final firstGridDay =
    firstDay.subtract(Duration(days: startOffset));

    return List.generate(
      42,
          (index) => firstGridDay.add(Duration(days: index)),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  bool _hasContest(DateTime date) {
    return widget.contestDates.any(
          (contestDate) => _isSameDay(contestDate, date),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _generateCalendarDays();

    final isDark =
        widget.cardColor.computeLuminance() < 0.5;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 420,
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //------------------------------------
              // HEADER
              //------------------------------------
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Contest Calendar",
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _previousMonth,
                        icon: Icon(
                          Icons.chevron_left,
                          color: widget.textColor,
                        ),
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minHeight: 24,
                          minWidth: 24,
                        ),
                      ),
                      Text(
                        "${_monthNames[_displayedMonth.month - 1]} ${_displayedMonth.year}",
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: _nextMonth,
                        icon: Icon(
                          Icons.chevron_right,
                          color: widget.textColor,
                        ),
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minHeight: 24,
                          minWidth: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 6),

              //------------------------------------
              // WEEKDAYS
              //------------------------------------
              Row(
                children: _weekdays.map((day) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: widget.textColor.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 4),

              //------------------------------------
              // DAYS GRID
              //------------------------------------
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 42,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.9,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemBuilder: (context, index) {
                  final date = days[index];

                  final isCurrentMonth =
                      date.month == _displayedMonth.month;

                  final isSelected =
                  _isSameDay(date, _selectedDate);

                  final hasEvent = _hasContest(date);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });

                      widget.onDateSelected(date);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? widget.accentColor
                            .withValues(alpha: 0.20)
                            : Colors.transparent,
                      ),
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              color: isSelected
                                  ? widget.accentColor
                                  : isCurrentMonth
                                  ? widget.textColor
                                  : widget.textColor
                                  .withValues(alpha: 0.3),
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                          if (hasEvent)
                            Container(
                              margin:
                              const EdgeInsets.only(top: 1),
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: widget.accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}