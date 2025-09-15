// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:realestate/models/user.dart';
// import 'package:realestate/services/firebase_user.dart';
// import 'package:realestate/services/firebase_cloudinary.dart';
// import 'package:realestate/accessories/custombutton.dart';

// class UserProfileSetting extends StatefulWidget {
//   const UserProfileSetting({super.key});

//   @override
//   State<UserProfileSetting> createState() => _UserProfileSettingState();
// }

// class _UserProfileSettingState extends State<UserProfileSetting> {
//   FilePickerResult? _filePickerResult;
//   final _formKey = GlobalKey<FormState>();
//   final _nameC = TextEditingController();
//   final _addressC = TextEditingController();
//   final _phoneC = TextEditingController();
//   final _profileUrlC = TextEditingController();
//   final _passwordC = TextEditingController();
//   final _confirmC = TextEditingController();
//   late String _emailC;

//   bool _isPremium = false;
//   bool _isLoading = true;
//   bool _isSaving = false;
//   bool _hidePassword = true;
//   bool _hideConfirm = true;

//   UserModel? _original;
//   final _service = FirebaseUser();

//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }

//   Future<void> _load() async {
//     setState(() => _isLoading = true);
//     try {
//       final user = await _service.getCurrentUser();
//       if (!mounted) return;
//       if (user != null) {
//         _original = user;
//         _emailC = user.email;
//         _nameC.text = user.name;
//         _addressC.text = user.address ?? '';
//         _phoneC.text = user.phoneNumber ?? '';
//         _profileUrlC.text = user.profilePicture ?? '';
//         _isPremium = user.isPremium;
//       }
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _openFilePicker() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: false,
//       allowedExtensions: ["jpg", "jpeg", "png"],
//       type: FileType.custom,
//     );
//     if (result != null) {
//        // Close the current modal
//         Navigator.pop(context);

//       // Auto-reopen the modal
//        _showEditDialog();
//       setState(() {
//         _filePickerResult = result;
//       });
//     }
//   }

//   /// Uploads to Cloudinary & Updates Firestore
//   Future<void> _uploadAndSaveProfilePic() async {
//     if (_filePickerResult == null) {
//       _showSnack("Please select a picture first");
//       return;
//     }
//     setState(() => _isSaving = true);
//     try {
//       // Upload to Cloudinary
//       final imageUrl = await uploadToCloudinary(_filePickerResult);
//       if (imageUrl == null) {
//         _showSnack("Image upload failed");
//         return;
//       }

//       // Save URL to Firestore
//       final res = await _service.updateUserProfile(profilePicture: imageUrl);
//       _showSnack(res ?? "Profile picture updated!");

//       // Update the profile URL controller immediately
//       _profileUrlC.text = imageUrl;

//       // Clear selected file and refresh data
//       setState(() {
//         _filePickerResult = null;
//       });

//       // Refresh data to ensure consistency
//       await _load();
//     } catch (e) {
//       _showSnack("Error: $e");
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }

//   Future<void> _save() async {
//     if (!_formKey.currentState!.validate()) return;

//     final updates = <String, dynamic>{};
//     final o = _original;

//     // Only set changed values
//     if (o == null || _nameC.text.trim() != o.name) {
//       updates['name'] = _nameC.text.trim();
//     }
//     if (o == null || _addressC.text.trim() != o.address) {
//       updates['address'] = _addressC.text.trim();
//     }
//     if (o == null || _phoneC.text.trim() != o.phoneNumber) {
//       updates['phoneNumber'] = _phoneC.text.trim();
//     }
//     if (o == null || (_profileUrlC.text.trim()) != (o.profilePicture ?? '')) {
//       updates['profilePicture'] = _profileUrlC.text.trim().isEmpty
//           ? null
//           : _profileUrlC.text.trim();
//     }
//     if (o == null || _isPremium != o.isPremium) {
//       updates['isPremium'] = _isPremium;
//     }

