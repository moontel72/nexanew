// Validation Helper for NexaTrace System
// This file contains validation utilities for forms and inputs

import 'package:flutter/material.dart';

class ValidationHelper {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  // Phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-()]'), ''))) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < 2) {
      return '$fieldName must be at least 2 characters long';
    }

    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');

    if (!nameRegex.hasMatch(value)) {
      return '$fieldName can only contain letters and spaces';
    }

    return null;
  }

  // Company name validation
  static String? validateCompanyName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Company name is required';
    }

    if (value.length < 2) {
      return 'Company name must be at least 2 characters long';
    }

    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }

    if (value.length < 10) {
      return 'Address must be at least 10 characters long';
    }

    return null;
  }

  // Product name validation
  static String? validateProductName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Product name is required';
    }

    if (value.length < 3) {
      return 'Product name must be at least 3 characters long';
    }

    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }

    final priceRegex = RegExp(r'^\d+(\.\d{1,2})?$');

    if (!priceRegex.hasMatch(value)) {
      return 'Please enter a valid price';
    }

    final price = double.tryParse(value);

    if (price == null || price <= 0) {
      return 'Price must be greater than 0';
    }

    return null;
  }

  // Quantity validation
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quantity is required';
    }

    final quantityRegex = RegExp(r'^\d+$');

    if (!quantityRegex.hasMatch(value)) {
      return 'Please enter a valid quantity';
    }

    final quantity = int.tryParse(value);

    if (quantity == null || quantity <= 0) {
      return 'Quantity must be greater than 0';
    }

    return null;
  }

  // Code batch size validation
  static String? validateCodeBatchSize(String? value, {int maxLimit = 100000}) {
    if (value == null || value.isEmpty) {
      return 'Batch size is required';
    }

    final batchRegex = RegExp(r'^\d+$');

    if (!batchRegex.hasMatch(value)) {
      return 'Please enter a valid number';
    }

    final batchSize = int.tryParse(value);

    if (batchSize == null || batchSize <= 0) {
      return 'Batch size must be greater than 0';
    }

    if (batchSize > maxLimit) {
      return 'Batch size cannot exceed $maxLimit';
    }

    return null;
  }

  // Date validation
  static String? validateDate(String? value, {String fieldName = 'Date'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

    if (!dateRegex.hasMatch(value)) {
      return 'Please enter date in YYYY-MM-DD format';
    }

    try {
      final date = DateTime.parse(value);
      if (date.isAfter(DateTime.now())) {
        return '$fieldName cannot be in the future';
      }
    } catch (e) {
      return 'Please enter a valid date';
    }

    return null;
  }

  // Expiry date validation
  static String? validateExpiryDate(
    String? value,
    DateTime? manufacturingDate,
  ) {
    if (value == null || value.isEmpty) {
      return 'Expiry date is required';
    }

    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

    if (!dateRegex.hasMatch(value)) {
      return 'Please enter date in YYYY-MM-DD format';
    }

    try {
      final expiryDate = DateTime.parse(value);

      if (expiryDate.isBefore(DateTime.now())) {
        return 'Expiry date cannot be in the past';
      }

      if (manufacturingDate != null && expiryDate.isBefore(manufacturingDate)) {
        return 'Expiry date must be after manufacturing date';
      }
    } catch (e) {
      return 'Please enter a valid date';
    }

    return null;
  }

  // Warranty period validation
  static String? validateWarrantyPeriod(String? value) {
    if (value == null || value.isEmpty) {
      return 'Warranty period is required';
    }

    final warrantyRegex = RegExp(r'^\d+$');

    if (!warrantyRegex.hasMatch(value)) {
      return 'Please enter a valid number';
    }

    final warranty = int.tryParse(value);

    if (warranty == null || warranty <= 0) {
      return 'Warranty period must be greater than 0';
    }

    if (warranty > 120) {
      return 'Warranty period cannot exceed 120 months';
    }

    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
      caseSensitive: false,
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // Validate form with multiple fields
  static Map<String, String> validateForm(Map<String, String> formData) {
    final errors = <String, String>{};

    for (final entry in formData.entries) {
      final fieldName = entry.key;
      final value = entry.value;

      String? error;

      switch (fieldName) {
        case 'email':
          error = validateEmail(value);
          break;
        case 'password':
          error = validatePassword(value);
          break;
        case 'phone':
          error = validatePhoneNumber(value);
          break;
        case 'name':
          error = validateName(value);
          break;
        case 'company_name':
          error = validateCompanyName(value);
          break;
        case 'address':
          error = validateAddress(value);
          break;
        case 'product_name':
          error = validateProductName(value);
          break;
        case 'price':
          error = validatePrice(value);
          break;
        case 'quantity':
          error = validateQuantity(value);
          break;
        default:
          if (fieldName.endsWith('_required')) {
            final cleanFieldName = fieldName.replaceAll('_required', '');
            error = validateRequired(value, fieldName: cleanFieldName);
          }
      }

      if (error != null) {
        errors[fieldName] = error;
      }
    }

    return errors;
  }

  // Check if form is valid
  static bool isFormValid(Map<String, String> formData) {
    return validateForm(formData).isEmpty;
  }

  // Clear validation errors
  static void clearValidationErrors(GlobalKey<FormState> formKey) {
    formKey.currentState?.reset();
  }

  // Show validation error snackbar
  static void showValidationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Show validation success snackbar
  static void showValidationSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
