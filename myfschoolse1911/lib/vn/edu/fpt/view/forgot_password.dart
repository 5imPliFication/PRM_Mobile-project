import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/spacing_styles.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _isSubmitted = false;

  void _handleSubmit() {
    setState(() {
      _isSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: SpacingStyles.paddingWithAppBarHeight,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(TSizes.lg),
                        decoration: BoxDecoration(
                          color: TColors.cardBackground,
                          borderRadius: BorderRadius.circular(24.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _isSubmitted
                            ? _buildSuccessContent()
                            : _buildFormContent(),
                      ),
                    ),
                  ),
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: TSizes.lg),
                child: Text(
                  '© 2023 FPT EDUCATION. ALL RIGHTS RESERVED.',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: TColors.textSubtitle.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Back button row
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: TColors.textTitle),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        const SizedBox(height: TSizes.md),

        // Lock icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: TColors.bgGradientTop,
            shape: BoxShape.circle,
            border: Border.all(color: TColors.primary.withOpacity(0.3), width: 2),
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            size: 40,
            color: TColors.primary,
          ),
        ),
        const SizedBox(height: TSizes.lg),

        // Title
        const Text(
          'Quên mật khẩu?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: TColors.textTitle,
          ),
        ),
        const SizedBox(height: TSizes.sm),

        // Subtitle
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: TSizes.sm),
          child: Text(
            'Nhập số điện thoại đã đăng ký để nhận mã xác nhận đặt lại mật khẩu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: TSizes.fontSizeSm,
              color: TColors.textSubtitle,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: TSizes.xl),

        // Phone number input
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Số điện thoại',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: TColors.textSubtitle,
                fontSize: TSizes.fontSizeSm,
              ),
            ),
            const SizedBox(height: TSizes.sm),
            TextFormField(
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: 'Nhập số điện thoại của bạn',
                prefixIcon: const Icon(Icons.phone, color: TColors.iconColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: TColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: TColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: TColors.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: TSizes.xl),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Gửi mã xác nhận',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: TSizes.fontSizeLg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.send_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: TSizes.lg),

        // Back to login
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Nhớ mật khẩu? ',
              style: TextStyle(color: TColors.textSubtitle),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'Đăng nhập',
                style: TextStyle(
                  color: TColors.textTitle,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: TSizes.lg),

        // Success icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3), width: 2),
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 48,
            color: Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(height: TSizes.lg),

        // Title
        const Text(
          'Đã gửi mã xác nhận!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: TColors.textTitle,
          ),
        ),
        const SizedBox(height: TSizes.sm),

        // Subtitle
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: TSizes.sm),
          child: Text(
            'Vui lòng kiểm tra tin nhắn SMS để nhận mã xác nhận đặt lại mật khẩu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: TSizes.fontSizeSm,
              color: TColors.textSubtitle,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: TSizes.xl),

        // Back to login button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Quay lại đăng nhập',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: TSizes.fontSizeLg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: TSizes.lg),
      ],
    );
  }
}
