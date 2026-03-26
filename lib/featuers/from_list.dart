import 'package:flutter/material.dart';
import '../core/network/connectivity_service.dart';
import 'controller/form_list_controller.dart';
import 'model/form_list_model.dart';

class FormList extends StatefulWidget {
  final ConnectivityService connectivity;

  const FormList({super.key, required this.connectivity});

  @override
  State<FormList> createState() => _FormListState();
}

class _FormListState extends State<FormList> {
  late final FormListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FormListController(widget.connectivity);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: StreamBuilder<bool>(
              stream: widget.connectivity.onChanged,
              initialData: widget.connectivity.isOnline,
              builder: (context, snapshot) {
                final isOnline = snapshot.data ?? false;
                return Row(
                  children: [
                    Icon(
                      isOnline ? Icons.wifi : Icons.wifi_off,
                      size: 16,
                      color: isOnline ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _controller.items.isEmpty
          ? const Center(child: Text('কোনো data নেই'))
          : RefreshIndicator(
              onRefresh: _controller.loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _controller.items.length,
                itemBuilder: (context, index) {
                  final Datum item = _controller.items[index];
                  return _buildCard(item);
                },
              ),
            ),
    );
  }

  Widget _buildCard(Datum item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(item.name?.substring(0, 1).toUpperCase() ?? '?'),
        ),
        title: Text(item.name ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.phone != null)
              Row(
                children: [
                  const Icon(Icons.phone, size: 12),
                  const SizedBox(width: 4),
                  Text(item.phone!),
                ],
              ),
            if (item.email != null)
              Row(
                children: [
                  const Icon(Icons.email, size: 12),
                  const SizedBox(width: 4),
                  Text(item.email!),
                ],
              ),
          ],
        ),
        trailing: item.isActive == null
            ? const Icon(Icons.cloud_off, color: Colors.orange, size: 18)
            : item.isActive!
            ? const Icon(Icons.check_circle, color: Colors.green, size: 18)
            : const Icon(Icons.cancel, color: Colors.red, size: 18),
      ),
    );
  }
}
