import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Biodata',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D12),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9C7BFF),
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF17171F),
          labelStyle: const TextStyle(
            color: Color(0xFFBDBDBD),
          ),
          floatingLabelStyle: const TextStyle(
            color: Color(0xFFB99CFF),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF30303A),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF30303A),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF9C7BFF),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.redAccent,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 2,
            ),
          ),
        ),
      ),
      home: const BiodataPage(),
    );
  }
}

class BiodataPage extends StatefulWidget {
  const BiodataPage({super.key});

  @override
  State<BiodataPage> createState() => _BiodataPageState();
}

class _BiodataPageState extends State<BiodataPage> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final ageController = TextEditingController();
  final birthdayController = TextEditingController();
  final addressController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();

  final schoolController = TextEditingController();
  final courseController = TextEditingController();

  final skillsController = TextEditingController();
  final hobbiesController = TextEditingController();

  bool isSaving = false;

  // false = show normal biodata
  // true = show hidden biodata
  bool showHidden = false;

  // ==============================
  // SAVE BIODATA
  // ==============================

  Future<void> saveBiodata() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('biodata').add({
        'fullName': fullNameController.text.trim(),
        'age': ageController.text.trim(),
        'birthday': birthdayController.text.trim(),
        'address': addressController.text.trim(),
        'contact': contactController.text.trim(),
        'email': emailController.text.trim(),
        'school': schoolController.text.trim(),
        'course': courseController.text.trim(),
        'skills': skillsController.text.trim(),
        'hobbies': hobbiesController.text.trim(),

        // New biodata is visible by default
        'isHidden': false,

        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biodata saved successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      clearForm();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving biodata: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ==============================
  // CLEAR FORM
  // ==============================

  void clearForm() {
    fullNameController.clear();
    ageController.clear();
    birthdayController.clear();
    addressController.clear();
    contactController.clear();
    emailController.clear();

    schoolController.clear();
    courseController.clear();

    skillsController.clear();
    hobbiesController.clear();

    _formKey.currentState?.reset();

    setState(() {});
  }

  // ==============================
  // HIDE / SHOW BIODATA
  // ==============================

  Future<void> toggleBiodataVisibility(
    String documentId,
    bool currentlyHidden,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('biodata')
          .doc(documentId)
          .update({
        'isHidden': !currentlyHidden,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentlyHidden
                ? 'Biodata is now visible.'
                : 'Biodata is now hidden.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error updating biodata: $e',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==============================
  // VALIDATION
  // ==============================

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    if (!value.contains('@')) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // ==============================
  // TEXT FIELD
  // ==============================

  Widget buildTextField({
    required String label,
    required String accessibilityLabel,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final actualKeyboardType =
        maxLines > 1 ? TextInputType.multiline : keyboardType;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Semantics(
        textField: true,
        label: accessibilityLabel,
        child: TextFormField(
          controller: controller,
          keyboardType: actualKeyboardType,
          maxLines: maxLines,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          cursorColor: const Color(0xFF9C7BFF),
          validator: validator,
          onFieldSubmitted: maxLines == 1
              ? (_) {
                  FocusScope.of(context).nextFocus();
                }
              : null,
          decoration: InputDecoration(
            labelText: label,
          ),
        ),
      ),
    );
  }

  // ==============================
  // SECTION
  // ==============================

  Widget buildSection({
    required String title,
    required Widget child,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF121218),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF292933),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: accentColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  // ==============================
  // BIODATA CARD
  // ==============================

  Widget buildBiodataCard(
    String documentId,
    Map<String, dynamic> data,
  ) {
    final bool isHidden = data['isHidden'] ?? false;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF121218),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHidden
              ? const Color(0xFF555563)
              : const Color(0xFF393343),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NAME
          Text(
            data['fullName'] ?? 'No Name',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (isHidden) ...[
            const SizedBox(height: 6),
            const Text(
              'This biodata is hidden.',
              style: TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 13,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // PERSONAL INFORMATION
          buildDataRow('Age', data['age']),
          buildDataRow('Birthday', data['birthday']),
          buildDataRow('Address', data['address']),
          buildDataRow('Contact Number', data['contact']),
          buildDataRow('Email', data['email']),

          const SizedBox(height: 15),

          const Divider(
            color: Color(0xFF30303A),
          ),

          const SizedBox(height: 15),

          // EDUCATION
          const Text(
            'Education',
            style: TextStyle(
              color: Color(0xFF7DD3FC),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          buildDataRow('School', data['school']),
          buildDataRow('Course', data['course']),

          const SizedBox(height: 15),

          const Divider(
            color: Color(0xFF30303A),
          ),

          const SizedBox(height: 15),

          // OTHER INFORMATION
          const Text(
            'Other Information',
            style: TextStyle(
              color: Color(0xFF86E3C4),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          buildDataRow('Skills', data['skills']),
          buildDataRow('Hobbies', data['hobbies']),

          const SizedBox(height: 20),

          // HIDE / SHOW BUTTON
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {
                toggleBiodataVisibility(
                  documentId,
                  isHidden,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB99CFF),
                side: const BorderSide(
                  color: Color(0xFF555563),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                isHidden ? 'SHOW' : 'HIDE',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================
  // DATA ROW
  // ==============================

  Widget buildDataRow(
    String label,
    dynamic value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF888894),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value?.toString() ?? 'Not provided',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================
  // SAVED BIODATA
  // ==============================

  Widget buildSavedBiodata() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('biodata')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // ERROR
        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF121218),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Error loading biodata:\n${snapshot.error}',
              style: const TextStyle(
                color: Colors.redAccent,
              ),
            ),
          );
        }

        // LOADING
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(30),
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9C7BFF),
              ),
            ),
          );
        }

        final allDocuments =
            snapshot.data?.docs ?? [];

        // FILTER HIDDEN / VISIBLE
        final documents = allDocuments.where((document) {
          final data =
              document.data() as Map<String, dynamic>;

          // Old records without isHidden
          // will be treated as visible.
          final bool isHidden =
              data['isHidden'] ?? false;

          if (showHidden) {
            return isHidden;
          } else {
            return !isHidden;
          }
        }).toList();

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            // TITLE + SHOW/HIDE HIDDEN BUTTON
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    showHidden
                        ? 'Hidden Biodata'
                        : 'Saved Biodata',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      showHidden = !showHidden;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        const Color(0xFFB99CFF),
                    side: const BorderSide(
                      color: Color(0xFF555563),
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    showHidden
                        ? 'HIDE HIDDEN'
                        : 'SHOW HIDDEN',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // NO BIODATA
            if (documents.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: const Color(0xFF121218),
                  borderRadius:
                      BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF292933),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      showHidden
                          ? 'No hidden biodata.'
                          : 'No biodata saved yet.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      showHidden
                          ? 'Hidden biodata will appear here.'
                          : 'Fill out the form above and press SAVE BIODATA.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF888894),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            // BIODATA LIST
            ...documents.map(
              (document) {
                final data =
                    document.data()
                        as Map<String, dynamic>;

                return buildBiodataCard(
                  document.id,
                  data,
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ==============================
  // DISPOSE
  // ==============================

  @override
  void dispose() {
    fullNameController.dispose();
    ageController.dispose();
    birthdayController.dispose();
    addressController.dispose();
    contactController.dispose();
    emailController.dispose();

    schoolController.dispose();
    courseController.dispose();

    skillsController.dispose();
    hobbiesController.dispose();

    super.dispose();
  }

  // ==============================
  // BUILD
  // ==============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 40,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 650,
                ),
                child: FocusTraversalGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        // ==========================
                        // TITLE
                        // ==========================

                        const Center(
                          child: Text(
                            'PERSONAL BIODATA',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Center(
                          child: Text(
                            'Personal Information Form',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 15,
                            ),
                          ),
                        ),

                        const SizedBox(height: 35),

                        // ==========================
                        // PERSONAL INFORMATION
                        // ==========================

                        buildSection(
                          title:
                              'Personal Information',
                          accentColor:
                              const Color(0xFFB99CFF),
                          child: Column(
                            children: [
                              buildTextField(
                                label: 'Full Name',
                                accessibilityLabel:
                                    'Enter your full name',
                                controller:
                                    fullNameController,
                                validator:
                                    requiredValidator,
                              ),

                              buildTextField(
                                label: 'Age',
                                accessibilityLabel:
                                    'Enter your age',
                                controller:
                                    ageController,
                                keyboardType:
                                    TextInputType.number,
                                validator:
                                    requiredValidator,
                              ),

                              buildTextField(
                                label: 'Birthday',
                                accessibilityLabel:
                                    'Enter your birthday',
                                controller:
                                    birthdayController,
                                keyboardType:
                                    TextInputType.datetime,
                                validator:
                                    requiredValidator,
                              ),

                              buildTextField(
                                label: 'Address',
                                accessibilityLabel:
                                    'Enter your complete address',
                                controller:
                                    addressController,
                                maxLines: 3,
                                validator:
                                    requiredValidator,
                              ),

                              buildTextField(
                                label:
                                    'Contact Number',
                                accessibilityLabel:
                                    'Enter your contact number',
                                controller:
                                    contactController,
                                keyboardType:
                                    TextInputType.phone,
                                validator:
                                    requiredValidator,
                              ),

                              buildTextField(
                                label:
                                    'Email Address',
                                accessibilityLabel:
                                    'Enter your email address',
                                controller:
                                    emailController,
                                keyboardType:
                                    TextInputType.emailAddress,
                                validator:
                                    emailValidator,
                              ),
                            ],
                          ),
                        ),

                        // ==========================
                        // EDUCATIONAL BACKGROUND
                        // ==========================

                        buildSection(
                          title:
                              'Educational Background',
                          accentColor:
                              const Color(0xFF7DD3FC),
                          child: Column(
                            children: [
                              buildTextField(
                                label: 'School',
                                accessibilityLabel:
                                    'Enter your school',
                                controller:
                                    schoolController,
                                validator:
                                    requiredValidator,
                              ),

                              buildTextField(
                                label: 'Course',
                                accessibilityLabel:
                                    'Enter your course',
                                controller:
                                    courseController,
                                validator:
                                    requiredValidator,
                              ),
                            ],
                          ),
                        ),

                        // ==========================
                        // OTHER INFORMATION
                        // ==========================

                        buildSection(
                          title:
                              'Other Information',
                          accentColor:
                              const Color(0xFF86E3C4),
                          child: Column(
                            children: [
                              buildTextField(
                                label: 'Skills',
                                accessibilityLabel:
                                    'Enter your skills',
                                controller:
                                    skillsController,
                                maxLines: 3,
                                validator:
                                    requiredValidator,
                              ),

                              buildTextField(
                                label: 'Hobbies',
                                accessibilityLabel:
                                    'Enter your hobbies',
                                controller:
                                    hobbiesController,
                                maxLines: 3,
                                validator:
                                    requiredValidator,
                              ),
                            ],
                          ),
                        ),

                        // ==========================
                        // BUTTONS
                        // ==========================

                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child:
                                    ElevatedButton(
                                  onPressed: isSaving
                                      ? null
                                      : saveBiodata,
                                  style:
                                      ElevatedButton
                                          .styleFrom(
                                    backgroundColor:
                                        const Color(
                                            0xFF9C7BFF),
                                    foregroundColor:
                                        Colors.white,
                                    disabledBackgroundColor:
                                        const Color(
                                            0xFF494354),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        12,
                                      ),
                                    ),
                                  ),
                                  child: isSaving
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth:
                                                2,
                                            color:
                                                Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'SAVE BIODATA',
                                          style:
                                              TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child:
                                    OutlinedButton(
                                  onPressed: isSaving
                                      ? null
                                      : clearForm,
                                  style:
                                      OutlinedButton
                                          .styleFrom(
                                    foregroundColor:
                                        Colors.white,
                                    side:
                                        const BorderSide(
                                      color:
                                          Color(
                                              0xFF555563),
                                    ),
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        12,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'CLEAR',
                                    style:
                                        TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // ==========================
                        // SAVED BIODATA
                        // ==========================

                        buildSavedBiodata(),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}