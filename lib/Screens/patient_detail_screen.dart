import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../Utils/main_variables.dart';
import '../Utils/health_service.dart';

class PatientDetailScreen extends StatefulWidget {
  final dynamic patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> with WidgetsBindingObserver {
  // Health Connect data variables
  int? _heartRate;
  int? _oxygenSaturation;
  int? _calories;
  double? _sleepHours;
  int? _steps;
  double? _distance;
  bool _isLoadingHealthData = false;
  bool _healthDataAvailable = false;
  String _healthDataError = '';
  
  // Real-time timestamp variables
  DateTime? _heartRateTime;
  DateTime? _oxygenTime;
  DateTime? _caloriesTime;
  DateTime? _sleepTime;

  // Auto-refresh timer
  Timer? _refreshTimer;
  DateTime? _lastRefreshTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadHealthData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Refresh data when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _refreshHealthData();
    }
  }

  void _startAutoRefresh() {
    // Refresh every 2 minutes for real-time data when app is active
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (mounted) {
        _refreshHealthData();
      }
    });
  }

  void _refreshHealthData() {
    // Only refresh if it's been at least 30 seconds since last refresh
    final now = DateTime.now();
    if (_lastRefreshTime == null || 
        now.difference(_lastRefreshTime!).inSeconds >= 30) {
      _lastRefreshTime = now;
      _loadHealthData();
    }
  }

  Future<void> _loadHealthData() async {
    setState(() {
      _isLoadingHealthData = true;
      _healthDataError = '';
    });

    try {
      // Use the final, most robust Health Connect service
      final healthService = HealthService();
      
      // Initialize Health Connect service
      await healthService.initialize();
      
      // Check if all permissions are granted
      final permissionsGranted = await healthService.checkAllPermissions();
      
      if (!permissionsGranted) {
        setState(() {
          _healthDataAvailable = false;
          _healthDataError = 'Please grant all health permissions in your device settings: Settings > Apps > CardioPTech > Permissions';
          _isLoadingHealthData = false;
        });
        return;
      }

      // Get health data from Health Connect (this will handle permission verification internally)
      final healthData = await healthService.getAllHealthData();
      
      // Check if we got any meaningful data (non-null, non-zero values)
      final hasAnyData = healthData.values.any((value) => value != null);
      final hasMeaningfulData = healthData.entries.any((entry) {
        final value = entry.value;
        if (value == null) return false;
        if (value is num) return value > 0;
        return true; // For non-numeric values like DateTime
      });
      
      if (!hasAnyData) {
        // Check if HealthConnect is available and connected
        final isHealthConnectAvailable = healthService.healthConnectAvailable;
        final isInitialized = healthService.isInitialized;
        
        String errorMessage;
        if (isHealthConnectAvailable && isInitialized) {
          // HealthConnect is connected but no data available
          errorMessage = 'HealthConnect is connected but no recent health data found.\n\n'
                        'This could mean:\n'
                        '• Your fitness tracker hasn\'t synced recently\n'
                        '• No health data was recorded in the last 30 days\n'
                        '• Your device doesn\'t support the requested health metrics\n\n'
                        'Try syncing your fitness tracker or recording some health data.';
        } else {
          // HealthConnect is not properly connected
          errorMessage = healthService.getUserFriendlyErrorMessage();
          if (errorMessage.isEmpty) {
            errorMessage = 'Please connect to HealthConnect and grant all health permissions.';
          }
        }
        
        setState(() {
          _healthDataAvailable = false;
          _healthDataError = errorMessage;
          _isLoadingHealthData = false;
        });
        return;
      }
      
      if (!hasMeaningfulData) {
        // We have some data but it's all zeros - show a different message
        setState(() {
          _healthDataAvailable = false;
          _healthDataError = 'HealthConnect is connected but only zero values found.\n\n'
                            'This could mean:\n'
                            '• Your fitness tracker hasn\'t recorded any activity today\n'
                            '• Health data is being recorded but shows zero values\n'
                            '• Try recording some health data manually\n\n'
                            'The app will search for the latest non-zero data from the past 30 days.';
          _isLoadingHealthData = false;
        });
        return;
      }
      
      setState(() {
        _heartRate = healthData['heartRate'];
        _oxygenSaturation = healthData['oxygenSaturation'];
        _calories = healthData['calories'];
        _sleepHours = healthData['sleepHours'];
        _steps = healthData['steps'];
        _distance = healthData['distance'];
        
        // Update timestamps for real-time display
        _heartRateTime = healthData['heartRateTime'];
        _oxygenTime = healthData['oxygenTime'];
        _caloriesTime = healthData['caloriesTime'];
        _sleepTime = healthData['sleepTime'];
        
        _healthDataAvailable = true;
        _healthDataError = '';
        _isLoadingHealthData = false;
      });
    } catch (e) {
      setState(() {
        _healthDataAvailable = false;
        _healthDataError = 'Error loading health data: $e';
        _isLoadingHealthData = false;
      });
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  Color _getAIStatusColor() {
    if (!_healthDataAvailable) return Colors.grey;
    
    // Simple health status based on available data
    if (_heartRate != null && _oxygenSaturation != null) {
      if (_heartRate! >= 60 && _heartRate! <= 100 && 
          _oxygenSaturation! >= 95) {
        return Colors.green;
      } else if (_heartRate! < 60 || _heartRate! > 100 || 
                 _oxygenSaturation! < 95) {
        return Colors.orange;
      }
    }
    
    return Colors.blue;
  }

  IconData _getAIStatusIcon() {
    if (!_healthDataAvailable) return Icons.help_outline;
    
    if (_heartRate != null && _oxygenSaturation != null) {
      if (_heartRate! >= 60 && _heartRate! <= 100 && 
          _oxygenSaturation! >= 95) {
        return Icons.check_circle;
      } else if (_heartRate! < 60 || _heartRate! > 100 || 
                 _oxygenSaturation! < 95) {
        return Icons.warning;
      }
    }
    
    return Icons.analytics;
  }

  String _getAIStatusText() {
    if (!_healthDataAvailable) return 'No Data';
    
    if (_heartRate != null && _oxygenSaturation != null) {
      if (_heartRate! >= 60 && _heartRate! <= 100 && 
          _oxygenSaturation! >= 95) {
        return 'Normal';
      } else if (_heartRate! < 60 || _heartRate! > 100 || 
                 _oxygenSaturation! < 95) {
        return 'Check Values';
      }
    }
    
    return 'Analyzing';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.patient.name,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: HexColor(mainColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadHealthData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heart Beats Card (Full Width)
                  _buildHeartBeatsCard(),
                  const SizedBox(height: 20),
                  
                  // Two Column Grid for other cards
                  _buildCardsGrid(),
                  
                  const SizedBox(height: 100), // Bottom padding for navigation
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeartBeatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                child: Icon(
                  Icons.favorite,
                  color: _heartRateTime != null 
                    ? Colors.red.shade400 
                    : Colors.grey.shade400,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Heart Beats',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              // Real-time status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _heartRateTime != null 
                    ? Colors.green.shade100 
                    : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _heartRateTime != null 
                      ? Colors.green.shade300 
                      : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _heartRateTime != null 
                          ? Colors.green.shade500 
                          : Colors.grey.shade500,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _heartRateTime != null ? 'Live' : 'Offline',
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: _heartRateTime != null 
                          ? Colors.green.shade700 
                          : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: _isLoadingHealthData 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
                      ),
                    )
                  : Icon(
                      Icons.refresh,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                onPressed: _isLoadingHealthData ? null : () {
                  _loadHealthData();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 500),
                      style: GoogleFonts.montserrat(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _healthDataAvailable && _heartRate != null
                          ? Colors.red.shade400
                          : Colors.grey.shade400,
                      ),
                      child: Text(
                        _isLoadingHealthData
                          ? '...' 
                          : (_healthDataAvailable && _heartRate != null
                              ? _heartRate.toString()
                              : '--'),
                      ),
                    ),
                    Text(
                      'bpm',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Real-time timestamp with enhanced styling
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _heartRateTime != null 
                          ? Colors.blue.shade50 
                          : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _heartRateTime != null 
                            ? Colors.blue.shade200 
                            : Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _heartRateTime != null 
                              ? Icons.schedule 
                              : (_isLoadingHealthData ? Icons.hourglass_empty : Icons.warning_amber),
                            size: 12,
                            color: _heartRateTime != null 
                              ? Colors.blue.shade600 
                              : (_isLoadingHealthData ? Colors.orange.shade600 : Colors.grey.shade600),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _heartRateTime != null
                              ? 'Updated ${_formatTimeAgo(_heartRateTime!)}'
                              : (_isLoadingHealthData ? 'Loading data...' : 'No recent data'),
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _heartRateTime != null 
                                ? Colors.blue.shade700 
                                : (_isLoadingHealthData ? Colors.orange.shade700 : Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 80,
                width: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 10,
                    minY: 0,
                    maxY: 6,
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 3),
                          FlSpot(1, 3.5),
                          FlSpot(2, 2.8),
                          FlSpot(3, 4.2),
                          FlSpot(4, 3.1),
                          FlSpot(5, 3.8),
                          FlSpot(6, 2.9),
                          FlSpot(7, 4.1),
                          FlSpot(8, 3.3),
                          FlSpot(9, 3.7),
                          FlSpot(10, 3.2),
                        ],
                        color: Colors.red.shade400,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.red.shade400.withOpacity(0.3),
                              Colors.red.shade400.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardsGrid() {
    return Column(
      children: [
        // First Row: Oxygen and Calories
        Row(
          children: [
            Expanded(child: _buildOxygenCard()),
            const SizedBox(width: 16),
            Expanded(child: _buildCaloriesCard()),
          ],
        ),
        const SizedBox(height: 16),
        // Second Row: Sleep and AI Prediction
        Row(
          children: [
            Expanded(child: _buildSleepCard()),
            const SizedBox(width: 16),
            Expanded(child: _buildAIPredictionCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildOxygenCard() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.air,
                color: Colors.blue.shade400,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Oxygen Saturation',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 100,
            width: 100,
            child: CircularPercentIndicator(
              radius: 50,
              lineWidth: 8,
              animation: true,
              percent: _healthDataAvailable && _oxygenSaturation != null 
                ? (_oxygenSaturation! / 100.0).clamp(0.0, 1.0) 
                : 0.0,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLoadingHealthData
                      ? '...' 
                      : (_healthDataAvailable && _oxygenSaturation != null
                          ? '${_oxygenSaturation}%'
                          : '--'),
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _healthDataAvailable && _oxygenSaturation != null
                        ? Colors.blue.shade400 
                        : Colors.grey.shade400,
                    ),
                  ),
                  Text(
                    'SpO2',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.grey.shade100,
              progressColor: Colors.blue.shade400,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ),
          // Real-time timestamp
          if (_oxygenTime != null)
            Text(
              _formatTimeAgo(_oxygenTime!),
              style: GoogleFonts.montserrat(
                fontSize: 9,
                color: Colors.grey.shade500,
              ),
            )
          else if (_isLoadingHealthData)
            Text(
              'Loading...',
              style: GoogleFonts.montserrat(
                fontSize: 9,
                color: Colors.grey.shade500,
              ),
            )
          else
            Text(
              'No recent data',
              style: GoogleFonts.montserrat(
                fontSize: 9,
                color: Colors.grey.shade500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCaloriesCard() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: Colors.orange.shade400,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Calories',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 100,
            width: 100,
            child: CircularPercentIndicator(
              radius: 50,
              lineWidth: 8,
              animation: true,
              percent: _healthDataAvailable && _calories != null 
                ? (_calories! / 500.0).clamp(0.0, 1.0) 
                : 0.0,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLoadingHealthData
                      ? '...' 
                      : (_healthDataAvailable && _calories != null
                          ? _calories.toString()
                          : '--'),
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _healthDataAvailable && _calories != null
                        ? Colors.orange.shade400 
                        : Colors.grey.shade400,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.grey.shade100,
              progressColor: Colors.orange.shade400,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ),
          // Real-time timestamp
          if (_caloriesTime != null)
            Text(
              _formatTimeAgo(_caloriesTime!),
              style: GoogleFonts.montserrat(
                fontSize: 9,
                color: Colors.grey.shade500,
              ),
            )
          else if (_isLoadingHealthData)
            Text(
              'Loading...',
              style: GoogleFonts.montserrat(
                fontSize: 9,
                color: Colors.grey.shade500,
              ),
            )
          else
            Text(
              'No recent data',
              style: GoogleFonts.montserrat(
                fontSize: 9,
                color: Colors.grey.shade500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSleepCard() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.nightlight_round,
                color: Colors.purple.shade400,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sleep',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 100,
            width: 100,
            child: CircularPercentIndicator(
              radius: 50,
              lineWidth: 8,
              animation: true,
              percent: _healthDataAvailable && _sleepHours != null 
                ? (_sleepHours! / 10.0).clamp(0.0, 1.0) 
                : 0.0,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLoadingHealthData
                      ? '...' 
                      : (_healthDataAvailable && _sleepHours != null
                          ? _sleepHours.toString()
                          : '--'),
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _healthDataAvailable && _sleepHours != null
                        ? Colors.purple.shade400 
                        : Colors.grey.shade400,
                    ),
                  ),
                  Text(
                    'hours',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.grey.shade100,
              progressColor: Colors.purple.shade400,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ),
          // Real-time timestamp
          if (_sleepTime != null)
            Text(
              _formatTimeAgo(_sleepTime!),
              style: GoogleFonts.montserrat(
                fontSize: 9,
                color: Colors.grey.shade500,
              ),
            )
          else if (_isLoadingHealthData)
            Text(
              'Loading...',
              style: GoogleFonts.montserrat(
                fontSize: 9,
                color: Colors.grey.shade500,
              ),
            )
          else
            Text(
              'No recent data',
              style: GoogleFonts.montserrat(
                fontSize: 9,
                color: Colors.grey.shade500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAIPredictionCard() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: Colors.green.shade400,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'AI Prediction',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 100,
            width: 100,
            child: Container(
              decoration: BoxDecoration(
                color: _getAIStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getAIStatusColor().withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getAIStatusIcon(),
                        color: _getAIStatusColor(),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getAIStatusText(),
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getAIStatusColor(),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Real-time timestamp
          Text(
            _isLoadingHealthData ? 'Analyzing...' : 'Updated ${_formatTimeAgo(DateTime.now())}',
            style: GoogleFonts.montserrat(
              fontSize: 9,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
