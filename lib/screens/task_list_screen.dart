import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // <<< 1. IMPORT ADMOB
import 'dart:io' show Platform; // <<< 2. IMPORT PLATFORM for ad unit ID
import 'package:quick_task_flutter/models/task_model.dart';
import 'package:quick_task_flutter/providers/task_provider.dart';
import 'package:quick_task_flutter/services/ai_service.dart';
import 'package:quick_task_flutter/widgets/task_list_item.dart';
import 'package:quick_task_flutter/widgets/create_task_dialog.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  bool _isPrioritizing = false;

  // --- AdMob Banner Ad State ---
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  // Use test ad unit IDs. Replace with your own IDs in production.
  final String _adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111' // Android test ad unit
      : 'ca-app-pub-3940256099942544/2934735716'; // iOS test ad unit
  // --- End AdMob Banner Ad State ---

  @override
  void initState() {
    super.initState();
    _loadBannerAd(); // <<< 3. LOAD BANNER AD ONINIT

  }

  //StreamSubscription<InternetStatus>? _subscription;

  // void startListeningForConnectivityChanges() {
  //   _subscription = InternetConnection().onStatusChange.listen(
  //         (InternetStatus status) {
  //       if (status == InternetStatus.connected) {
  //         print('Internet is now connected.');
  //       } else {
  //         print('Internet is now disconnected.');
  //       }
  //     },
  //   );
  // }

  // --- AdMob Banner Ad Logic ---
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner, // Standard banner size
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded.');
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
      ),
    )..load();
  }
  // --- End AdMob Banner Ad Logic ---

  @override
  void dispose() {
    _bannerAd?.dispose(); // <<< 4. DISPOSE BANNER AD
    super.dispose();
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const CreateTaskDialog();
      },
    );
  }

  Future<void> _prioritizeTasks() async {
    final currentTasks = ref.read(taskListProvider);
    if (currentTasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add some tasks before prioritizing.')),
      );
      return;
    }

    setState(() {
      _isPrioritizing = true;
    });

    try {
      final aiService = ref.read(aiServiceProvider);
      final prioritizedTasks = await aiService.prioritizeTasks(currentTasks);
      ref.read(taskListProvider.notifier).updatePriorities(prioritizedTasks);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tasks prioritized by AI!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error prioritizing tasks: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPrioritizing = false;});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskListProvider);

    final sortedTasks = List<Task>.from(tasks);
    sortedTasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.priorityScore != null && b.priorityScore != null) {
        if (a.priorityScore != b.priorityScore) {
          return b.priorityScore!.compareTo(a.priorityScore!);
        }
      } else if (a.priorityScore != null) {
        return -1;
      } else if (b.priorityScore != null) {
        return 1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes App Flutter 2025'),
        actions: [
          IconButton(
            icon: _isPrioritizing
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Icon(Icons.auto_awesome_outlined),
            onPressed: _isPrioritizing ? null : _prioritizeTasks,
            tooltip: 'AI Prioritize Tasks',
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tasks yet!',
              style: TextStyle(fontSize: 20, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a new task to get started.',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: sortedTasks.length,
        itemBuilder: (context, index) {
          final task = sortedTasks[index];
          return TaskListItem(task: task);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
      // --- 5. ADD BANNER AD TO THE SCAFFOLD ---
      bottomNavigationBar: (_isBannerAdLoaded && _bannerAd != null)
          ? Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      )
          : SizedBox(
        height: AdSize.banner.height.toDouble(), // Placeholder for ad height
        // You can add a child here if you want to show something while ad is loading
        // child: Center(child: Text("Ad loading...")),
      ),
    );
  }
}