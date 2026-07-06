// Add Staff Dialog — shared form for adding drivers/conductors
// Pure UI widget — no setState for business logic.
// Returns a Map<String, dynamic> with the form data on save.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddStaffDialog extends StatefulWidget {
  final String title; // e.g. 'Add Bus Driver' or 'Add Conductor'

  const AddStaffDialog({super.key, required this.title});

  /// Shows the dialog and returns the form data map, or null if cancelled.
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required String title,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AddStaffDialog(title: title),
    );
  }

  @override
  State<AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<AddStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _license = TextEditingController();
  final _password = TextEditingController();
  final _email = TextEditingController();
  final _cnic = TextEditingController();
  final _address = TextEditingController();
  final _plate = TextEditingController();
  final _salary = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _license.dispose();
    _password.dispose();
    _email.dispose();
    _cnic.dispose();
    _address.dispose();
    _plate.dispose();
    _salary.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, {
      'name': _name.text.trim(),
      'phone': _phone.text.trim(),
      'license_number': _license.text.trim(),
      'password': _password.text,
      if (_email.text.isNotEmpty) 'email': _email.text.trim(),
      if (_cnic.text.isNotEmpty) 'cnic': _cnic.text.trim(),
      if (_address.text.isNotEmpty) 'address': _address.text.trim(),
      if (_plate.text.isNotEmpty) 'vehicle_plate': _plate.text.trim(),
      if (_salary.text.isNotEmpty) 'salary': _salary.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1B2838),
      title: Text(
        widget.title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(
                _name,
                'Full Name *',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 10.h),
              _field(
                _phone,
                'Phone *',
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 10.h),
              _field(
                _license,
                'License Number *',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 10.h),
              _field(
                _password,
                'Password *',
                obscure: true,
                validator: (v) =>
                    v == null || v.length < 4 ? 'Min 4 chars' : null,
              ),
              SizedBox(height: 10.h),
              _field(_email, 'Email', keyboardType: TextInputType.emailAddress),
              SizedBox(height: 10.h),
              _field(_cnic, 'CNIC'),
              SizedBox(height: 10.h),
              _field(_address, 'Address', maxLines: 2),
              SizedBox(height: 10.h),
              _field(_plate, 'Vehicle Plate'),
              SizedBox(height: 10.h),
              _field(_salary, 'Salary', keyboardType: TextInputType.number),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B4D8),
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    bool obscure = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF556677)),
        filled: true,
        fillColor: const Color(0xFF0D1B2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2A3A4A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2A3A4A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF00B4D8)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      validator: validator,
    );
  }
}
