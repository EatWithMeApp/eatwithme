import 'package:test/test.dart';
import 'package:eatwithme/services/db.dart';

void main() {
  final test_db = new DatabaseService();
  test("test ", (){
    String id = "u6225609";
    
    test_db.streamUser(id);
  });
}