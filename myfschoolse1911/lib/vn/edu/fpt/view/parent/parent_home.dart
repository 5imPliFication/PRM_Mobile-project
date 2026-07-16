import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/login.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/parent/parent_child_tab.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/parent/parent_grades_tab.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/parent/parent_attendance_tab.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/parent/parent_schedule_tab.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/parent/parent_notifications_tab.dart';

class ParentHome extends StatefulWidget {
  final String? fullName;
  const ParentHome({super.key, this.fullName});

  @override
  State<ParentHome> createState() => _ParentHomeState();
}

class _ParentHomeState extends State<ParentHome> {
  int _currentIndex = 0;
  Map<String, dynamic>? _profile;
  List<dynamic> _children = const [];
  String? _selectedChildId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await apiService.getParentProfile();
      final children = (p['children'] as List?) ?? const [];
      if (!mounted) return;
      setState(() {
        _profile = p;
        _children = children;
        if (children.isNotEmpty) {
          final ids = children
              .map((c) => (c as Map<String, dynamic>)['id'] as String?)
              .whereType<String>()
              .toList();
          if (!ids.contains(_selectedChildId)) {
            _selectedChildId = ids.first;
          }
        }
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _logout() async {
    await apiService.logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (r) => false,
      );
    }
  }

  String get _parentName =>
      _profile?['fullName'] as String? ?? widget.fullName ?? 'Phụ huynh';

  String get _selectedChildName {
    if (_selectedChildId == null) return '';
    for (final c in _children) {
      final m = c as Map<String, dynamic>;
      if (m['id'] == _selectedChildId) return m['fullName'] as String? ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(body: const Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Phụ huynh'), backgroundColor: TColors.primary),
        body: Center(child: Padding(
          padding: const EdgeInsets.all(TSizes.lg),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off, size: 56, color: TColors.iconColor),
            const SizedBox(height: TSizes.md),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: TColors.textSubtitle)),
            const SizedBox(height: TSizes.md),
            ElevatedButton(onPressed: _loadProfile, child: const Text('Thử lại')),
            const SizedBox(height: TSizes.md),
            OutlinedButton(onPressed: _logout, child: const Text('Đăng xuất')),
          ]),
        )),
      );
    }
    if (_selectedChildId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Phụ huynh'), backgroundColor: TColors.primary),
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.child_care, size: 56, color: TColors.iconColor),
          const SizedBox(height: TSizes.md),
          const Text('Chưa có học sinh được liên kết',
              style: TextStyle(color: TColors.textSubtitle, fontWeight: FontWeight.bold)),
          const SizedBox(height: TSizes.md),
          OutlinedButton(onPressed: _logout, child: const Text('Đăng xuất')),
        ])),
      );
    }

    final childId = _selectedChildId!;
    final tabs = [
      ParentChildTab(
        studentId: childId,
        parentName: _parentName,
        onLogout: _logout,
        onLinkChanged: _loadProfile,
      ),
      ParentGradesTab(studentId: childId),
      ParentAttendanceTab(studentId: childId),
      ParentScheduleTab(studentId: childId),
      ParentNotificationsTab(studentId: childId),
    ];
    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: TColors.primary,
        unselectedItemColor: TColors.textSubtitle,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.child_care_rounded), label: 'HS'),
          BottomNavigationBarItem(icon: Icon(Icons.grade_rounded), label: 'Điểm'),
          BottomNavigationBarItem(icon: Icon(Icons.fact_check_rounded), label: 'DD'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'TKB'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'TB'),
        ],
      ),
    );
  }
}