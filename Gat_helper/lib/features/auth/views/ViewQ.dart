import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionsViewPage extends StatefulWidget {
  final String studentName;
  final List<Map<String, dynamic>> questions;

  const QuestionsViewPage({
    Key? key,
    required this.studentName,
    required this.questions,
  }) : super(key: key);

  @override
  _QuestionsViewPageState createState() => _QuestionsViewPageState();
}

class _QuestionsViewPageState extends State<QuestionsViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          title: const Text(
            "Questions",
            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          flexibleSpace: Image.asset(
            "assets/img_17.png",
            fit: BoxFit.cover,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.questions.length,
                itemBuilder: (context, index) {
                  final q = widget.questions[index];
                  return _questionCard(
                    q['question'] ?? '',
                    List<String>.from(q['options'] ?? []),
                    q['correct_answer'] ?? '',
                    q['passage'],
                    q['image'],
                  );
                },
              ),
            ),
            // الحذف: لا توجد أزرار Accept/Reject بعد الآن
          ],
        ),
      ),
    );
  }
  Widget _questionCard(
      String question,
      List<String> options,
      String correctAnswer,
      dynamic passage,
      dynamic imageUrl,
      ) {
    // طباعة البيانات للتحقق منها
    print("Question: $question");
    print("Options: $options");
    print("Correct Answer: $correctAnswer");

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عرض السؤال
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.help_outline, color: Colors.black54, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
                ),
              ),
              if (passage != null || imageUrl != null)
                IconButton(
                  icon: const Icon(Icons.attach_file, size: 20),
                  tooltip: 'View extra content',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Extra Content'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (passage != null) ...[
                                Text(
                                  passage,
                                  style: const TextStyle(fontSize: 14.5, fontStyle: FontStyle.italic),
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (imageUrl != null)
                                Image.network(imageUrl),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text("Close"),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          // عرض الخيارات هنا
          if (options.isNotEmpty) ...[
            for (var option in options)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: Colors.black54),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          color: option == correctAnswer ? Colors.green : Colors.black54,
                          fontWeight: option == correctAnswer ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ] else ...[
            Text('No options available'),
          ]
        ],
      ),
    );
  }



}
