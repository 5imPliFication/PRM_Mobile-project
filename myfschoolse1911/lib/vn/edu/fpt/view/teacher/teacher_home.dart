import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/login.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/teacher/teacher_classes_tab.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/teacher/teacher_assignments_tab.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/teacher/teacher_profile_tab.dart';

class TeacherHome extends StatefulWidget {
  final String? fullName;
  const TeacherHome({super.key, this.fullName});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  int _currentIndex = 0;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final p = await apiService.getTeacherProfile();
      if (mounted) setState(() => _profile = p);
    } catch (_) {
      // the tabs will retry; keep silent here
    }
  }

  String get _name => _profile?['fullName'] as String? ?? widget.fullName ?? 'Giáo viên';

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

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const TeacherClassesTab(),
      const TeacherAssignmentsTab(),
      TeacherProfileTab(profile: _profile, fullName: _name, onLogout: _logout),
    ];
    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: TColors.primary,
        unselectedItemColor: TColors.textSubtitle,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.class_rounded), label: 'Lớp học'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'Bài tập'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Cá nhân'),
        ],
      ),
    );
  }
}