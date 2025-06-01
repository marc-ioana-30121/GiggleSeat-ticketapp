// // lib/screens/add_show_screen.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/show_model.dart';
// import '../services/show_service.dart';
// import '../widgets/custom_text_field.dart';

// class AddShowScreen extends StatefulWidget {
//   @override
//   _AddShowScreenState createState() => _AddShowScreenState();
// }

// class _AddShowScreenState extends State<AddShowScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final ShowService _showService = ShowService();
  
//   String _title = '';
//   DateTime _date = DateTime.now().add(Duration(days: 7));
//   String _venue = '';
//   int _ticketLimit = 100;
//   String _imageUrl = '';
//   bool _loading = false;
//   String _errorMessage = '';

//   final TextEditingController _dateController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _dateController.text = DateFormat('yyyy-MM-dd').format(_date);
//   }

//   @override
//   void dispose() {
//     _dateController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _date,
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(Duration(days: 365)),
//     );
//     if (picked != null && picked != _date) {
//       setState(() {
//         _date = picked;
//         _dateController.text = DateFormat('yyyy-MM-dd').format(_date);
//       });
//     }
//   }

//   void _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;
    
//     _formKey.currentState!.save();
//     setState(() {
//       _loading = true;
//       _errorMessage = '';
//     });

//     try {
//       // Create show object
//       final show = Show(
//         id: '', // Will be assigned by Firestore
//         title: _title,
//         date: _date,
//         venue: _venue,
//         ticketLimit: _ticketLimit,
//         imageUrl: _imageUrl,
//       );

//       // Save to Firestore
//       await _showService.addShow(show);
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Show added successfully!')),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//       });
//     } finally {
//       if (mounted) {
//         setState(() => _loading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add New Show'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 CustomTextField(
//                   labelText: 'Show Title',
//                   validator: (val) {
//                     if (val == null || val.isEmpty) {
//                       return 'Please enter a title';
//                     }
//                     return null;
//                   },
//                   onSaved: (val) => _title = val?.trim() ?? '',
//                 ),
                
//                 // Date Picker Field
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 16.0),
//                   child: TextFormField(
//                     controller: _dateController,
//                     decoration: InputDecoration(
//                       labelText: 'Show Date',
//                       border: OutlineInputBorder(),
//                       suffixIcon: IconButton(
//                         icon: Icon(Icons.calendar_today),
//                         onPressed: () => _selectDate(context),
//                       ),
//                     ),
//                     readOnly: true,
//                     onTap: () => _selectDate(context),
//                   ),
//                 ),
                
//                 CustomTextField(
//                   labelText: 'Venue',
//                   validator: (val) {
//                     if (val == null || val.isEmpty) {
//                       return 'Please enter a venue';
//                     }
//                     return null;
//                   },
//                   onSaved: (val) => _venue = val?.trim() ?? '',
//                 ),
                
//                 CustomTextField(
//                   labelText: 'Ticket Limit',
//                   keyboardType: TextInputType.number,
//                   validator: (val) {
//                     if (val == null || val.isEmpty) {
//                       return 'Please enter a ticket limit';
//                     }
//                     if (int.tryParse(val) == null) {
//                       return 'Please enter a valid number';
//                     }
//                     if (int.parse(val) <= 0) {
//                       return 'Ticket limit must be greater than 0';
//                     }
//                     return null;
//                   },
//                   onSaved: (val) => _ticketLimit = int.parse(val!),
//                 ),
                
//                 CustomTextField(
//                   labelText: 'Image URL (Optional)',
//                   onSaved: (val) => _imageUrl = val?.trim() ?? '',
//                 ),
                
//                 SizedBox(height: 16),
                
//                 if (_errorMessage.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 16.0),
//                     child: Text(
//                       _errorMessage,
//                       style: TextStyle(color: Colors.red),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
                
//                 _loading
//                     ? Center(child: CircularProgressIndicator())
//                     : ElevatedButton(
//                         onPressed: _submitForm,
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 12.0),
//                           child: Text('Add Show'),
//                         ),
//                       ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


// lib/screens/add_show_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/show_model.dart';
import '../services/show_service.dart';
import '../widgets/custom_text_field.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddShowScreen extends StatefulWidget {
  @override
  _AddShowScreenState createState() => _AddShowScreenState();
}

