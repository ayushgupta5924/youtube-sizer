import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/playlist_data.dart';

class YouTubeApiService {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';
  static const String _apiKey = 'Enter your API Key';

  static String? extractPlaylistId(String url) {
    final regex = RegExp(r'youtube\.com/playlist.*[?&]list=([a-zA-Z0-9_-]+)');
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  static Future<PlaylistData> calculatePlaylistDuration(String playlistId) async {
    final playlistInfo = await _getPlaylistInfo(playlistId);
    final videoIds = await _getAllVideoIds(playlistId);
    final durations = await _getVideoDurations(videoIds);
    
    final totalSeconds = durations.fold<int>(0, (sum, duration) => sum + duration);
    final speedAdjusted = {
      1.0: totalSeconds,
      1.25: (totalSeconds / 1.25).round(),
      1.5: (totalSeconds / 1.5).round(),
      2.0: (totalSeconds / 2.0).round(),
    };

    return PlaylistData(
      playlistTitle: playlistInfo['title'] ?? 'Unknown Playlist',
      channelTitle: playlistInfo['channelTitle'] ?? 'Unknown Creator',
      totalVideos: videoIds.length,
      totalSeconds: totalSeconds,
      speedAdjustedDurations: speedAdjusted,
    );
  }

  static Future<List<String>> _getAllVideoIds(String playlistId) async {
    final videoIds = <String>[];
    String? nextPageToken;

    do {
      final url = '$_baseUrl/playlistItems?part=contentDetails&playlistId=$playlistId&maxResults=50&key=$_apiKey${nextPageToken != null ? '&pageToken=$nextPageToken' : ''}';
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) throw Exception('Failed to fetch playlist items');

      final data = json.decode(response.body);
      nextPageToken = data['nextPageToken'];

      for (final item in data['items']) {
        videoIds.add(item['contentDetails']['videoId']);
      }
    } while (nextPageToken != null);

    return videoIds;
  }

  static Future<List<int>> _getVideoDurations(List<String> videoIds) async {
    final durations = <int>[];
    
    for (int i = 0; i < videoIds.length; i += 50) {
      final batch = videoIds.skip(i).take(50).join(',');
      final url = '$_baseUrl/videos?part=contentDetails&id=$batch&key=$_apiKey';
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) throw Exception('Failed to fetch video details');

      final data = json.decode(response.body);
      for (final item in data['items']) {
        final duration = _parseDuration(item['contentDetails']['duration']);
        durations.add(duration);
      }
    }

    return durations;
  }

  static Future<Map<String, String>> _getPlaylistInfo(String playlistId) async {
    final url = '$_baseUrl/playlists?part=snippet&id=$playlistId&key=$_apiKey';
    
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) throw Exception('Failed to fetch playlist info');

    final data = json.decode(response.body);
    final snippet = data['items'][0]['snippet'];
    
    return {
      'title': snippet['title'] ?? 'Unknown Playlist',
      'channelTitle': snippet['channelTitle'] ?? 'Unknown Creator',
    };
  }

  static int _parseDuration(String isoDuration) {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(isoDuration);
    
    if (match == null) return 0;
    
    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
    
    return hours * 3600 + minutes * 60 + seconds;
  }
}