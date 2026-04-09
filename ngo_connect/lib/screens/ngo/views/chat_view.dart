import 'package:flutter/material.dart';
import '../../../theme.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Contacts List
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: AppTheme.borderGrey)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Messages', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.filter_list, size: 20), onPressed: () {}),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search conversations...',
                        hintStyle: const TextStyle(fontSize: 13),
                        prefixIcon: const Icon(Icons.search, size: 18),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppTheme.borderGrey)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      children: [
                        _contactRow('Sarah Jenkins', '2:45 PM', 'Re: Food Distribution Drive', 'I\'ve uploaded the delivery receip...', true, true),
                        const Divider(height: 1),
                        _contactRow('Marcus Thorne', '1:20 PM', 'Re: Community Park Cleanup', 'Will be there in 15 minutes! Traffic is...', false, false),
                        const Divider(height: 1),
                        _contactRow('Elena Rodriguez', 'Yesterday', 'Re: Elderly Tech Support', 'Thanks for the opportunity. Looking...', false, false),
                        const Divider(height: 1),
                        _contactRow('James Chen', 'Oct 20', 'Re: Urban Garden Project', 'Do we need to bring our own gloves...', false, false),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          
          // Chat Area
          Expanded(
            flex: 7,
            child: Column(
              children: [
                // Chat Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.borderGrey))),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 20, backgroundColor: AppTheme.borderGrey, child: Icon(Icons.person, color: Colors.grey)),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sarah Jenkins', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('Active now', style: TextStyle(fontSize: 12, color: AppTheme.successGreen, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.phone_outlined, color: AppTheme.textGrey), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.videocam_outlined, color: AppTheme.textGrey), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.info_outline, color: AppTheme.textGrey), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.more_vert, color: AppTheme.textGrey), onPressed: () {}),
                    ],
                  ),
                ),
                
                // Context Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  color: AppTheme.primaryPurple.withOpacity(0.05),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.primaryPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Text('Active Task', style: TextStyle(color: AppTheme.primaryPurple, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Food Distribution Drive • Deadline: Oct 24', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                      TextButton(onPressed: () {}, child: const Text('View Details')),
                    ],
                  ),
                ),
                
                // Messages Body
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(32),
                    children: [
                      const Center(child: Text('Yesterday', style: TextStyle(fontSize: 11, color: AppTheme.textGrey))),
                      const SizedBox(height: 24),
                      _myMessage('Hi Sarah! Just checking in on the progress for the Sunday food drive. Are we all set with the logistics?', '10:15 AM'),
                      const SizedBox(height: 24),
                      _theirMessage('Hey! Yes, everything is on track. I\'ve confirmed with the 5 volunteers for the morning shift. We\'ll be at the warehouse by 8 AM.', '10:20 AM'),
                      const SizedBox(height: 32),
                      const Center(child: Text('Today', style: TextStyle(fontSize: 11, color: AppTheme.textGrey))),
                      const SizedBox(height: 24),
                      _myMessage('That\'s great. I\'ve sent over the final route map for the delivery vans.', '2:30 PM'),
                      const SizedBox(height: 24),
                      _theirImageMessage('10:45 AM'),
                    ],
                  ),
                ),
                
                // Input Area
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: AppTheme.borderGrey)),
                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(16)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.borderGrey)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            IconButton(icon: const Icon(Icons.attach_file, color: AppTheme.textGrey), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.image_outlined, color: AppTheme.textGrey), onPressed: () {}),
                            const Expanded(
                              child: TextField(
                                decoration: InputDecoration(hintText: 'Type a message...', border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, fillColor: Colors.transparent),
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.sentiment_satisfied_outlined, color: AppTheme.textGrey), onPressed: () {}),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppTheme.backgroundLight, shape: BoxShape.circle),
                              child: const Icon(Icons.send, color: AppTheme.textGrey, size: 20),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _quickReply('Confirm shift'),
                            _quickReply('I\'m running late'),
                            _quickReply('Request resource'),
                            _quickReply('Task completed!'),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _contactRow(String name, String time, String sub, String msg, bool isUnread, bool isSelected) {
    return Container(
      color: isSelected ? AppTheme.primaryPurple.withOpacity(0.05) : Colors.transparent,
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 24, backgroundColor: AppTheme.borderGrey, child: Icon(Icons.person, color: isSelected ? AppTheme.primaryPurple : Colors.grey)),
           const SizedBox(width: 16),
           Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.w600, fontSize: 14)),
                    Text(time, style: TextStyle(fontSize: 11, color: isUnread ? AppTheme.textDark : AppTheme.textGrey, fontWeight: isUnread ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(sub, style: TextStyle(fontSize: 12, color: AppTheme.primaryPurple, fontWeight: isUnread ? FontWeight.bold : FontWeight.w500)),
                const SizedBox(height: 4),
                Text(msg, style: TextStyle(fontSize: 12, color: AppTheme.textGrey), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
           ),
           if (isUnread) ...[
             const SizedBox(width: 12),
             Container(
               width: 18, height: 18,
               decoration: const BoxDecoration(color: AppTheme.primaryPurple, shape: BoxShape.circle),
               child: const Center(child: Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
             )
           ]
        ],
      ),
    );
  }

  Widget _myMessage(String text, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: const BoxDecoration(
            color: AppTheme.primaryPurple,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomLeft: Radius.circular(16)),
          ),
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(time, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
            const SizedBox(width: 4),
            const Icon(Icons.done_all, size: 14, color: AppTheme.primaryPurple),
          ],
        )
      ],
    );
  }

  Widget _theirMessage(String text, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.borderGrey),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
          ),
          child: Text(text, style: const TextStyle(color: AppTheme.textDark, fontSize: 14, height: 1.4)),
        ),
        const SizedBox(height: 8),
        Text(time, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
      ],
    );
  }

  Widget _theirImageMessage(String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 150,
          width: 250,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomRight: Radius.circular(16)),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1593113563332-afceed8f14af?auto=format&fit=crop&w=400&q=80'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(time, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
      ],
    );
  }

  Widget _quickReply(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: const BorderSide(color: AppTheme.borderGrey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.textDark)),
      ),
    );
  }
}
