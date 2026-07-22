import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';

class TeacherApplicationsTab extends StatefulWidget {
  const TeacherApplicationsTab({super.key});

  @override
  State<TeacherApplicationsTab> createState() => _TeacherApplicationsTabState();
}

class _TeacherApplicationsTabState extends State<TeacherApplicationsTab> {
  List<dynamic> _applications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await apiService.getClassApplications();
      if (mounted) {
        setState(() {
          _applications = data;
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

  String _getTypeName(String type) {
    switch (type) {
      case 'ABSENT_REQUEST':
        return 'Xin nghỉ phép';
      case 'RESCHEDULE':
        return 'Đổi lịch học';
      case 'REGRADE':
        return 'Phúc khảo điểm';
      case 'OTHER':
        return 'Khác';
      default:
        return type;
    }
  }

  String _getStatusName(String status) {
    switch (status) {
      case 'PENDING':
        return 'Đang chờ';
      case 'APPROVED':
        return 'Đã duyệt';
      case 'REJECTED':
        return 'Từ chối';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleApprove(String id) async {
    try {
      await apiService.respondApplication(applicationId: id, status: 'APPROVED');
      _loadApplications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã duyệt đơn'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleReject(String id) async {
    final noteController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Từ chối đơn'),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(
              labelText: 'Lý do từ chối (tùy chọn)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Từ chối', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      try {
        await apiService.respondApplication(
          applicationId: id,
          status: 'REJECTED',
          responseNote: noteController.text.trim(),
        );
        _loadApplications();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã từ chối đơn'), backgroundColor: Colors.orange),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Widget _buildApplicationCard(Map<String, dynamic> app) {
    final id = app['id'] as String;
    final status = app['status'] as String? ?? 'PENDING';
    final type = app['type'] as String? ?? 'OTHER';
    final title = app['title'] as String? ?? '';
    final content = app['content'] as String? ?? '';
    final createdAt = app['createdAt'] as String? ?? '';
    final studentName = app['studentName'] as String? ?? 'Không rõ';
    final className = app['className'] as String? ?? '';

    String formattedDate = createdAt;
    try {
      if (createdAt.isNotEmpty) {
        final d = DateTime.parse(createdAt);
        formattedDate = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getTypeName(type),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TColors.primary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusName(status),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getStatusColor(status)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TColors.textTitle)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.person, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text('$studentName${className.isNotEmpty ? ' - $className' : ''}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14, color: TColors.textSubtitle),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(formattedDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          if (status == 'PENDING') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _handleReject(id),
                    child: const Text('Từ chối'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _handleApprove(id),
                    child: const Text('Duyệt', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn từ học sinh', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: TColors.primary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadApplications,
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
              : (_error != null || _applications.isEmpty)
                  ? ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                        Center(
                          child: Column(
                            children: [
                              const Icon(Icons.not_interested, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text(
                                'Bạn không phải là giáo viên chủ nhiệm\nhoặc chưa có đơn nào',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(onPressed: _loadApplications, child: const Text('Tải lại'))
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(TSizes.lg),
                      itemCount: _applications.length,
                      itemBuilder: (context, index) {
                        return _buildApplicationCard(_applications[index] as Map<String, dynamic>);
                      },
                    ),
        ),
      ),
    );
  }
}
