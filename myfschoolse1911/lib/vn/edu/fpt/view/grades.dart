import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  String _selectedSemester = 'Học kỳ 1';
  List<String> _semesters = ['Học kỳ 1', 'Học kỳ 2', 'Cả năm'];
  Map<String, List<Map<String, dynamic>>> _bySemester = {};
  bool _loading = true;
  String? _error;

  static const List<Color> _palette = [
    Color(0xFF5C6BC0), Color(0xFFEF5350), Color(0xFFFF9800), Color(0xFF66BB6A),
    Color(0xFFEC407A), Color(0xFF26A69A), Color(0xFF26C6DA), Color(0xFF8D6E63),
  ];

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
      final data = await apiService.getGrades();
      final bySem = <String, List<Map<String, dynamic>>>{};
      for (var i = 0; i < data.length; i++) {
        final g = data[i] as Map<String, dynamic>;
        g['_color'] = _palette[i % _palette.length];
        final sem = (g['semester'] as String?) ?? 'Học kỳ 1';
        bySem.putIfAbsent(sem, () => []);
        bySem[sem]!.add(g);
      }
      final semKeys = bySem.keys.toList()..sort();
      final tabs = ['Học kỳ 1', 'Học kỳ 2', 'Cả năm'];
      final available = semKeys.where((k) => tabs.contains(k)).toList();
      final items = <String>[];
      for (final t in tabs) {
        if (available.contains(t) || !semKeys.any((k) => tabs.contains(k))) {
          items.add(t);
        }
      }
      if (items.isEmpty) items.addAll(tabs);
      if (mounted) {
        setState(() {
          _bySemester = bySem;
          _semesters = items;
          if (!_semesters.contains(_selectedSemester)) {
            _selectedSemester = _semesters.first;
          }
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

  List<_SubjectGrade> get _activeGrades {
    final list = _bySemester[_selectedSemester] ?? [];
    if (_selectedSemester == 'Cả năm') {
      final hk1 = _bySemester['Học kỳ 1'] ?? [];
      final hk2 = _bySemester['Học kỳ 2'] ?? [];
      final bySubj = <String, List<Map<String, dynamic>>>{};
      for (final g in [...hk1, ...hk2]) {
        final s = g['subject'] as String? ?? '';
        bySubj.putIfAbsent(s, () => []);
        bySubj[s]!.add(g);
      }
      final out = <_SubjectGrade>[];
      var i = 0;
      bySubj.forEach((subj, rows) {
        final color = _palette[i++ % _palette.length];
        double avg(List<Map<String, dynamic>> rs, String key) {
          final v = rs.map((r) => r[key]).whereType<num>().toList();
          return v.isEmpty ? 0 : v.fold<num>(0, (a, b) => a + b) / v.length;
        }

        out.add(_SubjectGrade(
          subj,
          avg(rows, 'oralScore'),
          avg(rows, 'fifteenMinScore'),
          avg(rows, 'onePeriodScore'),
          avg(rows, 'semesterScore'),
          avg(rows, 'average'),
          color,
        ));
      });
      return out;
    }
    var i = 0;
    return list.map((g) {
      final color = _palette[i++ % _palette.length];
      return _SubjectGrade(
        g['subject'] as String? ?? '',
        (g['oralScore'] as num?)?.toDouble() ?? 0,
        (g['fifteenMinScore'] as num?)?.toDouble() ?? 0,
        (g['onePeriodScore'] as num?)?.toDouble() ?? 0,
        (g['semesterScore'] as num?)?.toDouble() ?? 0,
        (g['average'] as num?)?.toDouble() ?? 0,
        color,
      );
    }).toList();
  }

  double get _gpa {
    final grades = _activeGrades;
    if (grades.isEmpty) return 0;
    return grades.map((g) => g.average).fold<num>(0, (a, b) => a + b) / grades.length;
  }

  String get _status {
    final g = _gpa;
    if (g >= 8) return 'Học sinh Giỏi';
    if (g >= 6.5) return 'Học sinh Khá';
    return 'Học sinh TB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng điểm',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
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
                  : Column(
                      children: [
                        _buildSemesterSelector(),
                        _buildGpaCard(_gpa, _status),
                        const SizedBox(height: TSizes.sm),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: TSizes.lg, vertical: TSizes.sm),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Chi tiết môn học',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: TColors.textTitle)),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                horizontal: TSizes.lg, vertical: TSizes.sm),
                            itemCount: _activeGrades.length,
                            itemBuilder: (context, index) =>
                                _buildSubjectGradeCard(_activeGrades[index]),
                          ),
                        ),
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

  Widget _buildSemesterSelector() {
    return Container(
      margin: const EdgeInsets.all(TSizes.lg),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSemester,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: TColors.primary, size: 28),
          style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
          onChanged: (v) {
            if (v != null) setState(() => _selectedSemester = v);
          },
          items: _semesters
              .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildGpaCard(double gpa, String status) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: TSizes.lg),
      padding: const EdgeInsets.all(TSizes.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF36F21), Color(0xFFFF8A50)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: TColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Điểm trung bình (GPA)',
                  style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Text(gpa.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(status,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: gpa / 10,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  color: Colors.white,
                ),
              ),
              Text('${(gpa * 10).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSubjectGradeCard(_SubjectGrade grade) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: ExpansionTile(
        shape: const Border(),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: grade.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.menu_book, color: grade.color, size: 22),
        ),
        title: Text(grade.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
        subtitle: Text('ĐTB môn: ${grade.average.toStringAsFixed(1)}',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: grade.average >= 8.0 ? Colors.green : Colors.orange)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: grade.color.withOpacity(0.1), shape: BoxShape.circle),
          child: Text(grade.average.toStringAsFixed(1),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: grade.color)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSubGradeItem('Miệng', grade.m1.toStringAsFixed(1)),
                    _buildSubGradeItem('15 phút', grade.m2.toStringAsFixed(1)),
                    _buildSubGradeItem('1 tiết', grade.m3.toStringAsFixed(1)),
                    _buildSubGradeItem('Học kỳ', grade.m4.toStringAsFixed(1)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSubGradeItem(String label, String val) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: TColors.textSubtitle)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(val,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
        ),
      ],
    );
  }
}

class _SubjectGrade {
  final String name;
  final double m1, m2, m3, m4, average;
  final Color color;
  _SubjectGrade(this.name, this.m1, this.m2, this.m3, this.m4, this.average, this.color);
}