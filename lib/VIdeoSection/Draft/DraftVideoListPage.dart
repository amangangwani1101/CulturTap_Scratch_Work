import 'package:flutter/material.dart';
import 'package:learn_flutter/CustomItems/VideoAppBar.dart';
import 'package:learn_flutter/VIdeoSection/Draft/EditDraftPage.dart';
import 'package:video_player/video_player.dart';
import 'package:learn_flutter/VIdeoSection/Draft_Local_Database/draft.dart';
import 'package:learn_flutter/VIdeoSection/Draft_Local_Database/database_helper.dart';
class VideoGridItem extends StatefulWidget {
  final int videoNumber;
  final VideoPlayerController controller;
  final Function()? onRemovePressed;

  VideoGridItem({
    required this.videoNumber,
    required this.controller,
    this.onRemovePressed,
  });
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
                  top: 2.0,
                  right: 8.0,
                  child: IconButton(
                    onPressed: widget.onRemovePressed,
                    icon: Icon(
                      Icons.highlight_remove_rounded,
                      size: 40.0,
                      color: Colors.white70,
                    ),
                  ),
                ),
                Positioned(
                  top: 8.0,
                  left: 8.0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.0,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Text(
                        widget.videoNumber.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
      final controller = VideoPlayerController.network(path)
        ..initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        });
      videoControllers.add(controller);
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
      appBar: VideoAppBar(
        title:'Edit Story',
      ),
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
                    videoNumber: index + 1,
                    controller: videoControllers[index],
                    onRemovePressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Color(0xFF263238),
                            content: Container(
                              height: 269,
                              width: 300,
                              child: Column(
                                children: [
                                  SizedBox(height: 30),
                                  Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Center(
                                      child: Image.asset('assets/images/saveDraftLogo.png'),
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  Text(
                                    'Are You Sure?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 25,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(),
                                      child: Column(
                                        children: [
                                          Text(
                                            'You are removing a video.',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      removeVideo(index); // Perform the remove functionality here
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Remove',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
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

      // Update the database
      if (updatedVideoPaths.isEmpty) {
        // If there are no video paths left, delete the entire draft
        DatabaseHelper.instance.deleteDraft(widget.draft.id);
      } else {
        // Otherwise, update the draft in the database
        DatabaseHelper.instance.updateDraft(widget.draft);
      }
    });
  }


  // void _showDeleteConfirmationDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text('Delete Draft?'),
  //         content: Text('You are about to delete the entire draft.'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               _deleteDraft();
  //             },
  //             child: Text('Delete'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void _deleteDraft() {
  //   // Delete the draft from the database
  //   DatabaseHelper.instance.deleteDraft(widget.draft.id);
  //   // Close the current page
  //   Navigator.of(context).pop();
  // }


}

void navigateToEditDraftPage(BuildContext context, Draft draft) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => EditDraftPage(draft: draft),
    ),
  );
}

