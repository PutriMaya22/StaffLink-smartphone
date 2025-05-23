import 'package:flutter/foundation.dart';

const String localIp = '192.168.18.162'; // Ganti dengan IP server Laravel kamu
const String port = '8080';

final String baseUrl = kIsWeb
    ? 'http://$localIp:$port'
    : 'http://$localIp:$port';
