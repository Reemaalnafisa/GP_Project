import 'dart:convert';
import 'package:flutter/services.dart';

class QuestionService {
  Future<List<Map<String, dynamic>>> fetchQuestions({
    required String questionType,
    required int limit,
  }) async {
    try {
      List<Map<String, dynamic>> finalQuestions = [];

      if (questionType == "Verbal") {
        // تحميل الأسئلة اللفظية العادية
        String verbalJson = await rootBundle.loadString('assets/verbal_questions.json');
        List<dynamic> verbalQuestions = json.decode(verbalJson);

        // تحميل أسئلة النصوص
        String passageJson = await rootBundle.loadString('assets/passages_questions_new.json');
        List<dynamic> passageQuestions = json.decode(passageJson);

        // خلط الأسئلة
        verbalQuestions.shuffle();
        passageQuestions.shuffle();

        // توزيع النسب
        int verbalLimit = (limit * 0.8).round(); // 80% عادية
        int passageLimit = limit - verbalLimit;  // 20% نصوص

        // اختيار الأسئلة العادية
        List<Map<String, dynamic>> selectedVerbal = verbalQuestions
            .map((q) => _fixQuestionFormat(q as Map<String, dynamic>))
            .take(verbalLimit)
            .toList();

        // تعيين subtype = "regular"
        selectedVerbal = selectedVerbal.map((q) {
          q['subtype'] = 'regular';
          return q;
        }).toList();

        // اختيار أسئلة النصوص
        List<Map<String, dynamic>> selectedPassages = passageQuestions
            .map((q) => _fixQuestionFormat(q as Map<String, dynamic>))
            .take(passageLimit)
            .toList();

        // تعيين subtype = "passage"
        selectedPassages = selectedPassages.map((q) {
          q['subtype'] = 'passage';
          return q;
        }).toList();

        // دمج النوعين في قائمة وحدة
        finalQuestions = [...selectedVerbal, ...selectedPassages]..shuffle();

        // تعيين النوع الرئيسي Verbal
        finalQuestions = finalQuestions.map((q) {
          q['type'] = 'Verbal';
          return q;
        }).toList();
      }

      else if (questionType == "Quantitative") {
        // جلب الأسئلة الكمية من ملف JSON
        String mathJson = await rootBundle.loadString('assets/Math_questions.json');
        List<dynamic> mathQuestions = json.decode(mathJson);

        String mathPicJson = await rootBundle.loadString('assets/math_pic.json');
        List<dynamic> mathPicQuestions = json.decode(mathPicJson);

        mathQuestions.shuffle(); // عشوائي لأسئلة قبل الاختيار
        mathPicQuestions.shuffle(); // عشوائي لأسئلة قبل الاختيار

        int mathLimit = (limit * 0.8).round(); // 80% من الأسئلة الرياضية
        int picLimit = limit - mathLimit; // الباقي يكون لأسئلة الصور

        List<Map<String, dynamic>> selectedMathQuestions = mathQuestions
            .map((q) => _fixQuestionFormat(q as Map<String, dynamic>))
            .take(mathLimit)
            .toList();

        List<Map<String, dynamic>> selectedMathPicQuestions = mathPicQuestions
            .map((q) => _fixQuestionFormat(q as Map<String, dynamic>))
            .take(picLimit)
            .toList();

        // دمج الأسئلة الرياضية والأسئلة التي تحتوي على صور
        finalQuestions = [
          ...selectedMathQuestions,
          ...selectedMathPicQuestions,
        ]..shuffle();

        // إضافة نوع السؤال كـ "Quantitative"
        finalQuestions = finalQuestions.map((q) {
          q['type'] = 'Quantitative';  // إضافة أو تعديل 'type'
          return q;  // إرجاع السؤال المعدل
        }).toList();
        // تحديد نوع السؤال

      } else if (questionType == "Both") {
        // جلب الأسئلة الكمية
        String mathJson = await rootBundle.loadString('assets/Math_questions.json');
        List<dynamic> mathQuestions = json.decode(mathJson);

        String mathPicJson = await rootBundle.loadString('assets/math_pic.json');
        List<dynamic> mathPicQuestions = json.decode(mathPicJson);

        // فرضياً "limit" هو العدد الكلي للأسئلة
        int mathLimit = (limit * 0.3).round();   // 30% رياضي
        int verbalLimit = (limit * 0.5).round(); // 50% لفظي (عادي + نصوص)
        int otherLimit = limit - mathLimit - verbalLimit; // 20% صور

        mathQuestions.shuffle();
        mathPicQuestions.shuffle();

        List<Map<String, dynamic>> selectedMathQuestions = mathQuestions
            .map((q) => _fixQuestionFormat(q as Map<String, dynamic>))
            .take(mathLimit)
            .toList();

        List<Map<String, dynamic>> selectedMathPicQuestions = mathPicQuestions
            .map((q) => _fixQuestionFormat(q as Map<String, dynamic>))
            .take(otherLimit)
            .toList();

        // جلب الأسئلة اللفظية العادية
        String verbalJson = await rootBundle.loadString('assets/verbal_questions.json');
        List<dynamic> verbalQuestions = json.decode(verbalJson);

        // جلب أسئلة النصوص
        String passageJson = await rootBundle.loadString('assets/passages_questions_new.json');
        List<dynamic> passageQuestions = json.decode(passageJson);

        verbalQuestions.shuffle();
        passageQuestions.shuffle();

        // توزيع اللفظي: 80% عادي، 20% نصوص من داخل verbalLimit
        int passageLimit = (verbalLimit * 0.2).round();
        int regularVerbalLimit = verbalLimit - passageLimit;

        List<Map<String, dynamic>> selectedVerbalQuestions = verbalQuestions
            .map((q) => _fixQuestionFormat(q as Map<String, dynamic>))
            .take(regularVerbalLimit)
            .toList();

        List<Map<String, dynamic>> selectedPassageQuestions = passageQuestions
            .map((q) => _fixQuestionFormat(q as Map<String, dynamic>))
            .take(passageLimit)
            .toList();

        // ضبط الـ subtype
        selectedVerbalQuestions = selectedVerbalQuestions.map((q) {
          q['subtype'] = 'regular';
          return q;
        }).toList();

        selectedPassageQuestions = selectedPassageQuestions.map((q) {
          q['subtype'] = 'passage';
          return q;
        }).toList();

        List<Map<String, dynamic>> allVerbal = [
          ...selectedVerbalQuestions,
          ...selectedPassageQuestions,
        ];

        // دمج جميع الأسئلة وعمل shuffle
        finalQuestions = [
          ...selectedMathQuestions,
          ...selectedMathPicQuestions,
          ...allVerbal,
        ]..shuffle();

        // تعيين النوع لكل سؤال
        finalQuestions = finalQuestions.map((q) {
          if (q['subtype'] == 'regular' || q['subtype'] == 'passage') {
            q['type'] = 'Verbal';
          } else {
            q['type'] = 'Quantitative';
          }
          return q;
        }).toList();
      }


      print("✅ Fetched ${finalQuestions.length} questions for type: $questionType");
      return finalQuestions;
    } catch (e) {
      print("❌ Error loading questions: $e");
      return [];
    }
  }

  /// ✅ **إصلاح تنسيق `wrong_answers` إذا كان نصًا بدلًا من قائمة**
  Map<String, dynamic> _fixQuestionFormat(Map<String, dynamic> question) {
    if (question["wrong_answers"] is String) {
      question["wrong_answers"] = json.decode(question["wrong_answers"]); // ✅ تحويل النص إلى قائمة
    }
    return question;
  }
}
