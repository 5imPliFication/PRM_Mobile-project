import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/teacher/class_students_screen.dart';

class TeacherClassesTab extends StatefulWidget {
  const TeacherClassesTab({super.key});

  @override
  State<TeacherClassesTab> createState() => _TeacherClassesTabState();
}

class _TeacherClassesTabState extends State<TeacherClassesTab> {
  List<dynamic> _classes = const [];
  String _homeroomClass = '';
  bool _loading = true;
  String? _error;

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
      final results = await Future.wait([
        apiService.getTeacherClasses(),
        apiService.getTeacherProfile(),
      ]);
      if (mounted) {
        setState(() {
          _classes = results[0] as List;
          final profile = results[1] as Map<String, dynamic>;
          _homeroomClass = profile['homeroomClass'] as String? ?? '';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lớp học', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  : _classes.isEmpty
                      ? _buildEmpty('Bạn chưa được phân lớp nào')
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: _classes.length,
                          itemBuilder: (context, index) {
                            final c = _classes[index] as String;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: TColors.primary.withOpacity(0.1),
                                  child: Icon(Icons.class_rounded, color: TColors.primary),
                                ),
                                title: Row(
                                  children: [
                                    Text('Lớp $c',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    if (c == _homeroomClass) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.orange),
                                        ),
                                        child: const Text(
                                          'Chủ nhiệm',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: const Text('Xem học sinh và điểm danh'),
                                trailing: const Icon(Icons.chevron_right, color: TColors.iconColor),
                                onTap: () async {
                                  await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ClassStudentsScreen(className: c),
                                    ),
                                  );
                                  _load();
                                },
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(child: Column(children: [
          const Icon(Icons.cloud_off, size: 56, color: TColors.iconColor),
          const SizedBox(height: 12),
          Text(_error ?? '', textAlign: TextAlign.center, style: const TextStyle(color: TColors.textSubtitle)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
        ])),
      ],
    );
  }

  Widget _buildEmpty(String msg) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.class_outlined, size: 56, color: TColors.iconColor.withOpacity(0.5)),
      const SizedBox(height: 12),
      Text(msg, style: const TextStyle(color: TColors.textSubtitle, fontWeight: FontWeight.bold)),
    ]));
  }
}