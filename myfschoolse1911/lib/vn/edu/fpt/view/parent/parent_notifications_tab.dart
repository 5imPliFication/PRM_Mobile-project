import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';

class ParentNotificationsTab extends StatefulWidget {
  final String studentId;
  const ParentNotificationsTab({super.key, required this.studentId});

  @override
  State<ParentNotificationsTab> createState() => _ParentNotificationsTabState();
}

class _ParentNotificationsTabState extends State<ParentNotificationsTab> {
  List<dynamic> _notifs = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ParentNotificationsTab oldWidget) {
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
      final data = await apiService.getChildNotifications(widget.studentId);
      if (mounted) setState(() => _notifs = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmtTime(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
      if (diff.inHours < 24) return '${diff.inHours} giờ trước';
      if (diff.inDays == 1) return 'Hôm qua';
      return '${diff.inDays} ngày trước';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  : _notifs.isEmpty
                      ? _buildEmpty('Chưa có thông báo')
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(TSizes.lg),
                          itemCount: _notifs.length,
                          itemBuilder: (context, index) {
                            final n = _notifs[index] as Map<String, dynamic>;
                            final unread = n['isRead'] == false;
                            return Card(
                              color: unread ? Colors.orange.withOpacity(0.05) : Colors.white,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                leading: CircleAvatar(
                                  backgroundColor: TColors.primary.withOpacity(0.1),
                                  child: Icon(Icons.campaign_rounded, color: TColors.primary),
                                ),
                                title: Text(n['title'] as String? ?? '',
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontWeight: unread ? FontWeight.bold : FontWeight.w600)),
                                subtitle: Text(
                                    '${n['category'] ?? ''} • ${_fmtTime(n['createdAt'] as String?)}',
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
      Icon(Icons.notifications_off_outlined, size: 56, color: TColors.iconColor.withOpacity(0.5)),
      const SizedBox(height: TSizes.md),
      Text(msg, style: const TextStyle(color: TColors.textSubtitle, fontWeight: FontWeight.bold)),
    ]));
  }
}