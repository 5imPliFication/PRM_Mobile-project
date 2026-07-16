import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';

class ParentAttendanceTab extends StatefulWidget {
  final String studentId;
  const ParentAttendanceTab({super.key, required this.studentId});

  @override
  State<ParentAttendanceTab> createState() => _ParentAttendanceTabState();
}

class _ParentAttendanceTabState extends State<ParentAttendanceTab> {
  List<dynamic> _records = const [];
  bool _loading = true;
  String? _error;

  static const Map<String, _StatusMeta> _kStatuses = {
    'PRESENT': _StatusMeta('Có mặt', Colors.green),
    'LATE': _StatusMeta('Trễ', Colors.orange),
    'ABSENT': _StatusMeta('Vắng', Colors.red),
    'EXCUSED': _StatusMeta('Có phép', Colors.blue),
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ParentAttendanceTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.studentId != widget.studentId) _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await apiService.getChildAttendance(widget.studentId);
      if (mounted) setState(() => _records = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final present = _records.where((r) => (r['status'] as String?) == 'PRESENT').length;
    final absent = _records.where((r) => (r['status'] as String?) == 'ABSENT').length;
    final late = _records.where((r) => (r['status'] as String?) == 'LATE').length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điểm danh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: TColors.primary,
        elevation: 0,
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
                  : _records.isEmpty
                      ? _buildEmpty('Chưa có dữ liệu điểm danh')
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(TSizes.lg),
                          itemCount: _records.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) return _summaryCard(present, late, absent);
                            final r = _records[index - 1] as Map<String, dynamic>;
                            final status = r['status'] as String? ?? '';
                            final m = _kStatuses[status];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: (m?.color ?? TColors.iconColor).withOpacity(0.1),
                                  child: Icon(Icons.fact_check_rounded, color: m?.color ?? TColors.iconColor),
                                ),
                                title: Text(r['subject'] as String? ?? '--',
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                    '${r['date'] ?? '--'} • ${m?.label ?? status}${r['note'] != null ? ' — ${r['note']}' : ''}',
                                    style: const TextStyle(fontSize: 12, color: TColors.textSubtitle)),
                                trailing: Text(m?.label ?? status,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, color: m?.color ?? TColors.textSubtitle)),
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }

  Widget _summaryCard(int present, int late, int absent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat('Có mặt', present, Colors.green),
          _stat('Trễ', late, Colors.orange),
          _stat('Vắng', absent, Colors.red),
        ],
      ),
    );
  }

  Widget _stat(String label, int value, Color color) {
    return Column(children: [
      Text('$value', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: const TextStyle(fontSize: 11, color: TColors.textSubtitle)),
    ]);
  }

  Widget _buildError() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Center(child: Column(children: [
          const Icon(Icons.cloud_off, size: 56, color: TColors.iconColor),
          const SizedBox(height: TSizes.md),
          Text(_error ?? '', textAlign: TextAlign.center, style: const TextStyle(color: TColors.textSubtitle)),
          const SizedBox(height: TSizes.md),
          ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
        ])),
      ],
    );
  }

  Widget _buildEmpty(String msg) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.fact_check_outlined, size: 56, color: TColors.iconColor.withOpacity(0.5)),
      const SizedBox(height: TSizes.md),
      Text(msg, style: const TextStyle(color: TColors.textSubtitle, fontWeight: FontWeight.bold)),
    ]));
  }
}

class _StatusMeta {
  final String label;
  final Color color;
  const _StatusMeta(this.label, this.color);
}