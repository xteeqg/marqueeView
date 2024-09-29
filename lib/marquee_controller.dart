part of 'marquee_view.dart';

class MarqueeController {
  final _marqueeStates = <_MarqueeViewState>[];

  void _attach(_MarqueeViewState state) {
    _marqueeStates.add(state);
  }

  void _detach(_MarqueeViewState state) {
    _marqueeStates.remove(state);
  }

  bool get hasClients => _marqueeStates.isNotEmpty;

  /// Get animate status of marquee view
  bool get isAnimating {
    assert(hasClients, 'Not found any attached marquee view');
    assert(_marqueeStates.length == 1, 'Multiple marquee view attached.');
    return _marqueeStates.single.animationController?.isAnimating ?? false;
  }

  /// Start movement for attached marquee view
  void start() {
    assert(hasClients, 'Not found any attached marquee view');
    for (final state in _marqueeStates) {
      state.start();
    }
  }

  /// Stop movement for attached marquee view
  void stop() {
    assert(hasClients, 'Not found any attached marquee view');
    for (final state in _marqueeStates) {
      state.stop();
    }
  }

  /// Reset initial status  for attached marquee view
  void reset() {
    assert(hasClients, 'Not found any attached marquee view');
    for (final state in _marqueeStates) {
      state.reset();
    }
  }
}
