// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:realestate/models/property.dart';
// import 'package:realestate/services/firebase_cloudinary.dart';
// import 'package:realestate/services/firebase_properties.dart';

// class PropertyAddToList extends StatefulWidget {
//   const PropertyAddToList({super.key});

//   @override
//   State<PropertyAddToList> createState() => _PropertyAddToListState();
// }

// class _PropertyAddToListState extends State<PropertyAddToList> {
//   final _formKey = GlobalKey<FormState>();

//   FilePickerResult? _filePickerResult;
//   List<String> _uploadUrls = [];
//   bool isUploadingMedia = false;

//   // controllers
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _rentPriceController = TextEditingController();
//   final _squareFeetController = TextEditingController();
//   final _bedroomController = TextEditingController();
//   final _bathroomController = TextEditingController();
//   final _balconyController = TextEditingController();
//   final _kitchenController = TextEditingController();
//   final _yearBuiltController = TextEditingController();
// //  final _cityController = TextEditingController();
//   final _districtController = TextEditingController();
//   final _subdistrictController = TextEditingController();
//   final _postCodeController = TextEditingController();
//   final _divisionController = TextEditingController();

//   PropertyType? _selectedPropertyType;
//   ListingType? _selectedListingType;
//   bool _isLoading = false;

//   void _pickMedia() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: true,
//       allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
//       type: FileType.custom,
//     );

//     if (result != null) {
//       setState(() {
//         _filePickerResult = result;
//       });
//     }
//   }

//   Future<void> _uploadMedia() async {
//     if (_filePickerResult == null) return;

//     setState(() {
//       isUploadingMedia = true;
//     });

//     _uploadUrls.clear(); // ager urls gulo remove

//     for (var file in _filePickerResult!.files) {
//       final signleResult = FilePickerResult([file]);

//       String? url = await uploadToCloudinary(signleResult);
//       if (url != null) _uploadUrls.add(url);
//     }

//     setState(() {
//       isUploadingMedia = false;
//     });
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;

//     if (_selectedPropertyType == null || _selectedListingType == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select property & listing type")),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     if (_filePickerResult != null && _filePickerResult!.files.isNotEmpty) {
//       await _uploadMedia();
//     }

//     final property = PropertyModel(
//       id: "",
//       ownerId: "",
//       title: _titleController.text.trim(),
//       description: _descriptionController.text.trim(),
//       propertyType: _selectedPropertyType!,
//       listingType: _selectedListingType!,
//       status: PropertyStatus.pending,
//       price: _selectedListingType == ListingType.sale
//           ? double.tryParse(_priceController.text)
//           : null,
//       rentPrice: _selectedListingType == ListingType.rent
//           ? double.tryParse(_rentPriceController.text)
//           : null,
//       address: _addressController.text.trim(),
//       city: _districtController.text.trim(),
//       district: _districtController.text.trim(),
//       postcode: _postCodeController.text.trim(),
//       division: _divisionController.text.trim(),
//       subDistrict: _subdistrictController.text.trim(),
//       country: "Bangladesh",
//       latitude: null,
//       longitude: null,
//       bedrooms:
//           (_selectedPropertyType == PropertyType.house ||
//               _selectedPropertyType == PropertyType.apartment)
//           ? int.tryParse(_bedroomController.text)
//           : null,
//       bathrooms:
//           (_selectedPropertyType == PropertyType.house ||
//               _selectedPropertyType == PropertyType.apartment)
//           ? int.tryParse(_bathroomController.text)
//           : null,
//       balcony:
//           (_selectedPropertyType == PropertyType.house ||
//               _selectedPropertyType == PropertyType.apartment)
//           ? int.tryParse(_balconyController.text)
//           : null,
//       kitchen:
//           (_selectedPropertyType == PropertyType.house ||
//               _selectedPropertyType == PropertyType.apartment)
//           ? int.tryParse(_kitchenController.text)
//           : null,
//       yearBuilt: int.tryParse(_yearBuiltController.text),
//       squareFeet: double.tryParse(_squareFeetController.text) ?? 0,
//       imageUrls: _uploadUrls,
//       additionalDetails: {},
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(),
//       isDeleted: false,
//       propertyImg: [],
//     );

//     final result = await FirebaseProperties().propertyAdd(property);

//     setState(() => _isLoading = false);

//     if (result != null && result != "NotLogged") {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Property added! ID: $result")));
//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Failed to add property")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Add Property"),
//        // backgroundColor: Colors.teal,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Form(
//                 key: _formKey,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       // BASIC INFO
//                       _buildTextField(
//                         _titleController,
//                         "Title",
//                         Icons.title,
//                         true,
//                       ),

