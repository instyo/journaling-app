// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_markdown/flutter_markdown.dart'; // For Markdown preview
// import 'package:journaling/common/widgets/markdown_input.dart';
// import 'package:journaling/common/widgets/markdown_input_v2.dart';
// import 'package:journaling/features/auth/cubit/auth_cubit.dart';
// import 'package:journaling/features/journal/cubit/journal_cubit.dart';
// import 'package:journaling/features/journal/models/journal_entry.dart';
// import 'package:markdown_editor_plus/widgets/markdown_auto_preview.dart';
// import '../../../common/constants.dart'; // Mood enum

// class JournalWriteScreen extends StatefulWidget {
//   final JournalEntry? journal; // Optional: for editing existing entries

//   const JournalWriteScreen({super.key, this.journal});

//   @override
//   State<JournalWriteScreen> createState() => _JournalWriteScreenState();
// }

// class _JournalWriteScreenState extends State<JournalWriteScreen> {
//   final _titleController = TextEditingController();
//   final _contentController = TextEditingController();
//   Mood _selectedMood = Mood.bad; // Default mood
//   final List<File> _pickedMediaFiles = []; // For new uploads
//   final List<String> _existingMediaUrls = []; // For existing URLs in edit mode

//   @override
//   void initState() {
//     super.initState();
//     if (widget.journal != null) {
//       _titleController.text = widget.journal!.title;
//       _contentController.text = widget.journal!.content;
//       // _selectedMood = widget.journal!.mood;
//       _existingMediaUrls.addAll(widget.journal!.emotions);
//     }
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     final picker = ImagePicker();
//     final XFile? pickedFile = await picker.pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() {
//         _pickedMediaFiles.add(File(pickedFile.path));
//       });
//     }
//   }

//   Future<void> _pickVideo(ImageSource source) async {
//     final picker = ImagePicker();
//     final XFile? pickedFile = await picker.pickVideo(source: source);
//     if (pickedFile != null) {
//       setState(() {
//         _pickedMediaFiles.add(File(pickedFile.path));
//       });
//     }
//   }

//   Future<void> _pickAudio() async {
//     final result = await FilePicker.platform.pickFiles(type: FileType.audio);
//     if (result != null && result.files.single.path != null) {
//       setState(() {
//         _pickedMediaFiles.add(File(result.files.single.path!));
//       });
//     }
//   }

//   void _saveJournal() {
//     final String title = _titleController.text.trim();
//     final String content = _contentController.text.trim();

//     if (title.isEmpty || content.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Title and content cannot be empty!')),
//       );
//       return;
//     }

//     final userId =
//         context.read<AuthCubit>().state is Authenticated
//             ? (context.read<AuthCubit>().state as Authenticated).user.uid
//             : 'unknown'; // Fallback, should not happen if auth is handled

