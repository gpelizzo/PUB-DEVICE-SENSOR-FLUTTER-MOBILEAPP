import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import './../models/user-model.dart';

class AuthenticateService {
  /*FireBase Authentication instance*/
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static User currentUser;

  /*Create UserModel based on Firebase*/
  static UserModel _userFromFirebase(User user) {
    currentUser = user;
    return user != null ? UserModel(user.uid) : null;
  }

  /*Create stream in order to manager User authentification change*/
  static Stream<UserModel> get user {
    return _firebaseAuth
        .authStateChanges()
        //.map((User user) => _userFromFirebase(user));
        .map(_userFromFirebase); //identical to the above line
  }

  /*
   Anonymous SignIn and SignOut - Testing only
  */
  static Future<UserModel> signinAnonymous() async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInAnonymously();

      //final User user = userCredential.user;
      currentUser = userCredential.user;

      if (user != null) {
        return _userFromFirebase(currentUser);
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }

  static Future<void> signOutAnonymous() async {
    await _firebaseAuth.signOut();
  }

  /*
    Goole SignIn and SignOut
  */
  static Future<UserModel> signInWithGoogle() async {
    try {
      /*if not already signed, open Google SignIn Account's pick-up*/
      final GoogleSignInAccount googleSignInAccount =
          await _googleSignIn.signIn();

      /*retrieve Google Account Infos*/
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      /*retrieve OAuth2 access for this account*/
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      /*Autenticate with Firebase*/
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      /*retrieve user infos*/
      //final User user = userCredential.user;
      currentUser = userCredential.user;

      /*ensure user returned exists and is valid*/
      if (user != null) {
        //print('signInWithGoogle succeeded: $user');

        return _userFromFirebase(currentUser);
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }

  static Future<UserModel> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      currentUser = null;
      return _userFromFirebase(currentUser);
    } catch (error) {
      print(error.toString());
    }
  }
}
