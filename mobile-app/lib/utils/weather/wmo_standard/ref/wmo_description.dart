/// WMO Description
///
/// This file is part of the Weather App project and provides utilities
/// for handling WMO (World Meteorological Organization) weather codes.
///
/// Licensed under the MIT License.
///
/// References:
/// - [WMO Code Table 4677](https://www.nodc.noaa.gov/archive/arc0021/0002199/1.1/data/0-data/HTML/WMO-CODE/WMO4677.HTM)
/// - [Open-Meteo Issue #287](https://github.com/open-meteo/open-meteo/issues/287)
/// - [StellaSphere/descriptions.json](https://gist.github.com/stellasphere/9490c195ed2b53c707087c8c2db4ec0c)
library;

const Map<int, String> wmoDescriptions = {
  0: 'Clear sky',
  1: 'Mainly clear',
  2: 'Partly cloudy',
  3: 'Overcast',
  45: 'Fog',
  48: 'Depositing rime fog',
  51: 'Drizzle: Light intensity',
  53: 'Drizzle: Moderate intensity',
  55: 'Drizzle: Dense intensity',
  56: 'Freezing drizzle: Light intensity',
  57: 'Freezing drizzle: Dense intensity',
  61: 'Rain: Slight intensity',
  63: 'Rain: Moderate intensity',
  65: 'Rain: Heavy intensity',
  66: 'Freezing rain: Light intensity',
  67: 'Freezing rain: Heavy intensity',
  71: 'Snow fall: Slight intensity',
  73: 'Snow fall: Moderate intensity',
  75: 'Snow fall: Heavy intensity',
  77: 'Snow grains',
  80: 'Rain showers: Slight intensity',
  81: 'Rain showers: Moderate intensity',
  82: 'Rain showers: Violent intensity',
  85: 'Snow showers: Slight intensity',
  86: 'Snow showers: Heavy intensity',
  95: 'Thunderstorm: Slight or moderate',
  96: 'Thunderstorm with slight hail',
  99: 'Thunderstorm with heavy hail',
};

const Map<int, String> wmoDescriptionsIndonesian = {
  0: 'Langit cerah',
  1: 'Sebagian besar cerah',
  2: 'Sebagian berawan',
  3: 'Mendung',
  45: 'Kabut',
  48: 'Kabut dengan embun beku',
  51: 'Gerimis: Intensitas ringan',
  53: 'Gerimis: Intensitas sedang',
  55: 'Gerimis: Intensitas lebat',
  56: 'Gerimis beku: Intensitas ringan',
  57: 'Gerimis beku: Intensitas lebat',
  61: 'Hujan: Intensitas ringan',
  63: 'Hujan: Intensitas sedang',
  65: 'Hujan: Intensitas lebat',
  66: 'Hujan beku: Intensitas ringan',
  67: 'Hujan beku: Intensitas lebat',
  71: 'Salju: Intensitas ringan',
  73: 'Salju: Intensitas sedang',
  75: 'Salju: Intensitas lebat',
  77: 'Butiran salju',
  80: 'Hujan deras: Intensitas ringan',
  81: 'Hujan deras: Intensitas sedang',
  82: 'Hujan deras: Intensitas hebat',
  85: 'Hujan salju: Intensitas ringan',
  86: 'Hujan salju: Intensitas lebat',
  95: 'Badai petir: Ringan atau sedang',
  96: 'Badai petir dengan hujan es ringan',
  99: 'Badai petir dengan hujan es lebat',
};
