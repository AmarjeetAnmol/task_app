// lib/home_screen.dart

import 'package:flutter/material.dart';
import 'package:task_app/test_model.dart';

import 'api_services.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Hit> _images = [];
  final ScrollController _scrollController = ScrollController();
  final ApiServices _apiServices = ApiServices();
  int _pageNumber = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true; // To track if more images are available

  @override
  void initState() {
    super.initState();
    _fetchImages();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchImages() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final fetchedImages = await _apiServices.fetchImages(page: _pageNumber);

    if (fetchedImages != null && fetchedImages.hits != null) {
      setState(() {
        if (fetchedImages.hits!.isEmpty) {
          _hasMore = false; // No more images to load
        } else {
          _pageNumber++;
          _images.addAll(fetchedImages.hits!);
        }
        _isLoadingMore = false;
      });
    } else {
      setState(() {
        _isLoadingMore = false;
      });
      // Optionally, handle error or show a message
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _fetchImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive grid
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900
        ? 4
        : screenWidth > 600
        ? 3
        : 2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text('Pixabay Images',style: TextStyle(color: Colors.white),),
      ),
      body: _images.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          // Refresh the list
          setState(() {
            _images.clear();
            _pageNumber = 1;
            _hasMore = true;
          });
          await _fetchImages();
        },
        child: GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.7, // Adjust as needed
          ),
          itemCount: _images.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _images.length) {
              // Display loading indicator at the end
              return const Center(child: CircularProgressIndicator());
            }

            final image = _images[index];

            return Card(
              elevation: 4.0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(6.0), // Rounded corners for all sides
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6.0),
                        topRight: Radius.circular(6.0),
                      ),
                      child: image.previewUrl != null
                          ? Image.network(
                        image.previewUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                          : const Center(
                        child: Text('No Image Available'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(6.0),
                        bottomRight: Radius.circular(6.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            image.user ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.favorite,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${image.likes}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.remove_red_eye,
                                    size: 18,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${image.views}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
            ;

          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}