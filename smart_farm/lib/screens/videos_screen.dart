import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:smart_farm/services/translation_service.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final List<Map<String, String>> _videos = [
    {
      'title': 'Ant Farming - Quick Tour',
      'id': 'Qjy_L0bmo18',
      'description': 'A short video showcasing ant farming.',
    },
    {
      'title': 'Modern Agriculture Techniques',
      'id': 'HSoFvkRreGY',
      'description': 'Learn about modern farming practices and equipment.',
    },
    {
      'title': 'Organic Farming Basics',
      'id': '2F74xw1VK8E',
      'description': 'An introduction to organic farming methods without chemicals.',
    },
    {
      'title': 'How to Start a Profitable Pig Farming?',
      'id': 'QXtrhImwHIc',
      'description': 'ಹೆಚ್ಚು ಆದಾಯಕ್ಕೆ ಸೂಕ್ತವಾದ ಉದ್ಯಮ | ಹಂದಿ ಸಾಕಾಣಿಕೆ in KANNADA',
    },
    {
      'title': 'Fish Farming in Kannada',
      'id': 'I6QUD0HP2tQ',
      'description': 'ಇದಕ್ಕಿಂತ ಸುಲಬದ ಕೃಷಿ ಯಾವುದು ಇಲ್ಲ ಸರ್ | katla gowri fish farm Karnataka',
    },
    {
      'title': 'Coconut Farming - High Income',
      'id': 'H_Ym8sXjrTI',
      'description': 'ಒಂದು ಎಕರೆ ತೆಂಗಿನ ತೋಟದಲ್ಲಿ 28 ಲಕ್ಷ ದುಡಿಯೋದು ಹೇಗೆ? | Raitha pragathi',
    },
    {
      'title': 'Goat Farming Guide for Beginners',
      'id': 'KnKCUWQDuh0',
      'description': 'ಮೇಕೆ ಸಾಕಾಣಿಕೆ ಯಲ್ಲಿ ಕಡಿಮೆ ಬಂಡವಾಳ ಹಾಕಿ ಅಧಿಕ ಲಾಭ ಗಳಿಸುವುದು ಹೇಗೆ ?',
    },
    {
      'title': 'Sheep Farming in Karnataka',
      'id': 'M37bptp9Dyo',
      'description': 'ಇದ್ರಲ್ಲಿ ನಷ್ಟದ ಮಾತೆ ಇಲ್ಲ ಸರ್ | kuri sakanike Kannada bannur yalaga sheep',
    },
    {
      'title': 'Silk Farming in Kannada',
      'id': 'NhLHtcYx1CU',
      'description': 'ಹೊಸ ಟೆಕ್ನಾಲಜಿನಲ್ಲಿ ರೇಷ್ಮೆ ಕೃಷಿ ಮಾಡಿ ಮೊದಲ ಬೆಳೆಯಲ್ಲೇ ಆದಾಯ ಗಳಿಸಿ',
    },
    {
      'title': 'Modern Farming Kannada - Black Pepper',
      'id': 'OJ-l6XMQ_GQ',
      'description': 'ಬರಡಲ್ಲೂ ಕಪ್ಪು ಬಂಗಾರ ಬೆಳೆಯುವ ಅವಕಾಶ | in payyani dhoopa',
    },
    {
      'title': 'Less Cost Farming Technique for 2025',
      'id': '5dnnMpEBAl4',
      'description': 'ಖರ್ಚಿಲ್ಲದೆ ಕೃಷಿ ಮಾಡೋದು ಹೇಗೆ? ಇವರು ಹೇಳ್ತಾರೆ! | in Kannada',
    },
    {
      'title': 'Best Farming Business Ideas in Kannada',
      'id': 'LKaayK3Sumo',
      'description': 'ಕೇವಲ 6 ತಿಂಗಳಿಗೆ ನಾನು ಗಳಿಸಿದ್ದು | Fish Farming',
    },
    {
      'title': 'Oyster Mushroom Farming in Kannada',
      'id': 'v0v1s9tz3ns',
      'description': 'How to Start Oyster Mushroom Farming? | Part 1',
    },
  ];

  late YoutubePlayerController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initPlayer(_videos[0]['id']!);
  }

  void _initPlayer(String videoId) {
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playVideo(int index) {
    setState(() {
      _currentIndex = index;
    });
    _controller.load(_videos[index]['id']!);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationService.translate('farming_videos') ?? 'Farming Videos'),
      ),
      body: Column(
        children: [
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Theme.of(context).primaryColor,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _videos[_currentIndex]['title']!,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _videos[_currentIndex]['description']!,
                  style: TextStyle(
                    fontSize: 14, 
                    color: isDark ? Colors.white70 : Colors.black87
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                final video = _videos[index];
                return ListTile(
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(YoutubePlayer.getThumbnail(videoId: video['id']!)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (_currentIndex == index)
                        Container(
                          width: 100,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
                        ),
                    ],
                  ),
                  title: Text(video['title']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    video['description']!, 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    if (_currentIndex != index) {
                      _playVideo(index);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
