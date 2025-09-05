import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../utils/get_products.dart';

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  String _search = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final filteredCategories = categoriesData
        .where((cat) => cat.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    final products = _selectedCategory != null
        ? productsData.where((p) => p['category'] == _selectedCategory).toList()
        : <dynamic>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue'),
        leading: _selectedCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                  });
                },
              )
            : null,
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher une catégorie',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _search = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _selectedCategory == null
                  ? (filteredCategories.isEmpty
                      ? const Center(child: Text('Aucune catégorie trouvée'))
                      : ListView.builder(
                          itemCount: filteredCategories.length,
                          itemBuilder: (context, index) {
                            final cat = filteredCategories[index];
                            return Card(
                              child: ListTile(
                                title: Text(cat),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = cat;
                                  });
                                },
                              ),
                            );
                          },
                        ))
                  : (products.isEmpty
                      ? const Center(
                          child: Text('Aucun produit dans cette catégorie'))
                      : SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: products.map<Widget>((product) {
                                return SizedBox(
                                  width: 140,
                                  child: Card(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/product/${product['id']}',
                                                arguments: product,
                                              );
                                            },
                                            child: product['image'] != null
                                                ? Image.network(
                                                    product['image'],
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                  )
                                                : const SizedBox(height: 80),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        )),
            ),
          ],
        ),
      ),
    );
  }
}
