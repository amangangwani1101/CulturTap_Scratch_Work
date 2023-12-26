import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import './SignallingService.dart';

class CallScreen extends StatefulWidget  implements PreferredSizeWidget{
  final String callerId, calleeId,section,imageOwn,imageOther;
  final dynamic offer;
  const CallScreen({
    super.key,
    this.offer,
    required this.section,
    required this.callerId,
    required this.calleeId,
    required this.imageOwn,
    required this.imageOther,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

}

class _CallScreenState extends State<CallScreen> {
  // socket instance
  final socket = SignallingService.instance.socket;

  // videoRenderer for localPeer
  final _localRTCVideoRenderer = RTCVideoRenderer();

  // videoRenderer for remotePeer
  final _remoteRTCVideoRenderer = RTCVideoRenderer();

  // mediaStream for localPeer
  MediaStream? _localStream;

  // RTC peer connection
  RTCPeerConnection? _rtcPeerConnection;

  // list of rtcCandidates to be sent over signalling
  List<RTCIceCandidate> rtcIceCadidates = [];

  // media status
  bool isVolumeDown=false , isAudioOn = true, isVideoOn = true, isFrontCameraSelected = true;
  late Timer _timer;
  int _seconds = 0;

  @override
  void initState() {
    // initializing renderers
    _localRTCVideoRenderer.initialize();
    _remoteRTCVideoRenderer.initialize();

    // setup Peer Connection
    _setupPeerConnection();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _setupPeerConnection() async {
    // create peer connection
    _rtcPeerConnection = await createPeerConnection({
      'iceServers': [
        {
          'urls': [
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302'
          ]
        }
      ]
    });

    // listen for remotePeer mediaTrack event
    _rtcPeerConnection!.onTrack = (event) {
      _remoteRTCVideoRenderer.srcObject = event.streams[0];
      setState(() {});
    };

    // get localStream
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': isAudioOn,
      'video': isVideoOn
          ? {'facingMode': isFrontCameraSelected ? 'user' : 'environment'}
          : false,
    });

    // add mediaTrack to peerConnection
    _localStream!.getTracks().forEach((track) {
      _rtcPeerConnection!.addTrack(track, _localStream!);
    });

    // set source for local video renderer
    _localRTCVideoRenderer.srcObject = _localStream;
    setState(() {});

    // for Incoming call
    if (widget.offer != null) {
      // listen for Remote IceCandidate
      socket!.on("IceCandidate", (data) {
        String candidate = data["iceCandidate"]["candidate"];
        String sdpMid = data["iceCandidate"]["id"];
        int sdpMLineIndex = data["iceCandidate"]["label"];

        // add iceCandidate
        _rtcPeerConnection!.addCandidate(RTCIceCandidate(
          candidate,
          sdpMid,
          sdpMLineIndex,
        ));
      });

      // set SDP offer as remoteDescription for peerConnection
      await _rtcPeerConnection!.setRemoteDescription(
        RTCSessionDescription(widget.offer["sdp"], widget.offer["type"]),
      );

      // create SDP answer
      RTCSessionDescription answer = await _rtcPeerConnection!.createAnswer();

      // set SDP answer as localDescription for peerConnection
      _rtcPeerConnection!.setLocalDescription(answer);

      // send SDP answer to remote peer over signalling
      socket!.emit("answerCall", {
        "callerId": widget.callerId,
        "sdpAnswer": answer.toMap(),
      });
      _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
        setState(() {
          _seconds++;
        });
      });
    }
    // for Outgoing Call
    else {
      // listen for local iceCandidate and add it to the list of IceCandidate
      _rtcPeerConnection!.onIceCandidate =
          (RTCIceCandidate candidate) => rtcIceCadidates.add(candidate);

      // when call is accepted by remote peer
      socket!.on("callAnswered", (data) async {
        // set SDP answer as remoteDescription for peerConnection
        await _rtcPeerConnection!.setRemoteDescription(
          RTCSessionDescription(
            data["sdpAnswer"]["sdp"],
            data["sdpAnswer"]["type"],
          ),
        );
        _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
          setState(() {
            _seconds++;
          });
        });
        // send iceCandidate generated to remote peer over signalling
        for (RTCIceCandidate candidate in rtcIceCadidates) {
          socket!.emit("IceCandidate", {
            "calleeId": widget.calleeId,
            "iceCandidate": {
              "id": candidate.sdpMid,
              "label": candidate.sdpMLineIndex,
              "candidate": candidate.candidate
            }
          });
        }
      });

      // create SDP Offer
      RTCSessionDescription offer = await _rtcPeerConnection!.createOffer();

      // set SDP offer as localDescription for peerConnection
      await _rtcPeerConnection!.setLocalDescription(offer);

      // make a call to remote peer over signalling
      socket!.emit('makeCall', {
        "calleeId": widget.calleeId,
        "sdpOffer": offer.toMap(),
        "section":widget.section,
        "imageOwn":widget.imageOwn,
        "imageOther":widget.imageOther,
      });
    }
  }

  _leaveCall() {
    Navigator.pop(context);
  }

  _toggleMic() {
    // change status
    isAudioOn = !isAudioOn;
    // enable or disable audio track
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = isAudioOn;
    });
    setState(() {});
  }

  _toggleCamera() {
    // change status
    isVideoOn = !isVideoOn;

    // enable or disable video track
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = isVideoOn;
    });
    setState(() {});
  }

  _toggleVolume() {
    // change status
    isVolumeDown = !isVolumeDown;

    // get audio tracks
    _localStream?.getAudioTracks().forEach((track) {
      // set volume based on the status
      track.enableSpeakerphone(isVolumeDown);
    });
    setState(() {});
  }

  _switchCamera() {
    // change status
    isFrontCameraSelected = !isFrontCameraSelected;

    // switch camera
    _localStream?.getVideoTracks().forEach((track) {
      // ignore: deprecated_member_use
      track.switchCamera();
    });
    setState(() {});
  }
  String _formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);
    String hours = (duration.inHours % 24).toString().padLeft(2, '0');
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String remainingSeconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      return '$hours:$minutes:$remainingSeconds';
    } else {
      return '$minutes:$remainingSeconds';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('CulturTap',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30.0),
          child: Text('${_formatDuration(_seconds)}',style: TextStyle(fontSize: 14,fontWeight: FontWeight.w800,color: Colors.white,),),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Container(
          width: screenWidth,
          decoration: BoxDecoration(
            color: Colors.black87,
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(children: [
                  widget.section=='video' && isVideoOn
                  ?RTCVideoView(
                    _remoteRTCVideoRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                  :Center(child: Container(
                    width: 150,
                    height: 150,
                    child: CircleAvatar(
                      backgroundImage: FileImage(File(widget.imageOwn)) as ImageProvider<Object>,// Use a default asset image
                    ),
                    decoration:BoxDecoration(borderRadius: BorderRadius.circular(100),
                      color: Colors.orange.withOpacity(1),
                    ),)),
                  widget.section=='video'
                      ? Positioned(
                    right: 20,
                    bottom: 20,
                    child: SizedBox(
                      height: 150,
                      width: 120,
                      child: RTCVideoView(
                        _localRTCVideoRenderer,
                        mirror: isFrontCameraSelected,
                        objectFit:
                        RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    ),
                  )
                      :SizedBox(height: 0,),
                  if(widget.section=='video' && isVideoOn)
                    Positioned(
                      top: 20,
                      right: 20,
                      child: IconButton(
                        iconSize: 30,
                        color: Colors.white,
                        icon: const Icon(Icons.cameraswitch),
                        onPressed: _switchCamera,
                      ),
                    ),
                ]),
              ),
              Container(
                height: 80,
                padding: EdgeInsets.only(top: 10,bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.black,
                 ),
                width: screenWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0)
                      ),
                      child: IconButton(
                        iconSize: 30,
                        color: isAudioOn?Colors.white:Colors.red,
                        icon: Icon(isAudioOn ? Icons.mic : Icons.mic_off),
                        onPressed: _toggleMic,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                        color: Colors.red,
                      ),
                      child: IconButton(
                        color: Colors.white,
                        icon: Icon(Icons.call_end),
                        iconSize: 30,
                        onPressed: _leaveCall,
                      ),
                    ),
                    widget.section=='video'
                        ? IconButton(
                      iconSize: 30,
                      color: isVideoOn?Colors.white:Colors.red,
                      icon: Icon(isVideoOn ? Icons.videocam : Icons.videocam_off),
                      onPressed: _toggleCamera,
                    )
                        : Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0)
                      ),
                          child: IconButton(
                            color: isVolumeDown?Colors.green:Colors.white,
                            icon: Icon(!isVolumeDown ? Icons.volume_down : Icons.volume_up),
                            iconSize: 30,
                            onPressed: _toggleVolume,
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _localRTCVideoRenderer.dispose();
    _remoteRTCVideoRenderer.dispose();
    _localStream?.dispose();
    _rtcPeerConnection?.dispose();
    super.dispose();
  }
}


