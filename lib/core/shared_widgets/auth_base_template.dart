// Auth Base Template — Shared multi-tenant login layout wrapper
//
// A single, highly scannable, adaptive login wrapper used by all 5 login
// endpoints.  Under 100 lines by delegating contextual rendering (logo,
// workspace banner, color profile) to `BrandingConfig` and reusing existing
// `PrimaryButton`, `AppColors`, and `TextStyles` from the shared layer.
//
// Usage from any login screen:
//   AuthBaseTemplate(
//     brand: BrandingConfig.forPanel(UserPanel.factory),
//     formKey: _formKey,
//     children: [ /* email field, password field, ... */ ],
//     onSubmit: () => bloc.add(LoginRequested(...)),
//     isLoading: state is AuthLoading,
//   );

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/core/theme/branding_config.dart';
import 'package:trace_odd/shared/theme/colors.dart';

import 'package:trace_odd/shared/widgets/buttons/primary_button.dart';

class AuthBaseTemplate extends StatelessWidget {
  final BrandProfile brand;
  final GlobalKey<FormState> formKey;
  final List<Widget> children; // Form fields injected by caller
  final VoidCallback onSubmit;
  final bool isLoading;
  final Widget? footer; // Optional: forgot-password link, security notice, etc.

  const AuthBaseTemplate({
    super.key,
    required this.brand,
    required this.formKey,
    required this.children,
    required this.onSubmit,
    this.isLoading = false,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [brand.primaryColor.withValues(alpha: 0.08), Colors.white],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Icon badge ──────────────────────────
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: brand.primaryColor,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: brand.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      brand.fallbackIcon,
                      size: 40.w,
                      color: Colors.white,
                    ),
                  ),
                  Gap(16.h),

                  // ── Title ──────────────────────────────
                  Text(
                    brand.enterpriseTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: brand.primaryColor,
                    ),
                  ),
                  Gap(8.h),
                  Text(
                    brand.workspaceBanner,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.gray600),
                  ),
                  Gap(32.h),

                  // ── Form fields (injected) ─────────────
                  ...children,
                  Gap(24.h),

                  // ── Submit button ──────────────────────
                  PrimaryButton(
                    text: 'Sign In',
                    onPressed: onSubmit,
                    isLoading: isLoading,
                    backgroundColor: brand.primaryColor,
                  ),

                  // ── Footer (forgot password, etc.) ─────
                  if (footer != null) ...[Gap(16.h), footer!],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
