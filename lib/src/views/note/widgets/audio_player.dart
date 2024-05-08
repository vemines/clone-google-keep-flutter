part of '../note_view.dart';

class _AudioPlayer extends StatefulWidget {
  const _AudioPlayer(this.url);
  final String url;

  @override
  State<_AudioPlayer> createState() => __AudioPlayerState();
}

class __AudioPlayerState extends State<_AudioPlayer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setSourceDeviceFile(widget.url);
    _initStreams();
  }

  void initDuration() {
    _audioPlayer.getDuration().then((value) {
      if (value != null)
        setState(() {
          _duration = value;
        });
    });
    _audioPlayer.getCurrentPosition().then((value) {
      if (value != null)
        setState(() {
          _position = value;
        });
    });
  }

  void _initStreams() {
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen(
      (p) => setState(() => _position = p),
    );

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  void _togglePlay() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.resume();
    }
    _isPlaying = !_isPlaying;
    setState(() {});
  }

  void _seek(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(_isPlaying
              ? Icons.pause_circle_outline
              : Icons.play_circle_outline),
          onPressed: _togglePlay,
        ),
        Expanded(
          child: Slider(
            min: 0,
            max: _duration.inSeconds.toDouble(),
            value: _position.inSeconds.toDouble(),
            onChanged: (value) {
              _seek(value);
            },
          ),
        ),
        Text(
          formatDuration(_duration.inSeconds),
        ),
      ],
    );
  }
}
