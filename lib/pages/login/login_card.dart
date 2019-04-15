//Adapted from https://github.com/iampawan/Flutter-UI-Kit/blob/master/lib/ui/page/login/login_one/login_card.dart
//Adapted from https://github.com/tattwei46/flutter_login_demo/blob/master/lib/pages/login_signup_page.dart

import 'package:eatwithme/pages/auth/auth.dart';
import 'package:eatwithme/pages/auth/auth_provider.dart';
import 'package:eatwithme/utils/error_toast.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/widgets/gradient_button.dart';
import 'package:flutter/services.dart';

class EmailFieldValidator {
  //https://services.anu.edu.au/information-technology/email/email-addresses-lists
  static final RegExp _emailStudentRegex =
      new RegExp(r'^u\d{7}\@anu\.edu\.au$');
  static final RegExp _emailNamedRegex =
      new RegExp(r'^\w+\.\w+\@anu\.edu\.au$');

  static String validate(String value) {
    String _email = value.trim();

    if (_email.isEmpty) {
      return 'Email can\'t be empty';
    }

    if (!_emailNamedRegex.hasMatch(_email) &&
        !_emailStudentRegex.hasMatch(_email)) {
      return 'Enter a valid ANU email';
    }

    return null;
  }
}

class PasswordFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? 'Password can\'t be empty' : null;
  }
}

enum FormType {
  login,
  register,
}

class LoginCard extends StatefulWidget {
  @override
  _LoginCardState createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard>
    with SingleTickerProviderStateMixin {
  var deviceSize;
  Animation<double> animation;
  AnimationController controller;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String _email;
  String _password;
  FormType _formType = FormType.login;

  bool validateAndSave() {
    final FormState form = formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        final BaseAuth auth = AuthProvider.of(context).auth;
        if (_formType == FormType.login) {
          final String userId = await auth.login(_email, _password);
          print('Signed in: $userId');
        } else {
          final String userId = await auth.signUp(_email, _password);
          print('Registered user: $userId');
        }
      } on PlatformException catch (e) {
        //Handle errors from login (based from signInWithEmailAndPassword)
        if (e.code == 'ERROR_USER_NOT_FOUND') {
          ErrorToast.show('The email or password was incorrect');

          //The below would be nice, but it's probably a security issue for phising
          /* showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Create new account?'),
                  content: Text(
                      'We couldn\'t find an account with email, would you like to create one?'),
                  actions: <Widget>[
                    FlatButton(
                        child: Text('No'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    FlatButton(
                        child: Text('Create User'),
                        onPressed: () {
                          _formType = FormType.register;
                          Navigator.of(context).pop();
                          validateAndSubmit();
                        }),
                  ],
                );
              }); */
        } else if (e.code == 'ERROR_WRONG_PASSWORD' ||
            e.code == 'ERROR_INVALID_EMAIL') {
          ErrorToast.show('The email or password was incorrect');
        } else if (e.code == 'ERROR_USER_DISABLED') {
          ErrorToast.show('This account is currently disabled');
        } else if (e.code == 'ERROR_WEAK_PASSWORD') {
          ErrorToast.show('Password did not meet complexity requirements');
        } else if (e.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
          ErrorToast.show('An error occured when creating account');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void switchIntoRegisterMode() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void switchIntoLoginMode() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return <Widget>[
        GradientButton(
          key: Key('signIn'),
          text: 'Login',
          onPressed: validateAndSubmit,
        ),
        SizedBox(
          height: 5.0,
        ),
        FlatButton(
          child: Text('Create an account', style: TextStyle(fontSize: 20.0)),
          onPressed: switchIntoRegisterMode,
        ),
      ];
    } else {
      return <Widget>[
        GradientButton(
          text: 'Create my Account',
          onPressed: validateAndSubmit,
        ),
        SizedBox(
          height: 5.0,
        ),
        FlatButton(
          child:
              Text('Have an account? Login', style: TextStyle(fontSize: 20.0)),
          onPressed: switchIntoLoginMode,
        ),
      ];
    }
  }

  Widget loginBuilder() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                key: Key('email'),
                onSaved: (String value) => _email = value.trim(),
                validator: EmailFieldValidator.validate,
                style: TextStyle(fontSize: 15.0, color: Colors.black),
                decoration: InputDecoration(
                    hintText: "",
                    labelText: "Email",
                    labelStyle: TextStyle(fontWeight: FontWeight.w700)),
              ),
              SizedBox(
                height: 10.0,
              ),
              TextFormField(
                key: Key('password'),
                onSaved: (String value) => _password = value,
                validator: PasswordFieldValidator.validate,
                style: TextStyle(fontSize: 15.0, color: Colors.black),
                decoration: InputDecoration(
                    hintText: "",
                    labelText: "Password",
                    labelStyle: TextStyle(fontWeight: FontWeight.w700)),
                obscureText: true,
              ),
              SizedBox(
                height: 30.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: buildSubmitButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget loginCard() {
    return Opacity(
      //opacity: animation.value,
      opacity: 1.0,
      child: SizedBox(
        height: deviceSize.height / 2 - 20,
        width: deviceSize.width * 0.85,
        child: Card(color: Colors.white, elevation: 2.0, child: loginBuilder()),
      ),
    );
  }

  @override
  initState() {
    // TODO: implement initState
    super.initState();
    //loginBloc =  LoginBloc();
    //apiStreamSubscription = apiSubscription(loginBloc.apiResult, context);
    controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn));
    animation.addListener(() => this.setState(() {}));
    controller.forward();
  }

  @override
  void dispose() {
    controller?.dispose();
    //loginBloc?.dispose();
    //apiStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return loginCard();
  }
}
