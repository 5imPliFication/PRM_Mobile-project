import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_AssignmentItem> _todoAssignments = [
    _AssignmentItem(
      'Bài tập 3: Cảm ứng điện từ',
      'Vật lý 11',
      'Làm các bài tập 1, 2, 3 trang 45 SGK Vật lý nâng cao. Chụp ảnh bài làm hoặc xuất file PDF để nộp.',
      '23:59 - 25/06/2026',
      const Color(0xFFEF5350),
      isUrgent: true,
    ),
    _AssignmentItem(
      'Essay: School of the Future',
      'Tiếng Anh 11',
      'Viết bài luận khoảng 250 từ nói về viễn cảnh trường học tương lai với sự hỗ trợ của AI công nghệ.',
      '12:00 - 28/06/2026',
      const Color(0xFF26A69A),
    ),
    _AssignmentItem(
      'Đại số: Khảo sát hàm số lượng giác',
      'Toán học 11',
      'Giải bài tập phần Ôn tập chương 1 Đại số và Giải tích lớp 11.',
      '23:59 - 30/06/2026',
      const Color(0xFF5C6BC0),
    ),
  ];

  final List<_AssignmentItem> _submittedAssignments = [
    _AssignmentItem(
      'Bài thực hành số 2: Lập trình C++',
      'Tin học 11',
      'Viết chương trình sắp xếp mảng và tìm kiếm nhị phân bằng C++.',
      'Đã nộp lúc 15:30 - 21/06/2026',
      const Color(0xFF26C6DA),
      grade: '9.5 / 10',
    ),
    _AssignmentItem(
      'Soạn văn bài: Chí Phèo',
      'Ngữ văn 11',
      'Trả lời các câu hỏi phần Soạn bài tác phẩm Chí Phèo của nhà văn Nam Cao.',
      'Đã nộp lúc 20:00 - 18/06/2026',
      const Color(0xFFEC407A),
      grade: '8.0 / 10',
    ),
  ];

  final List<_AssignmentItem> _overdueAssignments = [
    _AssignmentItem(
      'Vẽ sơ đồ tư duy: Lịch sử nhà Nguyễn',
      'Lịch sử 11',
      'Vẽ sơ đồ tư duy hệ thống hóa các sự kiện nổi bật của thời kỳ nhà Nguyễn.',
      'Hạn chót: 15/06/2026',
      const Color(0xFF8D6E63),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _submitAssignment(_AssignmentItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(TSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColors.textTitle,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Môn học: ${item.subject}',
                style: const TextStyle(
                  fontSize: 14,
                  color: TColors.textSubtitle,
                ),
              ),
              const SizedBox(height: TSizes.md),
              const Divider(),
              const SizedBox(height: TSizes.md),
              const Text(
                'Tải tệp tin lên bài làm',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: TSizes.sm),
              // Dummy upload container
              GestureDetector(
                onTap: () {
                  // Simulate upload success
                  Navigator.pop(context);
                  _simulateUploadSuccess(item);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: TColors.primary.withOpacity(0.3),
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 40,
                        color: TColors.primary,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Chọn tệp từ thiết bị của bạn',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: TColors.primary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Hỗ trợ PDF, PNG, JPG (Max 10MB)',
                        style: TextStyle(
                          fontSize: 11,
                          color: TColors.textSubtitle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: TSizes.md),
            ],
          ),
        );
      },
    );
  }

  void _simulateUploadSuccess(_AssignmentItem item) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: TSizes.md),
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: TSizes.lg),
              const Text(
                'Nộp bài thành công!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Hệ thống đã ghi nhận bài làm của bạn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: TColors.textSubtitle,
                ),
              ),
              const SizedBox(height: TSizes.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    setState(() {
                      _todoAssignments.remove(item);
                      final nowStr = 'Đã nộp lúc 11:30 - Hôm nay';
                      _submittedAssignments.insert(
                        0,
                        _AssignmentItem(
                          item.title,
                          item.subject,
                          item.body,
                          nowStr,
                          item.color,
                        ),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bài tập học tập',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
            Tab(text: 'Chưa nộp (${_todoAssignments.length})'),
            Tab(text: 'Đã nộp (${_submittedAssignments.length})'),
            Tab(text: 'Quá hạn (${_overdueAssignments.length})'),
          ],
        ),
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
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAssignmentList(_todoAssignments, isTodo: true),
            _buildAssignmentList(_submittedAssignments, isSubmitted: true),
            _buildAssignmentList(_overdueAssignments, isOverdue: true),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentList(List<_AssignmentItem> list,
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
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: TColors.textSubtitle,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(TSizes.lg),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ExpansionTile(
            shape: const Border(),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.assignment, color: item.color, size: 22),
            ),
            title: Text(
              item.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            subtitle: Text(
              item.subject,
              style: const TextStyle(
                fontSize: 12,
                color: TColors.textSubtitle,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Yêu cầu bài tập:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: const TextStyle(
                        fontSize: 13,
                        color: TColors.textSubtitle,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: TColors.textSubtitle,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.dueDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isOverdue
                                      ? Colors.red
                                      : item.isUrgent
                                          ? Colors.red
                                          : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isTodo) ...[
                          ElevatedButton.icon(
                            onPressed: () => _submitAssignment(item),
                            icon: const Icon(Icons.upload_file, size: 16, color: Colors.white),
                            label: const Text(
                              'Nộp bài',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          )
                        ],
                        if (isSubmitted && item.grade != null) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Điểm số:',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: TColors.textSubtitle,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.grade!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AssignmentItem {
  final String title;
  final String subject;
  final String body;
  final String dueDate;
  final Color color;
  final bool isUrgent;
  final String? grade;

  _AssignmentItem(
    this.title,
    this.subject,
    this.body,
    this.dueDate,
    this.color, {
    this.isUrgent = false,
    this.grade,
  });
}
