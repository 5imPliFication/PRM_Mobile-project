import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/login.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/home.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/teacher/teacher_home.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/parent/parent_home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My FPT School',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF36F21)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

/// Restores a persisted session (if any) and routes the user by role.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _checking = true;
  String? _role;
  String? _fullName;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final loggedIn = await apiService.isLoggedIn();
    if (!loggedIn) {
      if (mounted) setState(() => _checking = false);
      return;
    }
    final role = await apiService.getRole();
    final name = await apiService.getFullName();
    if (mounted) {
      setState(() {
        _role = role;
        _fullName = name;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    switch (_role) {
      case 'STUDENT':
        return HomeScreen(fullName: _fullName);
      case 'TEACHER':
        return TeacherHome(fullName: _fullName);
      case 'PARENT':
        return ParentHome(fullName: _fullName);
      default:
        return const LoginScreen();
    }
  }
}