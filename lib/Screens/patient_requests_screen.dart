import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../Utils/main_variables.dart';
import 'patient_detail_screen.dart';

class PatientRequestsScreen extends StatefulWidget {
  const PatientRequestsScreen({super.key});

  @override
  State<PatientRequestsScreen> createState() => _PatientRequestsScreenState();
}

class _PatientRequestsScreenState extends State<PatientRequestsScreen> {
  bool _isLoading = false;
  List<PatientRequest> _patientRequests = [];

  @override
  void initState() {
    super.initState();
    _loadPatientRequests();
  }

  void _loadPatientRequests() {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate loading delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _patientRequests = _getSampleData();
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Stack(
          children: [
            Center(
              child: Text(
                'Patient Requests',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: IconButton(
                onPressed: _loadPatientRequests,
                icon: const Icon(Icons.refresh, color: Colors.grey, size: 20),
                tooltip: 'Refresh',
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header Info Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: HexColor(mainColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_add,
                    color: HexColor(mainColor),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_patientRequests.length} Pending Requests',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Review and approve patient profile requests',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Patient Requests List
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _patientRequests.isEmpty
                    ? _buildEmptyState()
                    : _buildPatientRequestsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(HexColor(mainColor)),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading requests...',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_add_disabled,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Pending Requests',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any pending patient\nprofile requests at the moment.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadPatientRequests,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor(mainColor),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientRequestsList() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadPatientRequests();
      },
      color: HexColor(mainColor),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _patientRequests.length,
        itemBuilder: (context, index) {
          final request = _patientRequests[index];
          return _buildPatientRequestCard(context, request);
        },
      ),
    );
  }

  Widget _buildPatientRequestCard(BuildContext context, PatientRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with profile and basic info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 32,
                  backgroundImage: request.profileImage != null
                      ? AssetImage(request.profileImage!)
                      : null,
                  child: request.profileImage == null
                      ? Icon(Icons.person, size: 32, color: Colors.grey.shade400)
                      : null,
                ),
                const SizedBox(width: 16),
                // Patient Info
                Expanded(
                  child: Text(
                    request.name,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                // More options
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'view_profile') {
                      _viewPatientProfile(context, request);
                    } else if (value == 'message') {
                      _messagePatient(context, request);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'view_profile',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 18, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text('View Profile', style: GoogleFonts.montserrat()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'message',
                      child: Row(
                        children: [
                          Icon(Icons.message, size: 18, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text('Message', style: GoogleFonts.montserrat()),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.more_vert, color: Colors.grey.shade600, size: 20),
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Container(
            height: 1,
            color: Colors.grey.shade100,
          ),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showConfirmDialog(context, request),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HexColor(mainColor),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteDialog(context, request),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, PatientRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Accept Request',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to accept ${request.name} as a patient?',
              style: GoogleFonts.montserrat(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will allow them to access your medical services and view their health records.',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _acceptPatientRequest(request);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Accept',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, PatientRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.cancel, color: Colors.red.shade600, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Decline Request',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to decline the request from ${request.name}?',
              style: GoogleFonts.montserrat(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. The patient will be notified of your decision.',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _declinePatientRequest(request);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Decline',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _acceptPatientRequest(PatientRequest request) {
    setState(() {
      _patientRequests.remove(request);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('${request.name} has been accepted as a patient'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _declinePatientRequest(PatientRequest request) {
    setState(() {
      _patientRequests.remove(request);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.cancel, color: Colors.white),
            const SizedBox(width: 8),
            Text('Request from ${request.name} has been declined'),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _viewPatientProfile(BuildContext context, PatientRequest request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(patient: request),
      ),
    );
  }

  void _messagePatient(BuildContext context, PatientRequest request) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Messaging feature coming soon!'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSentRequests() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sent requests feature coming soon!'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  List<PatientRequest> _getSampleData() {
    return [
      PatientRequest(
        name: 'Zyad Aboelmakarem',
        mutualFriends: 43,
        timeAgo: '11h',
        profileImage: 'assets/person.png',
      ),
      PatientRequest(
        name: 'Ziad Saba',
        mutualFriends: 96,
        timeAgo: '9w',
        profileImage: 'assets/person.png',
      ),
      PatientRequest(
        name: 'Sarah Johnson',
        mutualFriends: 2,
        timeAgo: '23w',
        profileImage: 'assets/person.png',
      ),
      PatientRequest(
        name: 'Mohab Abdullrahman',
        mutualFriends: 85,
        timeAgo: '7w',
        profileImage: null,
      ),
      PatientRequest(
        name: 'Mostafa Abdallah',
        mutualFriends: 75,
        timeAgo: '19w',
        profileImage: 'assets/person.png',
      ),
    ];
  }
}

class PatientRequest {
  final String name;
  final int mutualFriends;
  final String timeAgo;
  final String? profileImage;

  PatientRequest({
    required this.name,
    required this.mutualFriends,
    required this.timeAgo,
    this.profileImage,
  });
}
