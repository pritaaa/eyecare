import 'package:eye_care_app/app_usage/app_usage_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppUsageView extends StatefulWidget {
  @override
  State<AppUsageView> createState() => _AppUsageViewState();
}

class _AppUsageViewState extends State<AppUsageView> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<AppUsageProvider>();
    provider.checkPermission().then((_) {
      if (provider.hasPermission) {
        provider.loadUsageStats();
      }
    });
  }

  String _formatDuration(int totalMinutes) {
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;
    if (hours > 0) {
      return '${hours}j ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Usage')),
      body: Consumer<AppUsageProvider>(
        builder: (context, provider, _) {
          if (!provider.hasPermission) {
            return Center(
              child: ElevatedButton(
                onPressed: provider.requestPermission,
                child: const Text('Aktifkan Akses Penggunaan'),
              ),
            );
          }

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          return ListView.builder(
            itemCount: provider.apps.length,
            itemBuilder: (context, index) {
              final app = provider.apps[index];
              return ListTile(
                leading: app.appIcon != null
                    ? Image.memory(app.appIcon!, width: 40, height: 40)
                    : const Icon(Icons.apps),
                title: Text(app.appName),
                subtitle: Text(
                  app.packageName,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                trailing: Text(
                  _formatDuration(app.minutes),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
