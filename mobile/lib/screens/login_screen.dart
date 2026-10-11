import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import '../utils/routes.dart';
import '../utils/validators.dart';
import '../widgets/app_background.dart';
import '../widgets/common.dart';
import '../widgets/logo_mark.dart';

// Login pengunjung (simulasi, tanpa server): email dan password dicek dengan akun demo.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // Tombol Masuk: validasi form dulu, lalu cek akun (jeda kecil seperti menunggu server).
  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    if (AppState.instance.login(_email.text, _password.text)) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else {
      setState(() {
        _loading = false;
        _error = 'Email atau password salah. Coba lagi.';
      });
    }
  }

  // Mengisi otomatis akun demo untuk presentasi.
  void _fillDemo() {
    _email.text = DummyData.demoEmail;
    _password.text = DummyData.demoPassword;
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: ResponsiveBody(padding: const EdgeInsets.fromLTRB(24, 40, 24, 24), children: [
          const Center(child: LogoMark(size: 72, ring: true)),
          const SizedBox(height: 14),
          Center(child: Text('Sumber Sira', style: AppTheme.display(26))),
          const SizedBox(height: 28),
          Text('Masuk dulu, yuk', style: AppTheme.display(22)),
          const SizedBox(height: 6),
          Text('Masuk untuk membeli tiket online dan melihat keramaian.', style: TextStyle(fontSize: 12, color: AppColors.white(.75))),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(hintText: 'Email', prefixIcon: Icon(Icons.mail_outline, size: 18)),
                validator: Validators.email,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: _hidePassword,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline, size: 18),
                  suffixIcon: IconButton(
                    tooltip: _hidePassword ? 'Tampilkan password' : 'Sembunyikan password',
                    icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                    onPressed: () => setState(() => _hidePassword = !_hidePassword),
                  ),
                ),
                validator: Validators.password,
              ),
            ]),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.coral, fontSize: 12)),
          ],
          const SizedBox(height: 20),
          PrimaryButton(label: 'Masuk', icon: Icons.arrow_forward, loading: _loading, onPressed: _submit),
          const SizedBox(height: 20),
          GlassCard(
            color: AppColors.leaf.withValues(alpha: .15),
            child: Row(children: [
              const Icon(Icons.auto_awesome, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Akun demo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('${DummyData.demoEmail}\n${DummyData.demoPassword}', style: AppTheme.mono(10, color: AppColors.white(.75))),
                ]),
              ),
              TextButton(onPressed: _fillDemo, child: const Text('Isi otomatis', style: TextStyle(color: Colors.white))),
            ]),
          ),
        ]),
      ),
    );
  }
}
