import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oauth1/oauth1.dart' as oauth1;
import 'package:url_launcher/url_launcher.dart';

import '../usos.dart';

class Login extends StatelessWidget {
  final pinController = TextEditingController();
  final setStatus;
  FlutterSecureStorage storage;
  Login(this.setStatus, this.storage, {Key? key}) : super(key: key);
  var temporaryCredentials;
  void _authWeb() async {
    auth.requestTemporaryCredentials('oob').then((res) {
      temporaryCredentials = res;
      print(temporaryCredentials.credentials.toString());
      launch(auth.getResourceOwnerAuthorizationURI(
          temporaryCredentials.credentials.token));
    });
  }

  _authPin(String pin) async {
    return auth.requestTokenCredentials(temporaryCredentials.credentials, pin);
  }

  void _authButton() {
    _authPin(pinController.text).then((resp) async {
      final client = oauth1.Client(
          platform.signatureMethod, clientCredentials, resp.credentials);
      // now you can access to protected resources via client
      client.get(Uri.parse(usosApi + 'services/users/user')).then((res) async {
        print(resp.credentials.toString());
        await storage.write(
          key: "oauth_token",
          value: resp.credentials.token,
        );
        await storage.write(
          key: "oauth_token_secret",
          value: resp.credentials.tokenSecret,
        );
        setStatus(false, client);
        //services/courses/user
        //services/progs/student
        //services/grades/course_edition2?course_id=".$kurs."&term_id=2020/2021-Z
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(100),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: _authWeb,
            child: Text('Uzyskaj PIN z USOSa'),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 20,
            ),
            child: TextField(
                decoration: InputDecoration(labelText: "Pin"),
                controller: pinController,
                keyboardType: TextInputType.number,
                onSubmitted: (_) => _authButton),
          ),
          ElevatedButton(
            onPressed: _authButton,
            child: Text('Zaloguj'),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }
}
