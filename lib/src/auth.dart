import 'dart:async';

import 'package:js/js.dart';

import 'app.dart';
import 'interop/auth_interop.dart';
import 'interop/firebase_interop.dart' as firebase_interop;
import 'js.dart';
import 'utils.dart';

export 'interop/auth_interop.dart'
    show
        ActionCodeInfo,
        ActionCodeEmail,
        AuthCredential,
        EmailAuthProvider,
        FacebookAuthProvider,
        GithubAuthProvider,
        GoogleAuthProvider,
        TwitterAuthProvider;
export 'interop/firebase_interop.dart' show UserProfile;

/// User profile information, visible only to the Firebase project's apps.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.UserInfo>.
class UserInfo<T extends firebase_interop.UserInfoJsImpl>
    extends JsObjectWrapper<T> {
  /// User's display name.
  String get displayName => jsObject.displayName;
  void set displayName(String s) {
    jsObject.displayName = s;
  }

  /// User's e-mail address.
  String get email => jsObject.email;
  void set email(String s) {
    jsObject.email = s;
  }

  /// User's profile picture URL.
  String get photoURL => jsObject.photoURL;
  void set photoURL(String s) {
    jsObject.photoURL = s;
  }

  /// User's authentication provider ID.
  String get providerId => jsObject.providerId;
  void set providerId(String s) {
    jsObject.providerId = s;
  }

  /// User's unique ID.
  String get uid => jsObject.uid;
  void set uid(String s) {
    jsObject.uid = s;
  }

  /// Creates a new UserInfo from [jsObject].
  UserInfo.fromJsObject(T jsObject) : super.fromJsObject(jsObject);
}

/// User account.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.User>.
class User extends UserInfo<firebase_interop.UserJsImpl> {
  /// If the user's email address has been already verified.
  bool get emailVerified => jsObject.emailVerified;

  /// If the user is anonymous.
  bool get isAnonymous => jsObject.isAnonymous;

  /// List of additional provider-specific information about the user.
  List<UserInfo> get providerData => jsObject.providerData
      .map((data) =>
          new UserInfo<firebase_interop.UserInfoJsImpl>.fromJsObject(data))
      .toList();

  /// Refresh token for the user account.
  String get refreshToken => jsObject.refreshToken;

  /// Creates a new User from [jsObject].
  User.fromJsObject(firebase_interop.UserJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Deletes and signs out the user.
  Future delete() => handleThenable(jsObject.delete());

  /// Returns a JWT token used to identify the user to a Firebase service.
  /// It forces refresh regardless of token expiration if [forceRefresh]
  /// parameter is [true].
  Future<String> getToken([bool forceRefresh = false]) =>
      handleThenable(jsObject.getToken(forceRefresh));

  /// Links the user account with the given [credential].
  Future<User> link(AuthCredential credential) => handleThenableWithMapper(
      jsObject.link(credential), (u) => new User.fromJsObject(u));

  /// Links the authenticated [provider] to the user account using
  /// a pop-up based OAuth flow.
  Future<UserCredential> linkWithPopup(AuthProvider provider) =>
      handleThenableWithMapper(jsObject.linkWithPopup(provider),
          (u) => new UserCredential.fromJsObject(u));

  /// Links the authenticated [provider] to the user account using
  /// a full-page redirect flow.
  Future linkWithRedirect(AuthProvider provider) =>
      handleThenable(jsObject.linkWithRedirect(provider));

  /// Re-authenticates a user using a fresh [credential]. Should be used
  /// before operations such as [updatePassword()] that require tokens
  /// from recent sign-in attempts.
  Future reauthenticate(AuthCredential credential) =>
      handleThenable(jsObject.reauthenticate(credential));

  /// If signed in, it refreshes the current user.
  Future reload() => handleThenable(jsObject.reload());

  /// Sends an e-mail verification to a user.
  Future sendEmailVerification() =>
      handleThenable(jsObject.sendEmailVerification());

  /// Unlinks a provider with [providerId] from a user account.
  Future<User> unlink(String providerId) => handleThenableWithMapper(
      jsObject.unlink(providerId),
      (firebase_interop.UserJsImpl u) => new User.fromJsObject(u));

  /// Updates the user's e-mail address to [newEmail].
  Future updateEmail(String newEmail) =>
      handleThenable(jsObject.updateEmail(newEmail));

  /// Updates the user's password to [newPassword].
  /// Requires the user to have recently signed in. If not, ask the user
  /// to authenticate again and then use [reauthenticate()].
  Future updatePassword(String newPassword) =>
      handleThenable(jsObject.updatePassword(newPassword));

  /// Updates a user's [profile] data.
  /// UserProfile has a displayName and photoURL.
  ///
  ///     UserProfile profile = new UserProfile(displayName: "Smart user");
  ///     await user.updateProfile(profile);
  Future updateProfile(firebase_interop.UserProfile profile) =>
      handleThenable(jsObject.updateProfile(profile));
}

/// The Firebase Auth service class.
///
/// See: <https://firebase.google.com/docs/reference/js/firebase.auth.Auth>.
class Auth extends JsObjectWrapper<AuthJsImpl> {
  App _app;

