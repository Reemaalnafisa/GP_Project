import 'package:cloud_firestore/cloud_firestore.dart';

class ParentConnectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// إرسال طلب اتصال من حساب الوالد إلى حساب الطفل
  Future<void> sendConnectionRequest({
    required String parentId,
    required String parentEmail,
    required String childEmail,
    required String parentName,
    String? childName,

  }) async {
    try {
      await _firestore.collection('connection_requests').add({
        'parentId': parentId,
        'parentEmail': parentEmail,
        'parentName':parentName,
        'childEmail': childEmail,
        'childName': childName,
        'status': 'Pending', // الحالة الابتدائية
        'timestamp': FieldValue.serverTimestamp(),
      });
      // هنا يمكن إضافة كود لإرسال إشعار للطالب باستخدام Firebase Cloud Messaging أو أي خدمة إشعارات أخرى
    } catch (e) {
      print("Error sending connection request: $e");
    }
  }

  Future<void> updateConnectionRequestStatus({
    required String requestId,
    required String newStatus,
  }) async {
    try {
      DocumentReference requestRef =
      _firestore.collection('connection_requests').doc(requestId);

      // الحصول على بيانات الطلب الحالي
      DocumentSnapshot requestSnapshot = await requestRef.get();
      if (!requestSnapshot.exists) {
        print("Request not found");
        return;
      }
      Map<String, dynamic> requestData =
      requestSnapshot.data() as Map<String, dynamic>;

      // تحديث حالة الطلب
      await requestRef.update({
        'status': newStatus,
      });

      // إذا كانت الحالة "approved"، نقوم بتحديث حقل children في مستند الوالد
      if (newStatus.toLowerCase() == 'approved') {
        String parentId = requestData['parentId'];
        String childEmail = requestData['childEmail'];

        await _firestore.collection('users').doc(parentId).update({
          'children': FieldValue.arrayUnion([childEmail]),
        });
      }
    } catch (e) {
      print("Error updating connection request status: $e");
    }
  }



  /// الاستماع لطلبات الاتصال الخاصة بالطفل (يمكن استخدامه في واجهة الطالب للإشعارات)
  Stream<QuerySnapshot> connectionRequestsStreamForChild({required String childEmail}) {
    return _firestore.collection('connection_requests')
        .where('childEmail', isEqualTo: childEmail)
        .snapshots();
  }

  /// الاستماع لطلبات الاتصال التي أرسلها الوالد (يمكن استخدامها لتحديث الواجهة عند تغيير الحالة)
  Stream<QuerySnapshot> connectionRequestsStreamForParent({required String parentId}) {
    return _firestore.collection('connection_requests')
        .where('parentId', isEqualTo: parentId)
        .snapshots();

  }
}
