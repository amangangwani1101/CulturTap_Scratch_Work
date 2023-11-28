import 'package:flutter/material.dart';
import 'package:learn_flutter/CustomItems/VideoAppBar.dart';
import 'package:learn_flutter/CustomItems/imagePopUpWithOK.dart';
import 'package:learn_flutter/Utils/BackButtonHandler.dart';
import 'package:learn_flutter/VIdeoSection/Draft/DraftVideoListPage.dart';
import 'package:learn_flutter/VIdeoSection/Draft_Local_Database/database_helper.dart';
import 'package:learn_flutter/VIdeoSection/Draft_Local_Database/draft.dart';
import 'package:learn_flutter/VIdeoSection/RemoveDialog.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class SavedDraftsPage extends StatefulWidget {
  @override
  _SavedDraftsPageState createState() => _SavedDraftsPageState();
}

class _SavedDraftsPageState extends State<SavedDraftsPage> {
  List<Draft> drafts = [];
  List<VideoPlayerController> videoControllers = [];
  List<bool> isPlaying = [];
  bool isEditStoryClicked = false;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  @override
  void dispose() {
    for (var controller in videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDrafts() async {
    final database = await DatabaseHelper.instance.database;
    final draftList = await database.query('drafts');
    setState(() {
      drafts = draftList.map((e) => Draft.fromMap(e)).toList().cast<Draft>();

      for (var draft in drafts) {
        var videoPaths = draft.videoPaths.split(',');
        if (videoPaths.isNotEmpty) {
          print('Video Paths for Draft "${draft.storyTitle}":');
          for (var videoPath in videoPaths) {
            print(videoPath);
          }
          var controller = VideoPlayerController.file(File(videoPaths[0]));
          videoControllers.add(controller);
          isPlaying.add(false);
          controller.initialize().then((_) {
            setState(() {});
          });
        } else {
          if (draft.id != null) {
            DatabaseHelper.instance.deleteDraft(draft.id!);
          }

        }
      }
    });
  }


  Future<void> _deleteDraft(int index) async {
    if (index < drafts.length) {
      final draftToDelete = drafts[index];
      // Delete the draft from the local database
      await DatabaseHelper.instance.deleteDraft(draftToDelete.id!);
      // Dispose of the video controller
      videoControllers[index].dispose();
      // Remove the draft and video controller from the lists
      setState(() {
        drafts.removeAt(index);
        videoControllers.removeAt(index);
      });
    }
  }

  Future<AlertDialog> deleteStory(index) async{
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
                child: Image.asset('assets/images/remove.png'),
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
                      'You are removing a film shoot',
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
            TextButton(
              onPressed: () {
                _deleteDraft(index);
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
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }
  Future<void> _refreshDrafts() async {

    await _loadDrafts();
  }

  BackButtonHandler backButtonHandler3 = BackButtonHandler(
    imagePath: 'assets/images/exit.svg',
    textField: 'HomePage',
    what: 'Home',
    button1: 'Yes',
    button2: 'No',
  );

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
        onWillPop: () => backButtonHandler3.onWillPop(context, true),
    child: Scaffold(
      appBar: VideoAppBar(
        title:'Your Drafts',
        exit: 'home',
      ),
      backgroundColor: Color(0xFF263238),
      body: RefreshIndicator(
        backgroundColor: Color(0xFF263238),
        color: Colors.orange,
        onRefresh: _refreshDrafts,
        child: drafts.isEmpty
            ? Center(child: Text('No saved drafts found.',style: TextStyle(color :Colors.white, fontWeight: FontWeight.bold,fontSize: 20),))
            : ListView.builder(
          itemCount: drafts.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                Container(
                  height: 360,
                  color: Color(0xFF263238),
                  padding: EdgeInsets.only(left: 36, right: 36, top: 25),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildVideoPlayer(index),
                      ),
                      Expanded(
                        flex: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            _buildVideoCount(index),
                            Padding(
                              padding: const EdgeInsets.only(left:28.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Title ',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    drafts[index].storyTitle,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 28.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Location  ',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${drafts[index].liveLocation}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 28.0),
                              child: Container(
                                width: 146,
                                height: 63,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DraftVideoListPage(draft: drafts[index]),
                                      ),
                                    );
                                    setState(() {
                                      isEditStoryClicked = !isEditStoryClicked;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: isEditStoryClicked
                                        ? Colors.orange
                                        : Colors.transparent, // Change background color
                                    elevation: 0, // No shadow
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      side: BorderSide(color: Colors.orange, width: 2.0),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                  ),
                                  child: Text(
                                    'Edit Story',
                                    style: TextStyle(
                                      color: isEditStoryClicked
                                          ? Colors.white
                                          : Colors.orange, // Change text color
                                      fontWeight: FontWeight.bold, // Change font weight
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            SizedBox(height:15),
            Divider(
            color: Colors.white, // Set the color of the line to white
            thickness: 0.2,      // Set the thickness of the line
            height: 10.0,        // Set the height of the line
            ),
              ],
            );
          },
        ),
      ),
    )
    );
  }

  Widget _buildVideoPlayer(int index) {
    if (videoControllers.length > index) {
      final VideoPlayerController controller = videoControllers[index];
      return AspectRatio(
        aspectRatio: 9 / 16,
        child: Stack(

          children: [
            VideoPlayer(controller),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: !isPlaying[index]
                  ? GestureDetector(
                onTap: () {
                  setState(() {
                    if (isPlaying[index]) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                    isPlaying[index] = !isPlaying[index];
                  });
                },
                child: Center(
                  child: Icon(
                    isPlaying[index] ? Icons.pause_circle : Icons.play_arrow,
                    size: 38.0,
                    color: Colors.white,
                  ),
                ),
              )
                  : SizedBox(), // Hide the play button when video is playing
            ),
          ],
        ),
      );
    } else {
      return CircularProgressIndicator(
        color: Colors.orange,
      );
    }
  }

  Widget _buildVideoCount(int index) {
    int videoCount = drafts[index].videoPaths.split(',').length;
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            IconButton(
              icon: Icon(Icons.video_library),
              color: Colors.white,
              onPressed: () {
                // Add the action you want when the video film icon is pressed
              },
            ),
            Text(
              '$videoCount',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ],),

          IconButton(
            icon: Icon(Icons.delete),
            color: Colors.white,
            onPressed: () {

              showDialog(
                context: context,
                builder: (context) {
                  return RemoveVideoDialog(onRemove: (){
                    _deleteDraft(index);
                  },what : 'story',);
                },
              );


              // _deleteDraft(index);



            },
          ),



        ],
      ),
    );
  }
}
