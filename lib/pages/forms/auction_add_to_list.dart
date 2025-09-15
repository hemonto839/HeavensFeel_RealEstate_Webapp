import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:realestate/models/property.dart';
import 'package:realestate/services/firebase_auction.dart';
import 'package:realestate/services/firebase_cloudinary.dart';
import 'package:realestate/services/firebase_properties.dart';
import 'package:realestate/services/map_service.dart';

class AuctionAddToList extends StatefulWidget {
  const AuctionAddToList({super.key});

  @override
  State<AuctionAddToList> createState() => _AuctionAddToListState();
}

class _AuctionAddToListState extends State<AuctionAddToList> {
  final _formKey = GlobalKey<FormState>();

  double? _selectedLatitude;
  double? _selectedLongitude;

  FilePickerResult? _filePickerResult;
  List<String> _uploadUrls = [];
  bool isUploadingMedia = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _squareFeetController = TextEditingController();
  final _bedroomController = TextEditingController();
  final _bathroomController = TextEditingController();
  final _balconyController = TextEditingController();
  final _kitchenController = TextEditingController();
  final _yearBuiltController = TextEditingController();
  //final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _subdistrictController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _divisionController = TextEditingController();

  // auction time remain
  int? _selectedDays;

  PropertyType? _selectedPropertyType;
  // final String _listingType = "Auction";
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

  // Pick media files
  Future<void> _pickMedia() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
        type: FileType.custom,
      );
      if (result != null && mounted) {
        setState(() => _filePickerResult = result);
      }
    } catch (e, st) {
      debugPrint("Error picking media: $e\n$st");
    }
  }

  // Upload media to Cloudinary
  Future<void> _uploadMedia() async {
    if (_filePickerResult == null || _filePickerResult!.files.isEmpty) return;

    setState(() => isUploadingMedia = true);
    _uploadUrls.clear();

    try {
      for (var file in _filePickerResult!.files) {
        final signleResult = FilePickerResult([file]);

        String? url = await uploadToCloudinary(signleResult);
        if (url != null) _uploadUrls.add(url);
      }
    } catch (e, st) {
      debugPrint("Upload error: $e\n$st");
    } finally {
      if (mounted) {
        setState(() => isUploadingMedia = false);
      }
    }
  }

  // Save property
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPropertyType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select property type")),
      );
      return;
    }

    setState(() => _isLoading = true);

    if (_filePickerResult != null && _filePickerResult!.files.isNotEmpty) {
      await _uploadMedia();
    }

    final int auctionFinish = _selectedDays ?? 1;

    final property = PropertyModel(
      id: "",
      ownerId: "",
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      propertyType: _selectedPropertyType!,
      listingType: ListingType.auction,
      status: PropertyStatus.pending,
      price: double.tryParse(_priceController.text) ?? 0,
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
      updatedAt: DateTime.now().add(Duration(days: auctionFinish)),
      isDeleted: false,
      propertyImg: [],
    );

    try {
      final result = await FirebaseProperties().propertyAdd(property);
      if (mounted) {
        setState(() => _isLoading = false);
        if (result != null && result != "NotLogged") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Property added! ID: $result")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to add property")),
          );
        }
      }

      await AuctionService().createAuction(
        propertyId: result.toString(),
        startingBid: double.tryParse(_priceController.text)?.toInt() ?? 0,
        duration: Duration(days: auctionFinish),
      );
    } catch (e, st) {
      debugPrint("Submit error: $e\n$st");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error during submission")),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _squareFeetController.dispose();
    _bedroomController.dispose();
    _bathroomController.dispose();
    _balconyController.dispose();
    _kitchenController.dispose();
    _yearBuiltController.dispose();
    //    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Property for Auction")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 600,
                  ), // keep form centered
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
                              "Auction Property Details",
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Listing Type
                            TextFormField(
                              initialValue: "Auction",
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: "Listing Type",
                                prefixIcon: Icon(Icons.gavel),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Common fields with helper function
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

                            _buildTextField(
                              _priceController,
                              "Initial Bid Price (৳)",
                              Icons.attach_money,
                              true,
                              number: true,
                            ),

                            const SizedBox(height: 16),

                            DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: "Auction Duration (Days)",
                                prefixIcon: Icon(Icons.timelapse),
                              ),
                              value: _selectedDays,
                              items: List.generate(
                                7,
                                (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text(
                                    "${i + 1} ${i == 0 ? "Day" : "Days"}",
                                  ),
                                ),
                              ),
                              onChanged: (val) =>
                                  setState(() => _selectedDays = val),
                              validator: (val) =>
                                  val == null ? "Select duration" : null,
                            ),

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
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        readOnly: readOnly,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        validator: required
            ? (value) => (value == null || value.isEmpty)
                  ? "Please enter $label"
                  : null
            : null,
      ),
    );
  }
}
