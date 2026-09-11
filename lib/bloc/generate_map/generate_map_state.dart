part of 'generate_map_cubit.dart';

enum GenerateMapStatus { initial, loading, success, failure }

class GenerateMapState {
  final GenerateMapStatus status;
  final GenerateMapResponse? response;
  final String? errorMessage;

  const GenerateMapState({
    this.status = GenerateMapStatus.initial,
    this.response,
    this.errorMessage,
  });
}
