import 'dart:core';
import 'dart:js_util';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';


// Calendars Schema
class MeetTimings{
  List<String>? meetStartTime;
  List<String>? meetEndTime;

  Map<String, dynamic> toJson() {
    return {
      'meetStartTime': meetStartTime,
      'meetEndTime': meetEndTime,
    };
  }

  // factory MeetTimings.fromJson(Map<String, dynamic> json) {
  //   return MeetTimings()
  //     ..meetStartTime = (json['meetStartTime'] as List<String>?)
  //     ..meetEndTime = (json['meetEndTime'] as List<String>?);
  // }
}

// void printAllData(CalendarPlansData data) {
//   data.date!.forEach((key, meetTimings) {
//     print("Date: $key");
//     if (meetTimings != null) {
//       print("Meeting Start Times:");
//       for (var startTime in meetTimings.meetStartTime!) {
//         print(startTime);
//       }
//
//       print("Meeting End Times:");
//       for (var endTime in meetTimings.meetEndTime!) {
//         print(endTime);
//       }
//     } else {
//       print("No data available for $key.");
//     }
//     print("");
//   });
// }
//
// class CalendarPlansData{
//   Map<String, MeetTimings>? date;
//
//
//   CalendarPlansData({this.date});
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> serializedData = {};
//     date?.forEach((d, meetTimings) {
//       serializedData[d] = meetTimings.toJson();
//     });
//     return serializedData;
//   }
//
//   // factory CalendarPlansData.fromJson(Map<String, dynamic> json) {
//   //   final Map<String, MeetTimings> deserializedData = {};
//   //   json.forEach((date, data) {
//   //     deserializedData[date] = MeetTimings.fromJson(data);
//   //   });
//   //
//   //   return CalendarPlansData()..date = deserializedData;
//   // }
//   factory CalendarPlansData.fromJson(Map<String, dynamic>? json) {
//     print(json);
//     final CalendarPlansData data = CalendarPlansData(date: {});
//
//     json?.forEach((date, meetTimingsData) {
//       List<List<String>> l = [];
//       meetTimingsData.forEach((day, meetings) {
//         l.add((meetings as List<dynamic>).map((dynamic item) => item.toString()).toList());
//       });
//
//       // final List<String>? meetStartTime = (meetTimingsData['meetStartTime'] as List<String>?)
//       //     ?.map((String item) => item.toString())
//       //     .toList();
//       // final List<String>? meetEndTime = (meetTimingsData['meetEndTime'] as List<dynamic>?)
//       //     ?.map((dynamic item) => item.toString())
//       //     .toList();
//       // print(meetStartTime);
//
//       if (l[0] != null && l[1] != null) {
//         final MeetTimings meetTimings = MeetTimings()
//           ..meetStartTime = l[0]
//           ..meetEndTime = l[1];
//         data.date![date] = meetTimings;
//       } else {
//         print("No meetStartTime or meetEndTime data found for date: $date");
//       }
//     });
//
//     return data;
//   }
// }


// Trip Calling Schema - Frontend
class ServiceTripCallingData{
  String? setStartTime=null;
  String? setEndTime=null;
  String? slots=null;

  ServiceTripCallingData({this.setStartTime,this.setEndTime,this.slots});

  Map<String,dynamic> toJson(){
    return {
      'startTimeFrom' : setStartTime,
      'endTimeTo' : setEndTime,
      'slotsChossen' : slots,
    };
  }
}

class ServiceTripAssistantData{
  String? timeSlotStart;
  String? timeSlotEnd;
  String? guideId;
  String? date;


  ServiceTripAssistantData({this.timeSlotStart,this.timeSlotEnd,this.guideId,this.date});

  Map<String,dynamic> toJson(){
    return {
      'startMeetTime' : timeSlotStart,
      'startEndTime' : timeSlotEnd,
      'guideId' : guideId,
      'date' : date,
    };
  }
}

// Rating Fields
class RatingEntry {
  String? name;
  int? count;
  String? comment;

  RatingEntry({
    this.name,
    this.count,
    this.comment,
  });

  Map<String,dynamic> toJson(){
    return {
      'ratersName' : name,
      'ratersStar' : count,
      'ratersComment' : comment,
    };
  }
}


// Payment Section
class PaymentDetails {
  String? name,cardNo,month,year,cvv;

