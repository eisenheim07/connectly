import 'package:equatable/equatable.dart';

/// Base state for connectivity
abstract class ConnectivityState extends Equatable {
  const ConnectivityState();

  @override
  List<Object?> get props => [];
}

/// Initial state - connectivity not checked yet
class ConnectivityInitial extends ConnectivityState {
  const ConnectivityInitial();
}

/// Checking connectivity state
class ConnectivityChecking extends ConnectivityState {
  const ConnectivityChecking();
}

/// Connected to internet
class ConnectivityConnected extends ConnectivityState {
  const ConnectivityConnected();
}

/// Disconnected from internet
class ConnectivityDisconnected extends ConnectivityState {
  const ConnectivityDisconnected();
}
