import 'dart:convert';
import 'package:http/http.dart' as http;

class FbFeedService {
  List<dynamic> feed = [];
  late String profilePicture;
  late String accessToken;
  late String pageId;
  final int getFeedLimit = 4;
  String? previous;
  String? oldNext;
  String? next;

  FbFeedService(
      {required this.accessToken,
      required this.pageId,
      this.profilePicture = ''});

  Future<List<dynamic>> getFeedStart() async {
    http.Response response = await getFeed();

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      next = decoded['paging']['next'] ?? next;

      final data = decoded['data'];
      feed.clear();
      feed.addAll(data);
      return feed;
    }
    throw Exception('Responce status ${response.statusCode}');
  }

  Future<List<dynamic>> getFeedNext() async {
    if (next == null) throw Exception('PagingNext equal null');
    http.Response response = await getNext(next!);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      next = decoded['paging']['next'] ?? next;
      final data = decoded['data'];
      feed.addAll(data);
      return feed;
    }
    throw Exception('Responce status ${response.statusCode}');
  }

  Future<String> getProfilePicture() async {
    final response = await http.get(
      Uri.parse(
        "https://graph.facebook.com/v11.0/$pageId?fields=picture&access_token=$accessToken",
      ),
    );

    if (response.statusCode == 200) {
      dynamic decoded = jsonDecode(response.body);
      profilePicture = decoded['picture']['data']['url'];
      return profilePicture;
    }
    throw Exception('Profile picture response code ${response.statusCode}');
  }

  Future<http.Response> getNext(String paging) {
    return http.get(
      Uri.parse(paging),
    );
  }

  Future<http.Response> getFeed() {
    return http.get(
      Uri.parse(
        "https://graph.facebook.com/v11.0/$pageId/feed?fields=id,created_time,from,shares,permalink_url,message,attachments&access_token=$accessToken&limit=$getFeedLimit",
      ),
    );
  }
}
