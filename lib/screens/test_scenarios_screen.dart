 import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/test_scenario_cubit.dart';
import '../cubits/test_scenario_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/button_widget.dart';

class TestScenariosScreen extends StatelessWidget {
  const TestScenariosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TestScenarioCubit(),
      child: const _TestScenariosView(),
    );
  }
}

class _TestScenariosView extends StatelessWidget {
  const _TestScenariosView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const CustomAppBar(title: 'Test Scenarios'),
      body: BlocConsumer<TestScenarioCubit, TestScenarioState>(
        listener: (context, state) {
          if (state is TestScenarioCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ ${state.testName} completed'),
                backgroundColor: AppColors.green,
              ),
            );
          } else if (state is TestScenarioAllCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ All tests completed!'),
                backgroundColor: AppColors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          final isRunning = state is TestScenarioRunning;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isRunning) _buildTestRunningCard(state as TestScenarioRunning),
                const SizedBox(height: 16),
                Text(
                  'Controlled Failure Matrix',
                  style: AppTypography.headlineSmallBold(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Simulate various scenarios to test state management and resilience',
                  style: AppTypography.bodyMediumSecondary(),
                ),
                const SizedBox(height: 24),
                _buildTestCard(
                  context: context,
                  title: '1. Late Join (20s)',
                  description: 'User B joins 20 seconds after meeting starts',
                  icon: Icons.schedule,
                  color: AppColors.blue,
                  onTest: () => context.read<TestScenarioCubit>().testLateJoin(),
                  isRunning: isRunning,
                ),
                _buildTestCard(
                  context: context,
                  title: '2. Camera Toggle',
                  description: 'User A turns camera off, then back on',
                  icon: Icons.videocam_off,
                  color: AppColors.orange,
                  onTest: () => context.read<TestScenarioCubit>().testCameraToggle(),
                  isRunning: isRunning,
                ),
                _buildTestCard(
                  context: context,
                  title: '3. Network Loss (10s)',
                  description: 'User A loses network for 10 seconds',
                  icon: Icons.wifi_off,
                  color: AppColors.red,
                  onTest: () => context.read<TestScenarioCubit>().testNetworkLoss(),
                  isRunning: isRunning,
                ),
                _buildTestCard(
                  context: context,
                  title: '4. App Background (15s)',
                  description: 'User A backgrounds app, returns after 15s',
                  icon: Icons.phone_android,
                  color: AppColors.purple,
                  onTest: () => context.read<TestScenarioCubit>().testAppBackground(),
                  isRunning: isRunning,
                ),
                _buildTestCard(
                  context: context,
                  title: '5. Leave & Rejoin',
                  description: 'User B leaves, then rejoins the meeting',
                  icon: Icons.exit_to_app,
                  color: AppColors.teal,
                  onTest: () => context.read<TestScenarioCubit>().testLeaveRejoin(),
                  isRunning: isRunning,
                ),
                _buildTestCard(
                  context: context,
                  title: '6. Permission Flow',
                  description: 'Mic permission denied, then granted',
                  icon: Icons.mic_off,
                  color: AppColors.amber,
                  onTest: () => context.read<TestScenarioCubit>().testPermissionFlow(),
                  isRunning: isRunning,
                ),
                _buildTestCard(
                  context: context,
                  title: '7. Poor Connection',
                  description: 'Simulate degraded network quality',
                  icon: Icons.signal_wifi_bad,
                  color: AppColors.deepOrange,
                  onTest: () => context.read<TestScenarioCubit>().testPoorConnection(),
                  isRunning: isRunning,
                ),
                _buildTestCard(
                  context: context,
                  title: '8. Duplicate Reconnect',
                  description: 'Test duplicate event suppression',
                  icon: Icons.sync_problem,
                  color: AppColors.indigo,
                  onTest: () => context.read<TestScenarioCubit>().testDuplicateReconnect(),
                  isRunning: isRunning,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButtonWidget(
                    text: 'Run All Tests Sequentially',
                    icon: Icons.play_circle,
                    onPressed: isRunning ? null : () => context.read<TestScenarioCubit>().runAllTests(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTestRunningCard(TestScenarioRunning state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(color: AppColors.secondary),
          const SizedBox(height: 16),
          Text(
            state.testName,
            style: AppTypography.titleMediumBold(),
          ),
          const SizedBox(height: 8),
          Text(
            'Completing in ${state.countdown} seconds...',
            style: AppTypography.bodyMediumSecondary(),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTest,
    required bool isRunning,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: AppTypography.titleSmallBold()),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(description, style: AppTypography.bodySmallSecondary()),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: isRunning ? null : onTest,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
