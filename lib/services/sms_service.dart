import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

// TODO: Firebase Dynamic Links is deprecated and will be shut down in August 2025.
// We need to migrate to an alternative solution before then.
class SMSService {
  final FirebaseDynamicLinks _dynamicLinks;

  SMSService(this._dynamicLinks);

  Future<void> sendInvite({
    required String phoneNumber,
    required String message,
    String? relationshipId,
  }) async {
    try {
      // Create a dynamic link for the invitation
      final dynamicLinkParams = DynamicLinkParameters(
        uriPrefix: 'https://interquatier.page.link',
        link: Uri.parse('https://interquatier.com/invite?relationshipId=$relationshipId'),
        androidParameters: const AndroidParameters(
          packageName: 'com.interquatier.app',
          minimumVersion: 0,
        ),
        iosParameters: const IOSParameters(
          bundleId: 'com.interquatier.app',
          minimumVersion: '0',
        ),
      );

      final dynamicLink = await _dynamicLinks.buildShortLink(dynamicLinkParams);
      final inviteUrl = dynamicLink.shortUrl.toString();

      // Format the phone number
      final formattedPhone = phoneNumber.startsWith('+') 
          ? phoneNumber 
          : '+$phoneNumber';

      // Launch SMS app with pre-filled message
      final uri = Uri.parse(
        'sms:$formattedPhone?body=${Uri.encodeComponent('$message\n\n$inviteUrl')}',
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch SMS app';
      }
    } catch (e) {
      rethrow;
    }
  }
}

final smsServiceProvider = Provider<SMSService>((ref) {
  return SMSService(FirebaseDynamicLinks.instance);
}); 