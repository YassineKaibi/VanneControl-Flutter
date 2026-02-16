/// NetworkResult - Sealed class for handling network call results.
/// Matches NetworkResult.kt from the Android project.
sealed class NetworkResult<T> {
  const NetworkResult();
}

/// Idle state - no operation in progress
class Idle<T> extends NetworkResult<T> {
  const Idle();
}

/// Loading state - request in progress
class Loading<T> extends NetworkResult<T> {
  const Loading();
}

/// Success state - request succeeded with data
class Success<T> extends NetworkResult<T> {
  final T data;
  const Success(this.data);
}

/// Error state - request failed
class NetworkError<T> extends NetworkResult<T> {
  final String message;
  final int? code;
  const NetworkError(this.message, [this.code]);
}

/// Extension methods matching Kotlin extensions
extension NetworkResultExtensions<T> on NetworkResult<T> {
  R when<R>({
    required R Function() idle,
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String message, int? code) error,
  }) {
    return switch (this) {
      Idle() => idle(),
      Loading() => loading(),
      Success(data: final data) => success(data),
      NetworkError(message: final msg, code: final code) => error(msg, code),
    };
  }

  void onSuccess(void Function(T data) action) {
    if (this is Success<T>) {
      action((this as Success<T>).data);
    }
  }

  void onError(void Function(String message, int? code) action) {
    if (this is NetworkError<T>) {
      final err = this as NetworkError<T>;
      action(err.message, err.code);
    }
  }

  bool get isLoading => this is Loading;
  bool get isSuccess => this is Success;
  bool get isError => this is NetworkError;
  bool get isIdle => this is Idle;
}