//     if (widget.journal == null) {
//       // Create new journal
//       final newEntry = JournalEntry(
//         userId: userId,
//         title: title,
//         content: content,
//         mood: '',
//         label: '',
//         createdAt: DateTime.now(),
//         // mediaUrls will be added by the repository after upload
//       );
//       context.read<JournalCubit>().createJournal(newEntry);
//     } else {
//       // Update existing journal
//       final updatedEntry = widget.journal!.copyWith(
//         title: title,
//         content: content,
//         // mood: _selectedMood,
//         // This assumes new media are *added* to existing, might need more complex logic
//         // For simplicity, we just pass existing URLs + new uploaded files
//         emotions: _existingMediaUrls,
//       );
//       // NOTE: Handling media during update is complex. If you allow removing media,
//       // you need to track deleted URLs and remove them from storage. For MVP,
//       // we'll assume existing media is kept and new media is added.
//       // The `JournalCubit`'s update method currently doesn't handle new media files directly.
//       // You'd need to extend it to upload new media and merge URLs.
//       context.read<JournalCubit>().updateJournal(updatedEntry);
//       // For new media added during an update, you'd need a separate function call
//       // or integrate `uploadMedia` into the `updateJournal` cubit method.
//       // For MVP, we'll keep `_pickedMediaFiles` logic only in `createJournal`.
//     }
//     Navigator.of(context).pop(); // Go back to list
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _contentController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.journal == null ? 'New Journal' : 'Edit Journal'),
//         actions: [
//           IconButton(icon: const Icon(Icons.save), onPressed: _saveJournal),
//         ],
//       ),
//       body: BlocListener<JournalCubit, JournalState>(
//         listener: (context, state) {
//           if (state is JournalError) {
//             ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(SnackBar(content: Text(state.message)));
//           } else if (state is JournalLoading) {
//             // Show loading indicator if desired
//           }
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: ListView(
//             children: [
//               TextField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(
//                   labelText: 'Title',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLength: 100,
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<Mood>(
//                 value: _selectedMood,
//                 decoration: const InputDecoration(
//                   labelText: 'How are you feeling?',
//                   border: OutlineInputBorder(),
//                 ),
//                 items:
//                     Mood.values
//                         .map(
//                           (mood) => DropdownMenuItem(
//                             value: mood,
//                             child: Text(
//                               '${mood.emoji} ${mood.name.capitalize()}',
//                             ),
//                           ),
//                         )
//                         .toList(),
//                 onChanged: (mood) {
//                   if (mood != null) {
//                     setState(() {
//                       _selectedMood = mood;
//                     });
//                   }
//                 },
//               ),
//               const SizedBox(height: 16),
//               // editable text with toolbar by default
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(width: 1, color: Colors.grey.shade100),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: MarkdownInputV2()
//               ),
//               const SizedBox(height: 16),

//               // Media Upload Buttons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed:
//                         () => _showMediaSourcePicker(context, _pickImage),
//                     icon: const Icon(Icons.image),
//                     label: const Text('Add Image'),
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: _pickAudio,
//                     icon: const Icon(Icons.audiotrack),
//                     label: const Text('Add Audio'),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),

//               // Display picked media (for newly added files)
//               if (_pickedMediaFiles.isNotEmpty)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'New Media to Upload:',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     ..._pickedMediaFiles.map(
//                       (file) => Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 4.0),
//                         child: Row(
//                           children: [
//                             Icon(_getMediaTypeIcon(file)),
//                             const SizedBox(width: 8),
//                             Expanded(child: Text(file.path.split('/').last)),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                   ],
//                 ),

//               // Display existing media (for journal editing)
//               if (_existingMediaUrls.isNotEmpty)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Existing Media:',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     ..._existingMediaUrls.map(
//                       (url) => Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 4.0),
//                         child: Row(
//                           children: [
//                             Icon(_getMediaTypeIconFromUrl(url)),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(url.split('/').last.split('?').first),
//                             ), // Show file name
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper to show image/video source picker (camera/gallery)
//   void _showMediaSourcePicker(
//     BuildContext context,
//     Function(ImageSource) onPick,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       builder: (ctx) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text('Take from Camera'),
//               onTap: () {
//                 Navigator.of(ctx).pop();
//                 onPick(ImageSource.camera);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('Choose from Gallery'),
//               onTap: () {
//                 Navigator.of(ctx).pop();
//                 onPick(ImageSource.gallery);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Helper to get icon based on file extension
//   IconData _getMediaTypeIcon(File file) {
//     final String extension = file.path.split('.').last.toLowerCase();
//     if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(extension)) {
//       return Icons.image;
//     } else if (['mp4', 'mov', 'avi', 'flv'].contains(extension)) {
//       return Icons.videocam;
//     } else if (['mp3', 'wav', 'ogg'].contains(extension)) {
//       return Icons.audiotrack;
//     }
//     return Icons.attach_file;
//   }

//   // Helper to get icon based on URL content (simple check for now)
//   IconData _getMediaTypeIconFromUrl(String url) {
//     final String lowerCaseUrl = url.toLowerCase();
//     if (lowerCaseUrl.contains('image')) {
//       return Icons.image_outlined;
//     } else if (lowerCaseUrl.contains('video')) {
//       return Icons.videocam_outlined;
//     } else if (lowerCaseUrl.contains('audio')) {
//       return Icons.audiotrack_outlined;
//     }
//     return Icons.cloud_download; // General cloud indicator
//   }
// }

// // Extension to capitalize first letter of a string (for mood enum display)
// extension StringCasingExtension on String {
//   String capitalize() =>
//       length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
// }