//     // Optional password change
//     final newPass = _passwordC.text;
//     if (newPass.isNotEmpty) {
//       if (newPass != _confirmC.text) {
//         _showSnack('Passwords do not match');
//         return;
//       }
//       if (newPass.length < 6) {
//         _showSnack('Password must be at least 6 characters');
//         return;
//       }
//     }

//     if (updates.isEmpty && newPass.isEmpty) {
//       _showSnack('Nothing to update');
//       return;
//     }

//     setState(() => _isSaving = true);
//     try {
//       final res = await _service.updateUserProfile(
//         name: updates['name'],
//         address: updates['address'],
//         phoneNumber: updates['phoneNumber'],
//         isPremium: updates['isPremium'],
//         profilePicture: updates['profilePicture'],
//         password: newPass.isNotEmpty ? newPass : null,
//       );

//       if (!mounted) return;
//       _showSnack(res ?? 'Updated');

//       // Clear password fields
//       _passwordC.clear();
//       _confirmC.clear();

//       // Refresh data
//       await _load();
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'requires-recent-login') {
//         _showSnack('Please log out and sign in again to change password.');
//       } else {
//         _showSnack(e.message ?? 'Auth error');
//       }
//     } catch (e) {
//       _showSnack('Update failed: $e');
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }

//   Future<void> _softDelete() async {
//     final ok = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Delete account?'),
//         content: const Text(
//           'This will mark your account as deleted. You can ask support to restore it later.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Cancel'),
//           ),
//           FilledButton.tonal(
//             onPressed: () => Navigator.pop(ctx, true),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (ok != true) return;

//     try {
//       setState(() => _isSaving = true);
//       final res = await _service.updateUserProfile(isDeleted: true);
//       if (!mounted) return;
//       _showSnack(res ?? 'Account marked as deleted');
//       Navigator.of(context).pop();
//     } catch (e) {
//       _showSnack('Delete failed: $e');
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }

//   void _showSnack(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
//     );
//   }

//   @override
//   void dispose() {
//     _nameC.dispose();
//     _addressC.dispose();
//     _phoneC.dispose();
//     _profileUrlC.dispose();
//     _passwordC.dispose();
//     _confirmC.dispose();
//     super.dispose();
//   }

