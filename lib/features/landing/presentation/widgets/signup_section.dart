// Signup Section
//
// Early-access capture form. Form state lives exclusively in
// LaunchSignupBloc — widgets only dispatch events and render state.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/landing_content.dart';
import '../blocs/launch_signup/launch_signup_bloc.dart';
import '../landing_palette.dart';

class SignupSection extends StatelessWidget {
  final LandingSignup signup;
  final String defaultInterest;

  const SignupSection({
    super.key,
    required this.signup,
    required this.defaultInterest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: LandingPalette.heroGradient,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            children: [
              Text(
                signup.headline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: LandingPalette.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                signup.copy,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: LandingPalette.textSecondary,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              BlocBuilder<LaunchSignupBloc, LaunchSignupState>(
                builder: (context, state) {
                  if (state.isSuccess) {
                    return _SuccessCard(signup: signup);
                  }
                  return _Form(
                    signup: signup,
                    defaultInterest: defaultInterest,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  final LandingSignup signup;
  final String defaultInterest;

  const _Form({required this.signup, required this.defaultInterest});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LaunchSignupBloc, LaunchSignupState>(
      builder: (context, state) {
        final bloc = context.read<LaunchSignupBloc>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              onChanged: (v) => bloc.add(SignupNameChanged(v)),
              style: const TextStyle(color: LandingPalette.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: LandingPalette.textSecondary),
                filled: true,
                fillColor: LandingPalette.inputFill,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: LandingPalette.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: LandingPalette.border),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              onChanged: (v) => bloc.add(SignupEmailChanged(v)),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: LandingPalette.textPrimary),
              decoration: InputDecoration(
                labelText: 'Email Address',
                labelStyle: const TextStyle(
                  color: LandingPalette.textSecondary,
                ),
                filled: true,
                fillColor: LandingPalette.inputFill,
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: LandingPalette.border),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: LandingPalette.border),
                ),
                errorText: state.error,
                errorStyle: const TextStyle(color: LandingPalette.highlight),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: defaultInterest,
              dropdownColor: LandingPalette.surfaceElevated,
              style: const TextStyle(
                color: LandingPalette.textPrimary,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                labelText: 'Interest',
                labelStyle: TextStyle(color: LandingPalette.textSecondary),
                filled: true,
                fillColor: LandingPalette.inputFill,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: LandingPalette.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: LandingPalette.border),
                ),
              ),
              items: signup.interestOptions
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (v) =>
                  bloc.add(SignupInterestChanged(v ?? defaultInterest)),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: LandingPalette.accent,
                foregroundColor: LandingPalette.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              onPressed: state.isSubmitting
                  ? null
                  : () => bloc.add(SignupSubmitted(signup)),
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: LandingPalette.background,
                      ),
                    )
                  : Text(signup.button),
            ),
          ],
        );
      },
    );
  }
}

class _SuccessCard extends StatelessWidget {
  final LandingSignup signup;

  const _SuccessCard({required this.signup});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: LandingPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LandingPalette.accent),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle,
            color: LandingPalette.accent,
            size: 48,
          ),
          const SizedBox(height: 14),
          Text(
            signup.successTitle,
            style: const TextStyle(
              color: LandingPalette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            signup.successBody,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: LandingPalette.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
