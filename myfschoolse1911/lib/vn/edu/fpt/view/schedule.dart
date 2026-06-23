import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDayIndex = 0;

  final List<String> _weekdays = [
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
  ];

  // Dummy schedules data
  final Map<int, List<_ScheduleClass>> _schedules = {
    0: [
      _ScheduleClass('Toán học', '07:30 - 08:15', 'Phòng A201', 'Thầy Nguyễn Văn B', const Color(0xFF5C6BC0), 'Đã học'),
      _ScheduleClass('Vật lý', '08:25 - 09:10', 'Phòng B102', 'Cô Trần Thị C', const Color(0xFFEF5350), 'Đã học'),
      _ScheduleClass('Tiếng Anh', '09:20 - 10:05', 'Phòng C305', 'Cô Lê Thị D', const Color(0xFF26A69A), 'Đã học'),
      _ScheduleClass('Chào cờ', '10:15 - 11:00', 'Sân trường', 'Thầy Hiệu Trưởng', const Color(0xFFAB47BC), 'Đã học'),
    ],
    1: [
      _ScheduleClass('Hóa học', '07:30 - 08:15', 'Phòng Hóa', 'Cô Nguyễn Thị E', const Color(0xFFFF9800), 'Sắp học'),
      _ScheduleClass('Ngữ văn', '08:25 - 09:10', 'Phòng A201', 'Cô Phạm Thị F', const Color(0xFFEC407A), 'Sắp học'),
      _ScheduleClass('Sinh học', '09:20 - 10:05', 'Phòng Sinh', 'Thầy Lê Văn G', const Color(0xFF66BB6A), 'Sắp học'),
      _ScheduleClass('Lịch sử', '10:15 - 11:00', 'Phòng A201', 'Cô Hoàng Thị H', const Color(0xFF8D6E63), 'Sắp học'),
    ],
    2: [
      _ScheduleClass('Tin học', '07:30 - 09:10', 'Phòng Máy 2', 'Thầy Đỗ Văn I', const Color(0xFF26C6DA), 'Sắp học'),
      _ScheduleClass('Địa lý', '09:20 - 10:05', 'Phòng A201', 'Cô Vũ Thị J', const Color(0xFF9CCC65), 'Sắp học'),
      _ScheduleClass('GDCD', '10:15 - 11:00', 'Phòng A201', 'Thầy Trần Văn K', const Color(0xFF78909C), 'Sắp học'),
    ],
    3: [
      _ScheduleClass('Toán học', '07:30 - 08:15', 'Phòng A201', 'Thầy Nguyễn Văn B', const Color(0xFF5C6BC0), 'Sắp học'),
      _ScheduleClass('Vật lý', '08:25 - 09:10', 'Phòng B102', 'Cô Trần Thị C', const Color(0xFFEF5350), 'Sắp học'),
      _ScheduleClass('Tiếng Anh', '09:20 - 10:05', 'Phòng C305', 'Cô Lê Thị D', const Color(0xFF26A69A), 'Sắp học'),
      _ScheduleClass('Thể dục', '10:15 - 11:00', 'Nhà đa năng', 'Thầy Phan Văn L', const Color(0xFF26A69A), 'Sắp học'),
    ],
    4: [
      _ScheduleClass('Ngữ văn', '07:30 - 09:10', 'Phòng A201', 'Cô Phạm Thị F', const Color(0xFFEC407A), 'Sắp học'),
      _ScheduleClass('Hóa học', '09:20 - 10:05', 'Phòng Hóa', 'Cô Nguyễn Thị E', const Color(0xFFFF9800), 'Sắp học'),
      _ScheduleClass('Sinh học', '10:15 - 11:00', 'Phòng Sinh', 'Thầy Lê Văn G', const Color(0xFF66BB6A), 'Sắp học'),
    ],
    5: [
      _ScheduleClass('Công nghệ', '07:30 - 08:15', 'Phòng A201', 'Thầy Ngô Văn M', const Color(0xFFD4E157), 'Sắp học'),
      _ScheduleClass('Toán học', '08:25 - 09:10', 'Phòng A201', 'Thầy Nguyễn Văn B', const Color(0xFF5C6BC0), 'Sắp học'),
      _ScheduleClass('Sinh hoạt', '09:20 - 10:05', 'Phòng A201', 'Cô Trần Thị C', const Color(0xFFAB47BC), 'Sắp học'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final currentClasses = _schedules[_selectedDayIndex] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thời khóa biểu',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: TColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              TColors.bgGradientTop,
              TColors.bgGradientBottom,
            ],
          ),
        ),
        child: Column(
          children: [
            // Calendar Day Selector
            _buildDaySelector(),
            const SizedBox(height: TSizes.md),

            // Schedule List
            Expanded(
              child: currentClasses.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: TSizes.lg, vertical: TSizes.sm),
                      itemCount: currentClasses.length,
                      itemBuilder: (context, index) {
                        return _buildClassCard(currentClasses[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
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
            onTap: () {
              setState(() {
                _selectedDayIndex = index;
              });
            },
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
                  Text(
                    _weekdays[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF333333),
                    ),
                  ),
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
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Subject color bar indicator
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
                        Text(
                          item.subject,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.teacher,
                      style: const TextStyle(
                        fontSize: 12,
                        color: TColors.textSubtitle,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: item.color),
                        const SizedBox(width: 6),
                        Text(
                          item.time,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: item.color,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.room_outlined, size: 14, color: TColors.textSubtitle),
                        const SizedBox(width: 6),
                        Text(
                          item.room,
                          style: const TextStyle(
                            fontSize: 12,
                            color: TColors.textSubtitle,
                          ),
                        ),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: TColors.iconColor.withOpacity(0.5)),
          const SizedBox(height: TSizes.md),
          const Text(
            'Không có lịch học',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TColors.textSubtitle,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Hôm nay bạn được nghỉ học hoặc không có lịch.',
            style: TextStyle(
              fontSize: 12,
              color: TColors.textSubtitle,
            ),
          ),
        ],
      ),
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