//                       _buildTextField(
//                         _descriptionController,
//                         "Description",
//                         Icons.description,
//                         true,
//                       ),
//                       _buildTextField(
//                         _addressController,
//                         "Address",
//                         Icons.location_on,
//                         true,
//                       ),
//                       _buildTextField(
//                         _districtController,
//                         "District",
//                         Icons.map,
//                         false,
//                       ),

//                       _buildTextField(
//                         _subdistrictController,
//                         "Subdistrict",
//                         Icons.location_city,
//                         false,
//                       ),
//                       _buildTextField(
//                         _postCodeController,
//                         "Post Code",
//                         Icons.code,
//                         false,
//                       ),
//                       _buildTextField(
//                         _divisionController,
//                         "Division",
//                         Icons.map,
//                         false,
//                       ),

//                       const SizedBox(height: 16),

//                       // PROPERTY TYPE
//                       DropdownButtonFormField<PropertyType>(
//                         decoration: const InputDecoration(
//                           labelText: "Property Type",
//                           border: OutlineInputBorder(),
//                         ),
//                         value: _selectedPropertyType,
//                         items: PropertyType.values
//                             .map(
//                               (e) => DropdownMenuItem(
//                                 value: e,
//                                 child: Text(e.name.toUpperCase()),
//                               ),
//                             )
//                             .toList(),
//                         onChanged: (val) =>
//                             setState(() => _selectedPropertyType = val),
//                         validator: (val) =>
//                             val == null ? "Select property type" : null,
//                       ),
//                       const SizedBox(height: 16),

//                       // LISTING TYPE
//                       DropdownButtonFormField<ListingType>(
//                         decoration: const InputDecoration(
//                           labelText: "Listing Type",
//                           border: OutlineInputBorder(),
//                         ),
//                         value: _selectedListingType,
//                         items: ListingType.values
//                             .where(
//                               (e) => e != ListingType.auction,
//                             ) // skip auction
//                             .map(
//                               (e) => DropdownMenuItem(
//                                 value: e,
//                                 child: Text(e.name.toUpperCase()),
//                               ),
//                             )
//                             .toList(),
//                         onChanged: (val) =>
//                             setState(() => _selectedListingType = val),
//                         validator: (val) =>
//                             val == null ? "Select listing type" : null,
//                       ),
//                       const SizedBox(height: 16),

//                       // PRICE or RENT PRICE
//                       if (_selectedListingType == ListingType.sale)
//                         _buildTextField(
//                           _priceController,
//                           "Sale Price (৳)",
//                           Icons.attach_money,
//                           true,
//                           number: true,
//                         ),
//                       if (_selectedListingType == ListingType.rent)
//                         _buildTextField(
//                           _rentPriceController,
//                           "Rent Price (৳/month)",
//                           Icons.money,
//                           true,
//                           number: true,
//                         ),

//                       const SizedBox(height: 16),

//                       // COMMON DETAILS
//                       _buildTextField(
//                         _squareFeetController,
//                         "Square Feet",
//                         Icons.square_foot,
//                         false,
//                         number: true,
//                       ),
//                       _buildTextField(
//                         _yearBuiltController,
//                         "Year Built",
//                         Icons.calendar_today,
//                         false,
//                         number: true,
//                       ),

//                       // CONDITIONAL DETAILS for HOUSE / APARTMENT
//                       if (_selectedPropertyType == PropertyType.house ||
//                           _selectedPropertyType == PropertyType.apartment) ...[
//                         _buildTextField(
//                           _bedroomController,
//                           "Bedrooms",
//                           Icons.bed,
//                           false,
//                           number: true,
//                         ),
//                         _buildTextField(
//                           _bathroomController,
//                           "Bathrooms",
//                           Icons.bathtub,
//                           false,
//                           number: true,
//                         ),
//                         _buildTextField(
//                           _balconyController,
//                           "Balconies",
//                           Icons.balcony,
//                           false,
//                           number: true,
//                         ),
//                         _buildTextField(
//                           _kitchenController,
//                           "Kitchens",
//                           Icons.kitchen,
//                           false,
//                           number: true,
//                         ),
//                       ],

//                       const SizedBox(height: 24),

//                       // Media picker button
//                       OutlinedButton.icon(
//                       onPressed: _pickMedia,
//                       icon: const Icon(Icons.upload_file),
//                       label: const Text("Select Images/Videos"),
//                     ),
//                     if (_filePickerResult != null && _filePickerResult!.files.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: _filePickerResult!.files.map((f) => Text(f.name)).toList(),
//                         ),
//                       ),

