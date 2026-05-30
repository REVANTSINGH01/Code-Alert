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
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
  ];

  final List<String> _weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    });
  }

  List<DateTime> _generateCalendarDays() {
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    int startOffset = firstDayOfMonth.weekday % 7;
    final firstDayOfGrid = firstDayOfMonth.subtract(Duration(days: startOffset));
    return List.generate(42, (index) => firstDayOfGrid.add(Duration(days: index)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _hasContest(DateTime date) {
    return widget.contestDates.any((contestDate) => _isSameDay(contestDate, date));
  }

  @override
  Widget build(BuildContext context) {
    final days = _generateCalendarDays();
    final isDark = widget.cardColor.computeLuminance() < 0.5;

    return Container(
      // 📉 Reduced padding from 20 to 12
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.cardColor,
        // 📉 Scaled down border radius
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔷 HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Contest Calendar",
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: 14, // 📉 Reduced from 18
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: widget.textColor.withValues(alpha: 0.7)),
                    iconSize: 20, // 📉 Smaller icons
                    onPressed: _previousMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24), // Tighter hit box
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${_monthNames[_displayedMonth.month - 1]} ${_displayedMonth.year}",
                    style: TextStyle(
                      color: widget.textColor.withValues(alpha: 0.9),
                      fontSize: 10, // 📉 Reduced from 13
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: widget.textColor.withValues(alpha: 0.7)),
                    iconSize: 20, // 📉 Smaller icons
                    onPressed: _nextMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12), // 📉 Reduced from 20

          // 🔷 WEEKDAYS ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distributes evenly without hardcoded widths
            children: _weekdays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      color: widget.textColor.withValues(alpha: 0.5),
                      fontSize: 10, // 📉 Reduced from 13
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8), // 📉 Reduced from 12

          // 🔷 CALENDAR GRID
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              mainAxisSpacing: 2, // 📉 Tighter vertical spacing
              crossAxisSpacing: 2, // 📉 Tighter horizontal spacing
            ),
            itemBuilder: (context, index) {
              final date = days[index];
              final isCurrentMonth = date.month == _displayedMonth.month;
              final isSelected = _isSameDay(date, _selectedDate);
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
                    color: isSelected
                        ? widget.accentColor.withValues(alpha: 0.2)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? widget.accentColor
                              : isCurrentMonth
                              ? widget.textColor
                              : widget.textColor.withValues(alpha: 0.3),
                          fontSize: 11, // 📉 Reduced from 14
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      if (hasEvent) ...[
                        const SizedBox(height: 1),
                        Container(
                          width: 3, // 📉 Smaller neon dot
                          height: 3,
                          decoration: BoxDecoration(
                            color: widget.accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 4),
                      ]
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}