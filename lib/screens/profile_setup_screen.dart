import 'dart:io';
import 'package:flutter/material.dart';
import 'package:people_discovery_app/models/user_model.dart';
import 'package:people_discovery_app/models/portfolio_model.dart';
import 'package:people_discovery_app/services/firestore_service.dart';
import 'package:people_discovery_app/services/storage_service.dart';

/// Profile setup screen for new users
///
/// This screen guides users through creating their profile after authentication.
/// It collects all required and optional information as per PRD section 2.1.2
class ProfileSetupScreen extends StatefulWidget {
  final String userId;
  final String phoneNumber;

  const ProfileSetupScreen({
    super.key,
    required this.userId,
    required this.phoneNumber,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final ImagePickerHelper _imagePicker = ImagePickerHelper();

  int _currentStep = 0;
  bool _isLoading = false;

  // Form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _behanceController = TextEditingController();
  final TextEditingController _dribbbleController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _yearsOfExperienceController =
      TextEditingController();

  File? _profilePhoto;
  String? _selectedProfession;
  String? _selectedCity;
  String? _selectedState;
  String? _selectedCountry = 'India'; // Default
  String? _selectedGender;

  // Portfolio items
  final List<PortfolioItemData> _portfolioItems = [];

  // Predefined professions list
  final List<String> _professions = [
    'Website Designer',
    'Video Editor',
    'Graphic Designer',
    'Photographer',
    'Content Writer',
    'Social Media Manager',
    'UI/UX Designer',
    'Frontend Developer',
    'Backend Developer',
    'Full Stack Developer',
    'Marketing Specialist',
    'Business Consultant',
  ];

  // Predefined cities (can be expanded)
  final List<String> _cities = [
    'Bangalore',
    'Mumbai',
    'Delhi',
    'Hyderabad',
    'Chennai',
    'Pune',
    'Kolkata',
    'Ahmedabad',
    'Jaipur',
    'Surat',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    _behanceController.dispose();
    _dribbbleController.dispose();
    _githubController.dispose();
    _yearsOfExperienceController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      // Validate step 1
      if (_formKey.currentState?.validate() ?? false) {
        if (_profilePhoto == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please upload a profile photo'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (_selectedProfession == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a profession'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (_selectedCity == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a city'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      } else {
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _pickProfilePhoto() async {
    final image = await _imagePicker.pickImage(context);
    if (image != null) {
      setState(() {
        _profilePhoto = image;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload profile photo
      String? profilePhotoUrl;
      if (_profilePhoto != null) {
        profilePhotoUrl = await _storageService.uploadProfilePhoto(
          userId: widget.userId,
          imageFile: _profilePhoto!,
        );
        if (profilePhotoUrl == null) {
          throw Exception('Failed to upload profile photo');
        }
      }

      // Create user model
      final user = UserModel(
        userId: widget.userId,
        phoneNumber: widget.phoneNumber,
        displayName: _nameController.text.trim(),
        profilePhotoUrl: profilePhotoUrl,
        profession: _selectedProfession!,
        location: UserLocation(
          city: _selectedCity!,
          state: _selectedState,
          country: _selectedCountry ?? 'India',
        ),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        website: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        socialLinks: SocialLinks(
          instagram: _instagramController.text.trim().isEmpty
              ? null
              : _instagramController.text.trim(),
          linkedin: _linkedinController.text.trim().isEmpty
              ? null
              : _linkedinController.text.trim(),
          twitter: _twitterController.text.trim().isEmpty
              ? null
              : _twitterController.text.trim(),
          behance: _behanceController.text.trim().isEmpty
              ? null
              : _behanceController.text.trim(),
          dribbble: _dribbbleController.text.trim().isEmpty
              ? null
              : _dribbbleController.text.trim(),
          github: _githubController.text.trim().isEmpty
              ? null
              : _githubController.text.trim(),
        ),
        projectCount: _portfolioItems.length,
        yearsOfExperience: _yearsOfExperienceController.text.trim().isEmpty
            ? null
            : int.tryParse(_yearsOfExperienceController.text.trim()),
        gender: _selectedGender,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save user profile
      final success = await _firestoreService.createOrUpdateUserProfile(user);
      if (!success) {
        throw Exception('Failed to save profile');
      }

      // Save portfolio items
      for (var item in _portfolioItems) {
        if (item.imageFile != null && item.imageUrl == null) {
          // Upload image first
          final imageUrl = await _storageService.uploadPortfolioImage(
            userId: widget.userId,
            portfolioId: item.portfolioId,
            imageFile: item.imageFile!,
          );
          if (imageUrl != null) {
            item.imageUrl = imageUrl;
          }
        }

        final portfolioItem = PortfolioItem(
          portfolioId: item.portfolioId,
          userId: widget.userId,
          imageUrl: item.imageUrl ?? '',
          title: item.title,
          description: item.description,
          projectUrl: item.projectUrl,
          tags: item.tags,
          createdAt: DateTime.now(),
          order: item.order,
        );

        await _firestoreService.addPortfolioItem(portfolioItem);
      }

      // Profile saved successfully
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setup Profile (${_currentStep + 1}/3)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [_buildStep1(), _buildStep2(), _buildStep3()],
              ),
            ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tell us about yourself',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          // Profile Photo
          Center(
            child: GestureDetector(
              onTap: _pickProfilePhoto,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profilePhoto != null
                        ? FileImage(_profilePhoto!)
                        : null,
                    child: _profilePhoto == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Full Name
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Profession
          DropdownButtonFormField<String>(
            value: _selectedProfession,
            decoration: const InputDecoration(
              labelText: 'Profession *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.work),
            ),
            items: _professions.map((profession) {
              return DropdownMenuItem(
                value: profession,
                child: Text(profession),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProfession = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a profession';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // City
          DropdownButtonFormField<String>(
            value: _selectedCity,
            decoration: const InputDecoration(
              labelText: 'City *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_city),
            ),
            items: _cities.map((city) {
              return DropdownMenuItem(value: city, child: Text(city));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a city';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Years of Experience (Optional)
          TextFormField(
            controller: _yearsOfExperienceController,
            decoration: const InputDecoration(
              labelText: 'Years of Experience (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          // Gender (Optional)
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(
              labelText: 'Gender (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
              DropdownMenuItem(
                value: 'prefer_not_to_say',
                child: Text('Prefer not to say'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'About & Links',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share more about yourself',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          // Bio
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: 'Bio / Description',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
              hintText: 'Tell us about yourself...',
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          // Website
          TextFormField(
            controller: _websiteController,
            decoration: const InputDecoration(
              labelText: 'Website URL (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.language),
              hintText: 'https://yourwebsite.com',
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 24),
          const Text(
            'Social Media Links (Optional)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Instagram
          TextFormField(
            controller: _instagramController,
            decoration: const InputDecoration(
              labelText: 'Instagram',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.camera_alt),
              hintText: '@username',
            ),
          ),
          const SizedBox(height: 16),
          // LinkedIn
          TextFormField(
            controller: _linkedinController,
            decoration: const InputDecoration(
              labelText: 'LinkedIn',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
              hintText: 'linkedin.com/in/username',
            ),
          ),
          const SizedBox(height: 16),
          // Twitter
          TextFormField(
            controller: _twitterController,
            decoration: const InputDecoration(
              labelText: 'Twitter / X',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.chat_bubble_outline),
              hintText: '@username',
            ),
          ),
          const SizedBox(height: 16),
          // Behance
          TextFormField(
            controller: _behanceController,
            decoration: const InputDecoration(
              labelText: 'Behance',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.palette),
              hintText: 'behance.net/username',
            ),
          ),
          const SizedBox(height: 16),
          // Dribbble
          TextFormField(
            controller: _dribbbleController,
            decoration: const InputDecoration(
              labelText: 'Dribbble',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.sports_basketball),
              hintText: 'dribbble.com/username',
            ),
          ),
          const SizedBox(height: 16),
          // GitHub
          TextFormField(
            controller: _githubController,
            decoration: const InputDecoration(
              labelText: 'GitHub',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.code),
              hintText: 'github.com/username',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Portfolio (Optional)',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your work samples',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _addPortfolioItem,
            icon: const Icon(Icons.add),
            label: const Text('Add Portfolio Item'),
          ),
          const SizedBox(height: 24),
          if (_portfolioItems.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'No portfolio items added yet.\nYou can add them later from your profile.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ..._portfolioItems.map((item) => _buildPortfolioItemCard(item)),
        ],
      ),
    );
  }

  Widget _buildPortfolioItemCard(PortfolioItemData item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: item.imageFile != null
            ? Image.file(
                item.imageFile!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.image, size: 60),
        title: Text(item.title),
        subtitle: item.description != null
            ? Text(
                item.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() {
              _portfolioItems.remove(item);
            });
          },
        ),
      ),
    );
  }

  void _addPortfolioItem() async {
    final image = await _imagePicker.pickImage(context);
    if (image == null) return;

    final title = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Portfolio Item Title'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter project title'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (title != null && title.isNotEmpty) {
      setState(() {
        _portfolioItems.add(
          PortfolioItemData(
            portfolioId: DateTime.now().millisecondsSinceEpoch.toString(),
            imageFile: image,
            title: title,
            order: _portfolioItems.length,
          ),
        );
      });
    }
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton(onPressed: _previousStep, child: const Text('Previous'))
          else
            const SizedBox(),
          ElevatedButton(
            onPressed: _isLoading ? null : _nextStep,
            child: Text(_currentStep == 2 ? 'Save Profile' : 'Next'),
          ),
        ],
      ),
    );
  }
}

/// Temporary data class for portfolio items during setup
class PortfolioItemData {
  final String portfolioId;
  final File? imageFile;
  String? imageUrl;
  String title;
  String? description;
  String? projectUrl;
  List<String> tags;
  int order;

  PortfolioItemData({
    required this.portfolioId,
    this.imageFile,
    this.imageUrl,
    required this.title,
    this.description,
    this.projectUrl,
    this.tags = const [],
    required this.order,
  });
}
