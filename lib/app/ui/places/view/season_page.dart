import 'package:bangla_utilities/bangla_date.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bangla_utilities/bangla_utilities.dart';
import 'package:choy_ritur_golpo/translation/bn_in.dart';
import 'package:url_launcher/url_launcher.dart';

// New data models for scalable season content
class SeasonSection {
  final String title;
  final String description;
  final String image;
  
  SeasonSection({
    required this.title,
    required this.description,
    required this.image,
  });
}

class Season {
  final int id;
  final String name;
  final List<SeasonSection> sections;
  
  Season({
    required this.id,
    required this.name,
    required this.sections,
  });
}

class SeasonPage extends StatefulWidget {
  const SeasonPage({super.key});

  @override
  State<SeasonPage> createState() => _SeasonPageState();
}

class _SeasonPageState extends State<SeasonPage> {
  late String banglaDate;
  late String banglaMonth;
  late String currentSeason;
  late String banglaYear;
  late String bar;

  @override
  void initState() {
    super.initState();
    _calculateBanglaDateAndSeason();
  }

  void _calculateBanglaDateAndSeason() {
    final now = DateTime.now();
    
    // Get current Bangla date, month, and season using the library
    bar = BanglaUtility.getBanglaWeekday(day: now.day, month: now.month, year: now.year);
    banglaDate = BanglaUtility.getBanglaDay(day: now.day, month: now.month, year: now.year);
    banglaYear = BanglaUtility.getBanglaYear(day: now.day, month: now.month, year: now.year);
    banglaMonth = BanglaUtility.getBanglaMonthName(day: now.day, month: now.month, year: now.year);
    currentSeason = BanglaUtility.getBanglaSeason(day: now.day, month: now.month, year: now.year);
    
    // Debug print to verify the conversion
    print('Gregorian Date: ${now.day}/${now.month}/${now.year}');
    print('Bangla Date: $banglaDate');
    print('Bangla Month: $banglaMonth');
    print('Current Season: $currentSeason');
    print('Current বার: $bar');
  }

  // Get ordered seasons with current season first
  List<Season> getOrderedSeasons() {
    // Create seasons with backward compatibility - each season starts with one section
    final seasons = [
      Season(
        id: 1,
        name: 'season_1_name'.tr,
        sections: [
          SeasonSection(
            title: 'season_1_name'.tr,
            description: 'season_1_description'.tr,
            image: 'assets/seasons/1.png',
          ),
        ],
      ),
      Season(
        id: 2,
        name: 'season_2_name'.tr,
        sections: [
          SeasonSection(
            title: 'season_2_name'.tr,
            description: 'season_2_description'.tr,
            image: 'assets/seasons/2.png',
          ),
          SeasonSection(
            title: 'বর্ষার নৌকাবাইচ'.tr,
            description: 'season_2_nouka_baich'.tr,
            image: 'assets/seasons/2_nouka_baich.png',
          ),
          SeasonSection(
            title: 'বর্ষার মাঠে খেলার ডাক'.tr,
            description: 'season_2_football'.tr,
            image: 'assets/seasons/2_football.png',
          ),
        ],
      ),
      Season(
        id: 3,
        name: 'season_3_name'.tr,
        sections: [
          SeasonSection(
            title: 'season_3_name'.tr,
            description: 'season_3_description'.tr,
            image: 'assets/seasons/3.png',
          ),
        ],
      ),
      Season(
        id: 4,
        name: 'season_4_name'.tr,
        sections: [
          SeasonSection(
            title: 'season_4_name'.tr,
            description: 'season_4_description'.tr,
            image: 'assets/seasons/4.png',
          ),
        ],
      ),
      Season(
        id: 5,
        name: 'season_5_name'.tr,
        sections: [
          SeasonSection(
            title: 'season_5_name'.tr,
            description: 'season_5_description'.tr,
            image: 'assets/seasons/5.png',
          ),
        ],
      ),
      Season(
        id: 6,
        name: 'season_6_name'.tr,
        sections: [
          SeasonSection(
            title: 'season_6_name'.tr,
            description: 'season_6_description'.tr,
            image: 'assets/seasons/6.png',
          ),
        ],
      ),
    ];

    // Debug print all seasons
    print('All seasons:');
    for (int i = 0; i < seasons.length; i++) {
      print('${i + 1}. ${seasons[i].name} - ${seasons[i].sections.length} sections');
    }
    print('Current season from library: $currentSeason');

    // Map library season names to our translation names
    final seasonMapping = {
      'গ্রীষ্ম': 'season_1_name'.tr,
      'বর্ষা': 'season_2_name'.tr,
      'শরৎ': 'season_3_name'.tr,
      'হেমন্ত': 'season_4_name'.tr,
      'শীত': 'season_5_name'.tr,
      'বসন্ত': 'season_6_name'.tr,
    };

    // Find current season index using the mapping
    String mappedCurrentSeason = seasonMapping[currentSeason] ?? currentSeason;
    print('Mapped current season: $mappedCurrentSeason');
    
    int currentIndex = seasons.indexWhere((season) => season.name == mappedCurrentSeason);
    print('Current season index: $currentIndex');
    
    if (currentIndex == -1) {
      // If current season not found, return original order
      print('Current season not found, returning original order');
      return seasons;
    }

    // Reorder: current season first, then others in chronological order
    List<Season> orderedSeasons = [];
    
    // Add current season first
    orderedSeasons.add(seasons[currentIndex]);
    
    // Add remaining seasons in chronological order (starting from next season)
    for (int i = 1; i < seasons.length; i++) {
      int nextIndex = (currentIndex + i) % seasons.length;
      orderedSeasons.add(seasons[nextIndex]);
    }
    
    print('Ordered seasons count: ${orderedSeasons.length}');
    for (int i = 0; i < orderedSeasons.length; i++) {
      print('${i + 1}. ${orderedSeasons[i].name}');
    }
    
    return orderedSeasons;
  }

