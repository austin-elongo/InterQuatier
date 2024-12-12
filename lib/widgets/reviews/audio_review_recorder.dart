import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:interquatier/providers/premium_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioReviewRecorder extends ConsumerStatefulWidget {
  final String eventId;
  final Function(String audioUrl) onAudioUploaded;
  final int reviewCount;

  const AudioReviewRecorder({
    super.key,
    required this.eventId,
    required this.onAudioUploaded,
    required this.reviewCount,
  });

  @override
  ConsumerState<AudioReviewRecorder> createState() => _AudioReviewRecorderState();
}

class _AudioReviewRecorderState extends ConsumerState<AudioReviewRecorder> {
  final _audioRecorder = Record();
  bool _isRecording = false;
  String? _recordingPath;
  bool _isUploading = false;
  int _recordingDuration = 0;
  Timer? _timer;

  // Premium settings
  static const _standardMaxDuration = 60; // 1 minute for free users
  static const _premiumMaxDuration = 180; // 3 minutes for premium users
  static const _maxReviewsStandard = 1;
  static const _maxReviewsPremium = 3;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    try {
      final status = await Permission.microphone.request();
      if (status.isGranted) {
        await _audioRecorder.isEncoderSupported(AudioEncoder.aacLc);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please grant microphone permission to record audio reviews'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error initializing recorder: $e');
    }
  }

  bool get _canAddMoreReviews {
    final isPremium = ref.watch(premiumProvider).value ?? false;
    final maxReviews = isPremium ? _maxReviewsPremium : _maxReviewsStandard;
    return widget.reviewCount < maxReviews;
  }

  int get _maxDuration {
    final isPremium = ref.watch(premiumProvider).value ?? false;
    return isPremium ? _premiumMaxDuration : _standardMaxDuration;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });

      if (_recordingDuration >= _maxDuration) {
        _stopRecording();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _recordingDuration = 0;
    });
  }

  Future<void> _startRecording() async {
    if (!_canAddMoreReviews) {
      final isPremium = ref.read(premiumProvider).value ?? false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPremium 
                ? 'Maximum number of reviews (3) reached'
                : 'Upgrade to premium to add more reviews',
          ),
          action: isPremium ? null : SnackBarAction(
            label: 'Upgrade',
            onPressed: () {
              // Navigate to premium upgrade screen
              Navigator.pushNamed(context, '/premium');
            },
          ),
        ),
      );
      return;
    }

    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        _recordingPath = '${directory.path}/audio_review_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(
          path: _recordingPath,
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          samplingRate: 44100,
        );
        
        setState(() => _isRecording = true);
        _startTimer();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission denied')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<String> _compressAudio(String inputPath) async {
    final directory = await getTemporaryDirectory();
    final outputPath = '${directory.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.m4a';
    
    try {
      final session = await FFmpegKit.execute(
        '-i $inputPath -c:a aac -b:a 64k -ac 1 $outputPath'
      );
      
      final returnCode = await session.getReturnCode();
      if (returnCode?.isValueError() ?? true) {
        throw Exception('Error compressing audio: ${await session.getLogsAsString()}');
      }
      
      return outputPath;
    } catch (e) {
      debugPrint('Error compressing audio: $e');
      // If compression fails, return original file
      return inputPath;
    }
  }

  Future<void> _uploadAudio() async {
    if (_recordingPath == null) return;

    setState(() => _isUploading = true);
    try {
      // Compress the audio before uploading
      final compressedPath = await _compressAudio(_recordingPath!);
      
      final ref = FirebaseStorage.instance
          .ref()
          .child('audio_reviews')
          .child(widget.eventId)
          .child('review_${DateTime.now().millisecondsSinceEpoch}.m4a');

      await ref.putFile(File(compressedPath));
      final audioUrl = await ref.getDownloadURL();
      
      // Clean up compressed file
      await File(compressedPath).delete();
      
      widget.onAudioUploaded(audioUrl);
    } catch (e) {
      debugPrint('Error uploading audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading: $e')),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  String get _remainingTimeText {
    final remaining = _maxDuration - _recordingDuration;
    return '${remaining ~/ 60}:${(remaining % 60).toString().padLeft(2, '0')}';
  }

  Future<void> _stopRecording() async {
    try {
      _stopTimer();
      await _audioRecorder.stop();
      setState(() => _isRecording = false);
      
      if (_recordingPath != null) {
        await _uploadAudio();
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(premiumProvider).value ?? false;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              onPressed: _isUploading ? null : (_isRecording ? _stopRecording : _startRecording),
            ),
            if (_isRecording)
              Text(
                _remainingTimeText,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else if (_isUploading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Review ${widget.reviewCount + 1} of ${isPremium ? _maxReviewsPremium : _maxReviewsStandard}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (!isPremium && widget.reviewCount >= _maxReviewsStandard) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/premium'),
            icon: const Icon(Icons.star),
            label: const Text('Upgrade to Premium for more reviews'),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _stopTimer();
    _audioRecorder.dispose();
    super.dispose();
  }
} 