  PaymentDetails({
    this.name,
    this.month,
    this.year,
    this.cardNo,
    this.cvv
  });

  Map<String,dynamic> toJson(){
    return {
      'name' : name,
      'month' : month,
      'year' : year,
      'cardNo':cardNo,
      'cvv':cvv,
    };
  }
}

// Provider : Profile Data Class - Storing Database  fields
class ProfileData{
  String? userId,userSetId;
  String? imagePath;
  String? name;
  String? quote,emailId;
  int? followerCnt = 0;
  int? followingCnt = 0;
  int? locations = 1;
  DateTime?dob;
  String?profileStatus;
  int statusCnt=0;
  String? place;
  String?profession;
  String? gender;
  String? age;
  bool service1 = false,service2=false;
  List<String>?languages;
  ServiceTripCallingData? tripCallingData;
  bool? tripAssistantData=false;
  List<RatingEntry>? reviewSection;
  List<PaymentDetails>? paymentDetail;

  ProfileData({this.userId,this.name,this.imagePath,this.quote,this.followerCnt,this.locations,this.followingCnt,
    this.place,this.profession,this.age,this.languages,this.gender,
    this.tripCallingData,this.reviewSection,this.tripAssistantData,this.paymentDetail,this.emailId,this.dob});

  Map<String,dynamic> toJson(){
    return {
      'userId':userSetId,
      'userPhoto':imagePath,
      'userName':name,
      'emailId':emailId,
      'userDOB':dob?.toUtc()?.toIso8601String(),
      'profileStatus':profileStatus,
      'userQuote':quote,
      'userFollowers':followerCnt==null?0:followerCnt,
      'userFollowing':followingCnt==null?0:followingCnt,
      'userExploredLocations' : locations==null?1:locations,
      'userPlace':place,
      'userProfession':profession,
      'userAge':age,
      'userGender':gender,
      'userLanguages':languages,
      'userServiceTripCallingData':tripCallingData?.toJson(),
      'userServiceTripAssistantData':tripAssistantData,
      'userReviewsData' : reviewSection?.map((entry)=>entry.toJson()).toList(),
      'userPaymentData' : paymentDetail?.map((entry)=>entry.toJson()).toList(),
    };
  }
}
class ProfileDataProvider extends ChangeNotifier {
  ProfileData _profileData = ProfileData();
  ProfileData get profileData => _profileData;


  void setUserId(String id) {
    _profileData.userSetId = id;
    print('Path is $id');
    notifyListeners();
  }
  String? retUserId(){
    return _profileData.userSetId;
  }


  void updateImagePath(String path) {
    _profileData.imagePath = path;
    print('Path is $path');
    notifyListeners();
  }

  void updateName(String userName) {
    _profileData.name = userName;
    print('Path is $userName');
    notifyListeners();
  }

  String? retUserName(){
    return _profileData.name;
  }

  void updateEmail(String emailId){
    _profileData.emailId = emailId;
    print('Path is $emailId');
    notifyListeners();
  }


  void updateFieldCnt(int score){
    _profileData.statusCnt+=score;
    notifyListeners();
    return;
  }

  int retFieldsCnt(){
    return _profileData.statusCnt;
  }

  void updateDOb(DateTime dob){
    _profileData.dob = dob;
    notifyListeners();
    return;
  }

  void setProfileStatus(String status){
    _profileData.profileStatus = status;
    notifyListeners();
    return;
  }

  void updateQuote(String userQuote) {
    _profileData.quote = userQuote;
    print('Path is $userQuote');
    notifyListeners();
  }

  void updateFollowersCnt(int userFollowers){
    _profileData.followerCnt = userFollowers==null?0:userFollowers;
    print('Path1 is $userFollowers');
    notifyListeners();
  }

  void updateFollowingCnt(int userFollowering){
    _profileData.followingCnt = userFollowering==null?0:userFollowering;
    print('Path2 is $userFollowering');
    notifyListeners();
  }

  void updateLocationsCnt(int userExploredLocations){
    _profileData.locations = userExploredLocations==null?0:userExploredLocations;
    print('Path3 is $userExploredLocations');
    notifyListeners();
  }

  void updatePlace(String userPlace) {
    _profileData.place = userPlace;
    print('Path is $userPlace');
    notifyListeners();
  }

  void updateProfession(String userProfession) {
    _profileData.profession = userProfession!;
    print('Path is $userProfession');
    notifyListeners();
  }

