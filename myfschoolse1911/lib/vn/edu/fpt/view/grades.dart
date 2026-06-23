import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  String _selectedSemester = 'Học kỳ 1';

  final List<String> _semesters = ['Học kỳ 1', 'Học kỳ 2', 'Cả năm'];

  final List<_SubjectGrade> _gradesHk1 = [
    _SubjectGrade('Toán học', 8.5, 9.0, 8.0, 8.5, 8.3, const Color(0xFF5C6BC0)),
    _SubjectGrade('Vật lý', 8.0, 7.5, 9.0, 8.5, 8.3, const Color(0xFFEF5350)),
    _SubjectGrade('Hóa học', 9.0, 9.5, 8.5, 9.0, 9.1, const Color(0xFFFF9800)),
    _SubjectGrade('Sinh học', 7.5, 8.0, 8.0, 8.5, 8.1, const Color(0xFF66BB6A)),
    _SubjectGrade('Ngữ văn', 8.0, 8.0, 7.5, 8.0, 7.9, const Color(0xFFEC407A)),
    _SubjectGrade('Tiếng Anh', 9.0, 8.5, 9.0, 9.5, 9.1, const Color(0xFF26A69A)),
    _SubjectGrade('Tin học', 9.5, 10.0, 9.5, 9.5, 9.6, const Color(0xFF26C6DA)),
    _SubjectGrade('Lịch sử', 8.0, 7.0, 8.0, 8.5, 7.9, const Color(0xFF8D6E63)),
  ];

  final List<_SubjectGrade> _gradesHk2 = [
    _SubjectGrade('Toán học', 9.0, 8.5, 9.0, 9.5, 9.1, const Color(0xFF5C6BC0)),
    _SubjectGrade('Vật lý', 8.5, 9.0, 8.5, 8.0, 8.4, const Color(0xFFEF5350)),
    _SubjectGrade('Hóa học', 9.5, 9.0, 9.0, 9.5, 9.4, const Color(0xFFFF9800)),
    _SubjectGrade('Sinh học', 8.0, 8.5, 8.0, 9.0, 8.5, const Color(0xFF66BB6A)),
    _SubjectGrade('Ngữ văn', 8.5, 8.0, 8.5, 8.0, 8.2, const Color(0xFFEC407A)),
    _SubjectGrade('Tiếng Anh', 9.5, 9.0, 9.5, 9.5, 9.4, const Color(0xFF26A69A)),
    _SubjectGrade('Tin học', 10.0, 9.5, 10.0, 10.0, 9.9, const Color(0xFF26C6DA)),
    _SubjectGrade('Lịch sử', 8.5, 8.0, 8.5, 9.0, 8.6, const Color(0xFF8D6E63)),
  ];

  @override
  Widget build(BuildContext context) {
    List<_SubjectGrade> activeGrades = _gradesHk1;
    double gpa = 8.5;
    String status = 'Học sinh Giỏi';

    if (_selectedSemester == 'Học kỳ 2') {
      activeGrades = _gradesHk2;
      gpa = 8.9;
      status = 'Học sinh Giỏi';
    } else if (_selectedSemester == 'Cả năm') {
      // average of both
      activeGrades = List.generate(_gradesHk1.length, (index) {
        final g1 = _gradesHk1[index];
        final g2 = _gradesHk2[index];
        final avg = (g1.average + g2.average) / 2;
        return _SubjectGrade(g1.name, (g1.m1 + g2.m1) / 2, (g1.m2 + g2.m2) / 2,
            (g1.m3 + g2.m3) / 2, (g1.m4 + g2.m4) / 2, avg, g1.color);
      });
      gpa = 8.7;
      status = 'Học sinh Giỏi';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bảng điểm',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: TColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              TColors.bgGradientTop,
              TColors.bgGradientBottom,
            ],
          ),
        ),
        child: Column(
          children: [
            // Semester Dropdown Selector
            _buildSemesterSelector(),

            // GPA overview Card
            _buildGpaCard(gpa, status),
            const SizedBox(height: TSizes.sm),

            // Subject grades header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: TSizes.lg, vertical: TSizes.sm),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Chi tiết môn học',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TColors.textTitle,
                  ),
                ),
              ),
            ),

            // Grades List
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: TSizes.lg, vertical: TSizes.sm),
                itemCount: activeGrades.length,
                itemBuilder: (context, index) {
                  return _buildSubjectGradeCard(activeGrades[index]);
                },
              ),
            ),
          ],
        ),
      ),
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
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSemester,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: TColors.primary, size: 28),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedSemester = newValue;
              });
            }
          },
          items: _semesters.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
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
          BoxShadow(
            color: TColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Điểm trung bình (GPA)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                gpa.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          // Ring display
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
              Text(
                '${(gpa * 10).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
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
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
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
        title: Text(
          grade.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Text(
          'ĐTB môn: ${grade.average.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: grade.average >= 8.0 ? Colors.green : Colors.orange,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: grade.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            grade.average.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: grade.color,
            ),
          ),
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: TColors.textSubtitle,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            val,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubjectGrade {
  final String name;
  final double m1; // mieng
  final double m2; // 15p
  final double m3; // 1tiet
  final double m4; // hoc ky
  final double average;
  final Color color;

  _SubjectGrade(this.name, this.m1, this.m2, this.m3, this.m4, this.average, this.color);
}
