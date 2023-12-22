import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../UserProfile/ProfileHeader.dart';
import '../../../widgets/hexColor.dart';


void main(){
  runApp(ChatsPage(userId:'65730cc45e3deb40f1067aca',state:'user'));
}

class ChatsPage extends StatefulWidget {
  String userId;
  String ? state;
  ChatsPage({required this.userId,this.state});
  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  List<String>userIds = [];
  List<String>distance = [];
  List<String>suggestedTexts = [
    'Need Mechanical help for my car ',
    'My Vehicle get Puncture  ',
    'My vehicle is out of fuel ',
    'My car battery get discharge ',
    'I need medical assistance ',
    'My car battery get discharge ',
    'I need medical assistance ',

  ];
  bool _isUiEnabled = true;
  final TextEditingController _controller = TextEditingController();
  bool pageVisitor = true; // true means person coming to this page is user while in else condition its helper
  bool messageTyping = false;
  @override
  void initState() {
    super.initState();
    if(widget.state!='user'){
      pageVisitor = false;
    }
    if(pageVisitor){
      userIds = ['6572878e19d698a615ce275a','6572cc23e816febdac42873b'];
      distance = ['0.05','0.09'];
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: ProfileHeader(reqPage: 5,userId: '',),),
        body: SingleChildScrollView(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [

                        SizedBox(width: 25,),
                        Column(
                          children: [
                            pageVisitor?
                            Column(
                              children: [
                                Container(
                                  color: Colors.grey.withOpacity(0.3),
                                  width: 286,
                                  height: 246,
                                  padding: EdgeInsets.all(13),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                          width: 236,
                                          child: Text('Hello ! How can Culturtap help you?',textAlign: TextAlign.justify,style: TextStyle(fontSize: 13,fontFamily: 'Poppins',fontWeight: FontWeight.w600),)),
                                      Container(
                                          width: 236,
                                          child: Text('You can find here local assistance immediately, we have found ' + '${userIds.length} helping hands' + ' near you.Please raise request for help'
                                            ,textAlign: TextAlign.justify,style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'Poppins',fontSize: 13),)),
                                      Container(
                                        width: 236,
                                        child: Text('Type your request carefully before sending it to the local assistant .',textAlign: TextAlign.justify,
                                          style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'Poppins',fontSize: 13,color: Colors.green),),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children:List.generate(suggestedTexts.length, (index) {
                                    return GestureDetector(
                                      onTap: (){
                                        print('Text: ${suggestedTexts[index]}');
                                        setState(() {
                                          messageTyping = true;
                                          _controller.text = suggestedTexts[index];
                                        });
                                      },
                                      child: Container(
                                        width: 276,
                                        height: 69,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.black12,
                                          ),
                                        ),
                                        padding: EdgeInsets.all(25),
                                        margin: EdgeInsets.only(bottom: 0.2),
                                        child: Text(suggestedTexts[index],
                                          style: TextStyle(fontWeight: FontWeight.w500,fontFamily: 'Poppins',fontSize: 13),),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ):SizedBox(height: 0,),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(child: SizedBox(height: 10,)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 20,),
                        Flexible(
                          child: Container(
                            width: messageTyping?screenWidth:screenWidth*0.70,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: _isUiEnabled?Colors.grey.withOpacity(0.2):Colors.grey,
                            ),
                            padding: EdgeInsets.only(left: 10,right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: TextField(
                                    onChanged: (text){
                                      if(text.length>0){
                                        setState(() {
                                          messageTyping = true;
                                        });
                                      }
                                      else{
                                        setState(() {
                                          messageTyping = false;
                                        });
                                      }
                                    },
                                    maxLines: null,
                                    controller: _controller,
                                    decoration: InputDecoration(hintText: 'Start Typing Here...',border: InputBorder.none,),
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Image.asset('assets/images/attach_icon.png'),
                                messageTyping==false?SizedBox(width: 20,):SizedBox(width: 5,),
                                messageTyping==false?Image.asset('assets/images/send_icon.png'):SizedBox(width: 0,),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 5,),
                        messageTyping==false? Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: _isUiEnabled?HexColor('#F2F2F2').withOpacity(0.2):HexColor('#F2F2F2')),
                          child: IconButton(
                            icon: Icon(Icons.call),
                            onPressed:(){},
                            // onPressed: !_isUiEnabled ? startCall : null,
                          ),
                        ):SizedBox(width: 0,),
                        messageTyping==false? SizedBox(width: 0,):SizedBox(width: 5,),
                        messageTyping==false? Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: _isUiEnabled?HexColor('#F2F2F2').withOpacity(0.2):HexColor('#F2F2F2')),
                          child: IconButton(
                            icon: Icon(Icons.videocam),
                            // onPressed:initiateVideoCall,
                            onPressed: (){},
                          ),
                        ):Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color: Colors.green),
                            child: Image.asset('assets/images/send_icon.png')),
                        messageTyping==false?SizedBox(width: 0,):SizedBox(width: 10,),
                      ],
                    ),
                    SizedBox(height: 6,),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
}