  @override
  Widget build(BuildContext context) {
    final orderedSeasons = getOrderedSeasons();
    
    return Scaffold(
      body: AnimatedScrollIndicator(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              // Bangla Date and Season Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'আজ $bar, $banglaDate $banglaMonth, $banglaYear',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'এখন চলছে $currentSeason-কাল',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Seasons List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orderedSeasons.length,
                itemBuilder: (context, index) {
                  final season = orderedSeasons[index];
                  
                  // Map library season names to our translation names
                  final seasonMapping = {
                    'গ্রীষ্ম': 'season_1_name'.tr,
                    'বর্ষা': 'season_2_name'.tr,
                    'শরৎ': 'season_3_name'.tr,
                    'হেমন্ত': 'season_4_name'.tr,
                    'শীত': 'season_5_name'.tr,
                    'বসন্ত': 'season_6_name'.tr,
                  };
                  String mappedCurrentSeason = seasonMapping[currentSeason] ?? currentSeason;
                  final isCurrentSeason = season.name == mappedCurrentSeason;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SeasonCard(
                        season: season,
                        isCurrentSeason: isCurrentSeason,
                      ),
                      if (isCurrentSeason && index < orderedSeasons.length - 1)
                        Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 16),
                          child: Text(
                            'এরপর কি আসছে',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              // Developer Info and Credits Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'অ্যাপ সম্পর্কে',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Developer Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          radius: 30,
                          child: Icon(
                            Icons.person,
                            size: 32,
                            color: Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Md Moniruzzaman',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'সিনিয়র সফটওয়্যার ইঞ্জিনিয়ার এবং শাহজালাল বিজ্ঞান ও প্রযুক্তি বিশ্ববিদ্যালয়, সিলেট-এর কম্পিউটার সায়েন্স বিভাগের গ্র্যাজুয়েট।',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // App Description
                    Text(
                      'মূল উদ্দেশ্য',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'প্রতিটি বাঙালির কাছে আবহাওয়ার তথ্যকে সহজ ও ব্যবহারযোগ্যভাবে পৌঁছে দেওয়া। বিশেষভাবে বাংলাদেশের গ্রামীণ মানুষের প্রযুক্তিগত সীমাবদ্ধতা মাথায় রেখে, হালকা ও ব্যবহারবান্ধবভাবে ডিজাইন করা হয়েছে। ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'অ্যাপের একটি বিশেষ অংশ "ঋতু" — যেখানে বাংলার হারিয়ে যাওয়া সংস্কৃতি, উৎসব ও প্রকৃতি নিয়ে সংক্ষিপ্তভাবে তুলে ধরা হয়েছে। ভবিষ্যতের আপডেটে আরও সমৃদ্ধ ও বিস্তারিত উপস্থাপনা যুক্ত করা হবে।',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Credits Section
                    Text(
                      '🙏 কৃতজ্ঞতা',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Credits List
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'বিশেষ ধন্যবাদ জানাই তাদের, যারা ঝুঁকিপূর্ণ মানুষের জন্য আবহাওয়া ও দুর্যোগ সতর্কতা নিয়ে ইন্টারভিওয়ে অংশ নিয়েছেন।',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCreditItem(
                          icon: Icons.cloud,
                          title: 'আবহাওয়ার তথ্য উৎস',
                          description: 'Open-Meteo (CC BY 4.0) and others',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Dedication
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.green.shade800,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '🎁 উৎসর্গ করা হলো স্ত্রী ও কন্যাকে।',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green.shade900,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Rate App Button
                    InkWell(
                      onTap: () async {
                        final Uri url = Uri.parse('https://play.google.com/store/apps/details?id=com.tech_with_m.choy_ritur_golpo');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber.shade600,
                              size: 24,
                            ),
                            Icon(
                              Icons.star,
                              color: Colors.amber.shade600,
                              size: 24,
                            ),
                            Icon(
                              Icons.star,
                              color: Colors.amber.shade600,
                              size: 24,
                            ),
                            Icon(
                              Icons.star,
                              color: Colors.amber.shade600,
                              size: 24,
                            ),
                            Icon(
                              Icons.star,
                              color: Colors.amber.shade600,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'অ্যাপটি রেট করুন',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildCreditItem({
  required IconData icon,
  required String title,
  required String description,
}) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 24,
          color: Colors.green.shade800,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// SeasonCard widget for expandable season content
class SeasonCard extends StatefulWidget {
  final Season season;
  final bool isCurrentSeason;

  const SeasonCard({
    super.key,
    required this.season,
    required this.isCurrentSeason,
  });

  @override
  State<SeasonCard> createState() => _SeasonCardState();
}

class _SeasonCardState extends State<SeasonCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Season Image (first section)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              widget.season.sections.first.image,
              width: double.infinity,
              fit: BoxFit.fitWidth,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: ${widget.season.sections.first.image}');
                print('Error: $error');
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey.shade300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Image not found',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.season.sections.first.image,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Season Content // todo the place to adjust gap
          //  between season name and 1st image: EdgeInsets.all(20),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Season Badge
                if (widget.isCurrentSeason)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'চলমান ঋতু',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (widget.isCurrentSeason) const SizedBox(height: 8),
                // Season Title
                Text(
                  widget.season.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                // Season Description (first section)
                Text(
                  widget.season.sections.first.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
          // All additional sections (always visible)
          if (widget.season.sections.length > 1)
            ...widget.season.sections.skip(1).map((section) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    Text(
                      section.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Section Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        section.image,
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 150,
                            color: Colors.grey.shade300,
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Section Description
                    Text(
                      section.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}

// Animated scroll indicator
class AnimatedScrollIndicator extends StatefulWidget {
  final Widget child;

  const AnimatedScrollIndicator({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedScrollIndicator> createState() => _AnimatedScrollIndicatorState();
}

class _AnimatedScrollIndicatorState extends State<AnimatedScrollIndicator> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  bool _hasScrolled = false;

  @override
  void initState() {
    super.initState();
    
    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Pulse animation controller for subtle movement
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start pulse animation
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasScrolled) {
      _hasScrolled = true;
      _fadeController.forward();
      _pulseController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The actual content
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              _onScroll();
            }
            return false;
          },
          child: widget.child,
        ),
        // Animated scroll indicator
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: Listenable.merge([_fadeAnimation, _pulseAnimation]),
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, _pulseAnimation.value * 5),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'নিচে স্ক্রল করুন',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 