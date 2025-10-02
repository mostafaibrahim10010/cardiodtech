import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../Utils/main_variables.dart';
import 'patient_detail_screen.dart';
import 'settings.dart';

class AcceptedPatientsScreen extends StatelessWidget {
  const AcceptedPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor(mainColor),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CardioDTech',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search about patient',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[500],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              // Spacing between search bar and patient list
              const SizedBox(height: 24),
              // Patients List
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: _acceptedPatients.length,
                  itemBuilder: (context, index) {
                    final patient = _acceptedPatients[index];
                    return _buildPatientCard(context, patient);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, AcceptedPatient patient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white,
          backgroundImage: patient.profileImage != null
              ? AssetImage(patient.profileImage!)
              : null,
          child: patient.profileImage == null
              ? Icon(Icons.person, size: 25, color: Colors.grey.shade400)
              : null,
        ),
        title: Text(
          patient.name,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetailScreen(patient: patient),
            ),
          );
        },
      ),
    );
  }
}

enum MessageType { text, voice, photo }

class AcceptedPatient {
  final String name;
  final String lastMessage;
  final String lastMessageDate;
  final MessageType lastMessageType;
  final String? profileImage;

  AcceptedPatient({
    required this.name,
    required this.lastMessage,
    required this.lastMessageDate,
    required this.lastMessageType,
    this.profileImage,
  });
}

// Sample data - replace with actual data from your backend
final List<AcceptedPatient> _acceptedPatients = [
  AcceptedPatient(
    name: 'Andrew Parker',
    lastMessage: 'What kind of strategy is better?',
    lastMessageDate: '11/16/19',
    lastMessageType: MessageType.text,
    profileImage: 'assets/person.png',
  ),
  AcceptedPatient(
    name: 'Karen Castillo',
    lastMessage: '0:14',
    lastMessageDate: '11/15/19',
    lastMessageType: MessageType.voice,
    profileImage: 'assets/person.png',
  ),
  AcceptedPatient(
    name: 'Maximillian Jacobson',
    lastMessage: 'Bro, I have a good idea!',
    lastMessageDate: '10/30/19',
    lastMessageType: MessageType.text,
    profileImage: 'assets/person.png',
  ),
  AcceptedPatient(
    name: 'Martha Craig',
    lastMessage: 'Photo',
    lastMessageDate: '10/28/19',
    lastMessageType: MessageType.photo,
    profileImage: 'assets/person.png',
  ),
  AcceptedPatient(
    name: 'Tabitha Potter',
    lastMessage: 'Actually I wanted to check with you',
    lastMessageDate: '8/25/19',
    lastMessageType: MessageType.text,
    profileImage: 'assets/person.png',
  ),
  AcceptedPatient(
    name: 'Sarah Johnson',
    lastMessage: 'How are you feeling today?',
    lastMessageDate: '8/20/19',
    lastMessageType: MessageType.text,
    profileImage: 'assets/person.png',
  ),
  AcceptedPatient(
    name: 'Michael Chen',
    lastMessage: '2:30',
    lastMessageDate: '8/18/19',
    lastMessageType: MessageType.voice,
    profileImage: 'assets/person.png',
  ),
  AcceptedPatient(
    name: 'Emily Rodriguez',
    lastMessage: 'Thanks for the update',
    lastMessageDate: '8/15/19',
    lastMessageType: MessageType.text,
    profileImage: 'assets/person.png',
  ),
  AcceptedPatient(
    name: 'David Thompson',
    lastMessage: 'Image',
    lastMessageDate: '8/12/19',
    lastMessageType: MessageType.photo,
    profileImage: 'assets/person.png',
  ),
  AcceptedPatient(
    name: 'Lisa Anderson',
    lastMessage: 'Can we schedule a follow-up?',
    lastMessageDate: '8/10/19',
    lastMessageType: MessageType.text,
    profileImage: 'assets/person.png',
  ),
  AcceptedPatient(
    name: 'Robert Wilson',
    lastMessage: '1:45',
    lastMessageDate: '8/8/19',
    lastMessageType: MessageType.voice,
    profileImage: 'assets/person.png',
  ),
  AcceptedPatient(
    name: 'Jennifer Brown',
    lastMessage: 'The results look good',
    lastMessageDate: '8/5/19',
    lastMessageType: MessageType.text,
    profileImage: 'assets/person.png',
  ),
  AcceptedPatient(
    name: 'Christopher Davis',
    lastMessage: 'Document',
    lastMessageDate: '8/3/19',
    lastMessageType: MessageType.photo,
    profileImage: 'assets/person.png',
  ),
  AcceptedPatient(
    name: 'Amanda Garcia',
    lastMessage: 'I have some questions',
    lastMessageDate: '8/1/19',
    lastMessageType: MessageType.text,
    profileImage: 'assets/person.png',
  ),
  AcceptedPatient(
    name: 'James Martinez',
    lastMessage: '3:20',
    lastMessageDate: '7/28/19',
    lastMessageType: MessageType.voice,
    profileImage: 'assets/person.png',
  ),
  AcceptedPatient(
    name: 'Michelle Lee',
    lastMessage: 'Appointment confirmed',
    lastMessageDate: '7/25/19',
    lastMessageType: MessageType.text,
    profileImage: 'assets/person.png',
  ),
  AcceptedPatient(
    name: 'Daniel Taylor',
    lastMessage: 'Chart',
    lastMessageDate: '7/22/19',
    lastMessageType: MessageType.photo,
    profileImage: 'assets/person.png',
  ),
  AcceptedPatient(
    name: 'Ashley White',
    lastMessage: 'Thank you for your help',
    lastMessageDate: '7/20/19',
    lastMessageType: MessageType.text,
    profileImage: 'assets/person.png',
  ),
  AcceptedPatient(
    name: 'Kevin Harris',
    lastMessage: '0:55',
    lastMessageDate: '7/18/19',
    lastMessageType: MessageType.voice,
    profileImage: 'assets/person.png',
  ),
  AcceptedPatient(
    name: 'Nicole Clark',
    lastMessage: 'See you next week',
    lastMessageDate: '7/15/19',
    lastMessageType: MessageType.text,
    profileImage: 'assets/person.png',
  ),
];