//                       // SUBMIT BUTTON
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           onPressed: _submitForm,
//                           icon: const Icon(Icons.save),
//                           label: const Text("Save Property"),
//                           style: ElevatedButton.styleFrom(
//                             //backgroundColor: Colors.teal,
//                             //foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }

//   // Reusable TextField builder
//   Widget _buildTextField(
//     TextEditingController controller,
//     String label,
//     IconData icon,
//     bool required, {
//     bool number = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(icon),
//           border: const OutlineInputBorder(),
//         ),
//         keyboardType: number ? TextInputType.number : TextInputType.text,
//         validator: required
//             ? (val) => val == null || val.isEmpty ? "Enter $label" : null
//             : null,
//       ),
//     );
//   }
// }

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:realestate/models/property.dart';
import 'package:realestate/services/firebase_cloudinary.dart';
import 'package:realestate/services/firebase_properties.dart';
import 'package:realestate/services/map_service.dart';

class PropertyAddToList extends StatefulWidget {
  const PropertyAddToList({super.key});

  @override
  State<PropertyAddToList> createState() => _PropertyAddToListState();
}

class _PropertyAddToListState extends State<PropertyAddToList> {
  final _formKey = GlobalKey<FormState>();
  double? _selectedLatitude;
  double? _selectedLongitude;

  FilePickerResult? _filePickerResult;
  List<String> _uploadUrls = [];
  bool isUploadingMedia = false;

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _rentPriceController = TextEditingController();
  final _squareFeetController = TextEditingController();
  final _bedroomController = TextEditingController();
  final _bathroomController = TextEditingController();
  final _balconyController = TextEditingController();
  final _kitchenController = TextEditingController();
  final _yearBuiltController = TextEditingController();
  final _districtController = TextEditingController();
  final _subdistrictController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _divisionController = TextEditingController();

  PropertyType? _selectedPropertyType;
  ListingType? _selectedListingType;
  bool _isLoading = false;

  Future<void> _pickLocation() async {
    final location = await LocationService.pickLocation(context);
    if (location != null) {
      setState(() {
        _selectedLatitude = location.latitude;
        _selectedLongitude = location.longitude;
      });
    }
  }

