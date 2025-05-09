import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/widgets/show_floating_toast.dart';
import 'package:flutter/material.dart';

class ReportPage extends StatefulWidget {
  String id;
  String type;

  ReportPage({super.key, required this.id, required this.type});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<String> storeReasons = [
    'Fake or scam store',
    'Inappropriate content',
    'Fake products',
    'Bad customer service',
    'Other'
  ];

  final List<String> riderReasons = [
    'Reckless driving',
    'Unprofessional behavior',
    'Late delivery',
    'Incorrect order handling',
    'Other'
  ];

  /// Dynamically returns the appropriate list of reasons
  List<String> get reportReasons => widget.type == 'store' ? storeReasons : riderReasons;

  String? selectedReason;
  final TextEditingController otherReasonController = TextEditingController();

  @override
  void dispose() {
    otherReasonController.dispose();
    super.dispose();
  }

  void _submitReport() async {
    if (_formKey.currentState!.validate()) {
      showFloatingToast(context: context, message: 'Submitting report...');
      String reason = selectedReason!;
      if (reason == 'Other') {
        reason = otherReasonController.text;
      }
      try {
        await firebaseFirestore
            .collection('reports')
            .doc(widget.id)
            .set({
          '${widget.type}ID': widget.id,
          'type': widget.type,
          'timestamp': Timestamp.now(),
          'reason': reason,
        });
        Navigator.pop(context);

        showFloatingToast(
            context: context,
            message: 'Report submitted.',
            backgroundColor: Colors.green);
      } catch (e) {
        showFloatingToast(
            context: context, message: 'Error submitting report.');
      }
    }
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 16,
      ),
      hintText: hint,
      hintStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        fontSize: 12,
      ),
      contentPadding:
      const EdgeInsets.symmetric(vertical: 10, horizontal: 12.0),
      isDense: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(24),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Page'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/report_store.png',
              height: 200,
              width: 200,
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reason', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: _inputDecoration('Select a reason'),
                      value: selectedReason,
                      items: reportReasons.map((reason) {
                        return DropdownMenuItem<String>(
                          value: reason,
                          child: Text(reason, style: const TextStyle(fontWeight: FontWeight.normal),),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                      validator: (value) =>
                      value == null ? 'Please select a reason' : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (selectedReason == 'Other')
                    TextFormField(
                      controller: otherReasonController,
                      decoration:
                      _inputDecoration('Enter your reason', hint: 'Type your reason here'),
                      maxLines: 3,
                      validator: (value) {
                        if (selectedReason == 'Other' &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Please enter your reason';
                        }
                        return null;
                      },
                    ),
                  if (selectedReason == 'Other')
                    const SizedBox(height: 24,),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Theme.of(context).colorScheme.primary,
                        foregroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
