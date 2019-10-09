//Adapted from https://github.com/iampawan/Flutter-UI-Kit/blob/master/lib/ui/page/login/login_one/login_card.dart
//Adapted from https://github.com/tattwei46/flutter_login_demo/blob/master/lib/pages/login_signup_page.dart

import 'package:eatwithme/services/auth.dart';
import 'package:eatwithme/utils/confirmation_toast.dart';
import 'package:eatwithme/utils/error_toast.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/widgets/gradient_button.dart';
import 'package:flutter/services.dart';
import 'package:eatwithme/utils/verification_exception.dart';

class EmailFieldValidator {
  //https://services.anu.edu.au/information-technology/email/email-addresses-lists
  static final RegExp _emailStudentRegex =
      new RegExp(r'^u\d{7}\@anu\.edu\.au$');
  static final RegExp _emailNamedRegex =
      new RegExp(r'^\w+\.\w+\@anu\.edu\.au$');

  //This one allows for testing with dummy users - remove once released
  static final RegExp _emailTestUserRegex = new RegExp(r'^u\w+\@anu\.edu\.au$');

  static String validate(String value) {
    if (value == null) {
      return 'Email can\'t be empty';
    }

    String _email = value.trim();
    if (!_emailNamedRegex.hasMatch(_email) &&
        !_emailStudentRegex.hasMatch(_email) &&
        !_emailTestUserRegex.hasMatch(_email)) {
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
  final AuthService auth = AuthService();

  String _email;
  String _password;
  final emailController = TextEditingController();
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
        (_formType == FormType.login)
            ? await auth.login(_email, _password)
            : await auth.signUp(_email, _password);

        // Drop focus and get rid of the keyboard
        FocusScope.of(context).requestFocus(new FocusNode());   
      } on VerificationException {
        ErrorToast.show('Please verify this email address');
      } on PlatformException catch (e) {
        //Handle errors from login (based from signInWithEmailAndPassword)
        if (e.code == 'ERROR_USER_NOT_FOUND') {
          ErrorToast.show('The email or password was incorrect');
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

  void resetPassword() {
    try {
      String userEmail = emailController.text.trim();

      var validate = EmailFieldValidator.validate(userEmail);

      validate != null
          ? throw 'Email is invalid'
          : auth.sendPasswordResetEmail(userEmail);

      ConfirmationToast.show(
          'Reset password email sent - please check your inbox');
    } on PlatformException catch (e) {
      if ((e.code == 'ERROR_INVALID_EMAIL') ||
          (e.code == 'ERROR_USER_NOT_FOUND')) {
        ErrorToast.show('The email was incorrect');
      }
    } catch (e) {
      ErrorToast.show(e.toString());
    }
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
                controller: emailController,
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
                // children: buildTermsandConds(),
              ),
              SizedBox(
                height: 2.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: buildSubmitButtons(),
              ),
              SizedBox(
                height: 0.0,
              ),
              FlatButton(
                child:
                    Text('Reset My Password', style: TextStyle(fontSize: 15.0)),
                onPressed: resetPassword,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget loginCard() {
    return Opacity(
      opacity: animation.value,
      //opacity: 1.0,
      child: SizedBox(
        height: deviceSize.height / 2 - 12,
        width: deviceSize.width * 0.85,
        child: Card(color: Colors.white, elevation: 2.0, child: loginBuilder()),
      ),
    );
  }

  @override
  initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return loginCard();
  }
}
