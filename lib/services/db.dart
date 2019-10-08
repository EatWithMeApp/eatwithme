import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/models/models.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class DatabaseService {
  final Firestore _db = Firestore.instance;
  final Geoflutterfire _geo = Geoflutterfire();

  Future<User> getUser(String id) async {
    if (id == null) return null;

    try {
      var snapshot = await _db.collection('Users').document(id).get();
      return User.fromFirestore(snapshot);
    }
    catch (e) {
      return null;
    }
  }

  Future<Interest> getInterest(String id) async {
    var snapshot = await _db.collection('Interests').document(id).get();

    return Interest.fromFirestore(snapshot);
  }

  Stream<User> streamUser(String id) {
    return _db
        .collection('Users')
        .document(id)
        .snapshots()
        .map((snap) => User.fromMap(snap.data));
  }

  // Stream<List<User>> streamSubcollection(FirebaseUser user) {
  //   var ref = _db.collection('Users').document(user.uid).collection('ChatRooms');

  //   return ref.snapshots().map((list) =>
  //     list.documents.map((doc) => User.fromFirestore(doc))
  //   );
  // }

  Stream<Iterable<User>> streamNearbyUsers(
      String loggedInUid, GeoFirePoint loggedInPosition) {
    // Grab all users within our radius
    return _geo
        .collection(collectionRef: _db.collection('Users'))
        .within(
            center: loggedInPosition,
            radius: USER_LOCATION_RADIUS,
            field: 'position',
            strictMode: true)
        .map((list) => list.map((doc) => User.fromFirestore(doc)));
  }

  Stream<Iterable<ChatRoom>> streamChatRoomsOfUser(FirebaseUser user) {
    return _db
        .collectionGroup('ChatRooms')
        .where('userUids', arrayContains: user.uid)
        .snapshots()
        .map(
            (list) => list.documents.map((doc) => ChatRoom.fromFirestore(doc)));
  }

  Stream<Iterable<Message>> streamMessagesFromChatRoom(
      String roomId, String loggedInUid) {
    return _db
        .collection('ChatRooms')
        .document(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((list) => list.documents.map((doc) => Message.fromFirestore(doc)));
  }

  Stream<Iterable<Interest>> streamAllInterests() {
    return _db.collectionGroup('Interests').snapshots().map(
        (list) => list.documents.map((doc) => Interest.fromFirestore(doc)));
  }

  Future<ChatRoom> getChatRoom(String id) async {
    var snapshot = await _db.collection('ChatRooms').document(id).get();

    return ChatRoom.fromFirestore(snapshot);
  }

  Stream<User> streamUserInChatRoom(String roomId, String loggedInUid) {
    var uids = roomId.split('-');
    uids.remove(loggedInUid);

    return streamUser(uids.first);
  }

  Future<void> updateUserLocation(String uid, GeoFirePoint point) {
    return _db
        .collection('Users')
        .document(uid)
        .setData({'position': point.data}, merge: true);
  }

  Future<void> updateToken(String uid, String token){
    return _db
        .collection('Users')
        .document(uid)
        .setData({'Token': token}, merge: true);
  }

  Future<void> updateUserLastSeen(String uid) {
    return _db
        .collection('Users')
        .document(uid)
        .setData({'lastSeen': DateTime.now()}, merge: true);
  }

  Future<void> updateUserPhoto(String uid, String photoURL) {
    return _db
        .collection('Users')
        .document(uid)
        .setData({'photoURL': photoURL}, merge: true);
  }

  Future<void> updateUserProfileText(
      String uid, String aboutMe, String displayName) {
    return _db.collection('Users').document(uid).setData({
      'aboutMe': aboutMe,
      'displayName': displayName,
    }, merge: true);
  }

  Future<void> updateUserInterests(String uid, Set<Interest> interests) {
    return _db.collection('Users').document(uid).setData({
      'interests': interests.map((interest) {
        return interest.toMap();
      }).toList(),
    }, merge: true);
  }

  Future<void> createNewUser(FirebaseUser verifiedUser) {
    return _db.collection('Users').document(verifiedUser.uid).setData({
      'uid': verifiedUser.uid,
      'email': verifiedUser.email,
      'photoURL': verifiedUser.photoUrl,
      'displayName': verifiedUser.email.split('@')[0].trim(),
      'lastSeen': DateTime.now(),
    }, merge: true);
  }

  Future<void> verifyChatRoom(List<String> userUids, String token) async {
    String id = ChatRoom.generateID(userUids);
    var room = _db.collection('ChatRooms').document(id);

    return room.get().then((doc) {
      if (doc.exists == false) {
        createChatRoom(id, userUids, token);
      }
    }).catchError((doc) {
      if (!doc.exists) {
        createChatRoom(id, userUids, token);
      }
    });
  }

  Future<void> createChatRoom(String roomId, List<String> userUids, String token) {
    var room = _db.collection('ChatRooms').document(roomId);

    return room.setData({
      'id': roomId,
      'userUids': userUids,
      'tokens': token,
      // Rooms with 2 users are user to user and shouldn't allow others
      'canAddUsers': (userUids.length != 2),
    }, merge: true);
  }

  Future<void> writeMessageToChatRoom(List<String> userUids, Message message, String token) {
    verifyChatRoom(userUids, token);

    String id = ChatRoom.generateID(userUids);
    var room = _db.collection('ChatRooms').document(id);

    //Write message to the messages subcollection
    var documentReference = room.collection('messages').document();

    message.id = documentReference.documentID;

    return _db.runTransaction((transaction) async {
      await transaction.set(documentReference, message.toMap());
    });
  }

  Future<void> writeTokenToChatRoom(List<String> userUids, String token){
    verifyChatRoom(userUids, token);
    String id = ChatRoom.generateID(userUids);
    var room = _db.collection('ChatRooms').document(id);

  }

  // Use this function if you need to repopulate or add to interests, modify list and attach function to button
  Future<void> addInterestsToDb() async {
    var list = [
      '3D printing',
      'Acrobatics',
      'Acting',
      'Air sports',
      'Aircraft spotting',
      'Airsoft',
      'Amateur astronomy',
      'American football',
      'Animal fancy',
      'Animation',
      'Antiquing',
      'Antiquities',
      'Aquascaping',
      'Archery',
      'Art collecting',
      'Association football',
      'Astrology',
      'Astronomy',
      'Audiophile',
      'Australian rules football',
      'Auto audiophilia',
      'Auto racing',
      'Axe throwing',
      'Backpacking',
      'Badminton',
      'Baking',
      'BASE jumping',
      'Baseball',
      'Basketball',
      'Baton twirling',
      'Beach volleyball',
      'Beatboxing',
      'Beauty pageants',
      'Beekeeping',
      'Billiards',
      'Bird watching',
      'Birdwatching',
      'Blacksmithing',
      'Blogging',
      'BMX',
      'Board sports',
      'Board/tabletop games',
      'Bodybuilding',
      'Book collecting',
      'Book discussion clubs',
      'Book restoration',
      'Bowling',
      'Boxing',
      'Brazilian jiu-jitsu',
      'Breadmaking',
      'Breakdancing',
      'Bridge',
      'Building',
      'Bus spotting',
      'Butterfly watching',
      'Cabaret',
      'Calligraphy',
      'Camping',
      'Candle making',
      'Canoeing',
      'Canyoning',
      'Car fixing & building',
      'Card games',
      'Cartophily',
      'Caving',
      'Cheerleading',
      'Cheesemaking',
      'Chess',
      'Climbing',
      'Clothes making',
      'Coffee roasting',
      'Coin collecting',
      'Collecting',
      'Collection hobbies',
      'Color guard',
      'Coloring',
      'Comic book collecting',
      'Competitive hobbies',
      'Composting',
      'Computer programming',
      'Confectionery',
      'Cooking',
      'Cosplaying',
      'Couponing',
      'Craft',
      'Creative writing',
      'Cricket',
      'Crocheting',
      'Cross-stitch',
      'Crossword puzzles',
      'Cryptography',
      'Cue sports',
      'Curling',
      'Cycling',
      'Dance',
      'Dancing',
      'Darts',
      'Debate',
      'Deltiology',
      'Diary writing',
      'Die-cast toy',
      'Digital arts',
      'Disc golf',
      'Distro Hopping',
      'Do it yourself',
      'Dog sport',
      'Dolls',
      'Dowsing',
      'Drama',
      'Drawing',
      'Drink mixing',
      'Driving',
      'Eating',
      'Electronics',
      'Element collecting',
      'Embroidery',
      'Ephemera collecting',
      'Equestrianism',
      'eSports',
      'EuroBillTracker',
      'Exhibition drill',
      'Experimenting',
      'Fantasy sports',
      'Fashion',
      'Fashion design',
      'Fencing',
      'Field hockey',
      'Figure skating',
      'Fishing',
      'Fishkeeping',
      'Flag football',
      'Flower arranging',
      'Flower collecting and pressing',
      'Flower growing',
      'Flying',
      'Flying disc',
      'Footbag',
      'Foraging',
      'Foreign language learning',
      'Fossil hunting',
      'Freestyle football',
      'Furniture building',
      'Fusilately',
      'Gaming',
      'Gardening',
      'Genealogy',
      'Geocaching',
      'Ghost hunting',
      'Gingerbread house making',
      'Glassblowing',
      'Go',
      'Gold prospecting',
      'Golfing',
      'Gongoozling',
      'Graffiti',
      'Graphic design',
      'Gunsmithing',
      'Gymnastics',
      'Handball',
      'Herbalism',
      'Herp keeping',
      'Herping',
      'High-power rocketry',
      'Hiking',
      'Hiking/backpacking',
      'Hobby horsing',
      'Home improvement',
      'Homebrewing',
      'Hooping',
      'Horseback riding',
      'Hula hooping',
      'Hunting',
      'Hydroponics',
      'Ice hockey',
      'Ice skating',
      'Indoors',
      'Inline skating',
      'Insect collecting',
      'Jewelry making',
      'Jigsaw puzzles',
      'Jogging',
      'Judo',
      'Juggling',
      'Jujitsu',
      'Jukskei',
      'Kabaddi',
      'Karaoke',
      'Karate',
      'Kart racing',
      'Kayaking',
      'Kite flying',
      'Kitesurfing',
      'Knife collecting',
      'Knife making',
      'Knife throwing',
      'Knitting',
      'Knot tying',
      'Kombucha brewing',
      'Lace making',
      'Lacrosse',
      'Lapidary',
      'LARPing',
      'Laser tag',
      'Learning',
      'Leather crafting',
      'Lego building',
      'Letterboxing',
      'Listening to music',
      'Listening to podcasts',
      'Lock picking',
      'Longboarding',
      'Lotology',
      'Machining',
      'Macrame',
      'Magic',
      'Magnet fishing',
      'Mahjong',
      'Makeup',
      'Marbles',
      'Marching band',
      'Martial arts',
      'Meditation',
      'Metal detecting',
      'Metalworking',
      'Meteorology',
      'Microscopy',
      'Mineral collecting',
      'Model aircraft',
      'Model building',
      'Model engineering',
      'Motor sports',
      'Mountain biking',
      'Mountaineering',
      'Mushroom hunting/mycology',
      'Nail Art',
      'Needlepoint',
      'Netball',
      'Nordic skating',
      'Observation hobbies',
      'Orienteering',
      'Origami',
      'Outdoors',
      'Paintball',
      'Painting',
      'Parkour',
      'Perfume',
      'Pet adoption & fostering',
      'Philately',
      'Phillumeny',
      'Photography',
      'Playing musical instruments',
      'Podcast hosting',
      'Poi',
      'Poker',
      'Polo',
      'Pottery',
      'Powerlifting',
      'Practical jokes',
      'Pressed flower craft',
      'Puzzles',
      'Quilling',
      'Quilting',
      'Quizzes',
      'Racquetball',
      'Radio-controlled car racing',
      'Rafting',
      'Rail transport modeling',
      'Rail transport modelling',
      'Rappelling',
      'Rapping',
      'Reading',
      'Record collecting',
      'Refinishing',
      'Road biking',
      'Robot combat',
      'Rock balancing',
      'Rock climbing',
      'Rock tumbling',
      'Roller derby',
      'Roller skating',
      'Rubiks Cubing',
      'Rugby',
      'Rugby league football',
      'Running',
      'Sailing',
      'Sand art',
      'Satellite watching',
      'Scouting',
      'Scrapbooking',
      'Scuba diving',
      'Sculling or rowing',
      'Sculpting',
      'Scutelliphily',
      'Sea glass collecting',
      'Seashell collecting',
      'Sewing',
      'Shoemaking',
      'Shoes',
      'Shogi',
      'Shooting',
      'Shooting sport',
      'Shopping',
      'Shortwave listening',
      'Singing',
      'Skateboarding',
      'Sketching',
      'Skiing',
      'Skimboarding',
      'Skydiving',
      'Slacklining',
      'Slot car racing',
      'Snowboarding',
      'Soapmaking',
      'Soccer',
      'Social media',
      'Softball',
      'Speed skating',
      'Speedcubing',
      'Sport stacking',
      'Sports memorabilia',
      'Squash',
      'Stamp collecting',
      'Stand-up comedy',
      'Stone collecting',
      'Stone skipping',
      'Stuffed toy collecting',
      'Sun bathing',
      'Surfing',
      'Survivalism',
      'Swimming',
      'Table football',
      'Table tennis',
      'Taekwondo',
      'Tai chi',
      'Taxidermy',
      'Tea bag collecting',
      'Tennis',
      'Tennis polo',
      'Tether car',
      'Thrifting',
      'Ticket collecting',
      'Topiary',
      'Tour skating',
      'Toys',
      'Trainspotting',
      'Trapshooting',
      'Travel',
      'Traveling',
      'Triathlon',
      'Ultimate frisbee',
      'Urban exploration',
      'Vacation',
      'Vegetable farming',
      'Vehicle restoration',
      'Video editing',
      'Video game collecting',
      'Video game developing',
      'Video gaming',
      'Videophilia',
      'Vintage cars',
      'Vintage clothing',
      'Volleyball',
      'Walking',
      'Watching movies',
      'Watching television',
      'Water polo',
      'Water sports',
      'Weaving',
      'Weight training',
      'Weightlifting',
      'Welding',
      'Whale watching',
      'Whittling',
      'Wikipedia Editing',
      'Winemaking',
      'Wood carving',
      'Woodworking',
      'Word searches',
      'Worldbuilding',
      'Wrestling',
      'Writing',
      'Yo-yoing',
      'Yoga',
    ];

    for (var interest in list) {
      var ref = await _db.collection('Interests').add({});

      _db.collection('Interests').document(ref.documentID).setData({
        'id': ref.documentID,
        'name': interest,
      }, merge: true);
    }
  }
}
