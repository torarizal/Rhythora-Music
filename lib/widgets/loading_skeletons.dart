import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart' as shimmer;
import 'package:carousel_slider/carousel_slider.dart';

// Colors copied from home_screen.dart for consistency
const Color kCardHoverColor = Color(0xFF27272A);
const Color kBorderColor = Color(0xFF3F3F46);

class PlaylistSidebarSkeleton extends StatelessWidget {
  const PlaylistSidebarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return shimmer.Shimmer.fromColors(
      baseColor: kCardHoverColor,
      highlightColor: kBorderColor,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: 8, // The number of skeleton items
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              height: 16,
              width: double.infinity,
              color: Colors.black,
            ),
          );
        },
      ),
    );
  }
}

class HomeLoadingSkeleton extends StatelessWidget {
  const HomeLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          shimmer.Shimmer.fromColors(
            baseColor: kCardHoverColor,
            highlightColor: kBorderColor,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: CarouselSlider.builder(
                options: CarouselOptions(
                  height: 250.0,
                  enlargeCenterPage: true,
                  viewportFraction: 0.8,
                ),
                itemCount: 3,
                itemBuilder: (context, itemIndex, pageViewIndex) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                shimmer.Shimmer.fromColors(
                  baseColor: kCardHoverColor,
                  highlightColor: kBorderColor,
                  child: Container(
                    height: 28,
                    width: 150,
                    color: Colors.black,
                    margin: const EdgeInsets.only(bottom: 20),
                  ),
                ),
                shimmer.Shimmer.fromColors(
                  baseColor: kCardHoverColor,
                  highlightColor: kBorderColor,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5, // Show 5 skeleton items
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Container(width: 40, height: 40, color: Colors.black),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(height: 16, width: double.infinity, color: Colors.black),
                                  const SizedBox(height: 4),
                                  Container(height: 14, width: 100, color: Colors.black),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LibraryLoadingSkeleton extends StatelessWidget {
  const LibraryLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220.0,
        mainAxisSpacing: 24.0,
        crossAxisSpacing: 24.0,
        childAspectRatio: 0.8,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return shimmer.Shimmer.fromColors(
            baseColor: kCardHoverColor,
            highlightColor: kBorderColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(height: 16, width: 150, color: Colors.black),
                const SizedBox(height: 4),
                Container(height: 14, width: 100, color: Colors.black),
              ],
            ),
          );
        },
        childCount: 8,
      ),
    );
  }
}
