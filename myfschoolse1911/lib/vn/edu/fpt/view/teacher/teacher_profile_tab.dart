import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';

class TeacherProfileTab extends StatefulWidget {
  final Map<String, dynamic>? profile;
  final String fullName;
  final VoidCallback onLogout;
  const TeacherProfileTab({
    super.key,
    this.profile,
    required this.fullName,
    required this.onLogout,
  });

  @override
  State<TeacherProfileTab> createState() => _TeacherProfileTabState();
}

class _TeacherProfileTabState extends State<TeacherProfileTab> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    if (_profile == null) _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await apiService.getTeacherProfile();
      if (mounted) setState(() => _profile = p);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['fullName'] as String? ?? widget.fullName;
    final specialization = _profile?['specialization'] as String? ?? '--';
    final phone = _profile?['phone'] as String? ?? '--';
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'G';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cá nhân', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          child: _loading && _profile == null
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                      Center(child: Column(children: [
                        const Icon(Icons.cloud_off, size: 56, color: TColors.iconColor),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: TColors.textSubtitle)),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
                      ])),
                    ])
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: TSizes.xl),
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: const Color(0xFFFFCC80),
                            child: Text(initial,
                                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFFF36F21))),
                          ),
                          const SizedBox(height: TSizes.md),
                          Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: TColors.textTitle)),
                          const SizedBox(height: 4),
                          const Text('Giáo viên', style: TextStyle(color: TColors.textSubtitle, fontWeight: FontWeight.w500)),
                          const SizedBox(height: TSizes.lg),
                          _infoCard(title: 'Thông tin', children: [
                            _row(Icons.book, 'Bộ môn', specialization),
                            _row(Icons.phone, 'Số điện thoại', phone),
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
                                    style: TextStyle(color: Colors.redAccent, fontSize: TSizes.fontSizeLg, fontWeight: FontWeight.bold)),
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

  Widget _infoCard({required String title, required List<Widget> children}) {
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

  Widget _row(IconData icon, String label, String value) {
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
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}