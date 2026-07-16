import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:intl/intl.dart';

class SubmissionsScreen extends StatefulWidget {
  final String assignmentId;
  final String title;
  const SubmissionsScreen({super.key, required this.assignmentId, required this.title});

  @override
  State<SubmissionsScreen> createState() => _SubmissionsScreenState();
}

class _SubmissionsScreenState extends State<SubmissionsScreen> {
  List<dynamic> _subs = const [];
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
      final data = await apiService.getSubmissions(widget.assignmentId);
      if (mounted) setState(() => _subs = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmtSubmitted(String? iso) {
    if (iso == null) return '--';
    try {
      return DateFormat('HH:mm dd/MM/yyyy').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  void _openGradeDialog(Map<String, dynamic> sub) {
    final existing = sub['grade'];
    final ctrl = TextEditingController(
        text: existing != null ? existing.toString() : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Chấm: ${sub['studentName'] ?? ''}', style: const TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MSHS: ${sub['studentCode'] ?? '--'}',
                style: const TextStyle(color: TColors.textSubtitle, fontSize: 12)),
            const SizedBox(height: 8),
            Text('Bài nộp: ${sub['fileUrl'] ?? '--'}',
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            const Text('Điểm (0 - 10)', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'VD: 8.5',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final v = double.tryParse(ctrl.text.trim());
              if (v == null || v < 0 || v > 10) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Điểm không hợp lệ')),
                );
                return;
              }
              try {
                await apiService.gradeSubmission(sub['id'] as String, v);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã lưu điểm')),
                  );
                }
                await _load();
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1),
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
                  : _subs.isEmpty
                      ? _buildEmpty('Chưa có bài nộp nào')
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: _subs.length,
                          itemBuilder: (context, index) {
                            final s = _subs[index] as Map<String, dynamic>;
                            final grade = s['grade'];
                            final graded = grade != null;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _openGradeDialog(s),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: TColors.primary.withOpacity(0.1),
                                        child: const Icon(Icons.person, color: TColors.primary),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(s['studentName'] as String? ?? '',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                            const SizedBox(height: 2),
                                            Text('MSHS: ${s['studentCode'] ?? '--'} • ${_fmtSubmitted(s['submittedAt'] as String?)}',
                                                style: const TextStyle(fontSize: 12, color: TColors.textSubtitle)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: graded
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          graded ? '$grade / 10' : 'Chấm điểm',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: graded ? Colors.green : Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
      Icon(Icons.inbox, size: 56, color: TColors.iconColor.withOpacity(0.5)),
      const SizedBox(height: 12),
      Text(msg, style: const TextStyle(color: TColors.textSubtitle, fontWeight: FontWeight.bold)),
    ]));
  }
}