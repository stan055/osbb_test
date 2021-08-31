import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:osbb_test/fb_feed/service/fb_feed_service.dart';
import 'package:osbb_test/fb_feed/screen/video_player.dart';
import 'package:provider/provider.dart';

class FbFeed extends StatefulWidget {
  const FbFeed({Key? key}) : super(key: key);

  @override
  _FbFeedState createState() => _FbFeedState();
}

class _FbFeedState extends State<FbFeed> {
  List<dynamic> feed = [];
  String profilePicture =
      'https://eitrawmaterials.eu/wp-content/uploads/2016/09/person-icon.png';
  ScrollController _scrollController = new ScrollController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    getFbFeedStart();
    getProfilePicture();
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 150) {
        if (!_loading) getFbFeedNext();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _error == null
        ? feed.length != 0
            ? RefreshIndicator(
                onRefresh: refreshFbFeed,
                child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: feed.length,
                    shrinkWrap: false,
                    itemBuilder: (BuildContext context, int index) {
                      //----------------------Get feed data---------------------
                      final name = feed[index]['from']['name'];
                      final dateTime =
                          parseDateTime(feed[index]['created_time']);
                      final message = feed[index]['message'];
                      final description =
                          feed[index]['attachments']?['data'][0]['description'];
                      final imageSrc = feed[index]['attachments']?['data'][0]
                          ['media']['image']['src'];
                      final mediaSource = feed[index]['attachments']?['data'][0]
                          ['media']['source'];
                      return Card(
                          margin: EdgeInsets.symmetric(vertical: 20),
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            constraints: BoxConstraints(
                                minHeight:
                                    MediaQuery.of(context).size.height * .3),
                            child: Column(
                              children: [
                                //--------------------------------Head Row----------------------------
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      //---------------------Avatar Picture-------------------------
                                      CachedNetworkImage(
                                        height: 45,
                                        width: 45,
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.person),
                                        imageUrl: profilePicture,
                                      ),
                                      //--------------------Chanel Name & Created Date--------------
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(dateTime)
                                            ],
                                          ))
                                    ],
                                  ),
                                ),
                                //----------------------------Message Text--------------------------
                                message != null
                                    ? Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(
                                            message,
                                          ),
                                        ),
                                      )
                                    :
                                    //----------------------------Description Text-----------------------
                                    description != null
                                        ? Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Text(
                                                description,
                                              ),
                                            ),
                                          )
                                        : Container(),

                                SizedBox(
                                  height: 10,
                                ),
                                //----------------------------Media----------------------------------
                                mediaSource == null
                                    ? Container(
                                        constraints: BoxConstraints(
                                            maxHeight: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .8),
                                        child: imageSrc != null
                                            ? CachedNetworkImage(
                                                fit: BoxFit.contain,
                                                imageUrl: imageSrc)
                                            : Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .1,
                                              ),
                                      )
                                    : VideoApp(mediaSource),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ));
                    }),
              )
            : Center(
                child: CircularProgressIndicator(),
              )
        : Center(child: Text(_error!));
  }

  Future<void> refreshFbFeed() {
    return context
        .read<FbFeedService>()
        .getFeedStart()
        .then(
            (value) => {
                  this.setState(() {
                    feed = value;
                    _loading = false;
                  })
                },
            onError: (error) => _error = error.toString())
        .catchError(handleError);
  }

  getFbFeedStart() {
    if (context.read<FbFeedService>().feed.length == 0) {
      context
          .read<FbFeedService>()
          .getFeedStart()
          .then(
              (value) => {
                    this.setState(() {
                      feed = value;
                      _loading = false;
                    })
                  },
              onError: (error) => _error = error.toString())
          .catchError(handleError);
    } else {
      this.setState(() {
        feed = context.read<FbFeedService>().feed;
        _loading = false;
      });
    }
  }

  getFbFeedNext() {
    _loading = true;
    context
        .read<FbFeedService>()
        .getFeedNext()
        .then(
            (value) => {
                  this.setState(() {
                    feed = value;
                    _scrollController.animateTo(_scrollController.offset + 100,
                        duration: Duration(seconds: 1), curve: Curves.ease);

                    _loading = false;
                  })
                },
            onError: (error) => _error = error.toString())
        .catchError(handleError);
  }

  getProfilePicture() {
    if (context.read<FbFeedService>().profilePicture == '') {
      context
          .read<FbFeedService>()
          .getProfilePicture()
          .then(
              (value) => {
                    this.setState(() {
                      profilePicture = value;
                    })
                  },
              onError: (error) => print(error))
          .catchError(handleError);
    } else {
      setState(() {
        profilePicture = context.read<FbFeedService>().profilePicture;
      });
    }
  }

  handleError(error) {
    setState(() {
      _loading = false;
    });
  }

  String parseDateTime(String? date) {
    if (date == null) return '';
    final parseDate = DateTime.tryParse(date);
    return parseDate != null
        ? parseDate.toLocal().toString().split('.').first
        : '';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
