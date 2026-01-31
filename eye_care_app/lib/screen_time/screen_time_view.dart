import 'package:eye_care_app/screen_time/screen_time_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScreenTimeView extends StatefulWidget {
  const ScreenTimeView({super.key});

  @override
  State<ScreenTimeView> createState() => _ScreenTimeViewState();
}

class _ScreenTimeViewState extends State<ScreenTimeView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ScreenTimeProvider>().loadTodayReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Screen Usage')),
      body: Consumer<ScreenTimeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final report = provider.report;
          if (report == null) {
            return Center(child: Text('No data'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Screen ON: '
                  '${report.screenOnDuration.inHours} jam',
                ),
                SizedBox(height: 8),
                Text(
                  'Screen OFF: '
                  '${report.screenOffDuration.inHours} jam',
                ),
                SizedBox(height: 8),
                Text(
                  'HP dibuka: '
                  '${report.screenOnCount} kali',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
