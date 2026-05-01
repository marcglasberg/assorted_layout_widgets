import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() =>
    runApp(const MaterialApp(home: EmailScreen(), debugShowCheckedModeBanner: false));

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendCode() {
    final email = _emailController.text.trim();
    if (!Email(email).isValid()) {
      setState(() => _emailError = 'Please enter a valid email address');
      return;
    }
    setState(() => _emailError = null);
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => OtpScreen(email: email)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text('OtpCodeVerificationField Example'),
      ),
      body: Box(
        color: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Text(
                'Type your email',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                inputFormatters: [EmailTextInputFormatter()],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Email',
                  hintText: 'you@example.com',
                  border: const OutlineInputBorder(),
                  errorText: _emailError,
                ),
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
                onSubmitted: (_) => _sendCode(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _sendCode,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Send me a verification code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({required this.email, super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late final DateTime _codeIssuedAt;

  @override
  void initState() {
    super.initState();
    _codeIssuedAt = DateTime.now();
  }

  Future<bool> _verifyCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 600));
    //
    // If the code is wrong, throw an error to open the Retry button.
    // Here we simulate having no internet connection.
    if (code == '222222') {
      throw Exception('No internet connection');
    }

    // If the code is wrong, throw an error to open the Retry button.
    // Here we simulate having a server error.
    if (code == '333333') {
      throw Exception('Server error');
    }

    // If the code is correct, navigate to the signed-in screen
    // and return true to close the keyboard.
    if (code == '111111') {
      if (!mounted) return true;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute<void>(builder: (_) => const SignedInScreen()));
      return true;
    }

    // For any other code, return false to keep the keyboard open and show an error.
    // Here we simulate the user typing a wrong code (or code expired).
    return false;
  }

  void _onExpiredGoBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text('Verify your code'),
      ),
      body: Box(
        color: Colors.yellow[50]!,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(
              'A verification code was sent to ${widget.email}',
              style: const TextStyle(fontSize: 18, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _otp(),
            const Spacer(),
            const Text(
              '111111 simulates a valid code.\n'
              '222222 simulates failing because of no internet (Retry).\n'
              '333333 simulates failing because of a server error (Retry).\n'
              'Any other code simulates the user typing the wrong code.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _otp() {
    return OtpCodeVerificationField(
      autoFocus: true,
      codeType: OtpCodeType.numbersOnly,
      codeLetterCasing: null,
      codeLetterSet: null,
      countdownStartDateTime: _codeIssuedAt,
      countdownDuration: const Duration(seconds: 17),
      onSubmit: _verifyCode,
      onExpiredGoBack: _onExpiredGoBack,
      digitTextStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      buttonBackgroundColor: Colors.indigo,
      buttonTextColor: Colors.white,
      countdownTextStyle: const TextStyle(color: Colors.grey),
    );
  }
}

class SignedInScreen extends StatelessWidget {
  const SignedInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text('Welcome'),
        automaticallyImplyLeading: false,
      ),
      body: Box(
        color: Colors.red[50]!,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'You have been signed in',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(builder: (_) => const EmailScreen()),
                  (route) => false,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
