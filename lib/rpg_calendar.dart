import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class RpgCalendarDemo extends StatefulWidget {
  const RpgCalendarDemo({super.key});

  @override
  State<RpgCalendarDemo> createState() => _RpgCalendarDemoState();
}

class _RpgCalendarDemoState extends State<RpgCalendarDemo> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> events = {};
  int xp = 0;
  int hp = 5;

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // ✅ default select today
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  List<String> getEventsForDay(DateTime day) {
    return events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _addQuest(DateTime day, String quest) {
    final key = DateTime(day.year, day.month, day.day);
    setState(() {
      events.putIfAbsent(key, () => []);
      events[key]!.add(quest);
    });
  }

  void _completeQuest(DateTime day, String quest) {
    final key = DateTime(day.year, day.month, day.day);
    setState(() {
      events[key]?.remove(quest);
      xp += 10;

      // 🎊 Level up check
      if (xp % 100 == 0) {
        _confettiController.play();
        _showLevelUpDialog();
      }

      if (events[key]?.isEmpty ?? true) {
        events.remove(key);
      }
    });
  }

  void _missQuest() {
    setState(() {
      if (hp > 0) hp -= 1;
    });
  }

  void _showLevelUpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("⚔ Level Up!"),
        content: Text("You reached Level ${(xp ~/ 100) + 1}! 🎉"),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Awesome!"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double xpPercent = (xp % 100) / 100;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("🌟 RPG Calendar — Level Up Your Day"),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          Column(
            children: [
              // XP & HP
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // XP progress bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0,
                              end: xpPercent.clamp(0, 1),
                            ),
                            duration: const Duration(milliseconds: 500),
                            builder: (context, value, _) =>
                                LinearProgressIndicator(
                                  value: value,
                                  backgroundColor: Colors.grey[300],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.orangeAccent,
                                      ),
                                  minHeight: 12,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text("Lv. ${(xp ~/ 100) + 1}"),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // HP hearts
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            index < hp ? Icons.favorite : Icons.favorite_border,
                            key: ValueKey<bool>(index < hp),
                            color: Colors.red,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Avatar
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Icon(
                  xp < 50
                      ? Icons.pets
                      : xp < 100
                      ? Icons.emoji_emotions
                      : Icons.emoji_nature,
                  key: ValueKey<int>(xp ~/ 50),
                  size: 100,
                  color: xp < 50
                      ? Colors.brown
                      : xp < 100
                      ? Colors.yellow[700]
                      : Colors.green,
                ),
              ),

              // Calendar
              TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: getEventsForDay,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.purpleAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Quest list
              Expanded(
                child: ListView(
                  children: getEventsForDay(_selectedDay ?? DateTime.now())
                      .map(
                        (quest) => Card(
                          color: Colors.lightBlueAccent.withOpacity(0.8),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text(
                              quest,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              onPressed: () =>
                                  _completeQuest(_selectedDay!, quest),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),

          // 🎉 Confetti widget
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 30,
              minBlastForce: 10,
              gravity: 0.3,
            ),
          ),
        ],
      ),

      // Add Quest button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () {
          if (_selectedDay == null) return;
          showDialog(
            context: context,
            builder: (context) {
              final controller = TextEditingController();
              return AlertDialog(
                title: const Text("Add Quest"),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "Enter your quest (task)",
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        _addQuest(_selectedDay!, controller.text);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text("Add"),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
