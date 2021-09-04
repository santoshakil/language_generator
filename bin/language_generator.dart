import 'dart:async';
import 'dart:io';

import 'package:translator/translator.dart';

Future<void> main(List<String> arguments) async {
  final translator = GoogleTranslator();
  var _dir = Directory('/home/santo/Projects/Flutter/flutterc/lib');
  var _fileEN = File('Generated/app_en.arb');
  var _fileBN = File('Generated/app_bn.arb');
  var _files = _dir.listSync(recursive: true).whereType<File>().toList();
  var _listOfString = <String>[];
  var _counter = 0;

  for (var file in _files) {
    var _lines = file.readAsLinesSync();
    for (var line in _lines) {
      line = line.trim();
      // Pattern 1
      if (line.contains('Text(\'') && line.contains('\')')) {
        var _string = line.substring(line.indexOf('Text(\'') + 6);
        _string = _string.substring(0, _string.indexOf('\')'));

        if (!_listOfString.contains(_string) && _string.isNotEmpty) {
          _listOfString.add(_string);
        }
      }
      // Pattern 2
      if (line.contains('text: \'') && line.contains('\',')) {
        var _string = line.substring(line.indexOf('text: \'') + 7);
        _string = _string.substring(0, _string.indexOf('\','));

        if (!_listOfString.contains(_string) && _string.isNotEmpty) {
          _listOfString.add(_string);
        }
      }
      // Pattern 3
      if (line.startsWith("'") &&
          line.endsWith("',") &&
          !line.contains('assets/')) {
        var _string = line.substring(1, line.length - 2);

        if (!_listOfString.contains(_string) && _string.isNotEmpty) {
          _listOfString.add(_string);
        }
      }
    }
  }

  _fileEN.writeAsStringSync('{\n');
  _fileBN.writeAsStringSync('{\n');

  for (var string in _listOfString) {
    _counter++;
    print('Translating: $string');

    var _translation = await translator.translate(string, to: 'bn');
    var _key =
        (string[0].toLowerCase() + string.substring(1)).replaceAll(' ', '');

    print(
        'Translated $_counter/${_listOfString.length} :: ' + _translation.text);

    _fileEN.writeAsStringSync(
      '  "' + _key + '": "' + string + '",\n',
      mode: FileMode.append,
    );
    _fileBN.writeAsStringSync(
      '  "' + _key + '": "' + _translation.text + '",\n',
      mode: FileMode.append,
    );
  }

  _fileEN.writeAsStringSync('}\n', mode: FileMode.append);
  _fileBN.writeAsStringSync('}\n', mode: FileMode.append);
}
