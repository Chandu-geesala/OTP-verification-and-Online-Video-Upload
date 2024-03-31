import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:math';
import 'view_video.dart';

class Library extends StatefulWidget {
  const Library({Key? key}) : super(key: key);

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Posts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final videos = snapshot.data?.docs.toList();
            if (videos == null || videos.isEmpty) {
              return Center(child: Text('No videos found.'));
            }
            return ListView.builder(
              reverse: true, // Display latest videos on top
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildVideoItem(video),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildVideoItem(QueryDocumentSnapshot video) {
    final videoUrl = video['url'];
    final title = video['title'] ?? 'Unnamed Video';
    final description = video['description'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenVideoPlayer(videoUrl),
              ),
            );
          },
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: VideoPlayerWidget(videoUrl),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconButton('assets/heart.png', Colors.blue),
                  _buildIconButton('assets/broken.png', Colors.red),
                  _buildShareButton(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }


// Inside _buildVideoItem method
  Widget _buildIconButton(String imagePath, Color backgroundColor) {
    final randomCount = Random().nextInt(10000); // Generate random count
    final countText = '$randomCount' + 'k'; // Add 'k' after random count

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor.withOpacity(0.8),
          ),
          child: InkWell(
            onTap: () {
              // Handle button press
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                imagePath,
                width: 24, // Adjust size as needed
                height: 24, // Adjust size as needed
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 4), // Add spacing between icon and count text
        Text(
          countText,
          style: TextStyle(fontSize: 12), // Adjust font size as needed
        ),
      ],
    );
  }

  Widget _buildShareButton() {
    final randomCount = Random().nextInt(100); // Generate random count
    final countText = '$randomCount' + 'k'; // Add 'k' after random count

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green.withOpacity(0.8),
          ),
          child: IconButton(
            onPressed: () {
              // Handle share button press
            },
            icon: Icon(Icons.share),
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4), // Add spacing between icon and count text
        Text(
          countText,
          style: TextStyle(fontSize: 12), // Adjust font size as needed
        ),
      ],
    );
  }



}

class VideoPlayerWidget extends StatefulWidget {
  final String? videoUrl;

  const VideoPlayerWidget(this.videoUrl, {Key? key}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl!);
    _controller.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? VideoPlayer(_controller)
        : Center(child: CircularProgressIndicator());
  }
}
