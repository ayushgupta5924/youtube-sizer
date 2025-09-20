class PlaylistData {
  final String playlistTitle;
  final String channelTitle;
  final int totalVideos;
  final int totalSeconds;
  final Map<double, int> speedAdjustedDurations;

  PlaylistData({
    required this.playlistTitle,
    required this.channelTitle,
    required this.totalVideos,
    required this.totalSeconds,
    required this.speedAdjustedDurations,
  });

  String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  int get averageDuration => totalVideos > 0 ? totalSeconds ~/ totalVideos : 0;
}