  // Pick files
  void _pickMedia() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
      type: FileType.custom,
    );
    if (result != null) setState(() => _filePickerResult = result);
  }

  // Upload
  Future<void> _uploadMedia() async {
    if (_filePickerResult == null) return;
    setState(() => isUploadingMedia = true);
    _uploadUrls.clear();

    for (var file in _filePickerResult!.files) {
      final single = FilePickerResult([file]);
      String? url = await uploadToCloudinary(single);
      if (url != null) _uploadUrls.add(url);
    }

    setState(() => isUploadingMedia = false);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPropertyType == null || _selectedListingType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select property & listing type")),
      );
      return;
    }

    setState(() => _isLoading = true);

    if (_filePickerResult != null && _filePickerResult!.files.isNotEmpty) {
      await _uploadMedia();
    }

    final property = PropertyModel(
      id: "",
      ownerId: "",
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      propertyType: _selectedPropertyType!,
      listingType: _selectedListingType!,
      status: PropertyStatus.pending,
      price: _selectedListingType == ListingType.sale
          ? double.tryParse(_priceController.text)
          : null,
      rentPrice: _selectedListingType == ListingType.rent
          ? double.tryParse(_rentPriceController.text)
          : null,
      address: _addressController.text.trim(),
      city: _districtController.text.trim(),
      district: _districtController.text.trim(),
      postcode: _postCodeController.text.trim(),
      division: _divisionController.text.trim(),
      subDistrict: _subdistrictController.text.trim(),
      country: "Bangladesh",
      latitude: _selectedLatitude,
      longitude: _selectedLongitude,
      bedrooms:
          (_selectedPropertyType == PropertyType.house ||
              _selectedPropertyType == PropertyType.apartment)
          ? int.tryParse(_bedroomController.text)
          : null,
      bathrooms:
          (_selectedPropertyType == PropertyType.house ||
              _selectedPropertyType == PropertyType.apartment)
          ? int.tryParse(_bathroomController.text)
          : null,
      balcony:
          (_selectedPropertyType == PropertyType.house ||
              _selectedPropertyType == PropertyType.apartment)
          ? int.tryParse(_balconyController.text)
          : null,
      kitchen:
          (_selectedPropertyType == PropertyType.house ||
              _selectedPropertyType == PropertyType.apartment)
          ? int.tryParse(_kitchenController.text)
          : null,
      yearBuilt: int.tryParse(_yearBuiltController.text),
      squareFeet: double.tryParse(_squareFeetController.text) ?? 0,
      imageUrls: _uploadUrls,
      additionalDetails: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDeleted: false,
      propertyImg: [],
    );

    final result = await FirebaseProperties().propertyAdd(property);

    setState(() => _isLoading = false);

    if (result != null && result != "NotLogged") {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Property added! ID: $result")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to add property")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Property")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text(
                              "Property Details",
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            _buildTextField(
                              _titleController,
                              "Title",
                              Icons.title,
                              true,
                            ),
                            _buildTextField(
                              _descriptionController,
                              "Description",
                              Icons.description,
                              true,
                            ),
                            _buildTextField(
                              _addressController,
                              "Address",
                              Icons.location_on,
                              true,
                            ),
                            _buildTextField(
                              _districtController,
                              "District",
                              Icons.map,
                              false,
                            ),
                            _buildTextField(
                              _subdistrictController,
                              "Subdistrict",
                              Icons.location_city,
                              false,
                            ),
                            _buildTextField(
                              _postCodeController,
                              "Post Code",
                              Icons.code,
                              false,
                            ),
                            _buildTextField(
                              _divisionController,
                              "Division",
                              Icons.map,
                              false,
                            ),

                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _pickLocation,
                              icon: const Icon(Icons.location_on),
                              label: Text(
                                _selectedLatitude != null &&
                                        _selectedLongitude != null
                                    ? "Location: ${_selectedLatitude!.toStringAsFixed(4)}, ${_selectedLongitude!.toStringAsFixed(4)}"
                                    : "Select Location on Map",
                              ),
                            ),
                            const SizedBox(height: 16),

                            DropdownButtonFormField<PropertyType>(
                              decoration: const InputDecoration(
                                labelText: "Property Type",
                                prefixIcon: Icon(Icons.home_work),
                              ),
                              value: _selectedPropertyType,
                              items: PropertyType.values
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.name.toUpperCase()),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedPropertyType = val),
                              validator: (val) =>
                                  val == null ? "Select property type" : null,
                            ),

                            const SizedBox(height: 16),

                            DropdownButtonFormField<ListingType>(
                              decoration: const InputDecoration(
                                labelText: "Listing Type",
                                prefixIcon: Icon(Icons.category),
                              ),
                              value: _selectedListingType,
                              items: ListingType.values
                                  .where(
                                    (e) => e != ListingType.auction,
                                  ) // skip auction
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e.name.toUpperCase()),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedListingType = val),
                              validator: (val) =>
                                  val == null ? "Select listing type" : null,
                            ),

                            const SizedBox(height: 16),

                            if (_selectedListingType == ListingType.sale)
                              _buildTextField(
                                _priceController,
                                "Sale Price (৳)",
                                Icons.attach_money,
                                true,
                                number: true,
                              ),
                            if (_selectedListingType == ListingType.rent)
                              _buildTextField(
                                _rentPriceController,
                                "Rent Price (৳/month)",
                                Icons.money,
                                true,
                                number: true,
                              ),

                            _buildTextField(
                              _squareFeetController,
                              "Square Feet",
                              Icons.square_foot,
                              false,
                              number: true,
                            ),
                            _buildTextField(
                              _yearBuiltController,
                              "Year Built",
                              Icons.calendar_today,
                              false,
                              number: true,
                            ),

                            if (_selectedPropertyType == PropertyType.house ||
                                _selectedPropertyType ==
                                    PropertyType.apartment) ...[
                              _buildTextField(
                                _bedroomController,
                                "Bedrooms",
                                Icons.bed,
                                false,
                                number: true,
                              ),
                              _buildTextField(
                                _bathroomController,
                                "Bathrooms",
                                Icons.bathtub,
                                false,
                                number: true,
                              ),
                              _buildTextField(
                                _balconyController,
                                "Balconies",
                                Icons.balcony,
                                false,
                                number: true,
                              ),
                              _buildTextField(
                                _kitchenController,
                                "Kitchens",
                                Icons.kitchen,
                                false,
                                number: true,
                              ),
                            ],

                            const SizedBox(height: 24),

                            OutlinedButton.icon(
                              onPressed: _pickMedia,
                              icon: const Icon(Icons.upload_file),
                              label: const Text("Select Images/Videos"),
                            ),
                            if (_filePickerResult != null &&
                                _filePickerResult!.files.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _filePickerResult!.files
                                      .map((f) => Text(f.name))
                                      .toList(),
                                ),
                              ),

                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: _submitForm,
                                icon: const Icon(Icons.save),
                                label: const Text("Save Property"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool required, {
    bool number = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        keyboardType: number ? TextInputType.number : TextInputType.text,
        validator: required
            ? (val) => val == null || val.isEmpty ? "Enter $label" : null
            : null,
      ),
    );
  }
}
