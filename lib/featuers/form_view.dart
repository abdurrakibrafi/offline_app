// lib/screens/form_screen.dart
import 'package:flutter/material.dart';
import '../core/network/connectivity_service.dart';
import 'controller/form_sending_controller.dart';
import 'from_list.dart';

class FormScreen extends StatefulWidget {
  final FormSendingController repo;
  final ConnectivityService connectivity;

  const FormScreen({super.key, required this.repo, required this.connectivity});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  bool _isOnline = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    widget.connectivity.checkNow().then((v) => setState(() => _isOnline = v));
    widget.connectivity.onChanged.listen((v) => setState(() => _isOnline = v));
  }

  Future<void> _submit() async {
    if (_name.text.isEmpty || _email.text.isEmpty) return;
    setState(() => _loading = true);

    try {
      await widget.repo.save(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim(),
      );

      _name.clear(); _phone.clear(); _email.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isOnline
              ? 'Server এ পাঠানো হয়েছে'
              : 'Offline এ সংরক্ষিত — net আসলে upload হবে'),
          backgroundColor:
          _isOnline ? Colors.green.shade700 : Colors.orange.shade700,
        ));
      }
    } catch (e) {
      // API fail হলে error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('সমস্যা হয়েছে, আবার চেষ্টা করুন'),
          backgroundColor: Colors.red.shade700,
        ));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Form'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  _isOnline ? Icons.wifi : Icons.wifi_off,
                  size: 16,
                  color: _isOnline ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _email,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit'),
              ),
            ),

            SizedBox(height: 45),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FormList(connectivity: widget.connectivity),
                  ),
                );
              },
              child: const Text('List of Data'),
            ),
          ],
        ),
      ),
    );
  }
}
