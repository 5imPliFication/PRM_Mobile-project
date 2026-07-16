import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/parent/parent_link_requests_screen.dart';

class ParentChildTab extends StatefulWidget {
  final String studentId;
  final String parentName;
  final VoidCallback onLogout;
  final VoidCallback? onLinkChanged;
  const ParentChildTab({
    super.key,
    required this.studentId,
    required this.parentName,
    required this.onLogout,
    this.onLinkChanged,
  });

  @override
  State<ParentChildTab> createState() => _ParentChildTabState();
}

class _ParentChildTabState extends State<ParentChildTab> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ParentChildTab oldWidget) {
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
      final p = await apiService.getChildProfile(widget.studentId);
      if (mounted) setState(() => _profile = p);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmtDate(dynamic d) {
    if (d == null) return '--';
    return d.toString().split('T').first;
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['fullName'] as String? ?? 'Học sinh';
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'A';
    return Scaffold(
      appBar: AppBar(
        title: Text('Xin chào, ${widget.parentName}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: TColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Lời mời liên kết',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ParentLinkRequestsScreen()),
              );
              _load();
              widget.onLinkChanged?.call();
            },
            icon: const Icon(Icons.link_rounded, color: Colors.white),
          ),
        ],
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
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: TSizes.lg),
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: const Color(0xFFFFCC80),
                            child: Text(initial,
                                style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF36F21))),
                          ),
                          const SizedBox(height: TSizes.md),
                          Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: TColors.textTitle)),
                          const SizedBox(height: 4),
                          Text('Lớp ${_profile?['className'] ?? '--'}',
                              style: const TextStyle(color: TColors.textSubtitle, fontWeight: FontWeight.w500)),
                          const SizedBox(height: TSizes.lg),
                          _card('Thông tin học tập', [
                            _row(Icons.account_tree_rounded, 'Ngành', _profile?['program']),
                            _row(Icons.calendar_month_rounded, 'Niên khóa', _profile?['academicYear']),
                            _row(Icons.location_city_rounded, 'Cơ sở', _profile?['campus']),
                            _row(Icons.class_rounded, 'GV chủ nhiệm', _profile?['homeroomTeacher']),
                          ]),
                          const SizedBox(height: TSizes.md),
                          _card('Liên lạc', [
                            _row(Icons.phone_android, 'SĐT', _profile?['phone']),
                            _row(Icons.email, 'Email', _profile?['email']),
                            _row(Icons.home, 'Địa chỉ', _profile?['address']),
                            _row(Icons.cake, 'Ngày sinh', _fmtDate(_profile?['dateOfBirth'])),
                            _row(Icons.tag, 'MSHS', _profile?['studentCode']),
                          ]),
                          const SizedBox(height: TSizes.xl),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: TSizes.lg),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: widget.onLogout,
                                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                                label: const Text('Đăng xuất',
                                    style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: TSizes.fontSizeLg,
                                        fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: TSizes.xl),
                        ],
                      ),
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

  Widget _card(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: TSizes.lg),
      padding: const EdgeInsets.all(TSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TColors.textTitle)),
          const SizedBox(height: TSizes.md),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: TColors.iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: TColors.textSubtitle)),
                const SizedBox(height: 2),
                Text(value ?? '--',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}