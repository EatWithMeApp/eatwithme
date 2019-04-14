//Adapted from https://github.com/bizz84/coding-with-flutter-login-demo/blob/master/lib/auth.dart

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_auth/simple_auth.dart';
import 'package:simple_auth_flutter/simple_auth_flutter.dart';

import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';

import 'package:flutter_aad/flutter_aad.dart';

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as base_http;

abstract class OldBaseAuth {
  Stream<String> get onAuthStateChanged;
  Future<String> signInWithAzureToken();
  Future<String> currentUser();
  Future<void> signOut();
}

class OldAuth implements OldBaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Stream<String> get onAuthStateChanged {
    return _firebaseAuth.onAuthStateChanged
        .map((FirebaseUser user) => user?.uid); //Only return user if not null
  }

  @override
  Future<String> signInWithAzureToken() async {
    //Authenitcate with Azure (access token received)
    final Config config = new Config(
         "e37d725c-ab5c-4624-9ae5-f0533e486437", "e3a62f96-d33f-4964-8fe7-e925129aa3ad", "openid profile offline_access");
    final AadOAuth oauth = new AadOAuth(config);

    await oauth.login();
    String azureAccessToken = await oauth.getAccessToken();

    print("azureAccessToken $azureAccessToken");

    //Use access token to get full token with user data

    String azureClientId = "e3a62f96-d33f-4964-8fe7-e925129aa3ad";
    String azureTenant = "e37d725c-ab5c-4624-9ae5-f0533e486437";

    Map<String, String> envVars = Platform.environment;
    final aadConfig = AADConfig(
        //resource: 'e37d725c-ab5c-4624-9ae5-f0533e486437',//envVars['AAD_RESOURCE'],
        clientID: azureClientId,//envVars['AAD_CLIENT_ID'],
        redirectURI: 'https://login.live.com/oauth20_desktop.srf',//envVars['AAD_REDIRECT_URI'],
        apiVersion: 2,
        scope: [
          "openid",
          //"Sites.Read.All",
          "User.Read",
          "profile",
          "offline_access",
        ]);

    var aad = FlutterAAD(aadConfig);

    var full_token = await aad.GetTokenMapWithAuthCode(azureAccessToken);

    // base_http.Response response;
    // base_http.BaseClient http;

    // response = await http.post(
    //     Uri.encodeFull('https://login.microsoftonline.com/common/oauth2/v2.0/token'),
    //     headers: {"Accept": "application/json;odata=verbose"},
    //     body: {
    //       "grant_type": "authorization_code",
    //       "client_id": aadConfig.clientID,
    //       "code": azureAccessToken,
    //       "redirect_uri": aadConfig.redirectURI,
    //       "scope": aadConfig.scope.join(' '),
    //     },
    //   );

    //print(response);

    //var full_token = null;

    // if (response != null &&
    //     response.statusCode >= 200 &&
    //     response.statusCode < 400) {
    //   full_token = json.decode(response.body);
    //   //_tokenIn.add(this.loggedIn);
    //   //return _fullToken;
    // } else {
    //   //if (onError != null) {
    //   //  onError(response?.body);
    //   //}
    //   //return null;
    // }

    if (full_token == null) {
      print("ERROR GETTING TOKEN!!!");
      return null;
    }

    print("Full token:");
    print(full_token);

    JsonEncoder encoder = new JsonEncoder.withIndent('  ');

    var profile = await aad.GetMyProfile();
    print("here is the profile:");
    print(encoder.convert(profile));
    
    // final Config config = new Config(
    //      "e37d725c-ab5c-4624-9ae5-f0533e486437", "e3a62f96-d33f-4964-8fe7-e925129aa3ad", "openid profile offline_access");
    // final AadOAuth oauth = new AadOAuth(config);

    // await oauth.login();
    // String azureAccessToken = await oauth.getAccessToken();

    // print("azureAccessToken $azureAccessToken");

    // String azureClientId = "e3a62f96-d33f-4964-8fe7-e925129aa3ad";
    // String azureTenant = "e37d725c-ab5c-4624-9ae5-f0533e486437";
    // final AzureADApi azureApi = AzureADApi(
    //   "azure",
    //   azureClientId,
    //   "https://login.microsoftonline.com/$azureTenant/oauth2/authorize",
    //   "https://login.microsoftonline.com/$azureTenant/oauth2/token",
    //   "https://management.azure.com/",
    //   "https://eatwithme-c103e.firebaseapp.com/__/auth/handler");
    // var request = new Request(
    //   HttpMethod.Post,
    //   "https://login.microsoftonline.com/$azureTenant/oauth2/token",
    //   parameters: {"token:": azureAccessToken},
    // );
    // var userInfo = await azureApi.send<UserInfo>(request);
    
    // print('userInfo $userInfo');

    // String azureClientId = "e3a62f96-d33f-4964-8fe7-e925129aa3ad";
    // String azureTenant = "e37d725c-ab5c-4624-9ae5-f0533e486437";
    // final AzureADApi azureApi = AzureADApi(
    //   "azure",
    //   azureClientId,
    //   "https://login.microsoftonline.com/$azureTenant/oauth2/authorize",
    //   "https://login.microsoftonline.com/$azureTenant/oauth2/token",
    //   "https://management.azure.com/",
    //   "redirecturl");
    // var request = new Request(HttpMethod.Get, "https://login.microsoftonline.com/$azureTenant/oauth2/token");
    // var userInfo = await azureApi.send<UserInfo>(request);




    //final FirebaseUser user =
        //await _firebaseAuth.signInWithCustomToken(token: azureToken);
        //await _firebaseAuth.signInWithCredential((AuthCredential){config.tokenUrl, azureAccessToken});
    //return user?.uid;
  }

  @override
  Future<String> currentUser() async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    return user?.uid;
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}

