part of 'authentication_feature.dart';


/// SignUpWidget displays signup form with animations
class SignUpWidget extends StatelessWidget {
  final VoidCallback onLoginTap;
  final VoidCallback onSignUp;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController nameController;
  final GlobalKey<FormState> formKey;
  final bool isLoading;

  const SignUpWidget({
    super.key,
    required this.onLoginTap,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.nameController,
    required this.onSignUp,
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
            'Create an\nAccount',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ).animate().fade(duration: const Duration(milliseconds: 500)).slideX(
              begin: -0.2, end: 0, duration: const Duration(milliseconds: 400)),
          const SizedBox(height: 40),
          AnimatedInputField(
            controller: nameController,
            label: 'Full Name',
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          AnimatedInputField(
            controller: emailController,
            label: 'Email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              } else if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              } else if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          AnimatedInputField(
            controller: confirmPasswordController,
            label: 'Confirm Password',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              } else if (value != passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          AnimatedFilledButton(
            onPressed: onSignUp,
            label: 'Sign Up',
            isLoading: isLoading,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already have an account?"),
              TextButton(
                onPressed: onLoginTap,
                child: Text(
                  'Login',
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