//   Widget _buildProfileSection(String title) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
//       child: ListTile(
//         leading: Text(
//           title,
//           style: const TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         trailing: Custombutton(
//           onPressed: _showEditDialog,
//           buttonText: "Edit",
//           height: 40,
//           width: 80,
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           borderRadius: 10,
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileItem({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     VoidCallback? onTap,
//     Color? iconColor,
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//         leading: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: (iconColor ?? Colors.blue).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, color: iconColor ?? Colors.blue, size: 24),
//         ),
//         title: Text(
//           title,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: Colors.black87,
//           ),
//         ),
//         subtitle: Text(
//           subtitle,
//           style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.3),
//         ),
//         onTap: () {},
//       ),
//     );
//   }

//   void _showEditDialog() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setModalState) {
//           return DraggableScrollableSheet(
//             initialChildSize: 0.9,
//             maxChildSize: 0.95,
//             minChildSize: 0.5,
//             builder: (context, scrollController) => Container(
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               child: Form(
//                 key: _formKey,
//                 child: SingleChildScrollView(
//                   controller: scrollController,
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       Container(
//                         width: 40,
//                         height: 4,
//                         margin: const EdgeInsets.only(bottom: 20),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[300],
//                           borderRadius: BorderRadius.circular(2),
//                         ),
//                         alignment: Alignment.center,
//                       ),
//                       const Text(
//                         'Edit Profile',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 30),

//                       // Profile Picture Upload Section
//                       Center(
//                         child: Stack(
//                           children: [
//                             CircleAvatar(
//                               radius: 50,
//                               backgroundImage:
//                                   (_profileUrlC.text.trim().isNotEmpty)
//                                   ? NetworkImage(_profileUrlC.text.trim())
//                                   : null,
//                               backgroundColor: Colors.grey[200],
//                               child: (_profileUrlC.text.trim().isEmpty)
//                                   ? Icon(
//                                       Icons.person,
//                                       size: 50,
//                                       color: Colors.grey[400],
//                                     )
//                                   : null,
//                             ),
//                             Positioned(
//                               bottom: 0,
//                               right: 0,
//                               child: GestureDetector(
//                                 onTap: () async {
//                                     // Open file picker
//                                   _openFilePicker();

//                                 },
//                                 child: Container(
//                                   padding: const EdgeInsets.all(8),
//                                   decoration: const BoxDecoration(
//                                     color: Colors.blue,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(
//                                     Icons.camera_alt,
//                                     color: Colors.white,
//                                     size: 16,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       if (_filePickerResult != null) ...[
//                         const SizedBox(height: 12),
//                         Center(
//                           child: Column(
//                             children: [
//                               Text(
//                                 "Selected: ${_filePickerResult!.files.single.name}",
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   fontStyle: FontStyle.italic,
//                                   color: Colors.blue,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               ElevatedButton.icon(
//                                 onPressed: _isSaving
//                                     ? null
//                                     : () async {
//                                         await _uploadAndSaveProfilePic();
//                                         // Update both states after upload
//                                         setModalState(() {});
//                                       },
//                                 icon: _isSaving
//                                     ? const SizedBox(
//                                         width: 16,
//                                         height: 16,
//                                         child: CircularProgressIndicator(
//                                           strokeWidth: 2,
//                                           color: Colors.white,
//                                         ),
//                                       )
//                                     : const Icon(Icons.cloud_upload, size: 16),
//                                 label: Text(
//                                   _isSaving ? "Uploading..." : "Upload",
//                                 ),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.blue,
//                                   foregroundColor: Colors.white,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],

//                       const SizedBox(height: 30),

//                       // Form Fields
//                       TextFormField(
//                         controller: _nameC,
//                         textInputAction: TextInputAction.next,
//                         decoration: InputDecoration(
//                           labelText: 'Name',
//                           prefixIcon: Icon(
//                             Icons.person_outline,
//                             color: Colors.grey[600],
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: const BorderSide(color: Colors.blue),
//                           ),
//                         ),
//                         validator: (v) => (v == null || v.trim().isEmpty)
//                             ? 'Please enter your name'
//                             : null,
//                       ),
//                       const SizedBox(height: 16),

//                       TextFormField(
//                         controller: _addressC,
//                         textInputAction: TextInputAction.next,
//                         decoration: InputDecoration(
//                           labelText: 'Address',
//                           prefixIcon: Icon(
//                             Icons.home_outlined,
//                             color: Colors.grey[600],
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: const BorderSide(color: Colors.blue),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       TextFormField(
//                         controller: _phoneC,
//                         keyboardType: TextInputType.phone,
//                         textInputAction: TextInputAction.next,
//                         decoration: InputDecoration(
//                           labelText: 'Phone Number',
//                           prefixIcon: Icon(
//                             Icons.phone_outlined,
//                             color: Colors.grey[600],
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: const BorderSide(color: Colors.blue),
//                           ),
//                         ),
//                         validator: (v) {
//                           final t = v?.trim() ?? '';
//                           if (t.isEmpty) return 'Please enter phone number';
//                           if (t.length < 11) return 'Enter a valid phone number';
//                           return null;
//                         },
//                       ),

//                       const SizedBox(height: 24),
//                       const Divider(),
//                       const SizedBox(height: 16),

//                       const Text(
//                         'Change Password',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       TextFormField(
//                         controller: _passwordC,
//                         obscureText: _hidePassword,
//                         decoration: InputDecoration(
//                           labelText: 'New Password (optional)',
//                           prefixIcon: Icon(
//                             Icons.lock_outline,
//                             color: Colors.grey[600],
//                           ),
//                           suffixIcon: IconButton(
//                             onPressed: () => setModalState(
//                               () => _hidePassword = !_hidePassword,
//                             ),
//                             icon: Icon(
//                               _hidePassword
//                                   ? Icons.visibility
//                                   : Icons.visibility_off,
//                             ),
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: const BorderSide(color: Colors.blue),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       TextFormField(
//                         controller: _confirmC,
//                         obscureText: _hideConfirm,
//                         decoration: InputDecoration(
//                           labelText: 'Confirm Password',
//                           prefixIcon: Icon(
//                             Icons.lock_reset_outlined,
//                             color: Colors.grey[600],
//                           ),
//                           suffixIcon: IconButton(
//                             onPressed: () => setModalState(
//                               () => _hideConfirm = !_hideConfirm,
//                             ),
//                             icon: Icon(
//                               _hideConfirm
//                                   ? Icons.visibility
//                                   : Icons.visibility_off,
//                             ),
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(color: Colors.grey[300]!),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: const BorderSide(color: Colors.blue),
//                           ),
//                         ),
//                         validator: (v) {
//                           if (_passwordC.text.isEmpty) return null;
//                           if (v != _passwordC.text) return 'Passwords do not match';
//                           return null;
//                         },
//                       ),

//                       const SizedBox(height: 30),

//                       // Save Button
//                       Custombutton(
//                         buttonText: _isSaving ? 'Saving...' : 'Save Changes',
//                         icon: Icons.save_outlined,
//                         onPressed: _isSaving
//                             ? () {}
//                             : () async {
//                                 await _save();
//                                 if (!_isSaving && mounted) {
//                                   Navigator.pop(context);
//                                 }
//                               },
//                         height: 52,
//                         fontSize: 16,
//                       ),

//                       const SizedBox(height: 16),

//                       // Delete Account Button
//                       OutlinedButton.icon(
//                         onPressed: _isSaving
//                             ? null
//                             : () async {
//                                 await _softDelete();
//                                 if (mounted) {
//                                   Navigator.pop(context);
//                                 }
//                               },
//                         icon: const Icon(
//                           Icons.delete_outline,
//                           color: Colors.red,
//                         ),
//                         label: const Text(
//                           'Delete Account',
//                           style: TextStyle(color: Colors.red),
//                         ),
//                         style: OutlinedButton.styleFrom(
//                           side: const BorderSide(color: Colors.red),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                       ),

//                       const SizedBox(height: 16),

//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.blue.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Text(
//                           'Tip: To successfully change password, you may need to sign in again if your session is old.',
//                           style: TextStyle(fontSize: 12, color: Colors.blue),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),

//                       // Add bottom padding for safe area
//                       SizedBox(
//                         height: MediaQuery.of(context).padding.bottom + 20,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           'Profile',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         // backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               child: Padding(
//                 padding: MediaQuery.of(context).size.width > 600
//                     ? const EdgeInsets.only(left: 80.0, right: 80.0)
//                     : const EdgeInsets.all(0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header with profile picture and name
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(20),
//                         decoration: const BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.all(Radius.circular(12)),
//                         ),
//                         child: Column(
//                           children: [
//                             CircleAvatar(
//                               radius: 80,
//                               backgroundImage: (_profileUrlC.text.trim().isNotEmpty)
//                                   ? NetworkImage(_profileUrlC.text.trim())
//                                   : null,
//                               // backgroundColor: Colors.grey[200],
//                               child: (_profileUrlC.text.trim().isEmpty)
//                                   ? Icon(
//                                       Icons.person,
//                                       size: 80,
//                                       color: Colors.grey[200],
//                                     )
//                                   : null,
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               _nameC.text.isEmpty ? 'Your Name' : _nameC.text,
//                               style: const TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               _emailC,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
                
//                     const SizedBox(height: 20),
                
//                     // Personal Info Section
//                     _buildProfileSection('Personal Info'),
                
//                     _buildProfileItem(
//                       icon: Icons.person_outline,
//                       title: 'Name',
//                       subtitle: _nameC.text.isEmpty
//                           ? 'Your first and last given names'
//                           : _nameC.text,
//                       onTap: _showEditDialog,
//                     ),
                
//                     _buildProfileItem(
//                       icon: Icons.home_outlined,
//                       title: 'Address',
//                       subtitle: _addressC.text.isEmpty
//                           ? 'Your home address'
//                           : _addressC.text,
//                       onTap: _showEditDialog,
//                     ),
                
//                     _buildProfileItem(
//                       icon: Icons.phone_outlined,
//                       title: 'Phone',
//                       subtitle: _phoneC.text.isEmpty
//                           ? 'Your contact number'
//                           : _phoneC.text,
//                       onTap: _showEditDialog,
//                     ),
                
//                     _buildProfileItem(
//                       icon: Icons.photo_camera_outlined,
//                       title: 'Photo',
//                       subtitle:
//                           'Personalize your profile pic with a custom photo.',
//                       onTap: _showEditDialog,
//                     ),
                
//                     // Sign in & Security Section
//                     _buildProfileSection('Sign in & Security'),
                
//                     _buildProfileItem(
//                       icon: Icons.email_outlined,
//                       title: 'Email',
//                       subtitle: _emailC,
//                     ),
                
//                     _buildProfileItem(
//                       icon: Icons.lock_outline,
//                       title: 'Password',
//                       subtitle: 'Set a unique password to protect your account.',
//                       onTap: _showEditDialog,
//                       iconColor: Colors.orange,
//                     ),
                
//                     const SizedBox(height: 40),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:realestate/models/user.dart';
import 'package:realestate/services/firebase_user.dart';
import 'package:realestate/services/firebase_cloudinary.dart';
import 'package:realestate/accessories/custombutton.dart';

class UserProfileSetting extends StatefulWidget {
  const UserProfileSetting({super.key});

  @override
  State<UserProfileSetting> createState() => _UserProfileSettingState();
}

class _UserProfileSettingState extends State<UserProfileSetting> {
  FilePickerResult? _filePickerResult;
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _addressC = TextEditingController();
  final _phoneC = TextEditingController();
  final _profileUrlC = TextEditingController();
  final _passwordC = TextEditingController();
  final _confirmC = TextEditingController();
  late String _emailC;

  bool _isPremium = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hidePassword = true;
  bool _hideConfirm = true;

  UserModel? _original;
  final _service = FirebaseUser();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final user = await _service.getCurrentUser();
      if (!mounted) return;
      if (user != null) {
        _original = user;
        _emailC = user.email;
        _nameC.text = user.name;
        _addressC.text = user.address ?? '';
        _phoneC.text = user.phoneNumber ?? '';
        _profileUrlC.text = user.profilePicture ?? '';
        _isPremium = user.isPremium;
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowedExtensions: ["jpg", "jpeg", "png"],
      type: FileType.custom,
    );
    if (result != null) {
      Navigator.pop(context);
      _showEditDialog();
      setState(() => _filePickerResult = result);
    }
  }

  Future<void> _uploadAndSaveProfilePic() async {
    if (_filePickerResult == null) {
      _showSnack("Please select a picture first");
      return;
    }
    setState(() => _isSaving = true);
    try {
      final imageUrl = await uploadToCloudinary(_filePickerResult);
      if (imageUrl == null) {
        _showSnack("Image upload failed");
        return;
      }

      final res = await _service.updateUserProfile(profilePicture: imageUrl);
      _showSnack(res ?? "Profile picture updated!");
      _profileUrlC.text = imageUrl;

      setState(() => _filePickerResult = null);
      await _load();
    } catch (e) {
      _showSnack("Error: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final updates = <String, dynamic>{};
    final o = _original;

    if (o == null || _nameC.text.trim() != o.name) {
      updates['name'] = _nameC.text.trim();
    }
    if (o == null || _addressC.text.trim() != o.address) {
      updates['address'] = _addressC.text.trim();
    }
    if (o == null || _phoneC.text.trim() != o.phoneNumber) {
      updates['phoneNumber'] = _phoneC.text.trim();
    }
    if (o == null || (_profileUrlC.text.trim()) != (o.profilePicture ?? '')) {
      updates['profilePicture'] = _profileUrlC.text.trim().isEmpty
          ? null
          : _profileUrlC.text.trim();
    }
    if (o == null || _isPremium != o.isPremium) {
      updates['isPremium'] = _isPremium;
    }

    final newPass = _passwordC.text;
    if (newPass.isNotEmpty) {
      if (newPass != _confirmC.text) {
        _showSnack('Passwords do not match');
        return;
      }
      if (newPass.length < 6) {
        _showSnack('Password must be at least 6 characters');
        return;
      }
    }

    if (updates.isEmpty && newPass.isEmpty) {
      _showSnack('Nothing to update');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final res = await _service.updateUserProfile(
        name: updates['name'],
        address: updates['address'],
        phoneNumber: updates['phoneNumber'],
        isPremium: updates['isPremium'],
        profilePicture: updates['profilePicture'],
        password: newPass.isNotEmpty ? newPass : null,
      );

      if (!mounted) return;
      _showSnack(res ?? 'Updated');
      _passwordC.clear();
      _confirmC.clear();
      await _load();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showSnack('Please log out and sign in again to change password.');
      } else {
        _showSnack(e.message ?? 'Auth error');
      }
    } catch (e) {
      _showSnack('Update failed: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _softDelete() async {
    final colorScheme = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete account?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: const Text(
          'This will mark your account as deleted. You can ask support to restore it later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      setState(() => _isSaving = true);
      final res = await _service.updateUserProfile(isDeleted: true);
      if (!mounted) return;
      _showSnack(res ?? 'Account marked as deleted');
      Navigator.of(context).pop();
    } catch (e) {
      _showSnack('Delete failed: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    _nameC.dispose();
    _addressC.dispose();
    _phoneC.dispose();
    _profileUrlC.dispose();
    _passwordC.dispose();
    _confirmC.dispose();
    super.dispose();
  }

  Widget _buildProfileSection(String title) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
      child: ListTile(
        leading: Text(
          title,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        trailing: Custombutton(
          onPressed: _showEditDialog,
          buttonText: "Edit",
          height: 40,
          width: 80,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? colorScheme.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor ?? colorScheme.onPrimary, size: 24),
        ),
        title: Text(
          title,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        // onTap: onTap,
      ),
    );
  }

  void _showEditDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: colorScheme.outline.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        alignment: Alignment.center,
                      ),
                      Text(
                        'Edit Profile',
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // Profile Picture Upload Section
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  (_profileUrlC.text.trim().isNotEmpty)
                                      ? NetworkImage(_profileUrlC.text.trim())
                                      : null,
                              backgroundColor: colorScheme.surfaceVariant,
                              child: (_profileUrlC.text.trim().isEmpty)
                                  ? Icon(Icons.person,
                                      size: 50,
                                      color: colorScheme.onSurfaceVariant)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _openFilePicker,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.camera_alt,
                                      color: colorScheme.onPrimary, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_filePickerResult != null) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                "Selected: ${_filePickerResult!.files.single.name}",
                                style: textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: _isSaving
                                    ? null
                                    : () async {
                                        await _uploadAndSaveProfilePic();
                                        setModalState(() {});
                                      },
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.cloud_upload, size: 16),
                                label: Text(
                                  _isSaving ? "Uploading..." : "Upload",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),

                      // Name
                      TextFormField(
                        controller: _nameC,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Please enter your name'
                                : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _addressC,
                        textInputAction: TextInputAction.next,
                        decoration:
                            const InputDecoration(labelText: 'Address'),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneC,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration:
                            const InputDecoration(labelText: 'Phone Number'),
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return 'Please enter phone number';
                          if (t.length < 11) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      Text('Change Password',
                          style: textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordC,
                        obscureText: _hidePassword,
                        decoration: InputDecoration(
                          labelText: 'New Password (optional)',
                          suffixIcon: IconButton(
                            onPressed: () => setModalState(
                                () => _hidePassword = !_hidePassword),
                            icon: Icon(
                                _hidePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _confirmC,
                        obscureText: _hideConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          suffixIcon: IconButton(
                            onPressed: () => setModalState(
                                () => _hideConfirm = !_hideConfirm),
                            icon: Icon(
                                _hideConfirm
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                        validator: (v) {
                          if (_passwordC.text.isEmpty) return null;
                          if (v != _passwordC.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),
                      Custombutton(
                        buttonText: _isSaving ? 'Saving...' : 'Save Changes',
                        icon: Icons.save_outlined,
                        onPressed: _isSaving
                            ? () {}
                            : () async {
                                await _save();
                                if (!_isSaving && mounted) {
                                  Navigator.pop(context);
                                }
                              },
                        height: 52,
                        fontSize: 16,
                      ),

                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _isSaving
                            ? null
                            : () async {
                                await _softDelete();
                                if (mounted) Navigator.pop(context);
                              },
                        icon: Icon(Icons.delete_outline,
                            color: colorScheme.error),
                        label: Text('Delete Account',
                            style: TextStyle(color: colorScheme.error)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorScheme.error),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Tip: To change password, you may need to sign in again if your session is old.',
                          style: textTheme.bodySmall
                              ?.copyWith(color: colorScheme.primary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: MediaQuery.of(context).size.width > 600
                    ? const EdgeInsets.symmetric(horizontal: 80)
                    : EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with profile picture & name
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 80,
                              backgroundImage:
                                  (_profileUrlC.text.trim().isNotEmpty)
                                      ? NetworkImage(_profileUrlC.text.trim())
                                      : null,
                              backgroundColor: colorScheme.surfaceVariant,
                              child: (_profileUrlC.text.trim().isEmpty)
                                  ? Icon(Icons.person,
                                      size: 80,
                                      color: colorScheme.onSurfaceVariant)
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _nameC.text.isEmpty
                                  ? 'Your Name'
                                  : _nameC.text,
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _emailC,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Personal Info Section
                    _buildProfileSection('Personal Info'),

                    _buildProfileItem(
                      icon: Icons.person_outline,
                      title: 'Name',
                      subtitle: _nameC.text.isEmpty
                          ? 'Your first and last given names'
                          : _nameC.text,
                      onTap: _showEditDialog,
                    ),
                    _buildProfileItem(
                      icon: Icons.home_outlined,
                      title: 'Address',
                      subtitle: _addressC.text.isEmpty
                          ? 'Your home address'
                          : _addressC.text,
                      onTap: _showEditDialog,
                    ),
                    _buildProfileItem(
                      icon: Icons.phone_outlined,
                      title: 'Phone',
                      subtitle: _phoneC.text.isEmpty
                          ? 'Your contact number'
                          : _phoneC.text,
                      onTap: _showEditDialog,
                    ),
                    _buildProfileItem(
                      icon: Icons.photo_camera_outlined,
                      title: 'Photo',
                      subtitle:
                          'Personalize your profile pic with a custom photo.',
                      onTap: _showEditDialog,
                    ),

                    // Security Section
                    _buildProfileSection('Sign in & Security'),

                    _buildProfileItem(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      subtitle: _emailC,
                    ),
                    _buildProfileItem(
                      icon: Icons.lock_outline,
                      title: 'Password',
                      subtitle:
                          'Set a unique password to protect your account.',
                      onTap: _showEditDialog,
                      iconColor: Colors.orange, // optional accent override
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}