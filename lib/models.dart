class Link {
  String name;
  String url;

  Link({required this.name, required this.url});
}

class Category {
  String name;
  bool isExpanded;
  List<Category> subCategories;
  List<Link> links;

  Category({
    required this.name,
    this.isExpanded = false,
    this.subCategories = const [],
    this.links = const [],
  });
}
