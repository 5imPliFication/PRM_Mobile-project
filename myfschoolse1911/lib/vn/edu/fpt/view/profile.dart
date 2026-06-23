import 'package:flutter/material.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/login.dart';

class ProfileScreen extends StatelessWidget {
  final String phone;

  const ProfileScreen({super.key, this.phone = ''});

  @override
  Widget build(BuildContext context) {
    final displayPhone = phone.isNotEmpty ? phone : '0912345678';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: TColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Avatar & Basic Info Card
              _buildAvatarCard(displayPhone),
              const SizedBox(height: TSizes.md),

              // Academic Information Card
              _buildAcademicCard(),
              const SizedBox(height: TSizes.md),

              // Contact Info Card
              _buildContactCard(displayPhone),
              const SizedBox(height: TSizes.md),

              // Parent Info Card
              _buildParentCard(),
              const SizedBox(height: TSizes.xl),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.lg),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    label: const Text(
                      'Đăng xuất',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: TSizes.fontSizeLg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TSizes.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarCard(String phone) {
    return Container(
      margin: const EdgeInsets.all(TSizes.lg),
      padding: const EdgeInsets.symmetric(vertical: TSizes.lg, horizontal: TSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
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
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFFFFCC80),
                    child: Text(
                      'A',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF36F21),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: TSizes.md),
          const Text(
            'Nguyễn Văn A',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: TColors.textTitle,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Học sinh • Lớp 11A1',
            style: TextStyle(
              fontSize: TSizes.fontSizeSm,
              color: TColors.textSubtitle,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: TSizes.md),
          const Divider(),
          const SizedBox(height: TSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('MSHS', 'FPT08921'),
              Container(
                height: 30,
                width: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
              _buildMiniStat('Trạng thái', 'Đang học'),
              Container(
                height: 30,
                width: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
              _buildMiniStat('Khóa', 'K19'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: TColors.textSubtitle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
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
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.school, color: TColors.primary),
              SizedBox(width: 8),
              Text(
                'Thông tin học tập',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TColors.textTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.md),
          const Divider(),
          _buildInfoRow(Icons.account_tree_rounded, 'Ngành học', 'Phổ thông chất lượng cao'),
          _buildInfoRow(Icons.calendar_month_rounded, 'Niên khóa', '2023 - 2026'),
          _buildInfoRow(Icons.location_city_rounded, 'Cơ sở', 'FPT School Cần Thơ'),
          _buildInfoRow(Icons.class_rounded, 'Giáo viên chủ nhiệm', 'Cô Trần Thị C'),
        ],
      ),
    );
  }

  Widget _buildContactCard(String phone) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: TSizes.lg),
      padding: const EdgeInsets.all(TSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.contact_mail, color: TColors.primary),
              SizedBox(width: 8),
              Text(
                'Thông tin liên lạc',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TColors.textTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.md),
          const Divider(),
          _buildInfoRow(Icons.phone_android, 'Số điện thoại', phone),
          _buildInfoRow(Icons.email, 'Email cá nhân', 'anv.se191101@fpt.edu.vn'),
          _buildInfoRow(Icons.home, 'Địa chỉ', '123 Đường 3/2, Ninh Kiều, Cần Thơ'),
          _buildInfoRow(Icons.cake, 'Ngày sinh', '15 / 08 / 2008'),
        ],
      ),
    );
  }

  Widget _buildParentCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: TSizes.lg),
      padding: const EdgeInsets.all(TSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.people_alt, color: TColors.primary),
              SizedBox(width: 8),
              Text(
                'Thông tin phụ huynh',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TColors.textTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.md),
          const Divider(),
          _buildInfoRow(Icons.person, 'Họ tên cha/mẹ', 'Nguyễn Văn B (Cha)'),
          _buildInfoRow(Icons.phone, 'Số điện thoại phụ huynh', '0912987654'),
          _buildInfoRow(Icons.work, 'Nghề nghiệp', 'Kỹ sư'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
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
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: TColors.textSubtitle,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
