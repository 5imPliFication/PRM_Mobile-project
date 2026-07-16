import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/login.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/link_parent_screen.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;

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
      final p = await apiService.getProfile();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
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
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _buildAvatarCard(),
                          const SizedBox(height: TSizes.md),
                          _buildAcademicCard(),
                          const SizedBox(height: TSizes.md),
                          _buildContactCard(),
                          const SizedBox(height: TSizes.md),
                          _buildParentCard(),
                          const SizedBox(height: TSizes.xl),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: TSizes.lg),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: _logout,
                                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                                label: const Text('Đăng xuất',
                                    style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: TSizes.fontSizeLg,
                                        fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 56, color: TColors.iconColor),
          const SizedBox(height: TSizes.md),
          Text(_error ?? '', textAlign: TextAlign.center,
              style: const TextStyle(color: TColors.textSubtitle)),
          const SizedBox(height: TSizes.md),
          ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
        ],
      ),
    );
  }

  List<dynamic>? get _parents => _profile?['parents'] as List<dynamic>?;
  String get _name => _profile?['fullName'] as String? ?? 'Học sinh';
  String get _className => _profile?['className'] as String? ?? '';
  String get _phone => _profile?['phone'] as String? ?? '--';

  void _logout() async {
    await apiService.logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildAvatarCard() {
    final initial = _name.isNotEmpty ? _name.substring(0, 1).toUpperCase() : 'A';
    return Container(
      margin: const EdgeInsets.all(TSizes.lg),
      padding: const EdgeInsets.symmetric(vertical: TSizes.lg, horizontal: TSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: TColors.primary, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFFFCC80),
                    child: Text(initial,
                        style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF36F21))),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: TSizes.md),
          Text(_name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: TColors.textTitle)),
          const SizedBox(height: 4),
          Text('Học sinh • Lớp $_className',
              style: const TextStyle(
                  fontSize: TSizes.fontSizeSm,
                  color: TColors.textSubtitle,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: TSizes.md),
          const Divider(),
          const SizedBox(height: TSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('MSHS', _profile?['studentCode'] as String? ?? '--'),
              Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.3)),
              _buildMiniStat('Trạng thái', _profile?['status'] as String? ?? '--'),
              Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.3)),
              _buildMiniStat('Niên khóa', _profile?['academicYear'] as String? ?? '--'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: TColors.textSubtitle)),
        const SizedBox(height: 4),
        Text(value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
      ],
    );
  }

  Widget _buildAcademicCard() {
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
          const Row(
            children: [
              Icon(Icons.school, color: TColors.primary),
              SizedBox(width: 8),
              Text('Thông tin học tập',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TColors.textTitle)),
            ],
          ),
          const SizedBox(height: TSizes.md),
          const Divider(),
          _buildInfoRow(Icons.account_tree_rounded, 'Ngành học', _profile?['program'] as String?),
          _buildInfoRow(Icons.calendar_month_rounded, 'Niên khóa', _profile?['academicYear'] as String?),
          _buildInfoRow(Icons.location_city_rounded, 'Cơ sở', _profile?['campus'] as String?),
          _buildInfoRow(Icons.class_rounded, 'Giáo viên chủ nhiệm', _profile?['homeroomTeacher'] as String?),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
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
          const Row(
            children: [
              Icon(Icons.contact_mail, color: TColors.primary),
              SizedBox(width: 8),
              Text('Thông tin liên lạc',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TColors.textTitle)),
            ],
          ),
          const SizedBox(height: TSizes.md),
          const Divider(),
          _buildInfoRow(Icons.phone_android, 'Số điện thoại', _phone),
          _buildInfoRow(Icons.email, 'Email', _profile?['email'] as String?),
          _buildInfoRow(Icons.home, 'Địa chỉ', _profile?['address'] as String?),
          _buildInfoRow(Icons.cake, 'Ngày sinh', _fmtDate(_profile?['dateOfBirth'])),
        ],
      ),
    );
  }

  Widget _buildParentCard() {
    final parents = _parents;
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
          const Row(
            children: [
              Icon(Icons.people_alt, color: TColors.primary),
              SizedBox(width: 8),
              Text('Thông tin phụ huynh',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TColors.textTitle)),
            ],
          ),
          const SizedBox(height: TSizes.md),
          const Divider(),
          if (parents == null || parents.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text('Chưa có thông tin phụ huynh',
                  style: TextStyle(color: TColors.textSubtitle)),
            )
          else
            ...parents.map((p) {
              final rel = p['relationship'] as String?;
              final name = p['fullName'] as String? ?? '--';
              return _buildInfoRow(
                  Icons.person, 'Họ tên phụ huynh', rel != null ? '$name ($rel)' : name);
            }),
          if (parents != null && parents.isNotEmpty)
            _buildInfoRow(Icons.phone, 'SĐT phụ huynh', (parents.first)['phone'] as String?),
          if (parents != null && parents.isNotEmpty)
            _buildInfoRow(Icons.work, 'Nghề nghiệp', (parents.first)['occupation'] as String?),
          const SizedBox(height: TSizes.md),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () async {
                await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const LinkParentScreen()),
                );
                _load();
              },
              icon: const Icon(Icons.link_rounded, color: TColors.primary),
              label: const Text('Mời liên kết phụ huynh',
                  style: TextStyle(color: TColors.primary, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
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