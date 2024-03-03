import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weatheragripedia/services/weather_services.dart';
import 'package:weatheragripedia/weather_page.dart';
import 'models/weather_model.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:geocoding/geocoding.dart';
import 'package:clock/clock.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    // wait 5 seconds
    Timer.periodic(Duration(milliseconds: 200), (Timer timer) {
      if (_progress < 1.0) {
        setState(() {
          _progress += 0.1;
          _progress = _progress.clamp(0.0, 1.0);
        });
      } else {
        timer.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => WeatherPage()),
        );
      }
    });

    Timer(Duration(seconds: 10), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => WeatherPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF191919),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'SIMPLEWEATHER',
                style: TextStyle(
                  fontFamily: 'Oswald',
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              SvgPicture.asset('assets/icon.svg', height: 100, width: 100),
              SizedBox(height: 15),
              Container(
                width: 150,
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[700],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(height: 10),
              Text(
                '${(_progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ));
  }
}

class _WeatherPageState extends State<WeatherPage> {
  //time
  String formattedTime = 'Loading time...';

  void updateTime() {
    final now = DateTime.now();
    final timeFormatter = DateFormat.Hm('en_US').add_yMMMd();
    formattedTime = timeFormatter.format(now);
    setState(() {});
  }

  //api key
  final _weatherService = WeatherService('');
  Weather? _weather;

  // fetch weather
  _fetchWeather() async {
    // get current city
    String cityName = await _weatherService.getCurrentCity();

    //get weather for city
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  // weather animation
  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloudy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  // init state
  @override
  void initState() {
    super.initState();

    // fetch weather on startup
    _fetchWeather();
    updateTime();
    Timer.periodic(Duration(minutes: 1), (timer) => updateTime());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF191919),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _weather?.cityName ?? "Loading city...",
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
                shadows: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.3), // Adjust the color and opacity
                    spreadRadius: 10,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
            // animation
            Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),

            // temperature
            Text(
              '${_weather?.temperature.round()}°C',
              style: TextStyle(
                fontFamily: 'Alfa',
                fontSize: 60,
                color: Colors.white,
                shadows: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.3), // Adjust the color and opacity
                    spreadRadius: 10,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),

            // weather condition
            Text(
              _weather?.mainCondition?.toLowerCase() == "clouds"
                  ? "Super Cozy"
                  : _weather?.mainCondition?.toLowerCase() == "rain"
                      ? "Bring an Umbrella"
                      : _weather?.mainCondition?.toLowerCase() == "clear"
                          ? "It's a Clear Sky"
                          : _weather?.mainCondition?.toLowerCase() ==
                                  "thunderstorm"
                              ? "Someone's Mad!"
                              : _weather?.mainCondition?.toLowerCase() ==
                                      "clear"
                                  ? "I know, it's hot."
                                  : _weather?.mainCondition ?? "",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.3), // Adjust the color and opacity
                    spreadRadius: 10,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
