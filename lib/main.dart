import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SuiteDashboard(),
    );
  }
}

class Booking {
  String name;
  String date;
  String start;
  String end;
  bool paid;

  Booking(this.name, this.date, this.start, this.end, this.paid);
}

class SuiteDashboard extends StatefulWidget {
  const SuiteDashboard({super.key});

  @override
  State<SuiteDashboard> createState() => _SuiteDashboardState();
}

class _SuiteDashboardState extends State<SuiteDashboard> {
  List<List<Booking>> suites = List.generate(8, (_) => []);

  Future<String?> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked == null) return null;

    return "${picked.day}/${picked.month}/${picked.year}";
  }

  Future<String?> pickTime() async {
  TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: const TimeOfDay(hour: 10, minute: 0),
  );


    if (picked == null) return null;

    return picked.format(context);
  }

  void addBooking(int suiteIndex) {
    final name = TextEditingController();
    String date = "";
    String start = "";
    String end = "";
    bool paid = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: Text("Tambah Booking Suite ${suiteIndex + 1}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: "Nama Pemesan"),
              ),

              ListTile(
                title: Text(date.isEmpty ? "Pilih Tanggal" : date),
                leading: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await pickDate();
                  if (d != null) setDialog(() => date = d);
                },
              ),

              ListTile(
                title: Text(start.isEmpty ? "Jam Mulai" : start),
                leading: const Icon(Icons.access_time),
                onTap: () async {
                  final t = await pickTime();
                  if (t != null) setDialog(() => start = t);
                },
              ),

              ListTile(
                title: Text(end.isEmpty ? "Jam Selesai" : end),
                leading: const Icon(Icons.access_time_filled),
                onTap: () async {
                  final t = await pickTime();
                  if (t != null) setDialog(() => end = t);
                },
              ),

              SwitchListTile(
                title: const Text("Sudah Bayar"),
                value: paid,
                onChanged: (v) => setDialog(() => paid = v),
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
            ElevatedButton(
              onPressed: () {
                if (name.text.isNotEmpty && date.isNotEmpty && start.isNotEmpty && end.isNotEmpty) {
                  setState(() {
                    suites[suiteIndex].add(Booking(name.text, date, start, end, paid));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Simpan"),
            )
          ],
        ),
      ),
    );
  }

  void pilihSuite() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Pilih Suite"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(8, (i) {
            return ListTile(
              title: Text("Suite ${i + 1}"),
              onTap: () {
                Navigator.pop(context);
                addBooking(i);
              },
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Suite Dashboard"), centerTitle: true),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: 8,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SuiteDetail(
                    suite: index + 1,
                    bookings: suites[index],
                    onDelete: (i) {
                      setState(() => suites[index].removeAt(i));
                    },
                  ),
                ),
              );
            },
            child: Card(
              color: suites[index].isEmpty ? Colors.green.shade200 : Colors.orange.shade200,
              child: Center(
                child: Text(
                  "Suite ${index + 1}\n(${suites[index].length} booking)",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: pilihSuite,
      ),
    );
  }
}

class SuiteDetail extends StatelessWidget {
  final int suite;
  final List<Booking> bookings;
  final Function(int) onDelete;

  const SuiteDetail({super.key, required this.suite, required this.bookings, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    Map<String, List<Booking>> grouped = {};

    for (var b in bookings) {
      grouped.putIfAbsent(b.date, () => []).add(b);
    }

    return Scaffold(
      appBar: AppBar(title: Text("Suite $suite")),
      body: ListView(
        children: grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.grey.shade300,
                child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...entry.value.asMap().entries.map((e) {
                int idx = bookings.indexOf(e.value);
                return ListTile(
                  title: Text(e.value.name),
                  subtitle: Text("${e.value.start} - ${e.value.end}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(e.value.paid ? "PAID" : "UNPAID",
                          style: TextStyle(color: e.value.paid ? Colors.green : Colors.red)),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          onDelete(idx);
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                );
              })
            ],
          );
        }).toList(),
      ),
    );
  }
}