  void updateAge(String userAge) {
    _profileData.age = userAge!;
    print('Path is ${ _profileData.age}');
    notifyListeners();
  }

  void updateGender(String userGender) {
    _profileData.gender = userGender!;
    notifyListeners();
  }

  void updateLanguages(List<String> languages) {
    _profileData.languages = languages!;
    print('Path is ${_profileData.languages}');
    notifyListeners();
  }

  void unsetTripCalling(){
    _profileData.tripCallingData = null;
    print('done it');
    notifyListeners();
    return;
  }
  void setStartTime(String?startTime) {
    if (_profileData.tripCallingData == null) {
      _profileData.tripCallingData = ServiceTripCallingData(); // Initialize if null
    }
    _profileData.tripCallingData!.setStartTime = startTime!;
    print('Path is $startTime');
    notifyListeners();
  }

  // bool isStartTimeSet(){
  //   print((_profileData.tripCallingData!.setStartTime)!=null);
  //   return (_profileData.tripCallingData!.setStartTime)!=null;
  // }

  String? retStartTime(){
    print('Time:${_profileData.tripCallingData?.setStartTime}');
     return _profileData.tripCallingData!.setStartTime==null?'':_profileData.tripCallingData!.setStartTime;
  }

  void setEndTime(String endTime) {
    if (_profileData.tripCallingData == null) {
      _profileData.tripCallingData = ServiceTripCallingData(); // Initialize if null
    }
    _profileData.tripCallingData!.setEndTime = endTime!;
    print('Path is $endTime');
    notifyListeners();
  }

  String? retEndTime(){
    return _profileData.tripCallingData!.setEndTime==null?'': _profileData.tripCallingData!.setEndTime;
  }

  void setSlots(String slot){
    if (_profileData.tripCallingData == null) {
      _profileData.tripCallingData = ServiceTripCallingData(); // Initialize if null
    }
    _profileData.tripCallingData!.slots = slot!;
    print('Path is $slot');
    notifyListeners();
  }
  void setServide1(){
    _profileData.service1 = !_profileData.service1;
    print('Set Service');
    notifyListeners();
  }

  bool retServide1(){
    print(111);
    return _profileData.service1;
  }

  void setServide2(){
    _profileData.service2 = !_profileData.service2;
    print('Set Service');
    notifyListeners();
  }

  bool retServide2(){
    print(111);
    return _profileData.service2;
  }

  String? retSlots(){
    return _profileData.tripCallingData!.slots;
  }

  // void setGuideId(String id){
  //   if (_profileData.tripAssistantData == null) {
  //     _profileData.tripAssistantData = ServiceTripAssistantData(); // Initialize if null
  //   }
  //   _profileData.tripAssistantData!.guideId = id!;
  //   print('Path is $id');
  //   notifyListeners();
  // }
  //
  // void setDate(String time){
  //   if (_profileData.tripAssistantData == null) {
  //     _profileData.tripAssistantData = ServiceTripAssistantData(); // Initialize if null
  //   }
  //   _profileData.tripAssistantData!.guideId = time!;
  //   print('Path is $time');
  //   notifyListeners();
  // }


  void addRatings(RatingEntry rating){
    if (_profileData.reviewSection == null) {
      _profileData.reviewSection = []; // Initialize if null
    }
    _profileData.reviewSection!.add(rating);
    print('Path is ${rating.name}');
    notifyListeners();
  }


  void addCardDetails(PaymentDetails details){
    if (_profileData.paymentDetail == null) {
      _profileData.paymentDetail = []; // Initialize if null
    }
    _profileData.paymentDetail!.add(details);
    print('Path is ${details}');
    notifyListeners();
  }

  void removeCard(int index){
    _profileData.paymentDetail!.removeAt(index);
    print('Removed');
    notifyListeners();
  }
  void removeAllCards(){
    _profileData.paymentDetail = [];
    print('All Removed');
    notifyListeners();
  }
}

// Single Story Schema -> VideoCards Details
class CardItem {
  final String image;
  // final String videoUrl;
  final int countVideos;
  final String location;
  final String category;
  final int viewCnt;
  final int likes;
  final String distance;

  CardItem({
    required this.image,
    required this.location,
    required this.countVideos,
    required this.category,
    required this.viewCnt,
    required this.likes,
    required this.distance,
    // required this.videoUrl,
  });
}

