import 'package:equatable/equatable.dart';

abstract class TestScenarioState extends Equatable {
  const TestScenarioState();

  @override
  List<Object?> get props => [];
}

class TestScenarioInitial extends TestScenarioState {
  const TestScenarioInitial();
}

class TestScenarioRunning extends TestScenarioState {
  final String testName;
  final int countdown;

  const TestScenarioRunning({
    required this.testName,
    required this.countdown,
  });

  @override
  List<Object?> get props => [testName, countdown];
}

class TestScenarioCompleted extends TestScenarioState {
  final String testName;

  const TestScenarioCompleted({required this.testName});

  @override
  List<Object?> get props => [testName];
}

class TestScenarioAllCompleted extends TestScenarioState {
  const TestScenarioAllCompleted();
}
