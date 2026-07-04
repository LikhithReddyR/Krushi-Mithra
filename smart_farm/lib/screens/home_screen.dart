import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_farm/screens/scanner_screen.dart';
import 'package:smart_farm/screens/mandi_screen.dart';
import 'package:smart_farm/screens/sell_screen.dart';
import 'package:smart_farm/screens/rent_screen.dart';
import 'package:smart_farm/screens/weather_screen.dart';
import 'package:smart_farm/screens/shop_screen.dart';
import 'package:smart_farm/screens/profile_screen.dart';
import 'package:smart_farm/screens/soil_moisture_predictor_screen.dart';
import 'package:smart_farm/screens/notifications_screen.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:smart_farm/services/weather_service.dart';
import 'package:smart_farm/theme/app_theme.dart';
import 'package:smart_farm/screens/chatbot_screen.dart';
import 'package:smart_farm/widgets/animated_weather_icon.dart';
import 'package:smart_farm/screens/reminders_screen.dart';
import 'package:smart_farm/screens/videos_screen.dart';
import 'package:smart_farm/widgets/fast_page_route.dart';
import 'package:smart_farm/screens/my_crops_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: TranslationService.currentLanguage,
      builder: (context, lang, child) {
        final weatherSvc = context.watch<WeatherService>();
        return Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
              ),
            ),
            title: Text(TranslationService.translate('home') ?? 'AgriGrow'),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Theme.of(context).iconTheme.color),
                onPressed: () {
                  Navigator.push(
                    context,
                    FastPageRoute(page: const NotificationsScreen()),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(context),
                const SizedBox(height: 20),
                _buildWeatherCard(weatherSvc, context),
                const SizedBox(height: 20),
                _buildScanCard(context),
                const SizedBox(height: 20),
                _buildFunctionGrid(context),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.push(context, FastPageRoute(page: const ChatbotScreen()));
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0), // Slightly less padding to make icon larger
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/images/raitha_bandhu_icon.png'),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherCard(WeatherService svc, BuildContext context) {
    final w = svc.weatherData;
    final temp = w != null ? '${w.temperature.round()}°C' : '--°C';
    final condition = w?.condition ?? 'Loading...';
    final humidity = w != null ? '${w.humidity.round()}%' : '--';
    final wind = w != null ? '${w.windSpeed.round()} km/h' : '--';
    final rain = w != null ? '${w.rainfall.toStringAsFixed(1)} mm' : '--';
    final icon = w != null ? WeatherService.codeToIcon(w.weatherCode) : Icons.wb_sunny;
    final iconColor = w != null ? WeatherService.iconColorForCode(w.weatherCode) : Theme.of(context).primaryColor;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(temp, style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: iconColor)),
                AnimatedWeatherIcon(icon: icon, color: iconColor, size: 44),
              ],
            ),
            const SizedBox(height: 4),
            Text(condition, style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyMedium?.color)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _weatherMetric(TranslationService.translate('humidity') ?? 'Humidity', humidity, Icons.water_drop, context),
                _weatherMetric(TranslationService.translate('wind') ?? 'Wind', wind, Icons.air, context),
                _weatherMetric(TranslationService.translate('rainfall') ?? 'Rain', rain, Icons.umbrella, context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _weatherMetric(String label, String value, IconData icon, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).primaryColor),
            const SizedBox(width: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.titleSmall?.color)),
      ],
    );
  }

  Widget _buildScanCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E3A2B) : Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TranslationService.translate('scan_crop'),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  TranslationService.translate('ai_analysis_desc'),
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.2),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ],
      ),
    );
  }

  Widget _buildFunctionGrid(BuildContext context) {
    final items = [
      {'title': 'my_crops', 'icon': Icons.agriculture, 'color': Colors.green.shade100, 'onTap': () {
        Navigator.push(context, FastPageRoute(page: const MyCropsScreen()));
      }},
      {'title': 'scan_crop', 'icon': Icons.camera_alt, 'color': Colors.blue.shade50, 'onTap': () {
        Navigator.push(context, FastPageRoute(page: const ScannerScreen()));
      }},
      {'title': 'sell_crops', 'icon': Icons.storefront, 'color': Colors.orange.shade50, 'onTap': () {
        Navigator.push(context, FastPageRoute(page: const MandiScreen(initialIndex: 1)));
      }},
      {'title': 'hire_machinery', 'icon': Icons.build, 'color': Colors.green.shade50, 'onTap': () {
        Navigator.push(context, FastPageRoute(page: const RentScreen()));
      }},
      {'title': 'check_prices', 'icon': Icons.trending_up, 'color': Colors.purple.shade50, 'onTap': () {
        Navigator.push(context, FastPageRoute(page: const MandiScreen(initialIndex: 0)));
      }},
      {'title': 'Reminders', 'icon': Icons.alarm, 'color': Colors.teal.shade50, 'onTap': () {
        Navigator.push(context, FastPageRoute(page: const RemindersScreen()));
      }},
      {'title': 'Watch Videos', 'icon': Icons.play_circle_fill, 'color': Colors.red.shade50, 'onTap': () {
        Navigator.push(context, FastPageRoute(page: const VideosScreen()));
      }},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(TranslationService.translate('quick_actions') ?? 'Quick Actions',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
              letterSpacing: 1.1,
            )),
        const SizedBox(height: 16),
        GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final baseColor = item['color'] as Color;
            
            return InkWell(
              onTap: item['onTap'] as void Function()?,
              borderRadius: BorderRadius.circular(20),
              splashColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark ? Theme.of(context).colorScheme.surface : baseColor,
                      isDark ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black26 : baseColor.withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        TranslationService.translate(item['title'] as String),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          letterSpacing: 0.7,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        showSearch(context: context, delegate: AppSearchDelegate());
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Text(
              TranslationService.translate('search') ?? 'Search app features...',
              style: TextStyle(color: Theme.of(context).textTheme.titleSmall?.color, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class AppSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> searchItems = [
    {
      'title': 'My Crops Tracking',
      'icon': Icons.agriculture,
      'screen': const MyCropsScreen()
    },
    {
      'title': 'Weather Forecast',
      'icon': Icons.wb_sunny,
      'screen': const WeatherScreen()
    },
    {
      'title': 'Scan Crop Disease',
      'icon': Icons.camera_alt,
      'screen': const ScannerScreen()
    },
    {
      'title': 'Sell Crops (Mandi)',
      'icon': Icons.storefront,
      'screen': const SellScreen()
    },
    {
      'title': 'Hire Machinery',
      'icon': Icons.build,
      'screen': const RentScreen()
    },
    {
      'title': 'Soil Moisture Predictor',
      'icon': Icons.shower,
      'screen': const SoilMoisturePredictorScreen()
    },
    {
      'title': 'Shop (Buy inputs)',
      'icon': Icons.shopping_cart,
      'screen': const ShopScreen()
    },
    {
      'title': 'Profile',
      'icon': Icons.person,
      'screen': const ProfileScreen()
    },
    {
      'title': 'Reminders',
      'icon': Icons.alarm,
      'screen': const RemindersScreen()
    },
    {
      'title': 'Farming Videos',
      'icon': Icons.play_circle_fill,
      'screen': const VideosScreen()
    },
  ];

  @override
  String get searchFieldLabel => TranslationService.translate('search') ?? 'Search app features...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.grey),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final suggestions = searchItems.where((item) {
      return (item['title'] as String).toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (suggestions.isEmpty) {
      return const Center(child: Text('No features found', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(item['icon'] as IconData, color: Theme.of(context).primaryColor, size: 20),
          ),
          title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              FastPageRoute(page: item['screen'] as Widget),
            );
          },
        );
      },
    );
  }
}