  /// App for this instance of auth service.
  App get app {
    if (_app != null) {
      _app.jsObject = jsObject.app;
    } else {
      _app = new App.fromJsObject(jsObject.app);
    }
    return _app;
  }

  User _currentUser;

  /// Currently signed-in user.
  User get currentUser {
    if (jsObject.currentUser != null) {
      if (_currentUser != null) {
        _currentUser.jsObject = jsObject.currentUser;
      } else {
        _currentUser = new User.fromJsObject(jsObject.currentUser);
      }
    } else {
      _currentUser = null;
    }
    return _currentUser;
  }

  var _onAuthUnsubscribe;
  StreamController<AuthEvent> _changeController;
  Stream<AuthEvent> get onAuthStateChanged {
    if (_changeController == null) {
      var nextWrapper = allowInterop((firebase_interop.UserJsImpl user) {
        _changeController.add(
            new AuthEvent((user != null) ? new User.fromJsObject(user) : null));
      });

      var errorWrapper = allowInterop((e) => _changeController.addError(e));

      void startListen() {
        _onAuthUnsubscribe =
            jsObject.onAuthStateChanged(nextWrapper, errorWrapper);
      }

      void stopListen() {
        _onAuthUnsubscribe();
      }

      _changeController = new StreamController<AuthEvent>.broadcast(
          onListen: startListen, onCancel: stopListen, sync: true);
    }
    return _changeController.stream;
  }

  Auth.fromJsObject(AuthJsImpl jsObject) : super.fromJsObject(jsObject);

  Future applyActionCode(String code) =>
      handleThenable(jsObject.applyActionCode(code));

  Future<ActionCodeInfo> checkActionCode(String code) =>
      handleThenable(jsObject.checkActionCode(code));

  Future confirmPasswordReset(String code, String newPassword) =>
      handleThenable(jsObject.confirmPasswordReset(code, newPassword));

  Future<User> createUserWithEmailAndPassword(String email, String password) =>
      handleThenableWithMapper(
          jsObject.createUserWithEmailAndPassword(email, password),
          (u) => new User.fromJsObject(u));

  Future<List<String>> fetchProvidersForEmail(String email) =>
      handleThenable(jsObject.fetchProvidersForEmail(email));

  Future<UserCredential> getRedirectResult() => handleThenableWithMapper(
      jsObject.getRedirectResult(), (u) => new UserCredential.fromJsObject(u));

  Future sendPasswordResetEmail(String email) =>
      handleThenable(jsObject.sendPasswordResetEmail(email));

  Future<User> signInAnonymously() => handleThenableWithMapper(
      jsObject.signInAnonymously(), (u) => new User.fromJsObject(u));

  Future<User> signInWithCredential(AuthCredential credential) =>
      handleThenableWithMapper(jsObject.signInWithCredential(credential),
          (u) => new User.fromJsObject(u));

  Future<User> signInWithCustomToken(String token) => handleThenableWithMapper(
      jsObject.signInWithCustomToken(token), (u) => new User.fromJsObject(u));

  Future<User> signInWithEmailAndPassword(String email, String password) =>
      handleThenableWithMapper(
          jsObject.signInWithEmailAndPassword(email, password),
          (u) => new User.fromJsObject(u));

  Future<UserCredential> signInWithPopup(AuthProvider provider) =>
      handleThenableWithMapper(jsObject.signInWithPopup(provider),
          (u) => new UserCredential.fromJsObject(u));

  Future signInWithRedirect(AuthProvider provider) =>
      handleThenable(jsObject.signInWithRedirect(provider));

  Future signOut() => handleThenable(jsObject.signOut());

  Future<String> verifyPasswordResetCode(String code) =>
      handleThenable(jsObject.verifyPasswordResetCode(code));
}

/// Event propagated in Stream controllers when auth state changes.
class AuthEvent {
  final User user;
  AuthEvent(this.user);
}

/// A structure containing [User] and [AuthCredential].
class UserCredential extends JsObjectWrapper<UserCredentialJsImpl> {
  User _user;
  User get user {
    if (jsObject.user != null) {
      if (_user != null) {
        _user.jsObject = jsObject.user;
      } else {
        _user = new User.fromJsObject(jsObject.user);
      }
    } else {
      _user = null;
    }
    return _user;
  }

  void set user(User u) {
    _user = u;
    jsObject.user = u.jsObject;
  }

  AuthCredential get credential => jsObject.credential;

  void set credential(AuthCredential c) {
    jsObject.credential = c;
  }

  factory UserCredential({User user, AuthCredential credential}) =>
      new UserCredential.fromJsObject(new UserCredentialJsImpl(
          user: user.jsObject, credential: credential));

  UserCredential.fromJsObject(UserCredentialJsImpl jsObject)
      : super.fromJsObject(jsObject);
}
