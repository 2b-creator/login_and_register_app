import 'package:device_uuid/device_uuid.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class HttpHandlerIm {
  static String host = 'https://matrix.phosphorus.top';
  static String emailRec = '/_matrix/client/v3/register/email/requestToken';
  static String reg = '/_matrix/client/v3/register';
  static int attempt = 0;
}

class API {
  final dio = Dio();

  Future<String> registerUserService({
    required String username,
    required String password,
    required String email,
  }) async {
    try {
      //DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      //AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      //final uuid = DeviceUuid().getUUID();
      HttpHandlerIm.attempt++;
      final data = {
        'client_secret': 'onZR8j57RKTTU8wM',
        'email': email,
        'send_attempt': HttpHandlerIm.attempt,
      };

      final resp = await dio.post(HttpHandlerIm.host + HttpHandlerIm.emailRec,
          data: data,);
      print(1);
      final serverSid = resp.data['sid'].toString();
      return serverSid;
    } catch (e) {
      HttpHandlerIm.attempt += 1;
      throw e;
    }
  }
}

class RegEmailAuthWidget extends StatefulWidget {
  const RegEmailAuthWidget(
      {required this.sid, required this.username, required this.password, super.key,});
  final String sid;
  final String username;
  final String password;
  @override
  State<RegEmailAuthWidget> createState() => _RegEmailAuthState();
}

class _RegEmailAuthState extends State<RegEmailAuthWidget> {
  final uuid = DeviceUuid().getUUID();
  Future<void> _finishValid() async {
    final dataAuth = {
      'auth': {
        'type': 'm.login.email.identity',
        'threepid_creds': {
          'sid': widget.sid,
          'client_secret': 'onZR8j57RKTTU8wM',
          'id_server': 'matrix.phosphorus.top',
        },
      },
      'device_id': 'unknown',
      'initial_device_display_name': 'unknown',
      'password': widget.password,
      'username': widget.username,
    };

    final dio = Dio();
    try {
      final resp = await dio.post(HttpHandlerIm.host + HttpHandlerIm.reg,
          data: dataAuth,);
      if (resp.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resp.data.toString()),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('注册成功！'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //TODO
    return Scaffold(
      appBar: AppBar(
        title: const Text('邮箱验证'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('请注意查收您的验证邮箱以便完成验证，注意，请在验证完毕后点击我已完成验证！'),
            TextButton(onPressed: _finishValid, child: const Text('我已完成验证')),
          ],
        ),
      ),
    );
  }
}
