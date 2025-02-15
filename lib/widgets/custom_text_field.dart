// import 'package:flutter/material.dart';
//
// class CustomTextField extends StatelessWidget {
//   CustomTextField({
//     super.key,
//     this.controller,
//     this.inputType,
//     this.enabled,
//     this.isObscure,
//     this.labelText,
//     this.validator,
//   });
//
//   final String? labelText;
//   final TextEditingController? controller;
//   TextInputType? inputType = TextInputType.text;
//   bool? enabled = true;
//   bool? isObscure = true;
//   final String? Function(String?)? validator;
//
//   //Validation for email
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       enabled: enabled,
//       controller: controller,
//       keyboardType: inputType,
//       obscureText: isObscure!,
//       decoration: InputDecoration(
//         labelText: labelText,
//         focusedBorder: UnderlineInputBorder(
//             borderSide: BorderSide(color: Theme.of(context).colorScheme.primary,),
//             borderRadius: BorderRadius.circular(30),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
//           borderRadius: BorderRadius.circular(30.0), // Circular border
//         ),
//         errorBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//           borderRadius: BorderRadius.circular(30.0), // Circular border
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
//           borderRadius: BorderRadius.circular(30.0), // Circular border
//         ),
//       ),
//       validator: validator,
//     );
//   }
// }
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  CustomTextField({
    super.key,
    this.controller,
    this.inputType,
    this.enabled,
    this.isObscure,
    this.labelText,
    this.validator,
    this.suffixIcon,
    this.prefixText,
  });

  final String? labelText;
  final TextEditingController? controller;
  TextInputType? inputType = TextInputType.text;
  bool? enabled = true;
  bool? isObscure = true;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final String? prefixText;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {


  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      controller: widget.controller,
      keyboardType: widget.inputType,
      obscureText: widget.isObscure!,
      decoration: InputDecoration(
        prefixText: widget.prefixText,
        suffixIcon: widget.suffixIcon,
        // Smaller label and hint for compact design
        labelText: widget.labelText,
        labelStyle: const TextStyle(
          color: Colors.grey, // Lighter label color
          fontSize: 16, // Smaller label font
        ),
        // Borders with soft, rounded corners
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5, // Thinner focused border
          ),
          borderRadius: BorderRadius.circular(24), // Slightly smaller radius for a more compact look
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), // Subtle border color
            width: 1.5, // Even thinner border for normal state
          ),
          borderRadius: BorderRadius.circular(24), // Slightly smaller radius
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        // Adjusted padding for a more compact field
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12.0), // Reduced padding
        isDense: true, // Reduce height of the text field
        floatingLabelBehavior: FloatingLabelBehavior.never, // Modern floating label behavior
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), // Faded hint text
          fontSize: 12, // Smaller hint text
        ),
      ),
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
