// upload_product_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product_dm.dart';
import '../provider/product_provider.dart';

class UploadProductScreen extends StatefulWidget {
  const UploadProductScreen({super.key});

  @override
  UploadProductScreenState createState() => UploadProductScreenState();
}

class UploadProductScreenState extends State<UploadProductScreen> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockQuantityController;
  late final TextEditingController _discountValueController;

  ProductCategory _selectedCategory = ProductCategory.electronics;
  DiscountType _selectedDiscountType = DiscountType.none;
  bool _isAvailable = true;
  late final Map<String, dynamic> _attributes;
  late final List<File> _selectedImages;

  late final ImagePicker _picker;

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _stockQuantityController = TextEditingController();
    _discountValueController = TextEditingController();
    _attributes = {};
    _selectedImages = List.empty(growable: true);
    _picker = ImagePicker();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockQuantityController.dispose();
    _discountValueController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    List<XFile>? pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages
            .addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _addAttribute() {
    showDialog(
      context: context,
      builder: (context) {
        String key = '';
        String value = '';

        return AlertDialog(
          title: const Text('Add Attribute'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Attribute Name'),
                onChanged: (val) => key = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Attribute Value'),
                onChanged: (val) => value = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (key.isNotEmpty && value.isNotEmpty) {
                  setState(() {
                    _attributes[key] = value;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeAttribute(String key) {
    setState(() {
      _attributes.remove(key);
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one image')),
        );
        return;
      }

      final ProductProvider productProvider =
          Provider.of<ProductProvider>(context, listen: false);

      final success = await productProvider.createProduct(
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        stockQuantity: int.parse(_stockQuantityController.text),
        discountType: _selectedDiscountType,
        discountValue: _selectedDiscountType != DiscountType.none
            ? double.parse(_discountValueController.text)
            : 0.0,
        category: _selectedCategory,
        images: _selectedImages,
        isAvailable: _isAvailable,
        attributes: _attributes,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product uploaded successfully')),
        );

        // Clear form
        _nameController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _stockQuantityController.clear();
        _discountValueController.clear();
        setState(() {
          _selectedCategory = ProductCategory.electronics;
          _selectedDiscountType = DiscountType.none;
          _isAvailable = true;
          _attributes = {};
          _selectedImages = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProductProvider productProvider =
        Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Product'),
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Images
                    const Text(
                      'Product Images',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: _selectedImages.isEmpty
                          ? Center(
                              child: TextButton.icon(
                                onPressed: _pickImages,
                                icon: const Icon(Icons.add_photo_alternate),
                                label: const Text('Add Images'),
                              ),
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _selectedImages.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index == _selectedImages.length) {
                                        return Container(
                                          width: 100,
                                          margin: const EdgeInsets.all(5),
                                          child: IconButton(
                                            onPressed: _pickImages,
                                            icon: const Icon(
                                                Icons.add_photo_alternate),
                                          ),
                                        );
                                      }

                                      return Stack(
                                        children: [
                                          Container(
                                            width: 100,
                                            margin: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: Image.file(
                                                _selectedImages[index],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: IconButton(
                                              icon: const Icon(Icons.close,
                                                  color: Colors.red),
                                              onPressed: () =>
                                                  _removeImage(index),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 20),

                    // Basic Information
                    const Text(
                      'Basic Information',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Category Dropdown
                    DropdownButtonFormField<ProductCategory>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedCategory,
                      items: ProductCategory.values.map((category) {
                        return DropdownMenuItem<ProductCategory>(
                          value: category,
                          child: Text(category.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Price Information
                    const Text(
                      'Price & Stock',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Price',
                              prefixText: '\$',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter price';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _stockQuantityController,
                            decoration: const InputDecoration(
                              labelText: 'Stock Quantity',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter stock quantity';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Discount
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<DiscountType>(
                            decoration: const InputDecoration(
                              labelText: 'Discount Type',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedDiscountType,
                            items: DiscountType.values.map((discountType) {
                              return DropdownMenuItem<DiscountType>(
                                value: discountType,
                                child: Text(
                                    discountType.toString().split('.').last),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedDiscountType = value;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _discountValueController,
                            decoration: InputDecoration(
                              labelText: 'Discount Value',
                              prefixText: _selectedDiscountType ==
                                      DiscountType.percentage
                                  ? ''
                                  : '\$',
                              suffixText: _selectedDiscountType ==
                                      DiscountType.percentage
                                  ? '%'
                                  : '',
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            enabled: _selectedDiscountType != DiscountType.none,
                            validator: (value) {
                              if (_selectedDiscountType != DiscountType.none) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter discount value';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Availability
                    SwitchListTile(
                      title: const Text('Available for Sale'),
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _isAvailable = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Attributes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Additional Attributes',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addAttribute,
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (_attributes.isNotEmpty)
                      Card(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _attributes.length,
                          itemBuilder: (context, index) {
                            String key = _attributes.keys.elementAt(index);
                            dynamic value = _attributes[key];

                            return ListTile(
                              title: Text(key),
                              subtitle: Text(value.toString()),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeAttribute(key),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 30),

                    if (productProvider.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          productProvider.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'Upload Product',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
