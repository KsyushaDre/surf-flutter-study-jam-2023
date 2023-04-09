import 'package:flutter/material.dart';
import 'package:surf_flutter_study_jam_2023/features/ticket_storage/ticket_list_item.dart';

class Ticket {
  String fileName;
  String fileUrl;

  Ticket({required this.fileName, required this.fileUrl});
}

/// Экран “Хранения билетов”.
class TicketStoragePage extends StatefulWidget {
  const TicketStoragePage({Key? key}) : super(key: key);

  @override
  State<TicketStoragePage> createState() => _TicketStoragePageState();
}

class _TicketStoragePageState extends State<TicketStoragePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();
  final List<Ticket> tickets = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Хранение билетов'),
        ),
      ),
      body: tickets.isNotEmpty
          ? ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                return TicketListItem(
                  title: tickets[index].fileName,
                  url: tickets[index].fileUrl,
                );
              })
          : const Center(
              child: Text('Здесь пока ничего нет'),
            ),
      floatingActionButton: Builder(builder: (context) {
        return TextButton(
          onPressed: handleAddTicketButtonTap,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(const Color(0xFFD1C4E9)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
          ),
          child: const Text('Добавить'),
        );
      }),
    );
  }

  void handleAddTicketButtonTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SingleChildScrollView(
        child: AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 100),
          curve: Curves.decelerate,
          child: Container(
            height: 300,
            width: double.infinity,
            padding: const EdgeInsets.all(26),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(26),
                topRight: Radius.circular(26),
              ),
              color: Color(0xFFE8EAF6),
            ),
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: TextFormField(
                    validator: validatePassword,
                    controller: controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      // errorText: ,
                      labelText: 'Введите url',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: handleAddUrlButton,
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  child: const Text('Добавить'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void handleAddUrlButton() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        tickets.add(
          Ticket(
              fileName: 'Ticket ${tickets.length + 1}',
              fileUrl: controller.text),
        );
      });
      controller.clear();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            duration: Duration(seconds: 2), content: Text('Билет добавлен')),
      );
    }
  }

  String? validatePassword(String? value) {
    if (value != null) {
      final bool validURL = Uri.parse(value).isAbsolute;
      if (!validURL) {
        return 'Введите корректный Url';
      }
    }
    return null;
  }
}
