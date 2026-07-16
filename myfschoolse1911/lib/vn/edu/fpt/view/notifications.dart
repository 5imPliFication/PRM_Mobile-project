import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';

class NotificationsScreen extends StatefulWidget {
  final bool asTab;

  const NotificationsScreen({super.key, this.asTab = false});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = const [];
  bool _loading = true;
  String? _error;

  static const Map<String, _CategoryStyle> _styles = {
    'Học tập': _CategoryStyle(Icons.menu_book, Color(0xFF5C6BC0)),
    'Học phí': _CategoryStyle(Icons.payments, Color(0xFF26A69A)),
    'Hoạt động': _CategoryStyle(Icons.campaign, Color(0xFFFF9800)),
    'Khảo sát': _CategoryStyle(Icons.poll, Color(0xFFAB47BC)),
  };

  _CategoryStyle _categoryStyle(String? cat) =>
      _styles[cat] ?? const _CategoryStyle(Icons.notifications, Color(0xFF42A5F5));

  String _fmtTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
      if (diff.inHours < 24) return '${diff.inHours} giờ trước';
      if (diff.inDays == 1) return 'Hôm qua';
      return '${diff.inDays} ngày trước';
    } catch (_) {
      return iso;
    }
  }

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
      final data = await apiService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = data.cast<Map<String, dynamic>>();
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

  Future<void> _markItemRead(Map<String, dynamic> item) async {
    final id = item['id'] as String?;
    final wasUnread = item['isRead'] == false;
    if (wasUnread && id != null) {
      try {
        await apiService.markNotificationRead(id);
        setState(() => item['isRead'] = true);
      } catch (_) {
        // ignore optimistic
      }
    }
    _showDetail(item);
  }

  Future<void> _markAllRead() async {
    try {
      await apiService.markAllNotificationsRead();
      setState(() {
        for (final n in _notifications) {
          n['isRead'] = true;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đánh dấu tất cả là đã đọc')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  void _showDetail(Map<String, dynamic> item) {
    final style = _categoryStyle(item['category'] as String?);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: style.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(style.icon, color: style.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(item['category'] as String? ?? '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: style.color)),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item['title'] as String? ?? '',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
              const SizedBox(height: 6),
              Text(_fmtTime(item['createdAt'] as String?),
                  style: const TextStyle(fontSize: 12, color: TColors.textSubtitle)),
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 14),
              Text(item['body'] as String? ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child:
                const Text('Đóng', style: TextStyle(color: TColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? _buildError()
            : _notifications.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(TSizes.lg),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) => _buildCard(_notifications[index]),
                    ),
                  );

    if (widget.asTab) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [TColors.bgGradientTop, TColors.bgGradientBottom],
          ),
        ),
        child: SafeArea(child: Column(
          children: [
            _buildHeader(),
            Expanded(child: body),
          ],
        )),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: TColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _markAllRead,
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
            colors: [TColors.bgGradientTop, TColors.bgGradientBottom],
          ),
        ),
        child: body,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(TSizes.lg, TSizes.md, TSizes.lg, TSizes.sm),
      child: Row(
        children: [
          const Text('Thông báo',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: TColors.textTitle)),
          const Spacer(),
          IconButton(
            onPressed: _markAllRead,
            icon: const Icon(Icons.done_all, color: TColors.primary),
            tooltip: 'Đọc tất cả',
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 64, color: TColors.iconColor.withOpacity(0.5)),
          const SizedBox(height: TSizes.md),
          const Text('Không có thông báo mới',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TColors.textSubtitle)),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final style = _categoryStyle(item['category'] as String?);
    final isUnread = item['isRead'] == false;
    return GestureDetector(
      onTap: () => _markItemRead(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? Colors.orange.withOpacity(0.03) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isUnread
              ? Border.all(color: TColors.primary.withOpacity(0.2), width: 1.5)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: style.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(style.icon, color: style.color, size: 22),
            ),
            const SizedBox(width: 14),
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
                          color: style.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(item['category'] as String? ?? '',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold, color: style.color)),
                      ),
                      Text(_fmtTime(item['createdAt'] as String?),
                          style: const TextStyle(fontSize: 11, color: TColors.textSubtitle)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(item['title'] as String? ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          color: const Color(0xFF333333))),
                  const SizedBox(height: 4),
                  Text(item['body'] as String? ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: TColors.textSubtitle, height: 1.4)),
                ],
              ),
            ),
            if (isUnread) ...[
              const SizedBox(width: 8),
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryStyle {
  final IconData icon;
  final Color color;
  const _CategoryStyle(this.icon, this.color);
}