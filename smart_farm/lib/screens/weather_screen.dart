import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_farm/screens/notifications_screen.dart';
import 'package:smart_farm/services/weather_service.dart';
import 'package:smart_farm/widgets/farm_loader.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:smart_farm/widgets/animated_weather_icon.dart';
import 'package:smart_farm/widgets/fast_page_route.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherService>(
      builder: (context, svc, _) {
        final w = svc.weatherData;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFF4A6741);

        return Scaffold(
          backgroundColor: bgColor,
          body: svc.isLoading
              ? const Center(child: FarmLoader(size: 80, color: Colors.white))
              : SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header ──────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    w?.cityName ?? 'My Farm',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _todayLabel(),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  _headerBtn(Icons.refresh, () => svc.fetchWeather()),
                                  const SizedBox(width: 4),
                                  _headerBtn(
                                    Icons.notifications_none,
                                    () => Navigator.push(
                                      context,
                                      FastPageRoute(
                                          page: const NotificationsScreen()),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Error banner
                        if (svc.error != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                            child: _ErrorBanner(error: svc.error!, onRetry: svc.fetchWeather),
                          ),

                        // ── Main Temp Card ───────────────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: _MainTempCard(w: w),
                        ),

                        // ── Smart Farming Suggestions ────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: _SmartSuggestionsCard(w: w),
                        ),

                        // ── 7-Day Forecast ───────────────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: _ForecastCard(svc: svc),
                        ),

                        // ── 2×2 Stats Grid ───────────────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                          child: _StatsGrid(w: w),
                        ),

                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _headerBtn(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    const months = [
      'JAN','FEB','MAR','APR','MAY','JUN',
      'JUL','AUG','SEP','OCT','NOV','DEC'
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

// ── Main Temperature Card ────────────────────────────────────────────────────

class _MainTempCard extends StatelessWidget {
  final WeatherData? w;
  const _MainTempCard({required this.w});

  @override
  Widget build(BuildContext context) {
    final temp = w != null ? '${w!.temperature.round()}°C' : '--°C';
    final feelsLike = w != null ? '${w!.feelsLike.round()}°C' : '--';
    final condition = w?.condition ?? '--';
    final high = w?.forecast.isNotEmpty == true
        ? '${w!.forecast.first.maxTemp.round()}°'
        : '--°';
    final low = w?.forecast.isNotEmpty == true
        ? '${w!.forecast.first.minTemp.round()}°'
        : '--°';
    final icon = w != null ? WeatherService.codeToIcon(w!.weatherCode) : Icons.wb_sunny_outlined;
    final iconColor = w != null ? WeatherService.iconColorForCode(w!.weatherCode) : const Color(0xFFFFD54F);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      temp,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 68,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$condition  •  ${TranslationService.translate('feels_like')} $feelsLike',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedWeatherIcon(icon: icon, color: iconColor, size: 44),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'H: $high  L: $low',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Smart Farming Suggestions ────────────────────────────────────────────────

class _SmartSuggestionsCard extends StatelessWidget {
  final WeatherData? w;
  const _SmartSuggestionsCard({required this.w});

  @override
  Widget build(BuildContext context) {
    final wind = w?.windSpeed ?? 0;
    final rain = w?.rainfall ?? 0;
    final code = w?.weatherCode ?? 0;

    // Decide if good for spraying (low wind, no rain, not raining)
    final safeForSpraying = wind < 20 && rain < 1 && code < 50;
    // Good for planting if not rainy or stormy
    final goodForPlanting = code < 60 && rain < 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              TranslationService.translate('smart_farming_suggestions') ?? 'SMART FARMING SUGGESTIONS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.7)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SuggestionTile(
                icon: Icons.water_drop,
                iconColor: const Color(0xFF4A6741),
                bgColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.surface : const Color(0xFFDCEDD8),
                title: safeForSpraying ? (TranslationService.translate('safe_spraying') ?? 'Safe for Spraying') : (TranslationService.translate('avoid_spraying') ?? 'Avoid Spraying'),
                subtitle: safeForSpraying ? 'Ideal wind & dry conditions' : 'Rain or high wind detected',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SuggestionTile(
                icon: Icons.agriculture,
                iconColor: const Color(0xFF7A6030),
                bgColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.surface : const Color(0xFFFFF8E1),
                title: goodForPlanting ? (TranslationService.translate('good_planting') ?? 'Good for Planting') : (TranslationService.translate('delay_planting') ?? 'Delay Planting'),
                subtitle: goodForPlanting ? 'Soil moisture optimal' : 'Unfavourable conditions',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;

  const _SuggestionTile({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: iconColor,
                  height: 1.2)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(fontSize: 11, color: iconColor.withOpacity(0.75), height: 1.3)),
        ],
      ),
    );
  }
}

// ── 7-Day Forecast Card ──────────────────────────────────────────────────────

class _ForecastCard extends StatelessWidget {
  final WeatherService svc;
  const _ForecastCard({required this.svc});

  @override
  Widget build(BuildContext context) {
    final forecasts = svc.weatherData?.forecast ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationService.translate('weather_title') != 'Weather Forecast' ? TranslationService.translate('weather_title').toUpperCase() : '7-DAY FORECAST',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          forecasts.isEmpty
              ? Center(
                  child: Text(TranslationService.translate('forecast_not_available') ?? 'Forecast not available',
                      style: const TextStyle(color: Colors.white70)))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: forecasts
                      .map((f) => _ForecastDay(forecast: f))
                      .toList(),
                ),
        ],
      ),
    );
  }
}

