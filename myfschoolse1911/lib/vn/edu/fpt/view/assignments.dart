import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';
import 'package:intl/intl.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _todo = const [];
  List<Map<String, dynamic>> _submitted = const [];
  List<Map<String, dynamic>> _overdue = const [];
  bool _loading = true;
  String? _error;

  static const List<Color> _palette = [
    Color(0xFFEF5350), Color(0xFF26A69A), Color(0xFF5C6BC0),
    Color(0xFF26C6DA), Color(0xFFEC407A), Color(0xFF8D6E63),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await apiService.getAssignments();
      final todo = <Map<String, dynamic>>[];
      final submitted = <Map<String, dynamic>>[];
      final overdue = <Map<String, dynamic>>[];
      for (var i = 0; i < data.length; i++) {
        final a = data[i] as Map<String, dynamic>;
        a['_color'] = _palette[i % _palette.length];
        final s = (a['status'] as String?)?.toUpperCase();
        if (s == 'SUBMITTED') {
          submitted.add(a);
        } else if (s == 'OVERDUE') {
          overdue.add(a);
        } else {
          todo.add(a);
        }
      }
      if (mounted) {
        setState(() {
          _todo = todo;
          _submitted = submitted;
          _overdue = overdue;
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

  String _fmtDue(String? iso) {
    if (iso == null) return '--';
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('HH:mm - dd/MM/yyyy').format(dt.toLocal());
    } catch (_) {
      return iso;
    }
  }

  String _fmtSubmitted(String? iso) {
    if (iso == null) return '--';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return 'Đã nộp lúc ${DateFormat('HH:mm - dd/MM/yyyy').format(dt)}';
    } catch (_) {
      return iso;
    }
  }

  void _submitAssignment(Map<String, dynamic> item) {
    final urlCtrl = TextEditingController(text: 'student_upload.pdf');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nộp bài tập'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['title'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Đường dẫn tệp bài làm',
                style: TextStyle(fontSize: 13, color: TColors.textSubtitle)),
            const SizedBox(height: 8),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(
                hintText: 'Tên/đường dẫn tệp (vd: bai_tap.pdf)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _doSubmit(item, urlCtrl.text.trim());
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary),
            child: const Text('Nộp', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _doSubmit(Map<String, dynamic> item, String fileUrl) async {
    try {
      final id = item['id'] as String?;
      if (id == null) return;
      await apiService.submitAssignment(id, fileUrl.isEmpty ? 'student_upload.pdf' : fileUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nộp bài thành công'), behavior: SnackBarBehavior.floating),
        );
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài tập học tập',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: TColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: 'Chưa nộp (${_todo.length})'),
            Tab(text: 'Đã nộp (${_submitted.length})'),
            Tab(text: 'Quá hạn (${_overdue.length})'),
          ],
        ),
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
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildList(_todo, isTodo: true),
                        _buildList(_submitted, isSubmitted: true),
                        _buildList(_overdue, isOverdue: true),
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

  Widget _buildList(List<Map<String, dynamic>> list,
      {bool isTodo = false, bool isSubmitted = false, bool isOverdue = false}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSubmitted
                  ? Icons.check_circle_outline
                  : isOverdue
                      ? Icons.running_with_errors_outlined
                      : Icons.assignment_turned_in_outlined,
              size: 64,
              color: TColors.iconColor.withOpacity(0.5),
            ),
            const SizedBox(height: TSizes.md),
            Text(
              isSubmitted
                  ? 'Chưa nộp bài tập nào'
                  : isOverdue
                      ? 'Không có bài tập quá hạn'
                      : 'Tuyệt vời! Đã hoàn thành tất cả',
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: TColors.textSubtitle),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(TSizes.lg),
      itemCount: list.length,
      itemBuilder: (context, index) => _buildCard(list[index],
          isTodo: isTodo, isSubmitted: isSubmitted, isOverdue: isOverdue),
    );
  }

  Widget _buildCard(Map<String, dynamic> item,
      {bool isTodo = false, bool isSubmitted = false, bool isOverdue = false}) {
    final color = item['_color'] as Color;
    final title = item['title'] as String? ?? '';
    final subject = item['subject'] as String? ?? '';
    final description = item['description'] as String?;
    final grade = item['grade'];
    final dueStr = isSubmitted
        ? _fmtSubmitted(item['submittedAt'] as String?)
        : _fmtDue(item['dueDate'] as String?);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: ExpansionTile(
        shape: const Border(),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.assignment, color: color, size: 22),
        ),
        title: Text(title,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
        subtitle: Text(subject, style: const TextStyle(fontSize: 12, color: TColors.textSubtitle)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                if (description != null && description.isNotEmpty) ...[
                  const Text('Yêu cầu bài tập:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(fontSize: 13, color: TColors.textSubtitle, height: 1.4)),
                  const SizedBox(height: 12),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              isSubmitted
                                  ? 'Trạng thái:'
                                  : isOverdue
                                      ? 'Hạn cuối:'
                                      : 'Thời hạn nộp:',
                              style: const TextStyle(fontSize: 11, color: TColors.textSubtitle)),
                          const SizedBox(height: 2),
                          Text(dueStr,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: (isOverdue || isTodo) ? Colors.red : Colors.green)),
                        ],
                      ),
                    ),
                    if (isTodo)
                      ElevatedButton.icon(
                        onPressed: () => _submitAssignment(item),
                        icon: const Icon(Icons.upload_file, size: 16, color: Colors.white),
                        label: const Text('Nộp bài',
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    if (isSubmitted && grade != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Điểm số:', style: TextStyle(fontSize: 11, color: TColors.textSubtitle)),
                          const SizedBox(height: 2),
                          Text('$grade / 10',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}