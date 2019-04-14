import 'dart:convert';

import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http_get;

import 'package:microsoft_graph/src/core/http_client.dart';
import 'package:microsoft_graph/src/core/http_method.dart';
import 'package:microsoft_graph/src/core/http_request_message.dart';
import 'package:microsoft_graph/src/models/folder_id.dart';
import 'package:microsoft_graph/src/models/message.dart';
import 'package:microsoft_graph/src/models/serializers.dart';
import 'package:microsoft_graph_http/microsoft_graph_http.dart';

abstract class BaseAuth {
  Stream<FirebaseUser> get onAuthStateChanged;
  Future<FirebaseUser> handleSignIn();
  Future<FirebaseUser> currentUser();
  Future<void> signOut();
}

class DummyFirebaseUserMetadata {
  DummyFirebaseUserMetadata(this._data);

  final Map<dynamic, dynamic> _data;

  int get creationTimestamp => _data['creationTimestamp'];

  int get lastSignInTimestamp => _data['lastSignInTimestamp'];
}

class DummyInfo {
  DummyInfo(this._data, this._app);

  final FirebaseApp _app;

  final Map<dynamic, dynamic> _data;

  /// The provider identifier.
  String get providerId => _data['providerId'];

  /// The provider’s user ID for the user.
  String get uid => _data['uid'];

  /// The name of the user.
  String get displayName => _data['displayName'];

  /// The URL of the user’s profile photo.
  String get photoUrl => _data['photoUrl'];

  /// The user’s email address.
  String get email => _data['email'];

  /// The user's phone number.
  String get phoneNumber => _data['phoneNumber'];

  @override
  String toString() {
    return '$runtimeType($_data)';
  }
}

class DummyUser extends DummyInfo {
  DummyUser(Map<dynamic, dynamic> data, FirebaseApp app)
      : providerData = data['providerData']
            .map<DummyInfo>((dynamic item) => DummyInfo(item, app))
            .toList(),
        _metadata = DummyFirebaseUserMetadata(data),
        super(data, app);

  final List<DummyInfo> providerData;
  final DummyFirebaseUserMetadata _metadata;
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static final Config config = Config("e37d725c-ab5c-4624-9ae5-f0533e486437",
      "e3a62f96-d33f-4964-8fe7-e925129aa3ad", "openid profile offline_access user.read");
  static final AadOAuth oauth = AadOAuth(config);

  static const MethodChannel channel = MethodChannel(
    'login.io/azure',
  );

  //final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Stream<FirebaseUser> get onAuthStateChanged {
    return _firebaseAuth.onAuthStateChanged
        .map((FirebaseUser user) => user); //Only return user if not null
  }

  @override
  Future<FirebaseUser> handleSignIn() async {
    // final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    // final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    // final AuthCredential credential = GoogleAuthProvider.getCredential(
    //   accessToken: googleAuth.accessToken,
    //   idToken: googleAuth.idToken,
    // );

    //Auth user
    if (!oauth.tokenIsValid()) {
      await oauth.logout();
    }
    await oauth.login();
    String accessToken = await oauth.getAccessToken();

    print(accessToken);

    //final Future<FirebaseUser> user = _firebaseAuth.signInWithCredential(credential);
    /* final Future<FirebaseUser> user = (String accessToken) async {
      assert(accessToken != null);
      final Map<dynamic, dynamic> data = await channel.invokeMethod(
        'signInWithCredential',
        <String, dynamic>{
          'app': _firebaseAuth.app.name,
          'provider': 'microsoft.com',
          'data': accessToken,
        },
      );
      final FirebaseUser currentUser = FirebaseUser(data, _firebaseAuth.app);
      return currentUser;
    }; */

    /* //TODO: extract variables and store properly
    String azureClientId = "e3a62f96-d33f-4964-8fe7-e925129aa3ad";
    String azureTenant = "e37d725c-ab5c-4624-9ae5-f0533e486437";
    String microsoftURL = "https://graph.microsoft.com/v1.0/me";

    //Pull user details from Microsoft Graph
    Future<Post> fetchPost() async {
      final response = await http_get
          .get(microsoftURL);

      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON
        return Post.fromJson(json.decode(response.body));
      } else {
        // If that response was not OK, throw an error.
        throw Exception(
            'Failed to load post ' + response.statusCode.toString());
      }
    }

    Post userDetails = await fetchPost();
    print(userDetails); */

    //Pull user details from Microsoft Graph

    assert(accessToken.length > 0);

    String microsoftURL = "https://graph.microsoft.com/v1.0/users/";
    IHttpClient httpClient = SimpleHttpClient(accessToken);

    final request =
        HttpRequestMessage(HttpMethod.Get, Uri.parse(microsoftURL), []);
    final authenticatedRequest =
        await httpClient.authenticationProvider.authenticateRequest(request);
    final response = await httpClient.httpProvider.send(authenticatedRequest);

    //print("request = " + request.headers.toSet(). + request.httpMethod.toString() + request.uri.toString());
    print("authRequest = " + authenticatedRequest.headers[0].name + authenticatedRequest.headers[0].value + authenticatedRequest.httpMethod.toString());
    Map<String, dynamic> json;
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      json = jsonDecode(response.body);
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post ' + response.statusCode.toString() + response.body.toString());
    }

    print(json.toString());

    //Either login with existing FirebaseUser or create a new one if one doesn't exist
    FirebaseUser user =
        await _firebaseAuth.createUserWithEmailAndPassword(email: "x", password: "");

    print("signed in " + user.toString());
    return user;
  }

  @override
  Future<FirebaseUser> currentUser() {
    return _firebaseAuth.currentUser();
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }
}

class Post {
  final int id;
  final String mail;
  final String givenName;
  final String body;

  Post({this.id, this.mail, this.givenName, this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['userId'],
      mail: json['id'],
      givenName: json['title'],
      body: json['body'],
    );
  }
}
