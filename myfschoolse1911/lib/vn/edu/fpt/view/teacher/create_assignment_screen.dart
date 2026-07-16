import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:intl/intl.dart';

class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _classCtrl = TextEditingController(text: '11A1');
  List<dynamic> _subjects = const [];
  Map<String, dynamic>? _selectedSubject;
  DateTime? _dueDate;
  bool _loadingSubjects = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final data = await apiService.getTeacherSubjects();
      if (mounted) {
        setState(() {
          _subjects = data;
          if (data.isNotEmpty) _selectedSubject = data.first as Map<String, dynamic>;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingSubjects = false);
    }
  }

  Future<void> _save() async {
    if (_titleCtrl.text.isEmpty || _selectedSubject == null || _dueDate == null || _classCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ tiêu đề, môn, lớp và hạn nộp')),
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await apiService.createAssignment({
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'dueDate': _dueDate!.toUtc().toIso8601String(),
        'targetClass': _classCtrl.text.trim(),
        'subjectId': _selectedSubject!['id'],
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tạo bài tập')),
        );
        Navigator.pop<bool>(context, true);
      }
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
        title: const Text('Tạo bài tập', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field('Tiêu đề', _titleCtrl),
            const SizedBox(height: 12),
            _field('Mô tả', _descCtrl, maxLines: 4),
            const SizedBox(height: 12),
            _field('Lớp', _classCtrl),
            const SizedBox(height: 12),
            if (!_loadingSubjects)
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedSubject,
                decoration: _deco('Môn học'),
                items: _subjects.map((s) => DropdownMenuItem(
                      value: s as Map<String, dynamic>,
                      child: Text('${s['name']}', overflow: TextOverflow.ellipsis),
                    )).toList(),
                onChanged: (v) => setState(() => _selectedSubject = v),
              ),
            const SizedBox(height: 12),
            TextFormField(
              readOnly: true,
              decoration: _deco('Hạn nộp').copyWith(
                hintText: _dueDate == null ? 'Chọn ngày' : DateFormat('dd/MM/yyyy HH:mm').format(_dueDate!),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.event),
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 3)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 23, minute: 59),
                      );
                      if (t != null) setState(() => _dueDate = DateTime(d.year, d.month, d.day, t.hour, t.minute));
                    }
                  },
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _deco(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: _deco(label),
    );
  }
}