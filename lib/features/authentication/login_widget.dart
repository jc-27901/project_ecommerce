part of 'authentication_feature.dart';

/// LoginWidget displays login form with animations
class LoginWidget extends StatelessWidget {
  final VoidCallback onSignUpTap;
  final VoidCallback onLogin;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final bool isLoading;

  const LoginWidget({
    super.key,
    required this.onSignUpTap,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    required this.formKey,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'Welcome\nBack',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ).animate().fade(duration: const Duration(milliseconds: 500)).slideX(
              begin: -0.2, end: 0, duration: const Duration(milliseconds: 400)),
          const SizedBox(height: 40),
          AnimatedInputField(
            controller: emailController,
            label: 'Email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          AnimatedInputField(
            controller: passwordController,
            label: 'Password',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              } else if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Implement forgot password functionality
              },
              child: const Text('Forgot Password?'),
            ),
          ).animate().fade(duration: const Duration(milliseconds: 500)),
          const SizedBox(height: 24),
          AnimatedFilledButton(
            onPressed: onLogin,
            label: 'Login',
            isLoading: isLoading,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account?"),
              TextButton(
                onPressed: onSignUpTap,
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ).animate().fade(duration: const Duration(milliseconds: 500)).slideY(
              begin: 0.2, end: 0, duration: const Duration(milliseconds: 400)),
        ],
      ),
    );
  }
}