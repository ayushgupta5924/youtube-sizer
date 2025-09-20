import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/youtube_api_service.dart';
import '../models/playlist_data.dart';

class PlaylistCalculatorScreen extends StatefulWidget {
  const PlaylistCalculatorScreen({super.key});

  @override
  State<PlaylistCalculatorScreen> createState() => _PlaylistCalculatorScreenState();
}

class _PlaylistCalculatorScreenState extends State<PlaylistCalculatorScreen>
    with TickerProviderStateMixin {
  final _urlController = TextEditingController();
  PlaylistData? _playlistData;
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    _showToast('Copied to clipboard!');
  }

  Future<void> _calculateDuration() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showToast('Please enter a playlist URL', isError: true);
      return;
    }

    final playlistId = YouTubeApiService.extractPlaylistId(url);
    if (playlistId == null) {
      setState(() {
        _errorMessage = 'Invalid YouTube playlist URL';
      });
      _showToast('Invalid YouTube playlist URL', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _playlistData = null;
    });
    _fadeController.reset();

    try {
      final data = await YouTubeApiService.calculatePlaylistDuration(playlistId);
      setState(() {
        _playlistData = data;
        _isLoading = false;
      });
      _fadeController.forward();
      _showToast('Playlist analyzed successfully!');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
      _showToast('Failed to analyze playlist', isError: true);
    }
  }

  Widget _buildSkeletonCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(4, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.playlist_play,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Enter a YouTube playlist URL\nto get started',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF800020), Color(0xFF5D001A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Color(0xFF800020),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'YouTube Playlist Length',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _urlController,
                                  decoration: InputDecoration(
                                    labelText: 'YouTube Playlist URL',
                                    hintText: 'https://www.youtube.com/playlist?list=...',
                                    prefixIcon: const Icon(
                                      Icons.link,
                                      color: Color(0xFF800020),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF800020)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF800020),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _calculateDuration,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF800020),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.analytics),
                                              SizedBox(width: 8),
                                              Text(
                                                'Analyze Playlist',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        if (_isLoading) ...[
                          _buildSkeletonCard(),
                          const SizedBox(height: 16),
                          _buildSkeletonCard(),
                        ],
                        
                        if (_playlistData != null)
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                Card(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.info_outline,
                                              color: Color(0xFF800020),
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Playlist Information',
                                              style: TextStyle(
                                                fontSize: isTablet ? 20 : 18,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF333333),
                                              ),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              onPressed: () => _copyToClipboard(
                                                'Title: ${_playlistData!.playlistTitle}\n'
                                                'Creator: ${_playlistData!.channelTitle}\n'
                                                'Videos: ${_playlistData!.totalVideos}\n'
                                                'Duration: ${_playlistData!.formatDuration(_playlistData!.totalSeconds)}',
                                              ),
                                              icon: const Icon(Icons.copy, color: Color(0xFF800020)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        _buildInfoRow(Icons.title, 'Title', _playlistData!.playlistTitle),
                                        _buildInfoRow(Icons.person, 'Creator', _playlistData!.channelTitle),
                                        _buildInfoRow(Icons.video_library, 'Total Videos', '${_playlistData!.totalVideos}'),
                                        _buildInfoRow(Icons.access_time, 'Total Duration', _playlistData!.formatDuration(_playlistData!.totalSeconds)),
                                        _buildInfoRow(Icons.bar_chart, 'Average Duration', _playlistData!.formatDuration(_playlistData!.averageDuration)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                Card(
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.speed,
                                              color: Color(0xFF800020),
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Speed-Adjusted Durations',
                                              style: TextStyle(
                                                fontSize: isTablet ? 20 : 18,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF333333),
                                              ),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              onPressed: () => _copyToClipboard(
                                                _playlistData!.speedAdjustedDurations.entries
                                                    .map((e) => '${e.key}x: ${_playlistData!.formatDuration(e.value)}')
                                                    .join('\n'),
                                              ),
                                              icon: const Icon(Icons.copy, color: Color(0xFF800020)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        ..._playlistData!.speedAdjustedDurations.entries.map(
                                          (entry) => _buildSpeedRow(entry.key, _playlistData!.formatDuration(entry.value)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        if (!_isLoading && _playlistData == null && _errorMessage == null)
                          SizedBox(
                            height: 300,
                            child: _buildEmptyState(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF666666),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedRow(double speed, String duration) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                speed == 1.0 ? Icons.play_arrow : Icons.fast_forward,
                color: const Color(0xFF800020),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${speed}x speed',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          Text(
            duration,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF800020),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}