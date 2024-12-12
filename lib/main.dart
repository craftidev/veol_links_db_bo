import 'package:flutter/material.dart';
import 'models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Links Back Office',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BackOffice(),
    );
  }
}

class BackOffice extends StatefulWidget {
  const BackOffice({Key? key}) : super(key: key);

  @override
  _BackOfficeState createState() => _BackOfficeState();
}

class _BackOfficeState extends State<BackOffice> {
  // Sample data
  List<Category> categories = [
    Category(
      name: 'Base Juridique',
      subCategories: [
        Category(
          name: 'En France',
          links: [Link(name: 'Solaire', url: '#'), Link(name: 'Eolien', url: '#')],
        ),
        Category(
          name: 'A l\'international',
          links: [Link(name: 'Chroniques DJE n°1', url: '#')],
        ),
      ],
    ),
    Category(
      name: 'Photos',
      links: [Link(name: 'Visite site collégiens Varaize', url: '#')],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Links Back Office'),
      ),
      body: ListView(
        children: categories.map((category) => buildCategory(category)).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCategoryForm();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildCategory(Category category) {
    return ExpansionTile(
      title: Text(category.name),
      children: [
        ...category.subCategories.map((sub) => buildCategory(sub)).toList(),
        ...category.links.map((link) => ListTile(
              title: Text(link.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showLinkForm(link, category);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        category.links.remove(link);
                      });
                    },
                  ),
                ],
              ),
            )),
        ListTile(
          title: const Text('+ Add Link'),
          onTap: () {
            _showLinkForm(null, category);
          },
        ),
      ],
    );
  }

  void _showLinkForm(Link? link, Category category) {
    final _formKey = GlobalKey<FormState>();
    String name = link?.name ?? '';
    String url = link?.url ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(link == null ? 'Add Link' : 'Edit Link'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  onSaved: (value) => name = value!,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Name is required' : null,
                ),
                TextFormField(
                  initialValue: url,
                  decoration: const InputDecoration(labelText: 'URL'),
                  onSaved: (value) => url = value!,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'URL is required' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  setState(() {
                    if (link == null) {
                      category.links.add(Link(name: name, url: url));
                    } else {
                      link.name = name;
                      link.url = url;
                    }
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showCategoryForm() {
    final _formKey = GlobalKey<FormState>();
    String name = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              decoration: const InputDecoration(labelText: 'Name'),
              onSaved: (value) => name = value!,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Name is required' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  setState(() {
                    categories.add(Category(name: name));
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
