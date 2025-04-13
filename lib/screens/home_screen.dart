import 'package:flutter/material.dart';
import 'package:oracle/models/heat_index_data.dart';
import 'package:oracle/models/temperature_data.dart';
import 'package:oracle/models/humidity_data.dart';
import 'package:oracle/widgets/map_placeholder.dart';
import 'package:provider/provider.dart';
import '../widgets/sidebar_menu.dart';
import '../widgets/heat_index_container.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/temperature_container.dart';
import '../widgets/humidity_container.dart';
import '../widgets/heat_index_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isFahrenheit = false;  // Changed from true to false
  late final Humidity _humidityProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _humidityProvider = Humidity();  // Create single instance
  }

  @override
  void dispose() {
    _tabController.dispose();
    _humidityProvider.dispose();  // Dispose of the Humidity instance
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Provider.of<UserProfileProvider>(context);
    
    return Scaffold(
      backgroundColor: isDarkMode ? null : const Color(0xFFFAFAFA),
      drawer: const SidebarMenu(), // Add this line to enable the sidebar
      appBar: AppBar(
        toolbarHeight: 80,
        leading: Builder(
          builder: (context) => Container(
            margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Material(
              type: MaterialType.circle,
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: IconButton(
                icon: const Icon(Icons.menu),
                splashRadius: 24,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          ),
        ),
        title: Center(  // Wrap with Center widget
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,  // Important for proper centering
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Oracle',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '°',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Text(
                'Castillejos, PH',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: const [
          SizedBox(width: 48),  // Keep this to balance with the leading icon
        ],
        backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Map View'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0), // Reduced top padding
                child: Column(
                  children: [
                    ChangeNotifierProvider(
                      create: (_) => HeatIndex(),
                      child: Consumer<HeatIndex>(
                        builder: (context, heatIndex, _) => HeatIndexContainer(
                          heatIndex: heatIndex,
                          onSwap: () {
                            setState(() {
                              isFahrenheit = !isFahrenheit;
                            });
                          },
                        ),
                      ),
                    ),
                    const HeatIndexChart(),
                    ChangeNotifierProvider(
                      create: (_) => Temperature(),
                      child: Consumer<Temperature>(
                        builder: (context, temperature, _) => TemperatureContainer(
                          temperature: temperature,
                          onSwap: () {
                            setState(() {
                              isFahrenheit = !isFahrenheit;
                            });
                          },
                        ),
                      ),
                    ),
                    ChangeNotifierProvider(
                      create: (_) => Humidity(),
                      child: Consumer<Humidity>(
                        builder: (context, humidity, _) => const HumidityContainer(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0), // Reduced top padding
              child: const MapPlaceholder(),
            ),
          ),
        ],
      ),
    );
  }
}