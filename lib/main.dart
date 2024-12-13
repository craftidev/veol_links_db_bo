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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "addCategory",
            onPressed: () {
              _showCategoryForm();
            },
            tooltip: 'Add Category',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "generateHtml",
            onPressed: () {
              Null;
            },
            tooltip: 'Generate HTML',
            child: const Icon(Icons.code),
          ),
        ]
      ),
    );
  }

  Color _getBackgroundColor(int depth) {
    return Colors.blue[(100 * (depth % 9 + 1))]!;
  }

  Widget buildLink(Link link, Category category) {
    return DragTarget<Link>(
      onAccept: (draggedLink) {
        setState(() {
          // Remove the dragged link from its original category
          for (var cat in categories) {
            if (cat.links.remove(draggedLink)) break;
            for (var sub in cat.subCategories) {
              if (sub.links.remove(draggedLink)) break;
            }
          }
          // Add the dragged link to this category
          category.links.add(draggedLink);
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Draggable<Link>(
          data: link,
          feedback: Material(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.green.withOpacity(0.8),
              child: Text(link.name, style: const TextStyle(color: Colors.white)),
            ),
          ),
          childWhenDragging: Container(
            color: Colors.grey.withOpacity(0.2),
            child: Text(link.name, style: const TextStyle(color: Colors.grey)),
          ),
          child: ListTile(
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
          ),
        );
      },
    );
  }

  Widget buildCategory(Category category, {int depth = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0),
      child: DragTarget<Category>(
        onAccept: (draggedCategory) {
          setState(() {
            // Remove the dragged category from its original parent
            categories.remove(draggedCategory);
            for (var cat in categories) {
              cat.subCategories.remove(draggedCategory);
            }
            // Add the dragged category to this one
            category.subCategories.add(draggedCategory);
          });
        },
        builder: (context, candidateData, rejectedData) {
          return ExpansionTile(
            title: Draggable<Category>(
              data: category,
              feedback: Material(
                child: Container(
                  color: Colors.blue.withOpacity(0.8),
                  padding: const EdgeInsets.all(8.0),
                  child: Text(category.name, style: const TextStyle(color: Colors.white)),
                ),
              ),
              childWhenDragging: Container(
                color: Colors.grey.withOpacity(0.2),
                child: Text(category.name, style: const TextStyle(color: Colors.grey)),
              ),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                color: _getBackgroundColor(depth),
                child: Text(category.name),
              ),
            ),
            children: [
              ...category.subCategories.map((sub) => buildCategory(sub, depth: depth + 1)).toList(),
              ...category.links.map((link) => buildLink(link, category)).toList(),
              ListTile(
                title: const Text('+ Add Link'),
                onTap: () {
                  _showLinkForm(null, category);
                },
              ),
            ],
          );
        },
      ),
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
