import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thrive_pilot/models/summary.dart';
import 'package:thrive_pilot/utils/api.dart';
import 'package:thrive_pilot/utils/app_colors.dart';
import 'package:thrive_pilot/widgets/dashboard_table.dart';

import 'pages/calendar_events.dart';
import 'pages/dashboard/details.dart';
import 'pages/dashboard/stories.dart';
import 'pages/settings/setting.dart';
import 'pages/timer/timer.dart';

// import 'explore.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

// Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
//   print(message);
// }

class _HomeState extends State<Home> with WidgetsBindingObserver {
  Summary summary;
  String username = "", photoUrl;
  bool isStored = false;
  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // if (prefs.containsKey("isStored")) {
    // try {
    Dio dio = Dio();
    Response response = await dio.post(baseUrl + "get_minute.php",
        data: FormData.fromMap(
            {"email": FirebaseAuth.instance.currentUser.email}));
    print(response.data);
    var data = jsonDecode(response.data);
    setState(() {
      isStored = true;
      summary = Summary.fromJson(data["data"]);
    });
    // } catch (e) {
    //   print(e);
    // }
    // }
  }

  @override
  void dispose() {
    super.dispose();
    categoryList.clear();
  }

  initState() {
    super.initState();
    getData();
    currentuser();
    _getFeaturedStories();
    _getCategories();
    // if (FirebaseAuth.instance.currentUser.displayName == null ||
    //     FirebaseAuth.instance.currentUser.displayName.isEmpty) {
    //   currentuser();
    // }
    WidgetsBinding.instance.addObserver(this);
  }

  List featuredStoryList = [];

  _getFeaturedStories() async {
    return FirebaseFirestore.instance
        .collection('fl_content')
        .where("_fl_meta_.schema", isEqualTo: "featuredStories")
        .snapshots()
        .listen((data) async {
      featuredStoryList =
          []; // Empty the array if database changes. Otherwise multiple stories will be made.
      Map<String, dynamic> fetchedObj;
      for (var doc in data.docs) {
        fetchedObj = doc.data();
        String coverImage =
            await doc['coverImage'][0].get().then((documentSnapshot) {
          return documentSnapshot.data()['file'];
        });
        fetchedObj['coverImage'] = coverImage;
        featuredStoryList.add(fetchedObj);
      }
      if (mounted) setState(() {});
      return featuredStoryList;
    });
  }

  List categoryList = [];

  _getCategories() async {
    return FirebaseFirestore.instance
        .collection('fl_content')
        .where("_fl_meta_.schema", isEqualTo: "categories")
        .snapshots()
        .listen((data) async {
      categoryList.clear();
      Map fetchedObj;
      for (var doc in data.docs) {
        fetchedObj = doc.data();

        String coverImage =
            await doc['coverImage'][0].get().then((documentSnapshot) {
          return documentSnapshot.data()['file'];
        });
        fetchedObj['coverImage'] = coverImage;
        categoryList.add(fetchedObj);
      }
      if (mounted) setState(() {});
      return categoryList;
    });
  }

  int _selectedIndex = 0;

  List<Widget> pages = [];
  appBarWidget() {
    return Positioned(
      top: -10,
      height: 270,
      width: MediaQuery.of(context).size.width,
      child: Container(
        color: AppColors.primaryColor,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[]),
        ),
      ),
    );
  }

  currentuser() async {
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    var user = _firebaseAuth.currentUser;

    FirebaseFirestore.instance
        .collection("fl_content")
        .doc("${user.uid}")
        .snapshots()
        .listen((onData) async {
      print(onData.data());
      if (this.mounted)
        setState(() {
          username = onData.data()["name"] == null
              ? ""
              : onData.data()["name"].toString();
          photoUrl = onData.data()["photoUrl"].toString().length <= 0
              ? null
              : onData.data()["photoUrl"];
        });
    });

    return user;
  }

  buildWidget() {
    return Positioned(
      // top: MediaQuery.of(context).size.height * 0.02,
      width: MediaQuery.of(context).size.width,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(gradient: AppColors.gradient),
              padding: EdgeInsets.only(bottom: 15),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 15, bottom: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          maxRadius: 20,
                          backgroundImage: photoUrl == null
                              ? AssetImage("assets/images/dummy.png")
                              : NetworkImage(
                                  photoUrl.replaceAll("s96-c", "s400-c")),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          "Hello $username,",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 32, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  summary == null
                      ? Container()
                      : isStored
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                children: [
                                  Text(
                                    "Mindful Productivity",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 28),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  DashboardTable(
                                    title: "Mindful Minutes",
                                    data: summary.meditate,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  DashboardTable(
                                    title: "Focus Minutes",
                                    data: summary.focus,
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                ],
              ),
            ),
            SizedBox(height: 30),
            featuredStoryList.length > 0 ? buildMeditationStep() : Container(),
            SizedBox(height: 30),
            buildCategories(),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget _page1 = SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height +
              120 * (categoryList.length / 2).round().toDouble(),
          // height: MediaQuery.of(context).size.height + 190,
          child: Stack(children: <Widget>[
            // appBarWidget(),
            buildWidget(),
          ]),
        ));
    Widget _progress = Dashboard();
    // Widget _explore = Explore();
    Widget _setting = Setting();
    pages = [_page1, _progress, _setting];
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          "assets/images/logo.png",
          width: MediaQuery.of(context).size.width * 0.5,
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              icon: Icon(
                Icons.calendar_today,
                color: AppColors.primaryColor,
              ),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => CalendarEvents()));
              }),
        ],
      ),
      body: Stack(
        children: <Widget>[
          pages.elementAt(_selectedIndex),
          Align(
            alignment: Alignment.bottomCenter,
            child: buildBottomNavigationBar(),
          )
        ],
      ),
    );
  }

  CurvedNavigationBar buildBottomNavigationBar() {
    return CurvedNavigationBar(
        height: 60.0,
        color: AppColors.primaryColor,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: AppColors.primaryColor,
        items: [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.alarm, color: Colors.white),
          // Icon(Icons.explore, color: iconColor),
          Icon(Icons.settings, color: Colors.white),
        ],
        onTap: (int index) {
          if (index == 0) {
            getData();
          }
          setState(() => _selectedIndex = index);
        });
  }

  Widget buildCategories() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text("Categories",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const Text("What is your priority right now?",
              style: TextStyle(fontSize: 12)),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('fl_content')
                .where("_fl_meta_.schema", isEqualTo: "categories")
                .get()
                .asStream(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> fetchedObject) {
              if (fetchedObject.hasData) {
                return GridView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: fetchedObject.data.docs.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 1.5, crossAxisCount: 2),
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot data = fetchedObject.data.docs[index];
                      var cl;
                      categoryList.forEach((element) {
                        if (element['name'] == data['name']) {
                          cl = element;
                        }
                      });

                      return cl != null
                          ? GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(new PageRouteBuilder(
                                    pageBuilder: (BuildContext context, _, __) {
                                  return Details(
                                      id: data['id'],
                                      coverImage: cl['coverImage'],
                                      name: data['name']);
                                }, transitionsBuilder: (_,
                                        Animation<double> animation,
                                        __,
                                        Widget child) {
                                  return new FadeTransition(
                                      opacity: animation, child: child);
                                }));
                              },
                              child: Hero(
                                tag: data['id'],
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primaryColor.withOpacity(0.1),
                                    image: DecorationImage(
                                        alignment: Alignment.center,
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          "https://firebasestorage.googleapis.com/v0/b/${GlobalConfiguration().get("firebaseProjectID")}.appspot.com/o/flamelink%2Fmedia%2F${cl['coverImage']}?alt=media",
                                        )),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.only(
                                      top: 20, left: 10, right: 10),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 6),
                                  child: Text(
                                    data['name'],
                                    style: TextStyle(
                                        decoration: TextDecoration.none,
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: SizedBox(
                                height: 100.0,
                                child: Shimmer.fromColors(
                                  baseColor: AppColors.primaryColor,
                                  highlightColor: AppColors.primaryColor,
                                  child: Center(
                                    child: Container(),
                                  ),
                                ),
                              ),
                            );
                    });
              } else
                return Center(
                  child: SizedBox(
                    height: 100.0,
                    child: Shimmer.fromColors(
                      baseColor: AppColors.primaryColor.withOpacity(0.7),
                      highlightColor: AppColors.primaryColor,
                      child: Center(
                        child: Container(),
                      ),
                    ),
                  ),
                );
            },
          ),
        ],
      ),
    );
  }

  Widget buildMeditationStep() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(left: 20, bottom: 20),
            child: Text("Featured stories",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ),
          Container(
            height: 100,
            padding: EdgeInsets.only(left: 20.0, right: 20),
            child: featuredStoryList.length > 0
                ? ListView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    children: featuredStoryList.map((dynamic fsl) {
                      return GestureDetector(
                          child: Container(
                              height: 90,
                              width: 162,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.only(top: 15, left: 20),
                              child: Text(fsl['name'],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              decoration: BoxDecoration(
                                  color:
                                      AppColors.primaryColor.withOpacity(0.1),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                        "https://firebasestorage.googleapis.com/v0/b/${GlobalConfiguration().get("firebaseProjectID")}.appspot.com/o/flamelink%2Fmedia%2F${fsl['coverImage']}?alt=media",
                                      ),
                                      alignment: Alignment.centerRight,
                                      fit: BoxFit.cover),
                                  borderRadius: BorderRadius.circular(10))),
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) =>
                                        Stories(fsl['storyItems'])));
                            Navigator.of(context).push(new PageRouteBuilder(
                                pageBuilder: (BuildContext context, _, __) {
                              return Stories(fsl['storyItems']);
                            }, transitionsBuilder: (_,
                                    Animation<double> animation,
                                    __,
                                    Widget child) {
                              return new FadeTransition(
                                  opacity: animation, child: child);
                            }));
                          });
                    }).toList())
                : SizedBox(
                    height: 100.0,
                    child: Shimmer.fromColors(
                      baseColor: Colors.white,
                      highlightColor: AppColors.primaryColor,
                      child: Center(
                        child: Image.asset(
                          'asset/img/logo-with-text.png',
                          height: 100.0,
                        ),
                      ),
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
