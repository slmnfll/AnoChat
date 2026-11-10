import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'glass_navigation.dart';

const ink = Color(0xff29372d);
const sage = Color(0xff586d54);
const cream = Color(0xfff8f6ee);
const mist = Color(0xffe1e7d7);
TextStyle editorial(double size) => TextStyle(
  fontFamily: 'STIX',
  fontSize: size,
  height: 1.08,
  letterSpacing: -.8,
  color: ink,
);

class AnoInterface extends StatefulWidget {
  const AnoInterface({super.key});
  @override
  State<AnoInterface> createState() => _AnoInterfaceState();
}

class _AnoInterfaceState extends State<AnoInterface> {
  bool entered = false, registering = false;
  int tab = 0;
  String name = 'A little anonymous', avatar = '✳';
  final username = TextEditingController();
  final password = TextEditingController();
  final lounge = <String>[
    'The light through my window this morning. Nothing extraordinary, just really lovely.',
    'Someone remembered how I take my coffee.',
    'This little corner of the internet, honestly.',
  ];
  final roomMessages = <String, List<String>>{};
  final privateMessages = <String, List<String>>{};
  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        bottom: false,
        child:
            entered
                ? Stack(
                  children: [
                    Positioned.fill(
                      child: IndexedStack(
                        index: tab,
                        children: [
                          ChatPage(
                            title: 'The lounge',
                            subtitle: 'A little closer, wherever you are.',
                            messages: lounge,
                            lounge: true,
                          ),
                          RoomsPage(
                            onOpen:
                                (room) => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ChatPage(
                                          title: room,
                                          subtitle:
                                              'A small room. A shared curiosity.',
                                          messages: roomMessages.putIfAbsent(
                                            room,
                                            () => [
                                              'Glad you found your way here. What’s on your mind?',
                                            ],
                                          ),
                                        ),
                                  ),
                                ),
                          ),
                          FriendsPage(
                            onChat:
                                (friend) => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ChatPage(
                                          title: friend,
                                          subtitle: 'Just the two of you.',
                                          messages: privateMessages.putIfAbsent(
                                            friend,
                                            () => [
                                              'That conversation stayed with me. How’s your day going?',
                                            ],
                                          ),
                                          friend: friend,
                                        ),
                                  ),
                                ),
                          ),
                          profile(),
                        ],
                      ),
                    ),
                    if (MediaQuery.viewInsetsOf(context).bottom == 0)
                      Positioned(
                        left: 24,
                        right: 24,
                        bottom: MediaQuery.paddingOf(context).bottom + 16,
                        child: GlassNavigation(
                          selected: tab,
                          onChanged: (value) {
                            FocusScope.of(context).unfocus();
                            setState(() => tab = value);
                          },
                        ),
                      ),
                  ],
                )
                : welcome(),
      ),
    );
  }

  Widget welcome() => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(26, 38, 26, 36),
        children: [
          Text('ano', style: editorial(76)),
          const SizedBox(height: 10),
          const Text('Feel yourself at ease.', style: TextStyle(color: sage)),
          const SizedBox(height: 28),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(CupertinoIcons.sparkles, color: ink, size: 30),
                const SizedBox(height: 22),
                Text(
                  registering
                      ? 'Your own little\nplace to belong.'
                      : 'Come as you are.\nStay for the company.',
                  style: editorial(32),
                ),
                const SizedBox(height: 18),
                const Text(
                  'A quiet place to find your people\nand let a conversation happen.',
                  style: TextStyle(height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          field('Username', username),
          const SizedBox(height: 14),
          field('Password', password, secret: true),
          const SizedBox(height: 14),
          const Text(
            'Interface preview · use made-up details.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: sage),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () {
              password.clear();
              setState(() {
                entered = true;
                if (username.text.trim().isNotEmpty)
                  name = username.text.trim();
              });
            },
            child: Text(registering ? 'Create an account  →' : 'Sign in  →'),
          ),
          TextButton(
            onPressed: () => setState(() => registering = !registering),
            child: Text(
              registering
                  ? 'Already here? Sign in'
                  : 'New here? Create an account',
            ),
          ),
        ],
      ),
    ),
  );
  Widget field(
    String label,
    TextEditingController controller, {
    bool secret = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: sage)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        obscureText: secret,
        autocorrect: !secret,
        enableSuggestions: !secret,
        decoration: InputDecoration(
          hintText: secret ? 'Sample password' : 'Your username',
        ),
      ),
    ],
  );
  Widget profile() => ListView(
    padding: const EdgeInsets.fromLTRB(24, 28, 24, 130),
    children: [
      header('Your little corner.', 'Exactly as you are.'),
      const SizedBox(height: 28),
      Panel(
        child: Row(
          children: [
            Text(avatar, style: editorial(44)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: editorial(25)),
                  const SizedBox(height: 8),
                  const Text(
                    'ANO · 008 241',
                    style: TextStyle(fontSize: 12, color: sage),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      setting('Your account', CupertinoIcons.person, () => editAccount()),
      setting(
        'Appearance',
        CupertinoIcons.sun_max,
        () => showInfo(
          'Appearance',
          'Warm ivory, soft sage, and a little breathing room. This preview uses the light appearance.',
        ),
      ),
      setting(
        'Notifications',
        CupertinoIcons.bell,
        () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PreferencesPage())),
      ),
      setting(
        'Privacy & safety',
        CupertinoIcons.hand_raised,
        () => showInfo(
          'Privacy & safety',
          'In public rooms, everyone appears as ANO with no avatar. Your pseudonym and avatar are visible to friends.\n\nBlocked accounts\nYou haven’t blocked anyone.',
        ),
      ),
      const SizedBox(height: 28),
      const Text(
        'A little less noise.\nA little more connection.',
        textAlign: TextAlign.center,
        style: TextStyle(color: sage, height: 1.7),
      ),
      const SizedBox(height: 16),
      TextButton(
        onPressed:
            () => setState(() {
              entered = false;
              tab = 0;
            }),
        child: const Text('Sign out'),
      ),
    ],
  );
  void showInfo(String title, String body) => showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder:
        (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: editorial(30)),
                const SizedBox(height: 20),
                Text(body, style: const TextStyle(height: 1.7)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
  );
  Future<void> editAccount() async {
    final controller = TextEditingController(text: name);
    String nextAvatar = avatar;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder:
          (sheetContext) => StatefulBuilder(
            builder:
                (context, update) => Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    8,
                    24,
                    MediaQuery.viewInsetsOf(context).bottom + 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Make it yours.', style: editorial(32)),
                      const SizedBox(height: 24),
                      TextField(
                        controller: controller,
                        maxLength: 30,
                        decoration: const InputDecoration(
                          labelText: 'Pseudonym',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        children:
                            ['✳', '☾', '✿', '◒']
                                .map(
                                  (symbol) => TextButton(
                                    onPressed:
                                        () => update(() => nextAvatar = symbol),
                                    child: Text(
                                      symbol,
                                      style: TextStyle(
                                        fontSize: 32,
                                        color:
                                            symbol == nextAvatar
                                                ? sage
                                                : Colors.grey,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      const Text(
                        'Account ID · 008 241',
                        style: TextStyle(color: sage),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () => Navigator.pop(sheetContext, true),
                        child: const Text('Save changes'),
                      ),
                    ],
                  ),
                ),
          ),
    );
    if (saved == true && mounted)
      setState(() {
        name = controller.text.trim().isEmpty ? name : controller.text.trim();
        avatar = nextAvatar;
      });
    // The closing sheet may still be animating while its text field is attached.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    controller.dispose();
  }
}

Widget header(String title, String subtitle) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(title, style: editorial(37)),
    const SizedBox(height: 10),
    Text(subtitle, style: const TextStyle(color: sage, height: 1.5)),
  ],
);
Widget setting(String title, IconData icon, VoidCallback action) => ListTile(
  contentPadding: const EdgeInsets.symmetric(vertical: 4),
  leading: Icon(icon, color: sage),
  title: Text(title),
  trailing: const Icon(CupertinoIcons.chevron_right, size: 16, color: sage),
  onTap: action,
);

class Panel extends StatelessWidget {
  final Widget child;
  const Panel({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: mist,
      borderRadius: BorderRadius.circular(28),
    ),
    child: child,
  );
}

class ChatPage extends StatefulWidget {
  final String title, subtitle;
  final String? friend;
  final List<String> messages;
  final bool lounge;
  const ChatPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.messages,
    this.lounge = false,
    this.friend,
  });
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final input = TextEditingController();
  final scroll = ScrollController();
  @override
  void dispose() {
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  void send() {
    if (input.text.trim().isEmpty) return;
    setState(() {
      widget.messages.add(input.text.trim());
      input.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients)
        scroll.animateTo(
          scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    final content = Column(
      children: [
        Expanded(
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
            children: [
              header(widget.title, widget.subtitle),
              const SizedBox(height: 26),
              if (widget.lounge) ...[
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GOOD COMPANY, NO INTRODUCTION NEEDED',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.4,
                          color: sage,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('What made you\nsmile today?', style: editorial(31)),
                      const SizedBox(height: 20),
                      const Text(
                        'TODAY’S LITTLE CONVERSATION',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.1,
                          color: sage,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Everyone is ANO here. Just be yourself.',
                  style: TextStyle(fontSize: 11, color: sage),
                ),
                const SizedBox(height: 22),
              ],
              for (final message in widget.messages)
                Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.friend ?? 'ANO',
                        style: const TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w600,
                          color: sage,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Container(
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .75),
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: Text(
                          message,
                          style: const TextStyle(height: 1.55, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            6,
            24,
            widget.lounge && !keyboard
                ? MediaQuery.paddingOf(context).bottom + 100
                : 14,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: input,
                  onSubmitted: (_) => send(),
                  textInputAction: TextInputAction.send,
                  decoration: const InputDecoration(
                    hintText: 'Add a little something…',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: send,
                tooltip: 'Send message',
                style: IconButton.styleFrom(backgroundColor: sage),
                icon: const Icon(CupertinoIcons.arrow_up),
              ),
            ],
          ),
        ),
      ],
    );
    return widget.lounge
        ? content
        : Scaffold(
          backgroundColor: cream,
          appBar: AppBar(
            backgroundColor: cream,
            title: const Text('Conversation', style: TextStyle(fontSize: 14)),
          ),
          body: SafeArea(child: content),
        );
  }
}

const rooms = [
  ('The slow club', 'Small rituals. Unhurried mornings.', '✳', 'Everyday'),
  ('After hours', 'Leave the day at the door.', '☾', 'Everyday'),
  ('On repeat', 'Something good in your headphones.', '♪', 'Culture'),
  ('Little victories', 'The small things count, too.', '✦', 'Everyday'),
  ('Between pages', 'For stories that stay with you.', '⌑', 'Culture'),
  ('Outside, a little', 'Fresh air. Fresh perspectives.', '↟', 'Curiosity'),
  ('What if?', 'Follow a thought somewhere new.', '⁕', 'Curiosity'),
  ('At the table', 'Recipes, memories, second helpings.', '◒', 'Culture'),
];

class RoomsPage extends StatefulWidget {
  final ValueChanged<String> onOpen;
  const RoomsPage({super.key, required this.onOpen});
  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  String query = '', category = 'All';
  @override
  Widget build(BuildContext context) {
    final visible =
        rooms
            .where(
              (r) =>
                  (category == 'All' || r.$4 == category) &&
                  '${r.$1} ${r.$2}'.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 140),
      children: [
        header('Find your people.', 'Small rooms. Shared curiosities.'),
        const SizedBox(height: 24),
        TextField(
          onChanged: (v) => setState(() => query = v),
          decoration: const InputDecoration(
            prefixIcon: Icon(CupertinoIcons.search),
            hintText: 'Find a room',
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 7,
          children:
              ['All', 'Everyday', 'Culture', 'Curiosity']
                  .map(
                    (c) => ChoiceChip(
                      label: Text(c),
                      selected: category == c,
                      onSelected: (_) => setState(() => category = c),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 22),
        if (query.isEmpty && category == 'All') ...[
          GestureDetector(
            onTap: () => widget.onOpen('The slow club'),
            child: Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'THIS WEEK’S SPOTLIGHT',
                    style: TextStyle(fontSize: 10, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Text('The slow club', style: editorial(33)),
                  const SizedBox(height: 12),
                  const Text(
                    'For small rituals, unhurried mornings,\nand taking life one cup at a time.',
                    style: TextStyle(height: 1.6),
                  ),
                  const SizedBox(height: 20),
                  const Text('Step inside  →'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
        ],
        const Text(
          'EXPLORE THE ROOMS',
          style: TextStyle(fontSize: 10, letterSpacing: 1.6, color: sage),
        ),
        const SizedBox(height: 14),
        if (visible.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No rooms found. Try another word.'),
          ),
        LayoutBuilder(
          builder:
              (context, constraints) => Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    visible
                        .map(
                          (r) => SizedBox(
                            width:
                                constraints.maxWidth > 340
                                    ? (constraints.maxWidth - 12) / 2
                                    : constraints.maxWidth,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(23),
                              onTap: () => widget.onOpen(r.$1),
                              child: Container(
                                padding: const EdgeInsets.all(19),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .7),
                                  borderRadius: BorderRadius.circular(23),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.$3,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        color: sage,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(r.$1, style: editorial(24)),
                                    const SizedBox(height: 10),
                                    Text(
                                      r.$2,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        height: 1.5,
                                        color: sage,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    const Text(
                                      '●  A little company awaits',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: sage,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
        ),
      ],
    );
  }
}

class FriendsPage extends StatelessWidget {
  final ValueChanged<String> onChat;
  const FriendsPage({super.key, required this.onChat});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 28, 24, 130),
    children: [
      header('Familiar company.', 'Good conversations have a way of staying.'),
      const SizedBox(height: 28),
      for (final person in [
        ('Moonlit', '☾', 'That conversation stayed with me.', '2m'),
        ('Clover', '✳', 'Same time tomorrow?', '1h'),
        ('Sunday', '◒', 'You’d love this song.', 'Yesterday'),
      ])
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          leading: IconButton(
            tooltip: '${person.$1} profile',
            onPressed:
                () => showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  builder:
                      (_) => Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(person.$2, style: editorial(48)),
                            const SizedBox(height: 18),
                            Text(person.$1, style: editorial(32)),
                            const SizedBox(height: 12),
                            const Text(
                              'A familiar face, in your own little circle.',
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                onChat(person.$1);
                              },
                              child: const Text('Open conversation'),
                            ),
                          ],
                        ),
                      ),
                ),
            icon: Text(
              person.$2,
              style: const TextStyle(fontSize: 27, color: sage),
            ),
          ),
          title: Text(person.$1),
          subtitle: Text(
            person.$3,
            maxLines: 2,
            style: const TextStyle(fontSize: 12, color: sage),
          ),
          trailing: Text(
            person.$4,
            style: const TextStyle(fontSize: 10, color: sage),
          ),
          onTap: () => onChat(person.$1),
        ),
    ],
  );
}

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});
  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  bool messages = true, topics = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: cream,
    appBar: AppBar(title: const Text('Notifications'), backgroundColor: cream),
    body: ListView(
      children: [
        SwitchListTile.adaptive(
          title: const Text('Messages from friends'),
          value: messages,
          onChanged: (v) => setState(() => messages = v),
        ),
        SwitchListTile.adaptive(
          title: const Text('A new daily topic'),
          value: topics,
          onChanged: (v) => setState(() => topics = v),
        ),
        const Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Preview preferences only. Device notifications aren’t connected yet.',
            style: TextStyle(color: sage),
          ),
        ),
      ],
    ),
  );
}
