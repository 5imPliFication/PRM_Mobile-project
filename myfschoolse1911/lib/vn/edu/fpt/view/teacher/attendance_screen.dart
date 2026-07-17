import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  final String className;
  const AttendanceScreen({super.key, required this.className});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _date = DateTime.now();
  List<dynamic> _sessions = const [];
  Map<String, dynamic>? _selectedSession;
  List<dynamic> _sheet = const [];
  final Map<String, String> _draftStatus = {}; // studentId -> status
  bool _loadingSessions = true;
  bool _loadingSheet = false;
  bool _saving = false;
  String? _error;

  static const Map<String, _StatusMeta> _kStatuses = {
    'PRESENT': _StatusMeta('Có mặt', Colors.green, Icons.check_circle),
    'LATE': _StatusMeta('Trễ', Colors.orange, Icons.access_time),
    'ABSENT': _StatusMeta('Vắng', Colors.red, Icons.cancel),
    'EXCUSED': _StatusMeta('Có phép', Colors.blue, Icons.receipt_long),
  };

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    if (!mounted) return;
    setState(() {
      _loadingSessions = true;
      _error = null;
    });
    try {
      final dow = _date.weekday + 1; // Mon=2..Sat=7
      final data = await apiService.getTeacherSessions(dayOfWeek: dow);
      // Only show sessions whose roster matches this class (approximate by subject/time same);
      // the API dedupes per period so all of them apply to the class.
      if (mounted) {
        setState(() {
          _sessions = data;
          if (data.isNotEmpty) {
            _selectedSession = data.first as Map<String, dynamic>;
          } else {
            _selectedSession = null;
          }
        });
        await _loadSheet();
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingSessions = false);
    }
  }

  Future<void> _loadSheet() async {
    final session = _selectedSession;
    if (session == null) {
      setState(() => _sheet = const []);
      return;
    }
    if (!mounted) return;
    setState(() => _loadingSheet = true);
    try {
      final sheet = await apiService.getAttendanceSheet(
        session['id'] as String,
        DateFormat('yyyy-MM-dd').format(_date),
      );
      if (mounted) {
        _draftStatus.clear();
        for (final row in sheet) {
          final r = row as Map<String, dynamic>;
          _draftStatus[r['studentId'] as String] =
              (r['status'] as String?) ?? 'PRESENT';
        }
        setState(() => _sheet = sheet);
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingSheet = false);
    }
  }

  Future<void> _save() async {
    final session = _selectedSession;
    if (session == null) return;
    if (!mounted) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final items = _sheet.map((raw) {
        final r = raw as Map<String, dynamic>;
        final id = r['studentId'] as String;
        return {
          'studentId': id,
          'status': _draftStatus[id] ?? 'PRESENT',
        };
      }).toList();
      await apiService.markAttendance(
        scheduleId: session['id'] as String,
        dateIso: DateFormat('yyyy-MM-dd').format(_date),
        items: items,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu điểm danh')),
        );
      }
      await _loadSheet();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điểm danh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: TColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [TColors.bgGradientTop, TColors.bgGradientBottom],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime.now().subtract(const Duration(days: 60)),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null && picked != _date) {
                        setState(() => _date = picked);
                        await _loadSessions();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.event, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd/MM/yyyy').format(_date),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<Map<String, dynamic>>(
                      value: _selectedSession,
                      hint: const Text('Chọn tiết'),
                      isExpanded: true,
                      items: _sessions.map((s) {
                        final sm = s as Map<String, dynamic>;
                        return DropdownMenuItem(
                          value: sm,
                          child: Text('${sm['subject'] ?? ''} (${sm['time'] ?? ''})', overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() => _selectedSession = v);
                        _loadSheet();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
            if (_selectedSession != null && _sheet.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.save),
                    label: const Text('Lưu điểm danh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loadingSessions) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off, color: TColors.iconColor),
          const SizedBox(height: 8),
          Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: TColors.textSubtitle)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _loadSessions, child: const Text('Thử lại')),
        ]),
      ));
    }
    if (_selectedSession == null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.event_busy, size: 48, color: TColors.iconColor.withOpacity(0.5)),
        const SizedBox(height: 8),
        Text('Không có tiết học lớp ${widget.className} ngày ${DateFormat('dd/MM').format(_date)}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: TColors.textSubtitle, fontWeight: FontWeight.bold)),
      ]));
    }
    if (_loadingSheet) return const Center(child: CircularProgressIndicator());
    if (_sheet.isEmpty) {
      return const Center(child: Text('Không có học sinh', style: TextStyle(color: TColors.textSubtitle)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: _sheet.length,
      itemBuilder: (context, index) {
        final r = _sheet[index] as Map<String, dynamic>;
        final id = r['studentId'] as String;
        final marked = r['marked'] == true;
        final current = _draftStatus[id] ?? 'PRESENT';
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(r['studentName'] as String? ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                    Text(marked ? 'Đã điểm danh' : 'Chưa điểm danh',
                        style: TextStyle(fontSize: 12, color: marked ? Colors.green : TColors.textSubtitle)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _kStatuses.entries.map((e) {
                    final selected = current == e.key;
                    final m = e.value;
                    return ChoiceChip(
                      label: Text(m.label, style: const TextStyle(fontSize: 12)),
                      selected: selected,
                      selectedColor: m.color.withOpacity(0.2),
                      labelStyle: TextStyle(color: selected ? m.color : TColors.textSubtitle, fontWeight: FontWeight.bold),
                      avatar: Icon(m.icon, size: 14, color: m.color),
                      onSelected: (_) => setState(() => _draftStatus[id] = e.key),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusMeta {
  final String label;
  final Color color;
  final IconData icon;
  const _StatusMeta(this.label, this.color, this.icon);
}