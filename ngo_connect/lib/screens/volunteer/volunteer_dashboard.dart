import 'package:flutter/material.dart';
import '../../theme.dart';

class VolunteerDashboard extends StatefulWidget {
  const VolunteerDashboard({super.key});

  @override
  State<VolunteerDashboard> createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // Left Sidebar
          _buildSidebar(),
          
          // Main Body
          Expanded(
            child: Column(
              children: [
                // Top Search/Profile Bar
                _buildTopBar(),
                
                // Scrollable Content
                Expanded(
                  child: Container(
                    color: AppTheme.backgroundLight,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPageHeader(),
                          const SizedBox(height: 24),
                          _buildFilterBar(),
                          const SizedBox(height: 32),
                          _buildGridRow([
                            _needCard('TechAid Global', 'Remote / San Francisco', 'Immediate', AppTheme.errorRed, 'Full Stack Developer for Crisis Management Tool', 'We are building an open-source platform to coordinate emergency logistics during natural disasters. Looking for React/Node.js experts to...', ['React', 'Node.js', 'TypeScript'], 'Oct 25, 2024'),
                            _needCard('Harbor Food Rescue', 'Brooklyn, NY', 'Needed Soon', AppTheme.primaryPurple, 'Weekend Community Kitchen Support', 'Help us prep and serve meals for over 200 local residents every Sunday. No experience needed, just a positive attitude and willingness to help.', ['Food Safety', 'Teamwork'], 'Nov 12, 2024'),
                            _needCard('EduFuture', 'Remote', 'Urgent', AppTheme.warningOrange, 'UI/UX Designer for Literacy App', 'Redesign our mobile app interface to be more accessible for children in rural areas. Focus on iconography and intuitive navigation.', ['Figma', 'Accessibility', 'Visual Design'], 'Oct 30, 2024'),
                          ]),
                          const SizedBox(height: 24),
                          _buildGridRow([
                            _needCard('GreenEarth Initiative', 'Remote', 'Flexible', AppTheme.textDark, 'Social Media Campaign Manager', 'Boost our visibility for the upcoming Tree Planting Month. We need someone to create engaging content and manage our Instagram/X', ['Copywriting', 'Analytics', 'Instagram'], 'Dec 05, 2024'),
                            _needCard('New Beginnings', 'Online', 'Needed Soon', AppTheme.primaryPurple, 'English Tutor for Refugee Youth', 'Provide 1-on-1 English language tutoring sessions online. Help high school students improve their communication skills and', ['Teaching', 'ESL', 'Patience'], 'Ongoing'),
                            _needCard('Justice For All', 'Chicago, IL', 'Urgent', AppTheme.warningOrange, 'Legal Advisor for Pro-Bono Services', 'Assist low-income families with housing dispute consultations. Must be a licensed attorney with a heart for community advocacy.', ['Legal', 'Advocacy', 'Counseling'], 'Nov 15, 2024'),
                          ]),
                          const SizedBox(height: 48),
                          _buildCallToAction(),
                          const SizedBox(height: 48),
                          _buildGridRow([
                            _needCard('HealPoint Foundation', 'Houston, TX', 'Flexible', AppTheme.textDark, 'Mobile Clinic Administrative Assistant', 'Coordinate patient scheduling and data entry for our mobile clinics operating in urban food deserts. Help us keep the workflow efficient.', ['Data Entry', 'Organization', 'Spanish (Bilingual)'], 'Nov 30, 2024'),
                            _needCard('Canvas for Kids', 'Remote', 'Urgent', AppTheme.warningOrange, 'Grant Writer for Youth Arts Program', 'We need a talented writer to help us apply for state arts grants. Your words will directly fund art supplies for underprivileged youth.', ['Grant Writing', 'Persuasive Writing'], 'Oct 22, 2024'),
                            _needCard('Second Chance Rescues', 'Portland, OR', 'Immediate', AppTheme.errorRed, 'Pet Foster Coordinator', 'Manage our network of temporary foster homes. Ensure all pets have a safe place to stay while awaiting their forever families.', ['Animal Welfare', 'Management', 'Communication'], 'Oct 28, 2024'),
                          ]),
                          const SizedBox(height: 48),
                          Center(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                side: BorderSide(color: AppTheme.borderGrey),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              child: const Text('Load More Opportunities', style: TextStyle(color: AppTheme.textDark)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Center(child: Text('Showing 9 of 124 results', style: TextStyle(color: AppTheme.textGrey, fontSize: 13, fontStyle: FontStyle.italic))),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Layout Components ---

  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundLight,
        border: Border(right: BorderSide(color: AppTheme.borderGrey)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: AppTheme.primaryPurple, shape: BoxShape.circle),
                  child: const Icon(Icons.show_chart, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text('NGO Connect', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sidebarItem(Icons.dashboard_outlined, 'Dashboard', 0),
          _sidebarItem(Icons.search, 'Explore Needs', 1),
          _sidebarItem(Icons.chat_bubble_outline, 'Messages', 2),
          const Spacer(),
          _sidebarItem(Icons.settings_outlined, 'Settings', 3),
          _sidebarItem(Icons.logout, 'Logout', 4, color: AppTheme.errorRed),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, int index, {Color? color}) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: AppTheme.borderGrey) : null,
          boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? (isSelected ? AppTheme.primaryPurple : AppTheme.textDark), size: 20),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: color ?? AppTheme.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.borderGrey)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_none, color: AppTheme.textDark),
          const SizedBox(width: 8),
          const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          SizedBox(
            width: 300,
            height: 40,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.borderGrey)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.borderGrey)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.primaryPurple)),
                filled: true,
                fillColor: AppTheme.backgroundLight,
              ),
            ),
          ),
          const SizedBox(width: 24),
          const CircleAvatar(
            backgroundColor: AppTheme.primaryPurple,
            radius: 18,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          )
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Explore Needs', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 4),
            Text('Discover opportunities that match your skills and passion.', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.language, size: 16, color: AppTheme.primaryPurple),
              const SizedBox(width: 8),
              RichText(
                text: const TextSpan(
                  style: TextStyle(color: AppTheme.textDark, fontSize: 13),
                  children: [
                    TextSpan(text: 'Showing '),
                    TextSpan(text: '124', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' matching opportunities'),
                  ]
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by title, NGO, or keyword...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderGrey)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.borderGrey)),
              fillColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.filter_list), label: const Text('Filters')),
        const SizedBox(width: 16),
        Container(width: 1, height: 40, color: AppTheme.borderGrey),
        const SizedBox(width: 16),
        _pillButton('All Categories', true),
        _pillButton('Technology', false),
        _pillButton('Education', false),
        _pillButton('Environment', false),
        _pillButton('More  v', false, isDropdown: true),
      ],
    );
  }

  Widget _pillButton(String title, bool isSelected, {bool isDropdown = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.backgroundLight : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? AppTheme.borderGrey : Colors.transparent),
          ),
          child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark, fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildGridRow(List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((c) => Expanded(child: Padding(padding: EdgeInsets.only(right: c != children.last ? 24.0 : 0.0), child: c))).toList(),
    );
  }

  Widget _needCard(String org, String loc, String urgency, Color urgencyColor, String title, String desc, List<String> skills, String date) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(backgroundColor: AppTheme.backgroundLight, radius: 20, child: const Icon(Icons.business, color: AppTheme.primaryPurple, size: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(org, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 14)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: AppTheme.textGrey),
                        const SizedBox(width: 4),
                        Text(loc, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: urgencyColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: urgencyColor.withOpacity(0.2))),
                child: Row(
                  children: [
                    Icon(Icons.schedule, size: 12, color: urgencyColor),
                    const SizedBox(width: 4),
                    Text(urgency, style: TextStyle(color: urgencyColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.3)),
          const SizedBox(height: 12),
          Text(desc, style: const TextStyle(color: AppTheme.textDark, fontSize: 13, height: 1.5, overflow: TextOverflow.ellipsis), maxLines: 3),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(6)),
              child: Text(s, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            )).toList(),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textGrey),
                  const SizedBox(width: 6),
                  Text('Apply by $date', style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Row(
                  children: [
                    Text('Apply Now'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 14),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCallToAction() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppTheme.primaryPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_border, size: 14, color: AppTheme.primaryPurple),
                      SizedBox(width: 6),
                      Text('COMMUNITY CHOICE', style: TextStyle(color: AppTheme.primaryPurple, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Can\'t find exactly what you\'re looking for?', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 16),
                const Text('NGO Connect uses an intelligent matching algorithm. Complete your volunteer profile with specific skills and availability to receive personalized notifications when a perfect match appears.', style: TextStyle(fontSize: 15, color: AppTheme.textDark, height: 1.5)),
                const SizedBox(height: 32),
                Row(
                  children: [
                    ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20)), child: const Text('Update My Profile')),
                    const SizedBox(width: 24),
                    TextButton(onPressed: () {}, child: const Text('Learn about matching', style: TextStyle(fontSize: 15))),
                  ],
                ),
              ],
            ),
          ),
          const Expanded(flex: 4, child: Center(child: Icon(Icons.hub_outlined, size: 150, color: AppTheme.primaryPurple))),
        ],
      ),
    );
  }
}