class _AddShowScreenState extends State<AddShowScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ShowService _showService = ShowService();
  
  String _title = '';
  DateTime _date = DateTime.now().add(Duration(days: 7));
  TimeOfDay _time = TimeOfDay(hour: 19, minute: 30); // Default to 7:30 PM
  String _venue = '';
  int _ticketLimit = 100;
  
  bool _loading = false;
  String _errorMessage = '';

  File? _imageFile;
  bool _uploading = false;
  final ImagePicker _picker = ImagePicker();
  String _imageUrl = '';

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
 
  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('EEEE, MMMM d, yyyy').format(_date);
    // Remove the time formatting from here - it needs context
    
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Move the time formatting here where context is available
    _timeController.text = _time.format(context);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _animationController.dispose();
    super.dispose();
  }
 Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToStorage() async {
    if (_imageFile == null) return null;
    
    setState(() {
      _uploading = true;
    });
    
    try {
      // Create a unique file name
      final fileName = 'show_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child('show_images/$fileName');
      
      // Upload file
      await storageRef.putFile(_imageFile!);
      
      // Get download URL
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    } finally {
      setState(() {
        _uploading = false;
      });
    }}

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _date) {
      setState(() {
        _date = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _time.hour,
          _time.minute,
        );
        _dateController.text = DateFormat('EEEE, MMMM d, yyyy').format(_date);
      });
    }
  }
  

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
        _date = DateTime(
          _date.year,
          _date.month,
          _date.day,
          _time.hour,
          _time.minute,
        );
        _timeController.text = _time.format(context);
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    try {
      // Upload image if selected
      if (_imageFile != null) {
        final imageUrl = await _uploadImageToStorage();
        if (imageUrl != null) {
          _imageUrl = imageUrl;
        }
      }
      
      // Create show object
      final show = Show(
        id: '',
        title: _title,
        date: _date,
        venue: _venue,
        ticketLimit: _ticketLimit,
        imageUrl: _imageUrl,
      );

      await _showService.addShow(show);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Show added successfully!'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            backgroundColor: Colors.green[700],
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Show'),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Form Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create a New Comedy Show',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Fill in the details below to create a new event',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Form Fields
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Show Title
                        CustomTextField(
                          labelText: 'Show Title',
                          hintText: 'Enter a catchy title for your show',
                          prefixIcon: Icon(Icons.title),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                          onSaved: (val) => _title = val?.trim() ?? '',
                        ),
                        
                        // Date Picker
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: TextFormField(
                            controller: _dateController,
                            decoration: InputDecoration(
                              labelText: 'Show Date',
                              hintText: 'Select a date',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.calendar_today),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.edit_calendar),
                                onPressed: () => _selectDate(context),
                              ),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                            ),
                            readOnly: true,
                            onTap: () => _selectDate(context),
                          ),
                        ),
                        
                        // Time Picker
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: TextFormField(
                            controller: _timeController,
                            decoration: InputDecoration(
                              labelText: 'Show Time',
                              hintText: 'Select a time',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.access_time),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.schedule),
                                onPressed: () => _selectTime(context),
                              ),
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                            ),
                            readOnly: true,
                            onTap: () => _selectTime(context),
                          ),
                        ),
                        
                        // Venue
                        CustomTextField(
                          labelText: 'Venue',
                          hintText: 'Enter the location of your show',
                          prefixIcon: Icon(Icons.location_on),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter a venue';
                            }
                            return null;
                          },
                          onSaved: (val) => _venue = val?.trim() ?? '',
                        ),
                        
                        // Ticket Limit with Slider
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                              child: Text(
                                'Ticket Limit: $_ticketLimit',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '10',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '500',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SliderTheme(
                                    data: SliderThemeData(
                                      activeTrackColor: Theme.of(context).colorScheme.primary,
                                      inactiveTrackColor: Colors.grey[200],
                                      thumbColor: Theme.of(context).colorScheme.primary,
                                      overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                      trackHeight: 4,
                                    ),
                                    child: Slider(
                                      min: 10,
                                      max: 500,
                                      divisions: 49,
                                      value: _ticketLimit.toDouble(),
                                      onChanged: (val) {
                                        setState(() {
                                          _ticketLimit = val.round();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 20),
                        
                        // Image URL
                         Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Show Image',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 12),
                            InkWell(
                              onTap: _pickImage,
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: _imageFile != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          _imageFile!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate,
                                            size: 50,
                                            color: Colors.grey[400],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Add Show Image',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 24),
                        
                        // Error message
                        if (_errorMessage.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            margin: EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red[100]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red[700],
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Submit button
                        _loading
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton.icon(
                                icon: Icon(Icons.add),
                                label: Text('Add Show'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: _submitForm,
                              ),
                        
                        SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}