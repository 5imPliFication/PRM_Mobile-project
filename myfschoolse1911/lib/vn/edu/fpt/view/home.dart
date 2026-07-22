import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/profile.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/schedule.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/grades.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/notifications.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/assignments.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/applications_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? fullName;

  const HomeScreen({super.key, this.fullName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _profile;
  List<dynamic> _todaySchedules = const [];
  double? _gpa;
  int _todoCount = 0;
  int _submittedCount = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // today's day-of-week: backend uses Monday=2 .. Saturday=7 (Flutter weekday + 1)
      final todayDow = DateTime.now().weekday + 1;
      final results = await Future.wait([
        apiService.getProfile(),
        apiService.getSchedules(dayOfWeek: todayDow),
        apiService.getGrades(),
        apiService.getAssignments(),
      ]);
      final profile = results[0] as Map<String, dynamic>;
      final today = results[1] as List;
      final grades = results[2] as List;
      final assignments = results[3] as List;

      double? gpa;
      if (grades.isNotEmpty) {
        final avgValues = grades
            .map((g) => g['average'])
            .whereType<num>()
            .toList();
        if (avgValues.isNotEmpty) {
          gpa = avgValues.fold<num>(0, (a, b) => a + b) / avgValues.length;
        }
      }

      int todo = 0, submitted = 0;
      for (final a in assignments) {
        final s = (a['status'] as String?)?.toUpperCase();
        if (s == 'SUBMITTED') {
          submitted++;
        } else if (s == 'TODO') {
          todo++;
        }
      }

      if (mounted) {
        setState(() {
          _profile = profile;
          _todaySchedules = today;
          _gpa = gpa;
          _todoCount = todo;
          _submittedCount = submitted;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildLearningHubTab();
      case 2:
        return const NotificationsScreen(asTab: true);
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeTab();
    }
  }

  void _handleServiceTap(String label) {
    if (label == 'Thời khóa biểu') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleScreen()));
    } else if (label == 'Bài tập') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignmentsScreen()));
    } else if (label == 'Bảng điểm') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const GradesScreen()));
    } else if (label == 'Thông báo') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
    } else if (label == 'Đơn từ') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ApplicationsScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tính năng "$label" đang được phát triển'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: _buildBody(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ----------------- TAB 0: HOME TAB -----------------
  Widget _buildHomeTab() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [TColors.bgGradientTop, TColors.bgGradientBottom],
        ),
      ),
      child: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError(_error!)
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: TSizes.lg),
                        _buildQuickStats(),
                        const SizedBox(height: TSizes.lg),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
                          child: Text(
                            'Dịch vụ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: TColors.textTitle,
                            ),
                          ),
                        ),
                        const SizedBox(height: TSizes.md),
                        _buildServiceGrid(),
                        const SizedBox(height: TSizes.lg),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
                          child: Text(
                            'Lịch học hôm nay',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: TColors.textTitle,
                            ),
                          ),
                        ),
                        const SizedBox(height: TSizes.md),
                        _buildScheduleCards(),
                        const SizedBox(height: TSizes.xl),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: TColors.iconColor),
            const SizedBox(height: TSizes.md),
            Text(msg, textAlign: TextAlign.center,
                style: const TextStyle(color: TColors.textSubtitle)),
            const SizedBox(height: TSizes.md),
            ElevatedButton(onPressed: _loadAll, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final name = _profile?['fullName'] as String? ?? widget.fullName ?? 'Học sinh';
    final className = _profile?['className'] as String? ?? '';
    final academicYear = _profile?['academicYear'] as String? ?? '';
    return Container(
      padding: const EdgeInsets.fromLTRB(TSizes.lg, TSizes.md, TSizes.lg, TSizes.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF36F21), Color(0xFFFF8A50)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Xin chào! 👋',
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                  const SizedBox(height: 4),
                  Text(name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(
                    className.isNotEmpty || academicYear.isNotEmpty
                        ? 'Lớp $className • Niên khóa $academicYear'
                        : '...',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => setState(() => _currentIndex = 2),
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: TSizes.sm),
                  GestureDetector(
                    onTap: () => setState(() => _currentIndex = 3),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFFFCC80),
                        child: Text(
                          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'A',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF36F21)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: TSizes.md),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final gpaStr = _gpa != null ? _gpa!.toStringAsFixed(1) : '--';
    final sessionsStr = '${_todaySchedules.length} hôm nay';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.lg),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const GradesScreen())),
              child: _buildStatCard(
                icon: Icons.emoji_events_rounded,
                iconColor: const Color(0xFFFFB300),
                bgColor: const Color(0xFFFFF8E1),
                label: 'Điểm TB',
                value: gpaStr,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const ScheduleScreen())),
              child: _buildStatCard(
                icon: Icons.calendar_today_rounded,
                iconColor: const Color(0xFF42A5F5),
                bgColor: const Color(0xFFE3F2FD),
                label: 'Buổi học',
                value: sessionsStr,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.star_rounded,
              iconColor: const Color(0xFF66BB6A),
              bgColor: const Color(0xFFE8F5E9),
              label: 'Hạnh kiểm',
              value: 'Tốt',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: TColors.textSubtitle)),
        ],
      ),
    );
  }

  Widget _buildServiceGrid() {
    final services = [
      _ServiceItem(Icons.menu_book_rounded, 'Thời khóa biểu', const Color(0xFF5C6BC0)),
      _ServiceItem(Icons.assignment_rounded, 'Bài tập', const Color(0xFFEF5350)),
      _ServiceItem(Icons.grade_rounded, 'Bảng điểm', const Color(0xFFFF9800)),
      _ServiceItem(Icons.campaign_rounded, 'Thông báo', const Color(0xFF42A5F5)),
      _ServiceItem(Icons.description_rounded, 'Đơn từ', const Color(0xFF66BB6A)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.lg),
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 8,
            childAspectRatio: 0.85,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final item = services[index];
            return GestureDetector(
              onTap: () => _handleServiceTap(item.label),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(item.icon, color: item.color, size: 26),
                  ),
                  const SizedBox(height: 6),
                  Text(item.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static const List<Color> _palette = [
    Color(0xFF5C6BC0), Color(0xFFEF5350), Color(0xFF26A69A),
    Color(0xFFAB47BC), Color(0xFFFF9800), Color(0xFF66BB6A),
    Color(0xFFEC407A), Color(0xFF26C6DA), Color(0xFF8D6E63),
  ];

  Widget _buildScheduleCards() {
    if (_todaySchedules.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: TSizes.lg),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: const Column(
            children: [
              Icon(Icons.calendar_today_outlined, size: 40, color: TColors.iconColor),
              SizedBox(height: 8),
              Text('Hôm nay không có lịch học',
                  style: TextStyle(color: TColors.textSubtitle, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    }

    final items = _todaySchedules.map((s) {
      final i = _todaySchedules.indexOf(s);
      return _ScheduleItem(
        s['subject'] as String? ?? '',
        s['time'] as String? ?? '',
        s['room'] as String? ?? '',
        s['teacher'] as String? ?? '',
        _palette[i % _palette.length],
        s['status'] as String?,
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.lg),
      child: Column(
        children: items.map((item) {
          return GestureDetector(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ScheduleScreen())),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 56,
                    decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.class_rounded, color: item.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.subject,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                        const SizedBox(height: 4),
                        Text(item.teacher,
                            style: const TextStyle(fontSize: 12, color: TColors.textSubtitle)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_rounded, size: 13, color: item.color),
                          const SizedBox(width: 4),
                          Text(item.time,
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600, color: item.color)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.room_outlined, size: 13, color: TColors.textSubtitle),
                          const SizedBox(width: 4),
                          Text(item.room,
                              style: const TextStyle(fontSize: 12, color: TColors.textSubtitle)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ----------------- TAB 1: LEARNING HUB TAB -----------------
  Widget _buildLearningHubTab() {
    final total = _todoCount + _submittedCount;
    final progress = total > 0 ? _submittedCount / total : 0.0;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [TColors.bgGradientTop, TColors.bgGradientBottom],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(TSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Góc Học Tập',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: TColors.textTitle)),
              const SizedBox(height: 4),
              const Text('Quản lý học tập và theo dõi tiến trình của bạn',
                  style: TextStyle(fontSize: 13, color: TColors.textSubtitle)),
              const SizedBox(height: TSizes.lg),
              _buildProgressOverviewCard(progress, total),
              const SizedBox(height: TSizes.lg),
              const Text('Phân mục chính',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TColors.textTitle)),
              const SizedBox(height: TSizes.md),
              _buildHubCard(
                title: 'Thời khóa biểu',
                subtitle: 'Xem lịch học các ngày trong tuần',
                icon: Icons.calendar_month_rounded,
                color: const Color(0xFF5C6BC0),
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const ScheduleScreen())),
              ),
              const SizedBox(height: 12),
              _buildHubCard(
                title: 'Bài tập cần làm',
                subtitle: 'Theo dõi bài tập về nhà và hạn nộp',
                icon: Icons.assignment_rounded,
                color: const Color(0xFFEF5350),
                badgeText: _todoCount > 0 ? '$_todoCount bài' : null,
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const AssignmentsScreen())),
              ),
              const SizedBox(height: 12),
              _buildHubCard(
                title: 'Kết quả học tập',
                subtitle: 'Xem bảng điểm các môn học kỳ',
                icon: Icons.grade_rounded,
                color: const Color(0xFFFF9800),
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const GradesScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressOverviewCard(double progress, int total) {
    final pct = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF26A69A), Color(0xFF4DB6AC)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF26A69A).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tiến độ hoàn thành bài tập',
                    style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text('Hoàn thành $pct%',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: total > 0 ? progress : 0,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.trending_up, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildHubCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: TColors.textSubtitle)),
                ],
              ),
            ),
            if (badgeText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(badgeText,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.arrow_forward_ios, size: 14, color: TColors.iconColor),
          ],
        ),
      ),
    );
  }

  // ----------------- BOTTOM NAV -----------------
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -2)),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: TColors.primary,
        unselectedItemColor: TColors.textSubtitle,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Học tập'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Cá nhân'),
        ],
      ),
    );
  }
}

class _ServiceItem {
  final IconData icon;
  final String label;
  final Color color;
  _ServiceItem(this.icon, this.label, this.color);
}

class _ScheduleItem {
  final String subject;
  final String time;
  final String room;
  final String teacher;
  final Color color;
  final String? status;
  _ScheduleItem(this.subject, this.time, this.room, this.teacher, this.color, this.status);
}