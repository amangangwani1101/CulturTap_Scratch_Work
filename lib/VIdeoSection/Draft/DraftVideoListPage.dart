import 'package:flutter/material.dart';
import 'package:learn_flutter/CustomItems/VideoAppBar.dart';
import 'package:learn_flutter/VIdeoSection/Draft/EditDraftPage.dart';
import 'package:video_player/video_player.dart';
import 'package:learn_flutter/VIdeoSection/Draft_Local_Database/draft.dart';

class VideoGridItem extends StatefulWidget {
  final VideoPlayerController controller;
  final Function()? onRemovePressed;

  VideoGridItem({required this.controller, this.onRemovePressed});

  @override
  _VideoGridItemState createState() => _VideoGridItemState();
}

class _VideoGridItemState extends State<VideoGridItem> {
  late VideoPlayerController _videoController;
  late bool _isPlaying;

  @override
  void initState() {
    super.initState();
    _videoController = widget.controller;
    _isPlaying = false;
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(

        child: ClipRRect(
          borderRadius: BorderRadius.circular(.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 4.0),
            ),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 2 / 3.3, // Adjust the aspect ratio
                  child: VideoPlayer(_videoController),
                ),
                Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        if (_isPlaying) {
                          _videoController.pause();
                        } else {
                          _videoController.play();
                        }
                        _isPlaying = !_isPlaying;
                      });
                    },
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 40.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 8.0,
                  right: 8.0,
                  child: IconButton(
                    onPressed: widget.onRemovePressed,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DraftVideoListPage extends StatefulWidget {
  final Draft draft;

  DraftVideoListPage({required this.draft});

  @override
  _DraftVideoListPageState createState() => _DraftVideoListPageState();
}

class _DraftVideoListPageState extends State<DraftVideoListPage> {
  List<VideoPlayerController> videoControllers = [];

  @override
  void initState() {
    super.initState();
    // Initialize video controllers for each video in the draft
    var videoPaths = widget.draft.videoPaths.split(',');
    for (var path in videoPaths) {
      videoControllers.add(VideoPlayerController.network(path)
        ..initialize().then((_) {
          setState(() {});
        }));
    }
  }

  Future<void> _refreshPage() async {
    // Implement your logic to refresh the drafts.
    // For example, you can re-fetch the drafts from the database.

  }
  @override
  void dispose() {
    for (var controller in videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VideoAppBar(),
      body:  RefreshIndicator(
        backgroundColor: Color(0xFF263238),
        color : Colors.orange,
        onRefresh: _refreshPage,
        child: Stack(
          children: [
            Container(
              color: Color(0xFF263238), // Set the background color
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2 / 3.15, // Adjust the aspect ratio
                ),
                itemCount: videoControllers.length,
                itemBuilder: (context, index) {
                  return VideoGridItem(
                    controller: videoControllers[index],
                    onRemovePressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Are you sure?'),
                            content: Text('You are removing a video.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  removeVideo(index);
                                  Navigator.of(context).pop();
                                },
                                child: Text('Remove'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Positioned(
              right: 20.0,
              bottom: 20.0,
              child: Container(
                height: 100,
                width: 80,
                child: IconButton(
                  icon: Image.asset("assets/images/next_button.png"),
                  onPressed: () {
                    navigateToEditDraftPage(context, widget.draft);

                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void removeVideo(int index) {
    setState(() {
      // Remove the video from the list of controllers
      videoControllers[index].dispose();
      videoControllers.removeAt(index);

      // Update the draft's videoPaths by removing the video URL at the specified index
      var updatedVideoPaths = widget.draft.videoPaths.split(',');
      updatedVideoPaths.removeAt(index);
      widget.draft.videoPaths = updatedVideoPaths.join(',');

      // You may want to update your database or storage here if applicable.

      // You can also update any other relevant data or UI to reflect the removal.
    });
  }
}

void navigateToEditDraftPage(BuildContext context, Draft draft) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => EditDraftPage(draft: draft),
    ),
  );
}

