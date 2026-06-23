import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_NotifItem> _notifications = [
    _NotifItem(
      'Thay đổi lịch học môn Vật lý lớp 11A1',
      'Lịch học môn Vật lý thứ 3 ngày 24/06 được dời từ tiết 2 sang tiết 4 do giáo viên bận công tác đột xuất.',
      '10:30 Hôm nay',
      'Học tập',
      Icons.menu_book,
      const Color(0xFF5C6BC0),
      isUnread: true,
    ),
    _NotifItem(
      'Thông báo thu học phí kỳ Summer 2026',
      'Thời hạn nộp học phí cho học kỳ mới đến hết ngày 30/06/2026. Quý phụ huynh vui lòng kiểm tra và đóng đúng hạn.',
      '08:15 Hôm nay',
      'Học phí',
      Icons.payments,
      const Color(0xFF26A69A),
      isUnread: true,
    ),
    _NotifItem(
      'Đăng ký tham gia Lễ hội mùa hè FPT School',
      'Học sinh có nhu cầu đăng ký văn nghệ, hoạt động gian hàng hoặc tham gia ban tổ chức vui lòng gửi đơn đăng ký trước ngày 26/06.',
      'Hôm qua',
      'Hoạt động',
      Icons.campaign,
      const Color(0xFFFF9800),
      isUnread: false,
    ),
    _NotifItem(
      'Công bố điểm kiểm tra 1 tiết môn Hóa học',
      'Điểm số bài kiểm tra chương 3 môn Hóa học đã được cập nhật. Học sinh truy cập Bảng điểm để xem chi tiết.',
      '2 ngày trước',
      'Học tập',
      Icons.assignment_turned_in,
      const Color(0xFF5C6BC0),
      isUnread: false,
    ),
    _NotifItem(
      'Khảo sát ý kiến học sinh về hoạt động ngoại khóa',
      'Vui lòng điền vào biểu mẫu khảo sát chất lượng hoạt động dã ngoại vừa qua nhằm giúp trường cải thiện dịch vụ.',
      '3 ngày trước',
      'Khảo sát',
      Icons.poll,
      const Color(0xFFAB47BC),
      isUnread: false,
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n.isUnread = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đánh dấu tất cả là đã đọc'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thông báo',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: TColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all, color: Colors.white),
            tooltip: 'Đọc tất cả',
          )
        ],
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
        child: _notifications.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(TSizes.lg),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotifCard(_notifications[index]);
                },
              ),
      ),
    );
  }

  Widget _buildNotifCard(_NotifItem item) {
    return GestureDetector(
      onTap: () {
        setState(() {
          item.isUnread = false;
        });
        _showNotifDetailDialog(item);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isUnread ? Colors.orange.withOpacity(0.03) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: item.isUnread
              ? Border.all(color: TColors.primary.withOpacity(0.2), width: 1.5)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(width: 14),

            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: item.color,
                          ),
                        ),
                      ),
                      Text(
                        item.time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: TColors.textSubtitle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: item.isUnread ? FontWeight.bold : FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: TColors.textSubtitle,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Unread dot indicator
            if (item.isUnread) ...[
              const SizedBox(width: 8),
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.fromLTRB(0,12,0,0),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showNotifDetailDialog(_NotifItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.category,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: item.color,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: TColors.textSubtitle,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 14),
                Text(
                  item.body,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Đóng',
                style: TextStyle(
                  color: TColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: TColors.iconColor.withOpacity(0.5)),
          const SizedBox(height: TSizes.md),
          const Text(
            'Không có thông báo mới',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TColors.textSubtitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifItem {
  final String title;
  final String body;
  final String time;
  final String category;
  final IconData icon;
  final Color color;
  bool isUnread;

  _NotifItem(this.title, this.body, this.time, this.category, this.icon, this.color, {this.isUnread = false});
}
