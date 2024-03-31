import 'dart:io' as io;
import 'package:flut1/post.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'library.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _videoURL;
  VideoPlayerController? _controller;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  bool _uploading = false;
  String? _uploadMessage;

  TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          if (_videoURL == null) _buildBackgroundAnimation(), // Conditionally render background animation
          Center(
            child: _videoURL != null ? _videoPreviewWidget() : _buildNoVideoRecordedWidget(), // Conditionally render video preview or "No video recorded" message
          ),
        ],
      ),


      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        buttonBackgroundColor: Colors.black,
        color: Colors.grey.shade400,
        animationDuration: Duration(milliseconds: 300),
        items: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.travel_explore,
                color: Colors.white,
              ),
              Text('Explore', style: TextStyle(color: Colors.white)),
            ],
          ),


          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: Colors.white,
              ),
              Text('Post', style: TextStyle(color: Colors.white)),
            ],
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library,
                color: Colors.white,
              ),
              Text('Library', style: TextStyle(color: Colors.white)),
            ],
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            _recordVideo();
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Library()));
          }
          _onItemTapped(index);
        },
      ),


    );
  }

  Widget _buildBackgroundAnimation() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Lottie.asset(
        'assets/anim.json', // Replace with your Lottie animation file path
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildNoVideoRecordedWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/anim.json', // Replace with your Lottie animation file path
          height: 200,
        ),
        const SizedBox(height: 20),
        Text(
          "",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }


  void _recordVideo() async {
    _videoURL = await recordVideo();
    if (_videoURL != null) {
      _initializeVideoPlayer();
    }
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.file(io.File(_videoURL!))
      ..initialize().then((_) {
        setState(() {});
        _controller!.play();
      });
  }





  void _uploadVideo() async {
    setState(() {
      _uploading = true;
      _uploadMessage = null;
    });

    String? downloadURL = await StoreData().uploadVideo(_videoURL!);
    if (downloadURL != null) {
      await StoreData.saveVideoData(
        downloadURL,
        _titleController.text,
        _descriptionController.text,
        _categoryController.text,
      );
      setState(() {
        _videoURL = null;
        _titleController.clear();
        _descriptionController.clear();
        _categoryController.clear();
        _uploading = false;
        _uploadMessage = 'Video uploaded successfully!';
      });
    } else {
      setState(() {
        _uploading = false;
        _uploadMessage = 'Failed to upload video. Please try again.';
      });
    }
  }


  Widget _videoPreviewWidget() {
    return Container(
      height: 400, // Fixed height for the preview box
      margin: EdgeInsets.all(20), // Margin for spacing around the box
      padding: EdgeInsets.all(20), // Padding for spacing inside the box
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey), // Border for box appearance
        borderRadius: BorderRadius.circular(10), // Rounded corners for box
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (_controller != null)
              Container(
                width: 300, // Set the width as per your requirement
                height: 200, // Set the height as per your requirement
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              ),
            if (_controller == null) // Conditionally render Lottie animation if no video is recorded
              Lottie.asset('assets/anim.json'), // Replace 'assets/anim.json' with the path to your Lottie animation file
            SizedBox(height: 20), // Add some space
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'Enter video title',
              ),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter video description',
              ),
            ),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Category',
                hintText: 'Enter video category',
              ),
            ),
            SizedBox(height: 20),

            // Add some space
            ElevatedButton(
              onPressed: _uploading ? null : () {
                _uploadVideo();
                Navigator.push(context, MaterialPageRoute(builder: (context) => Library()));
                setState(() {
                  _videoURL = null;
                });
              },
              child: Text('Post'),
            ),




            if (_uploading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            if (_uploadMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _uploadMessage!,
                  style: TextStyle(
                    color: _uploadMessage!.contains('failed') ? Colors.red : Colors.green,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _searchResultsWidget() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_searchResults[index]),
        );
      },
    );
  }

}







class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 80.0);

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          SizedBox(width: 16.0), // Add some space
          Text(
            'Chandu_Geesala',
            style: TextStyle(fontFamily: 'cha'), // Apply "cha" font family
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            // Handle notification button press
          },
        ),
      ],
      leading: CircleAvatar(
        backgroundImage: AssetImage('assets/chandu.jpg'),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.grey[200],
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (value) {
                    // Redirect to Library page when user hits enter
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Library()));
                  },
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                // Handle filter button press
              },
            ),
          ],
        ),
      ),
    );
  }
}




Future<String?> recordVideo() async {
  final picker = ImagePicker();
  XFile? videoFile;
  try {
    videoFile = await picker.pickVideo(source: ImageSource.camera);
    return videoFile!.path;
  } catch (e) {
    print('Error in recording video: $e');
    return null;
  }
}