class _ForecastDay extends StatelessWidget {
  final DailyForecast forecast;
  const _ForecastDay({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final iconColor = WeatherService.iconColorForCode(forecast.weatherCode);
    return Column(
      children: [
        Text(forecast.day,
            style: const TextStyle(
                color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Icon(WeatherService.codeToIcon(forecast.weatherCode), color: iconColor, size: 22),
        const SizedBox(height: 6),
        Text(
          '${forecast.rainfall.toStringAsFixed(0)}%',
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text('${forecast.maxTemp.round()}°',
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        Text('${forecast.minTemp.round()}°',
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}

// ── 2×2 Stats Grid ───────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final WeatherData? w;
  const _StatsGrid({required this.w});

  @override
  Widget build(BuildContext context) {
    final humidity = w?.humidity ?? 0;
    final wind = w?.windSpeed ?? 0;
    final uv = w?.uvIndex ?? 0;
    final soilMoisture = w?.soilMoisturePct ?? 65.0;

    final soilLabel = soilMoisture < 30
        ? (TranslationService.translate('low') ?? 'LOW')
        : soilMoisture < 60
            ? (TranslationService.translate('moderate') ?? 'MODERATE')
            : (TranslationService.translate('high') ?? 'HIGH');

    final humidityLabel = humidity < 30
        ? (TranslationService.translate('low') ?? 'LOW')
        : humidity < 60
            ? (TranslationService.translate('moderate') ?? 'MODERATE')
            : (TranslationService.translate('high') ?? 'HIGH');
    final uvLabel = uv <= 2
        ? (TranslationService.translate('low') ?? 'LOW')
        : uv <= 5
            ? (TranslationService.translate('moderate') ?? 'MODERATE')
            : uv <= 7
                ? (TranslationService.translate('high') ?? 'HIGH')
                : (TranslationService.translate('very_high') ?? 'VERY HIGH');
    final windLabel = wind <= 5
        ? (TranslationService.translate('calm') ?? 'CALM')
        : wind <= 20
            ? (TranslationService.translate('moderate') ?? 'MODERATE')
            : wind <= 40
                ? (TranslationService.translate('fresh') ?? 'FRESH')
                : (TranslationService.translate('strong') ?? 'STRONG');

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: TranslationService.translate('soil_moisture_label') ?? 'SOIL MOISTURE',
                mainValue: '${soilMoisture.round()}%',
                subValue: soilLabel,
                subText: 'Depth: 0-7 cm',
                icon: Icons.water_drop_outlined,
                iconColor: const Color(0xFF2E7D32),
                isCircular: true,
                circularValue: soilMoisture / 100.0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: TranslationService.translate('humidity') ?? 'HUMIDITY',
                mainValue: '${humidity.round()}%',
                subValue: humidityLabel,
                subText: 'Relative humidity',
                icon: Icons.water,
                iconColor: const Color(0xFF1565C0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: TranslationService.translate('wind_speed') ?? 'WIND SPEED',
                mainValue: '${wind.round()}',
                valueSuffix: ' km/h',
                subValue: windLabel,
                subText: 'Current conditions',
                icon: Icons.flag,
                iconColor: Colors.red.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: TranslationService.translate('uv_index') ?? 'UV INDEX',
                mainValue: uv.toStringAsFixed(1),
                subValue: uvLabel,
                subText: uv > 5 ? 'Sun protection needed' : 'Minimal risk',
                icon: Icons.wb_sunny,
                iconColor: const Color(0xFFFFA000),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String mainValue;
  final String? valueSuffix;
  final String subValue;
  final String subText;
  final IconData icon;
  final Color iconColor;
  final bool isCircular;
  final double circularValue;

  const _StatCard({
    required this.title,
    required this.mainValue,
    this.valueSuffix,
    required this.subValue,
    required this.subText,
    required this.icon,
    required this.iconColor,
    this.isCircular = false,
    this.circularValue = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final titleColor = isDark ? Colors.white70 : Colors.black54;
    final valueColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  letterSpacing: 0.8)),
          const SizedBox(height: 12),
          if (isCircular)
            Row(
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: circularValue,
                        strokeWidth: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                      ),
                      Icon(Icons.water_drop, color: iconColor, size: 18),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mainValue,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: iconColor)),
                    Text(subValue,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: iconColor)),
                  ],
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 36),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: mainValue,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: valueColor),
                          ),
                          if (valueSuffix != null)
                            TextSpan(
                              text: valueSuffix,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: titleColor,
                                  fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ),
                    Text(subValue,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: titleColor)),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 8),
          Text(subText,
              style: TextStyle(fontSize: 10, color: subColor, height: 1.3)),
        ],
      ),
    );
  }
}

// ── Error Banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade300)),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error.contains('denied') || error.contains('disabled')
                  ? 'Location permission needed. Please enable in Settings.'
                  : 'Could not load weather. Tap refresh to retry.',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          IconButton(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
