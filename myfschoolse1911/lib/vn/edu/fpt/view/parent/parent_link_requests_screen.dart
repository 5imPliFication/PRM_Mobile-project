import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';
import 'package:intl/intl.dart';

class ParentLinkRequestsScreen extends StatefulWidget {
  const ParentLinkRequestsScreen({super.key});

  @override
  State<ParentLinkRequestsScreen> createState() => _ParentLinkRequestsScreenState();
}

class _ParentLinkRequestsScreenState extends State<ParentLinkRequestsScreen> {
  List<dynamic> _requests = const [];
  bool _loading = true;
  String? _error;
  final Set<String> _busy = {};

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
      final data = await apiService.getIncomingParentLinkRequests();
      if (mounted) setState(() => _requests = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _respond(String id, bool accept) async {
    if (!mounted) return;
    setState(() => _busy.add(id));
    try {
      if (accept) {
        await apiService.acceptParentLinkRequest(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã chấp nhận liên kết'), behavior: SnackBarBehavior.floating),
          );
        }
      } else {
        await apiService.rejectParentLinkRequest(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã từ chối')),
          );
        }
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy.remove(id));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lời mời liên kết', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  : _requests.isEmpty
                      ? _buildEmpty('Chưa có lời mời liên kết nào')
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(TSizes.lg),
                          itemCount: _requests.length,
                          itemBuilder: (context, index) {
                            final r = _requests[index] as Map<String, dynamic>;
                            final status = r['status'] as String? ?? 'PENDING';
                            final busy = _busy.contains(r['id'] as String);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: TColors.primary.withOpacity(0.1),
                                          child: const Icon(Icons.child_care_rounded, color: TColors.primary),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(r['studentName'] as String? ?? '--',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                              Text(
                                                'MSHS ${r['studentCode'] ?? '--'} • Lớp ${r['className'] ?? '--'}',
                                                style: const TextStyle(fontSize: 12, color: TColors.textSubtitle),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _statusColor(status).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(_statusLabel(status),
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: _statusColor(status))),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    const Divider(),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.family_restroom, size: 16, color: TColors.iconColor),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            [
                                              if (r['parentName'] != null && (r['parentName'] as String).isNotEmpty)
                                                r['parentName'] as String,
                                              if (r['relationship'] != null && (r['relationship'] as String).isNotEmpty)
                                                '(${r['relationship']})',
                                              if (r['message'] != null && (r['message'] as String).isNotEmpty)
                                                '— ${r['message']}',
                                              _fmt(r['createdAt'] as String?),
                                            ].join(' • '),
                                            style: const TextStyle(fontSize: 12, color: TColors.textSubtitle),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (status == 'PENDING') ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: busy ? null : () => _respond(r['id'] as String, false),
                                              icon: const Icon(Icons.close, size: 18),
                                              label: const Text('Từ chối'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                                side: const BorderSide(color: Colors.red),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: busy ? null : () => _respond(r['id'] as String, true),
                                              icon: busy
                                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                                  : const Icon(Icons.check, size: 18),
                                              label: const Text('Chấp nhận'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: TColors.primary,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
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
      Icon(Icons.link_off_rounded, size: 56, color: TColors.iconColor.withOpacity(0.5)),
      const SizedBox(height: TSizes.md),
      Text(msg, style: const TextStyle(color: TColors.textSubtitle, fontWeight: FontWeight.bold)),
    ]));
  }
}