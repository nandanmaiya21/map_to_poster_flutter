part of 'render_map_cubit.dart';

enum RenderJobStatus { idle, loading, success, failure }

class RenderJob {
  final RenderJobStatus status;
  final RenderMapResponse? response;
  final String? error;

  const RenderJob({
    this.status = RenderJobStatus.idle,
    this.response,
    this.error,
  });
}

class RenderMapState {
  final Map<ExportFormat, RenderJob> jobs;

  const RenderMapState({this.jobs = const {}});

  RenderJob jobFor(ExportFormat format) => jobs[format] ?? const RenderJob();

  RenderMapState withJob(ExportFormat format, RenderJob job) {
    final next = Map<ExportFormat, RenderJob>.from(jobs);
    next[format] = job;
    return RenderMapState(jobs: next);
  }
}
