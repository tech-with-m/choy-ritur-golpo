import 'package:get/get.dart';
import 'package:choy_ritur_golpo/translation/bn_in.dart';
import 'package:choy_ritur_golpo/translation/en_us.dart';

class Translation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': EnUs().messages,
    'bn_IN': BnIn().messages,
  };
}
