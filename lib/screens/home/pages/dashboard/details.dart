import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:shimmer/shimmer.dart';

import 'audioPlayer.dart';

class Details extends StatefulWidget {
  final String id;
  final String coverImage;
  final String name;
  Details({this.id, this.coverImage, this.name});
  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  final PageController ctrl = PageController(viewportFraction: 0.8);
  int currentPage = 0;
  List audioDetailsList = [];

  @override
  void initState() {
    ctrl.addListener(() {
      int next = ctrl.page.round();

      if (currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });
    super.initState();
    _getAudioDetailsAndCheckExpiry();
  }

  _getAudioDetailsAndCheckExpiry() async {
    return FirebaseFirestore.instance
        .collection('fl_content')
        .where("id", isEqualTo: widget.id)
        .snapshots()
        .listen((data) async {
      audioDetailsList.clear();
      for (var items in data.docs[0]['audios']) {
        Map tempObj = {};
        tempObj['audioFile'] =
            await items['audioFile'][0].get().then((documentSnapshot) {
          return documentSnapshot.data()['file'];
        });
        tempObj['audioCoverImage'] =
            await items['audioCoverImage'][0].get().then((documentSnapshot) {
          return documentSnapshot.data()['file'];
        });

        tempObj['audioDescription'] = items['audioDescription'];
        tempObj['audioName'] = items['audioName'];
        tempObj['isPaid'] = items['isPaid'];

        audioDetailsList.add(tempObj);
      }
      if (mounted) {
        setState(() {});
      }
      return audioDetailsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AnimatedOpacity(
        opacity: 1.0,
        duration: Duration(milliseconds: 50),
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0, left: 10.0),
          child: FloatingActionButton(
            elevation: 10,
            child: BackButton(
              color: Colors.black,
            ),
            backgroundColor: Colors.white30,
            onPressed: () {
              dispose();
              Navigator.pop(context);
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: <Widget>[
            Container(height: 20),
            Hero(
              tag: widget.id,
              child: Container(
                height: 85,
                width: double.infinity,
                padding: const EdgeInsets.only(left: 40),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(
                          "https://firebasestorage.googleapis.com/v0/b/${GlobalConfiguration().get("firebaseProjectID")}.appspot.com/o/flamelink%2Fmedia%2F${widget.coverImage}?alt=media",
                        ),
                        alignment: Alignment.centerRight,
                        fit: BoxFit.cover)),
                child: Text(
                  "${widget.name}",
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: PageView.builder(
                    controller: ctrl,
                    itemCount: audioDetailsList.length + 1,
                    itemBuilder: (BuildContext context, int currentIdx) {
                      Widget content = SizedBox();
                      if (currentIdx == 0) {
                        content = audioDetailsList.length == 0
                            ? Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor: Colors.black,
                                child: _buildTagPage())
                            : _buildTagPage();
                      } else if (audioDetailsList.length >= currentIdx) {
                        // Active page

                        bool active = currentIdx == currentPage;
                        content = _buildStoryPage(
                            audioDetailsList[currentIdx - 1],
                            active,
                            currentIdx);
                      }
                      return content;
                    }),
              ),
            ),
            Container(
              height: 100,
            )
          ],
        ),
      ),
    );
  }

  _buildStoryPage(data, bool active, int index) {
    final double blur = active ? 30 : 0;
    final double offset = active ? 20 : 0;
    final double top = active ? 40 : 100;
    return InkWell(
      onTap: () async {
        Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => AudioPlayerDemo(
                    audioName: data['audioName'],
                    url: Uri.tryParse(
                            "https://firebasestorage.googleapis.com/v0/b/${GlobalConfiguration().get("firebaseProjectID")}.appspot.com/o/flamelink%2Fmedia%2F${data['audioFile']}?alt=media")
                        .toString(),
                  )),
        );
      },
      child: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Opacity(
                opacity: 1.0,
                child: Container(
                  child: AnimatedContainer(
                    width: double.infinity,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeOutQuint,
                    margin: EdgeInsets.only(top: top, bottom: 50, right: 30),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              "https://firebasestorage.googleapis.com/v0/b/${GlobalConfiguration().get("firebaseProjectID")}.appspot.com/o/flamelink%2Fmedia%2F${data['audioCoverImage']}?alt=media",
                            )),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: blur,
                              offset: Offset(offset, offset))
                        ]),
                    alignment: Alignment.bottomLeft,
                    padding:
                        const EdgeInsets.only(bottom: 70, left: 30, right: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        SizedBox(height: 40),
                        Text(
                          "${data['audioName']} ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              wordSpacing: 3.0,
                              letterSpacing: 1.0,
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Opacity(
              opacity: active ? 1.0 : 0.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  data['audioDescription'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontStyle: FontStyle.italic, color: Color(0xFF272121)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildTagPage() {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.name,
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
      ],
    ));
  }
}
