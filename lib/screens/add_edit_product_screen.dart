import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class AddEditProductScreen extends StatefulWidget {
  static const routeName = '/add-edit-products-screen';
  const AddEditProductScreen({super.key});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _addedProduct = Product(
    id: '',
    title: '',
    description: '',
    imageUrl: '',
    price: 0,
  );

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  var _isInit = true;
  var _isLoading = false;
  var _initValue = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        final productId = ModalRoute.of(context)!.settings.arguments as String;
        _addedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValue = {
          'title': _addedProduct.title,
          'description': _addedProduct.description,
          'price': _addedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _addedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    final bool? isValid = _formKey.currentState?.validate();
    if (!isValid!) {
      return;
    }
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    if (_addedProduct.id != '') {
      await Provider.of<Products>(context, listen: false)
          .updateExistingProduct(_addedProduct.id, _addedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_addedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('An error occurred!'),
            content: const Text('Something went wrong.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.pop(context);
      // }
    }
    setState(() {
      _isLoading = false;
    });
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save_alt_rounded),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValue['title'],
                      decoration: const InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) => _addedProduct = Product(
                        id: _addedProduct.id,
                        title: value.toString(),
                        description: _addedProduct.description,
                        imageUrl: _addedProduct.imageUrl,
                        price: _addedProduct.price,
                        isFav: _addedProduct.isFav,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value!';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValue['price'],
                      decoration: const InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) => _addedProduct = Product(
                        id: _addedProduct.id,
                        title: _addedProduct.title,
                        description: _addedProduct.description,
                        imageUrl: _addedProduct.imageUrl,
                        price: double.parse(value.toString()),
                        isFav: _addedProduct.isFav,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a price!';
                        }
                        if (double.tryParse(value) == null ||
                            double.tryParse(value)! <= 0) {
                          return 'Please enter a valid value!';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValue['description'],
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      textInputAction: TextInputAction.next,
                      focusNode: _descriptionFocusNode,
                      onSaved: (value) => _addedProduct = Product(
                        id: _addedProduct.id,
                        title: _addedProduct.title,
                        description: value.toString(),
                        imageUrl: _addedProduct.imageUrl,
                        price: _addedProduct.price,
                        isFav: _addedProduct.isFav,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value!';
                        }
                        if (value.length < 10) {
                          return 'Description should be at least 10 charcters';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty ||
                                  (!_imageUrlController.text
                                          .startsWith('http') &&
                                      !_imageUrlController.text
                                          .startsWith('https')) ||
                                  (!_imageUrlController.text.endsWith('.png') &&
                                      !_imageUrlController.text
                                          .endsWith('.jpg') &&
                                      !_imageUrlController.text
                                          .endsWith('.jpeg'))
                              ? const Text('Enter Image URL')
                              : FittedBox(
                                  fit: BoxFit.contain,
                                  child:
                                      Image.network(_imageUrlController.text),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            // initialValue: _initValue['imageUrl'],
                            decoration:
                                const InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: ((_) => _saveForm()),
                            onSaved: (value) => _addedProduct = Product(
                              id: _addedProduct.id,
                              title: _addedProduct.title,
                              description: _addedProduct.description,
                              imageUrl: value.toString(),
                              price: _addedProduct.price,
                              isFav: _addedProduct.isFav,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter an image URL.';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter a valid URL.';
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg')) {
                                return 'Please enter a valid image URL.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
