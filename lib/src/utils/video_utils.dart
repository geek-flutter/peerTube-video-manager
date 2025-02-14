import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:peerTube_video_manager/peerTube_video_manager.dart';

class VideoUtils {
  /// Formats the number of views with appropriate suffix (K for thousands, M for millions).
  /// Example:
  /// - `1234` → `1.2K views`
  /// - `1000000` → `1M views`
  static Widget buildViewCount(
    int? views, {
    Color color = Colors.grey,
    double fontSize = 12,
  }) {
    return Text(
      formatViews(views),
      style: TextStyle(color: color, fontSize: fontSize),
    );
  }

  static String formatViews(int? views) {
    if (views == null || views < 0) return "0 views";
    if (views >= 1000000) {
      return "${(views / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M views";
    } else if (views >= 1000) {
      return "${(views / 1000).toStringAsFixed(1).replaceAll('.0', '')}K views";
    } else {
      return "$views view${views == 1 ? '' : 's'}";
    }
  }

  static String formatVideosCount(int? views) {
    if (views == null || views < 0) return "0 videos";
    if (views >= 1000000) {
      return "${(views / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M views";
    } else if (views >= 1000) {
      return "${(views / 1000).toStringAsFixed(1).replaceAll('.0', '')}K videos";
    } else {
      return "$views video${views == 1 ? '' : 's'}";
    }
  }

  /// Extracts the best display name for a video uploader (Channel or Account).
  static String extractNameOrDisplayName(
    Video video, {
    bool prioritizeChannel = true,
    String? node,
  }) {
    String removeDefaultPrefix(String text) {
      const prefix = "Default";
      return text.startsWith(prefix)
          ? text.substring(prefix.length).trim()
          : text;
    }

    String? channelName = video.channel?.name;
    String? accountName = video.account?.name;
    String? channelDisplayName = video.channel?.displayName;
    String? accountDisplayName = video.account?.displayName;

    // ✅ Prioritize `name` first, then `displayName`
    String name =
        prioritizeChannel
            ? (channelName ??
                accountName ??
                channelDisplayName ??
                accountDisplayName ??
                "Unknown")
            : (accountName ??
                channelName ??
                accountDisplayName ??
                channelDisplayName ??
                "Unknown");

    name = removeDefaultPrefix(name);

    // ✅ Append `@host` only if both display names are null
    if (node != null && (channelName != null || accountName != null)) {
      Uri? parsedUri = Uri.tryParse(node);
      if (parsedUri != null) {
        node = parsedUri.host; // Extract only the host (remove scheme & path)
      }
      return "$name@$node";
    }

    return name;
  }

  /// 📌 Builds a video title that supports **up to 2 lines**.
  static Widget buildVideoTitle(
    String? title, {
    Color color = Colors.white,
    double fontSize = 18,
  }) {
    return Text(
      title ?? "Unknown Title",
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis, // Truncates if too long
    );
  }

  /// Builds a minimal video item (thumbnail, title, metadata)
  static Widget buildMinimalVideoItem(
    Video video,
    String nodeUrl, {
    required VoidCallback onTap,
  }) {
    final thumbnailURL = getVideoThumbnailUrl(video, nodeUrl);

    return GestureDetector(
      onTap: onTap, // 🔹 Executes callback on tap
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Video Thumbnail with Duration Overlay
            Stack(
              children: [
                UIUtils.buildHeroVideoOverViewThumbnail(
                  thumbnailURL: thumbnailURL ?? "",
                ),
                // 🕒 Video Duration (Bottom Right)
                Positioned(
                  bottom: 0, // Ensures it's at the bottom inside the thumbnail
                  right: -1, // Aligns to the right inside the thumbnail
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6),
                      ),
                    ),
                    child: Text(
                      VideoDateUtils.formatSecondsToMinSec(video.duration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            // Video Title
            Text(
              video.name ?? "Unknown Video",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            // Video Metadata (Views & Time Ago)
            Text(
              '${video.views} views • ${VideoDateUtils.formatTimeAgo(video.publishedAt?.toIso8601String())}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// **Shimmer Placeholder for Video Thumbnails**
  static Widget buildMinimalVideoBlurEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!, // ✅ Darker base color
      highlightColor: Colors.grey[700]!, // ✅ Subtle highlight
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Wrap(
          spacing: 20, // ✅ Horizontal spacing
          runSpacing: 20, // ✅ Vertical spacing
          children: List.generate(10, (_) => _buildShimmerContainer()),
        ),
      ),
    );
  }

  /// **Shimmer Placeholder for Each Video Item**
  static Widget _buildShimmerContainer() {
    return Container(
      width: 160, // ✅ Fixed width per item
      height: 100, // ✅ Ensures consistent height
      decoration: BoxDecoration(
        color: Colors.grey[800], // ✅ Matches theme
      ),
    );
  }

  static String? getVideoThumbnailUrl(Video video, String nodeUrl) {
    if (video.thumbnailPath != null && video.thumbnailPath!.isNotEmpty) {
      return '$nodeUrl${video.thumbnailPath}';
    } else if (video.previewPath != null && video.previewPath!.isNotEmpty) {
      return '$nodeUrl${video.previewPath}';
    }
    return null; // No image available
  }
}
