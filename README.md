# YouTube Playlist Calculator

A Flutter application that calculates the total watch time of YouTube playlists using the YouTube Data API v3.

## Features

- Extract playlist ID from YouTube URLs
- Calculate total duration of all videos in a playlist
- Show speed-adjusted durations (1x, 1.25x, 1.5x, 2x)
- Display playlist statistics (total videos, average duration)
- Handle playlists with 50+ videos through pagination

## Setup

1. Get a YouTube Data API v3 key from [Google Cloud Console](https://console.cloud.google.com/)
2. Replace `YOUR_API_KEY` in `lib/services/youtube_api_service.dart` with your actual API key
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the application

## Architecture

- **Framework**: Flutter with Material Design
- **Pattern**: Stateful Widget-based MVC
- **State Management**: Local setState()
- **API Integration**: HTTP package for REST API calls
- **Duration Parsing**: ISO 8601 format (PT1H23M45S)