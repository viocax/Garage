import 'dart:async';

/// A StreamTransformer that throttles events from the source stream.
///
/// It only emits an event if a specified duration has passed since the last emitted event.
class ThrottlingStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final Duration duration;

  ThrottlingStreamTransformer(this.duration);

  @override
  Stream<T> bind(Stream<T> stream) {
    return Stream<T>.eventTransformed(
      stream,
      (sink) => _ThrottlingSink<T>(sink, duration),
    );
  }
}

class _ThrottlingSink<T> implements EventSink<T> {
  final EventSink<T> _outputSink;
  final Duration _duration;
  int? _lastEventTime;

  _ThrottlingSink(this._outputSink, this._duration);

  @override
  void add(T event) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_lastEventTime == null ||
        now - _lastEventTime! >= _duration.inMilliseconds) {
      _outputSink.add(event);
      _lastEventTime = now;
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _outputSink.addError(error, stackTrace);
  }

  @override
  void close() {
    _outputSink.close();
  }
}

/// Extension on Stream to easily apply throttling.
extension StreamThrottle<T> on Stream<T> {
  /// Throttles the stream, emitting events at most once every [duration].
  Stream<T> throttle(Duration duration) {
    return transform(ThrottlingStreamTransformer<T>(duration));
  }
}
