import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/images.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/spacing_styles.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/sizes.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/common/colors.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/forgot_password.dart';
import 'package:myfschoolse1911/vn/edu/fpt/view/home.dart';
import 'package:myfschoolse1911/vn/edu/fpt/api_service.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Biến trạng thái để theo dõi việc ẩn/hiện mật khẩu
  bool _isObscure = true;
  // Biến trạng thái cho Checkbox Remember me
  bool _rememberMe = false;
  bool _isLoading = false;
  // Controller để lấy giá trị số điện thoại
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Logo
                            Image(
                              height: 100,
                              image: const AssetImage(Images.fptLogo),
                            ),
                            const SizedBox(height: TSizes.md),

                            // Title & Subtitle
                            const Text(
                              'MyFPTSchool',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: TColors.textTitle,
                              ),
                            ),
                            const SizedBox(height: TSizes.sm),
                            const Text(
                              'Chào mừng học sinh',
                              style: TextStyle(
                                fontSize: TSizes.fontSizeMd,
                                color: TColors.textSubtitle,
                              ),
                            ),
                            const SizedBox(height: TSizes.xl),

                            // Username
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
                                  controller: _phoneController,
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
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: TSizes.md),

                            // Password
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Mật khẩu',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: TColors.textSubtitle,
                                    fontSize: TSizes.fontSizeSm,
                                  ),
                                ),
                                const SizedBox(height: TSizes.sm),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _isObscure, // Sử dụng biến trạng thái ở đây
                                  decoration: InputDecoration(
                                    hintText: 'Nhập mật khẩu của bạn',
                                    prefixIcon: const Icon(Icons.key, color: TColors.iconColor),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        color: TColors.iconColor,
                                      ),
                                      onPressed: () {
                                        // Gọi setState để cập nhật lại giao diện khi đổi trạng thái
                                        setState(() {
                                          _isObscure = !_isObscure;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: TColors.border),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: TColors.border),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Remember me & Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Remember me Checkbox
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: TColors.primary,
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: TSizes.sm),
                                    const Text(
                                      'Nhớ mật khẩu',
                                      style: TextStyle(
                                        color: TColors.textSubtitle,
                                        fontSize: TSizes.fontSizeSm,
                                      ),
                                    ),
                                  ],
                                ),
                                // Forgot Password Button
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Quên mật khẩu?',
                                    style: TextStyle(
                                      color: TColors.textLink,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: TSizes.sm),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : () async {
                                  if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
                                    );
                                    return;
                                  }

                                  setState(() => _isLoading = true);

                                  try {
                                    final data = await apiService.login(_phoneController.text, _passwordController.text);
                                    
                                    if (mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => HomeScreen(phone: data['phone']),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isLoading = false);
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: TColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: _isLoading 
                                  ? const SizedBox(
                                      width: 24, 
                                      height: 24, 
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                    )
                                  : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Đăng nhập',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: TSizes.fontSizeLg,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.login, color: Colors.white),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: TSizes.lg),

                            // // Divider OR
                            // Row(
                            //   children: [
                            //     const Expanded(child: Divider(color: TColors.border)),
                            //     Padding(
                            //       padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
                            //       child: Text(
                            //         'Hoặc',
                            //         style: TextStyle(
                            //           color: TColors.textSubtitle.withOpacity(0.8),
                            //           fontWeight: FontWeight.bold,
                            //           fontSize: 12,
                            //         ),
                            //       ),
                            //     ),
                            //     const Expanded(child: Divider(color: TColors.border)),
                            //   ],
                            // ),
                            // const SizedBox(height: TSizes.lg),
                            //
                            // // Google Login Button
                            // SizedBox(
                            //   width: double.infinity,
                            //   height: 50,
                            //   child: OutlinedButton(
                            //     onPressed: () {},
                            //     style: OutlinedButton.styleFrom(
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(12),
                            //       ),
                            //       side: const BorderSide(color: TColors.border),
                            //     ),
                            //     child: Row(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       children: [
                            //         Image.asset(Images.googleLogo, height: 24),
                            //         const SizedBox(width: 12),
                            //         const Text(
                            //           'Sign in with Google',
                            //           style: TextStyle(
                            //             color: Colors.black87,
                            //             fontSize: TSizes.fontSizeMd,
                            //             fontWeight: FontWeight.w500,
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            // const SizedBox(height: TSizes.xl),

                            // Contact Support
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Cần hỗ trợ? ',
                                  style: TextStyle(color: TColors.textSubtitle),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'Liên hệ hỗ trợ',
                                    style: TextStyle(
                                      color: TColors.textTitle, // Dark brown/orange
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
}