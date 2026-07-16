import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';

class ParentScheduleTab extends StatefulWidget {
  final String studentId;
  const ParentScheduleTab({super.key, required this.studentId});

  @override
  State<ParentScheduleTab> createState() => _ParentScheduleTabState();
}

class _ParentScheduleTabState extends State<ParentScheduleTab> {
  List<dynamic> _sessions = const [];
  bool _loading = true;
  String? _error;

  static const List<String> _weekdays = ['', '', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ParentScheduleTab oldWidget) {
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
      final data = await apiService.getChildSchedule(widget.studentId);
      if (mounted) setState(() => _sessions = data);
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
        title: const Text('Thời khóa biểu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  : _sessions.isEmpty
                      ? _buildEmpty('Chưa có lịch học')
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(TSizes.lg),
                          itemCount: _sessions.length,
                          itemBuilder: (context, index) {
                            final s = _sessions[index] as Map<String, dynamic>;
                            final dow = s['dayOfWeek'] as int? ?? 2;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: TColors.primary.withOpacity(0.1),
                                  child: const Icon(Icons.class_rounded, color: TColors.primary),
                                ),
                                title: Text(s['subject'] as String? ?? '--',
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    '${_weekdays[dow]} • ${s['time'] ?? '--'} • ${s['room'] ?? '--'} • ${s['teacher'] ?? '--'}',
                                    style: const TextStyle(fontSize: 12, color: TColors.textSubtitle)),
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
      Icon(Icons.calendar_month_outlined, size: 56, color: TColors.iconColor.withOpacity(0.5)),
      const SizedBox(height: TSizes.md),
      Text(msg, style: const TextStyle(color: TColors.textSubtitle, fontWeight: FontWeight.bold)),
    ]));
  }
}