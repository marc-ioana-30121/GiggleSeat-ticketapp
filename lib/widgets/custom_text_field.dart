// // lib/widgets/custom_text_field.dart
// import 'package:flutter/material.dart';

// class CustomTextField extends StatelessWidget {
//   final String labelText;
//   final TextEditingController? controller;
//   final TextInputType keyboardType;
//   final bool obscureText;
//   final String? Function(String?)? validator;
//   final Function(String?)? onSaved;
//   final Function(String)? onChanged;
//   final Widget? suffixIcon;
//   final int maxLines;

//   const CustomTextField({
//     Key? key,
//     required this.labelText,
//     this.controller,
//     this.keyboardType = TextInputType.text,
//     this.obscureText = false,
//     this.validator,
//     this.onSaved,
//     this.onChanged,
//     this.suffixIcon,
//     this.maxLines = 1,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: labelText,
//           border: OutlineInputBorder(),
//           suffixIcon: suffixIcon,
//         ),
//         keyboardType: keyboardType,
//         obscureText: obscureText,
//         validator: validator,
//         onSaved: onSaved,
//         onChanged: onChanged,
//         maxLines: maxLines,
//       ),
//     );
//   }
// }


// lib/widgets/custom_text_field.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Function(String?)? onSaved;
  final Function(String)? onChanged;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int maxLines;
  final String? hintText;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    Key? key,
    required this.labelText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.hintText,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          contentPadding: contentPadding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        onSaved: onSaved,
        onChanged: onChanged,
        maxLines: maxLines,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}