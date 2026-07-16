import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';
import 'package:intl/intl.dart';

class LinkParentScreen extends StatefulWidget {
  const LinkParentScreen({super.key});

  @override
  State<LinkParentScreen> createState() => _LinkParentScreenState();
}

class _LinkParentScreenState extends State<LinkParentScreen> {
  final _phoneCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _relCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  List<dynamic> _requests = const [];
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  static const List<String> _relOptions = ['Cha', 'Mẹ', 'Anh', 'Chị', 'Khác'];

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
      final data = await apiService.getMyParentLinkRequests();
      if (mounted) setState(() => _requests = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số điện thoại phụ huynh')),
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await apiService.createParentLinkRequest({
        'parentPhone': _phoneCtrl.text.trim(),
        'parentName': _nameCtrl.text.trim(),
        'relationship': _relCtrl.text.trim(),
        'message': _msgCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi lời mời liên kết'), behavior: SnackBarBehavior.floating),
        );
        _phoneCtrl.clear();
        _nameCtrl.clear();
        _relCtrl.clear();
        _msgCtrl.clear();
      }
      await _load();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _cancel(String id) async {
    try {
      await apiService.cancelParentLinkRequest(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã hủy lời mời')),
        );
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  String _fmt(String? iso) {
    if (iso == null) return '';
    try {
      return DateFormat('HH:mm dd/MM').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACCEPTED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'ACCEPTED':
        return 'Đã chấp nhận';
      case 'REJECTED':
        return 'Đã từ chối';
      default:
        return 'Đang chờ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liên kết phụ huynh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          padding: const EdgeInsets.all(TSizes.lg),
          children: [
            // Intro card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mời phụ huynh liên kết',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TColors.textTitle)),
                  SizedBox(height: 8),
                  Text(
                    'Nhập số điện thoại của phụ huynh. Lời mời sẽ được gửi đến tài khoản phụ huynh. Sau khi phụ huynh đồng ý, họ có thể xem thông tin học tập của bạn.',
                    style: TextStyle(fontSize: 13, color: TColors.textSubtitle, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.md),
            // Form card
            Container(
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
                  _field('Số điện thoại phụ huynh *', _phoneCtrl, keyboard: TextInputType.phone),
                  const SizedBox(height: 12),
                  _field('Họ tên phụ huynh', _nameCtrl),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _relCtrl.text.isEmpty ? null : _relCtrl.text,
                    decoration: _deco('Mối quan hệ'),
                    items: _relOptions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (v) => setState(() => _relCtrl.text = v ?? ''),
                  ),
                  const SizedBox(height: 12),
                  _field('Lời nhắn', _msgCtrl, maxLines: 2),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _submitting ? null : _submit,
                      icon: _submitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send),
                      label: const Text('Gửi lời mời', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: TColors.primary),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: TSizes.lg),
            const Text('Lời mời đã gửi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TColors.textTitle)),
            const SizedBox(height: TSizes.md),
            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
            else if (_requests.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('Chưa có lời mời nào', style: TextStyle(color: TColors.textSubtitle))),
              )
            else
              ..._requests.map((raw) {
                final r = raw as Map<String, dynamic>;
                final status = r['status'] as String? ?? 'PENDING';
                final color = _statusColor(status);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: color.withOpacity(0.1),
                        child: Icon(status == 'ACCEPTED' ? Icons.link : Icons.link_outlined, color: color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r['parentPhone'] as String? ?? '--',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(
                              [
                                if (r['parentName'] != null && (r['parentName'] as String).isNotEmpty)
                                  r['parentName'] as String,
                                if (r['relationship'] != null && (r['relationship'] as String).isNotEmpty)
                                  '(${r['relationship']})',
                                _fmt(r['createdAt'] as String?),
                              ].join(' • '),
                              style: const TextStyle(fontSize: 12, color: TColors.textSubtitle),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(_statusLabel(status),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
                      ),
                      if (status == 'PENDING') ...[
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: 'Hủy',
                          icon: const Icon(Icons.close, color: Colors.red, size: 20),
                          onPressed: () => _cancel(r['id'] as String),
                        ),
                      ],
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  InputDecoration _deco(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType? keyboard, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: _deco(label),
    );
  }
}