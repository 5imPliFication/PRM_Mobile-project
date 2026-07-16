import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDayIndex = 0;
  List<dynamic> _all = const [];
  bool _loading = true;
  String? _error;

  static const List<String> _weekdays = [
    'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7',
  ];
  // backend day_of_week (Mon=2..Sat=7) -> index 0..5
  static const List<int> _dowByIndex = [2, 3, 4, 5, 6, 7];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await apiService.getSchedules();
      if (mounted) setState(() => _all = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<_ScheduleClass> get _currentClasses {
    final dow = _dowByIndex[_selectedDayIndex];
    final list = _all.where((s) => (s['dayOfWeek'] as int?) == dow).toList();
    final palette = const [
      Color(0xFF5C6BC0), Color(0xFFEF5350), Color(0xFF26A69A),
      Color(0xFFAB47BC), Color(0xFFFF9800), Color(0xFF66BB6A),
      Color(0xFFEC407A), Color(0xFF26C6DA), Color(0xFF8D6E63),
    ];
    var i = 0;
    return list.map((s) {
      final color = palette[i++ % palette.length];
      return _ScheduleClass(
        s['subject'] as String? ?? '',
        s['time'] as String? ?? '',
        s['room'] as String? ?? '',
        s['teacher'] as String? ?? '',
        color,
        s['status'] as String? ?? '',
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thời khóa biểu',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: TColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [TColors.bgGradientTop, TColors.bgGradientBottom],
            ),
          ),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildError()
                  : Column(
                      children: [
                        _buildDaySelector(),
                        const SizedBox(height: TSizes.md),
                        Expanded(
                          child: _currentClasses.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: TSizes.lg, vertical: TSizes.sm),
                                  itemCount: _currentClasses.length,
                                  itemBuilder: (context, index) =>
                                      _buildClassCard(_currentClasses[index]),
                                ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Column(
            children: [
              const Icon(Icons.cloud_off, size: 56, color: TColors.iconColor),
              const SizedBox(height: TSizes.md),
              Text(_error ?? '', textAlign: TextAlign.center,
                  style: const TextStyle(color: TColors.textSubtitle)),
              const SizedBox(height: TSizes.md),
              ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 70,
      margin: const EdgeInsets.only(top: TSizes.md),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
        itemCount: _weekdays.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedDayIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 75,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [TColors.primary, Color(0xFFFF8A50)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? TColors.primary.withOpacity(0.3)
                        : Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_weekdays[index],
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF333333))),
                  const SizedBox(height: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.white : Colors.transparent,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClassCard(_ScheduleClass item) {
    Color statusColor;
    switch (item.status) {
      case 'Đang học':
        statusColor = Colors.orange;
        break;
      case 'Đã học':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.green;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.subject,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(item.status.isEmpty ? 'Sắp học' : item.status,
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(item.teacher,
                        style: const TextStyle(fontSize: 12, color: TColors.textSubtitle)),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: item.color),
                        const SizedBox(width: 6),
                        Text(item.time,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600, color: item.color)),
                        const Spacer(),
                        const Icon(Icons.room_outlined, size: 14, color: TColors.textSubtitle),
                        const SizedBox(width: 6),
                        Text(item.room,
                            style: const TextStyle(fontSize: 12, color: TColors.textSubtitle)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(
          child: Column(
            children: [
              Icon(Icons.calendar_today_outlined, size: 64, color: TColors.iconColor.withOpacity(0.5)),
              const SizedBox(height: TSizes.md),
              const Text('Không có lịch học',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TColors.textSubtitle)),
              const SizedBox(height: 4),
              const Text('Ngày này bạn được nghỉ học hoặc không có lịch.',
                  style: TextStyle(fontSize: 12, color: TColors.textSubtitle)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScheduleClass {
  final String subject;
  final String time;
  final String room;
  final String teacher;
  final Color color;
  final String status;
  _ScheduleClass(this.subject, this.time, this.room, this.teacher, this.color, this.status);
}