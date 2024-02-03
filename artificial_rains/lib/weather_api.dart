import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherUtility {
// ignore: constant_identifier_names
  static const HIGH_TEMPERATURE_THRESHOLD = 26;
// ignore: constant_identifier_names
  static const LOW_CLOUD_THRESHOLD = 50;
// ignore: constant_identifier_names
  static const LOW_HUMIDITY_THRESHOLD = 47;
// ignore: constant_identifier_names
  static const LOW_PRECIPITATION_THRESHOLD = 1.7;
// ignore: constant_identifier_names
  static const DAYS_SINCE_RAINFALL_THRESHOLD = 126;
// ignore: constant_identifier_names
  static const LOW_RAINFALL_DAYSAVG_THRESHOLD = 15;

  static const String apiKey = 'fc93adce78a00821dc573efaa63d2666';
  late double latitude;
  late double longitude;
  Future<Map<String, double>> getCoordinatesForCity(String cityName) async {
    final String geocodingUrl =
        'https://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=1&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(geocodingUrl));

      if (response.statusCode == 200) {
        // Parse the JSON data
        List<dynamic> geocodingData = json.decode(response.body);

        if (geocodingData.isNotEmpty) {
          latitude = geocodingData[0]['lat'].toDouble();
          longitude = geocodingData[0]['lon'].toDouble();
          return {'latitude': latitude, 'longitude': longitude};
        } else {
          throw Exception('City not found');
        }
      } else {
        throw Exception('Failed to fetch geocoding data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<dynamic>> getHistoricalTemperatures(double latitude,
      double longitude, String startDate, String endDate) async {
    final String historicalWeatherUrl =
        'https://archive-api.open-meteo.com/v1/era5?latitude=$latitude&longitude=$longitude&start_date=$startDate&end_date=$endDate&hourly=temperature_2m';

    try {
      final response = await http.get(Uri.parse(historicalWeatherUrl));

      if (response.statusCode == 200) {
        // Parse the JSON data
        Map<String, dynamic> weatherData = json.decode(response.body);
        List<dynamic> hourlyTemperatures =
            weatherData['hourly']['temperature_2m'];
        return hourlyTemperatures;
      } else {
        throw Exception('Failed to fetch historical weather data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<double> calculateAverageTemperature(
      String city, String startDate, String endDate) async {
    await getCoordinatesForCity(city);
    List<dynamic> hourlyTemperatures = await getHistoricalTemperatures(
        latitude, longitude, startDate, endDate);

    // Calculate average temperature
    if (hourlyTemperatures.isNotEmpty) {
      double sum = 0.0;
      for (var temperature in hourlyTemperatures) {
        sum += temperature.toDouble();
      }
      return sum / hourlyTemperatures.length;
    } else {
      return 0.0;
    }
  }

  Future<List<dynamic>> getHistoricalCloudCoverage(double latitude,
      double longitude, String startDate, String endDate) async {
    final String historicalWeatherUrl =
        'https://archive-api.open-meteo.com/v1/era5?latitude=$latitude&longitude=$longitude&start_date=$startDate&end_date=$endDate&hourly=cloud_cover';

    try {
      final response = await http.get(Uri.parse(historicalWeatherUrl));

      if (response.statusCode == 200) {
        // Parse the JSON data
        Map<String, dynamic> weatherData = json.decode(response.body);
        List<dynamic> hourlyClouds = weatherData['hourly']['cloud_cover'];
        return hourlyClouds;
      } else {
        throw Exception('Failed to fetch historical weather data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<double> getCurrentCloudCoverage(String city) async {
    await getCoordinatesForCity(city);
    final String historicalWeatherUrl =
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=cloud_cover&forecast_days=1';

    try {
      final response = await http.get(Uri.parse(historicalWeatherUrl));

      if (response.statusCode == 200) {
        // Parse the JSON data
        Map<String, dynamic> weatherData = json.decode(response.body);
        double currentClouds = weatherData['current']['cloud_cover'].toDouble();
        return currentClouds;
      } else {
        throw Exception('Failed to fetch historical weather data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<double> calculateAverageCloudCoverage(
      String city, String startDate, String endDate) async {
    await getCoordinatesForCity(city);
    List<dynamic> hourlyClouds = await getHistoricalCloudCoverage(
        latitude, longitude, startDate, endDate);

    // Calculate average temperature
    if (hourlyClouds.isNotEmpty) {
      double sum = 0.0;
      for (var cloud in hourlyClouds) {
        sum += cloud.toDouble();
      }
      return sum / hourlyClouds.length;
    } else {
      return 0.0;
    }
  }

  Future<List<dynamic>> getHistoricalHumidity(double latitude, double longitude,
      String startDate, String endDate) async {
    final String historicalWeatherUrl =
        'https://archive-api.open-meteo.com/v1/era5?latitude=$latitude&longitude=$longitude&start_date=$startDate&end_date=$endDate&hourly=relative_humidity_2m';

    try {
      final response = await http.get(Uri.parse(historicalWeatherUrl));

      if (response.statusCode == 200) {
        // Parse the JSON data
        Map<String, dynamic> weatherData = json.decode(response.body);
        List<dynamic> hourlyHumidity =
            weatherData['hourly']['relative_humidity_2m'];
        return hourlyHumidity;
      } else {
        throw Exception('Failed to fetch historical weather data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<double> calculateAverageHumidity(
      String city, String startDate, String endDate) async {
    await getCoordinatesForCity(city);
    List<dynamic> hourlyHumidity =
        await getHistoricalHumidity(latitude, longitude, startDate, endDate);

    // Calculate average temperature
    if (hourlyHumidity.isNotEmpty) {
      double sum = 0.0;
      for (var humidity in hourlyHumidity) {
        sum += humidity.toDouble();
      }
      return sum / hourlyHumidity.length;
    } else {
      return 0.0;
    }
  }

  Future<List<dynamic>> getHistoricalRainFall(double latitude, double longitude,
      String startDate, String endDate) async {
    final String historicalWeatherUrl =
        'https://archive-api.open-meteo.com/v1/era5?latitude=$latitude&longitude=$longitude&start_date=$startDate&end_date=$endDate&daily=precipitation_hours&timezone=auto';

    try {
      final response = await http.get(Uri.parse(historicalWeatherUrl));

      if (response.statusCode == 200) {
        // Parse the JSON data
        Map<String, dynamic> weatherData = json.decode(response.body);
        List<dynamic> dailyRains = weatherData['daily']['precipitation_hours'];
        return dailyRains;
      } else {
        throw Exception('Failed to fetch historical weather data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, double>> calculateRainFallDays(
      String city, String startDate, String endDate) async {
    await getCoordinatesForCity(city);
    List<dynamic> historicalRainfall =
        await getHistoricalRainFall(latitude, longitude, startDate, endDate);

    int rainedDaysAgo = 0;
    double sumOfRainyDays = 0.0;

    if (historicalRainfall.isNotEmpty) {
      for (var i = historicalRainfall.length - 1; i >= 0; i--) {
        if (historicalRainfall[i] == 0.0) {
          rainedDaysAgo++;
        } else {
          break;
        }
      }

      for (var rained in historicalRainfall) {
        if (rained != 0.0) {
          sumOfRainyDays++;
        }
      }

      return {
        'totalRainyDays': sumOfRainyDays,
        'daysAgoLastRained': rainedDaysAgo.toDouble()
      };
    } else {
      return {'totalRainyDays': 0.0, 'daysAgoLastRained': 0.0};
    }
  }

  Future<double> calculateAverageRainFallDays(
      String city, String startDate, String endDate) async {
    late Map<String, double> totalRainDays;
    await calculateRainFallDays(city, startDate, endDate)
        .then((Map<String, double> result) {
      totalRainDays = result;
    });
    double? totalRainyDays = totalRainDays['totalRainyDays'];
    DateTime startDateTime = DateTime.parse(startDate);
    DateTime endDateTime = DateTime.parse(endDate);
    int numberOfDays = endDateTime.difference(startDateTime).inDays + 1;

    return numberOfDays > 0 ? (totalRainyDays! / numberOfDays) * 100 : 0.0;
  }

  Future<List<dynamic>> getHistoricalPrecipitation(double latitude,
      double longitude, String startDate, String endDate) async {
    final String historicalWeatherUrl =
        'https://archive-api.open-meteo.com/v1/era5?latitude=$latitude&longitude=$longitude&start_date=$startDate&end_date=$endDate&daily=precipitation_sum&timezone=auto';

    try {
      final response = await http.get(Uri.parse(historicalWeatherUrl));

      if (response.statusCode == 200) {
        // Parse the JSON data
        Map<String, dynamic> weatherData = json.decode(response.body);
        List<dynamic> dailyPrecipitations =
            weatherData['daily']['precipitation_sum'];
        return dailyPrecipitations;
      } else {
        throw Exception('Failed to fetch historical weather data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<double> calculateAveragePrecipitation(
      String city, String startDate, String endDate) async {
    await getCoordinatesForCity(city);
    List<dynamic> hourlyPrecipitation = await getHistoricalPrecipitation(
        latitude, longitude, startDate, endDate);

    // Calculate average temperature
    if (hourlyPrecipitation.isNotEmpty) {
      double sum = 0.0;
      for (var humidity in hourlyPrecipitation) {
        sum += humidity.toDouble();
      }
      return sum / hourlyPrecipitation.length;
    } else {
      return 0.0;
    }
  }

  Future<Map<String, dynamic>> getCurrentWeatherData(String city) async {
    await getCoordinatesForCity(city);
    String apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Parse the JSON data
        Map<String, dynamic> weatherData = json.decode(response.body);
        return weatherData;
      } else {
        throw Exception('Failed to fetch current weather data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> applicableForRain(String city) async {
    double cloudCoverage = await getCurrentCloudCoverage(city);
    if (cloudCoverage <= LOW_CLOUD_THRESHOLD) {
      return false;
    } else {
      return true;
    }
  }

  Future<String> needsArtificialRain(
      String city, String startDate, String endDate) async {
    late Map<String, double> rainFallData;
    double temperature =
        await calculateAverageTemperature(city, startDate, endDate);
    double cloudCoverage =
        await calculateAverageCloudCoverage(city, startDate, endDate);
    double humidity = await calculateAverageHumidity(city, startDate, endDate);
    await calculateRainFallDays(city, startDate, endDate)
        .then((Map<String, double> result) {
      rainFallData = result;
    });
    double? rainedDaysAgo = rainFallData['daysAgoLastRained'];
    double? totalRainDays = rainFallData['totalRainyDays'];
    double avgRainfallDays =
        await calculateAverageRainFallDays(city, startDate, endDate);
    double precipitation =
        await calculateAveragePrecipitation(city, startDate, endDate);
    int conditionsMet = 0;
    List<String> metConditions = [];
    List<double> metConditionsValues = [];
    bool isApplicable = true;
    String applicablity = "undefined";
    if (temperature > HIGH_TEMPERATURE_THRESHOLD) {
      conditionsMet++;
      metConditions.add('High Temperature');
      metConditionsValues.add(temperature);
    }

    if (cloudCoverage <= LOW_CLOUD_THRESHOLD) {
      conditionsMet++;
      metConditions.add('Cloud Coverage Low%');
      metConditionsValues.add(cloudCoverage);
      isApplicable = false;
    }

    if (humidity <= LOW_HUMIDITY_THRESHOLD) {
      conditionsMet++;
      metConditions.add('Low Humidity');
      metConditionsValues.add(humidity);
    }

    if (rainedDaysAgo! >= DAYS_SINCE_RAINFALL_THRESHOLD) {
      conditionsMet++;
      metConditions.add('no Rainfall Since');
      metConditionsValues.add(rainedDaysAgo);
      metConditionsValues.add(totalRainDays!);
    }

    if (avgRainfallDays <= LOW_RAINFALL_DAYSAVG_THRESHOLD) {
      conditionsMet++;
      metConditions.add('Low Average Rainfall Days');
      metConditionsValues.add(avgRainfallDays);
    }

    if (precipitation <= LOW_PRECIPITATION_THRESHOLD) {
      conditionsMet++;
      metConditions.add('Low Precipitation');
      metConditionsValues.add(precipitation);
    }
    isApplicable
        ? applicablity = "is Able for Artificial Rains"
        : applicablity = "is Not Able for Artificial Rains";
    switch (conditionsMet) {
      case 6:
      case 5:
      case 4:
      case 3:
        return ("$city Needs Artificial Rains $metConditions - $city $applicablity - $conditionsMet");
      default:
        return ("$city - Does Not Require");
    }
  }
}
