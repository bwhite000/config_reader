library ConfigReader;

import "dart:io";
import "dart:async";

class ConfigReader {
  File configFile;
  final Map <String, dynamic> configData = <String, dynamic>{};

  ConfigReader(String rootPath, final String filename) {
    print('ConfigReader(String, String) [constructor]');

    // Add the Directory slash at the end if one was not provided before assembling filepath
    if (rootPath.endsWith('/') == false) {
      rootPath += '/';
    }

    this.configFile = new File(Uri.parse(rootPath + filename).toFilePath());
  }

  /**
   * This is a one-time read of the config file; no need to store any of the data in a new Object.
   */
  static Future<Map<String, dynamic>> readStaticConfig(String rootPath, final String filename) {
    print('ConfigReader->readStaticConfig()');

    final Completer completer = new Completer();

    // Add the Directory slash at the end if one was not provided before assembling filepath
    if (rootPath.endsWith('/') == false) {
      rootPath += '/';
    }

    // Read the config file
    new File(Uri.parse(rootPath + filename).toFilePath()).readAsLines().then((final List<String> fileLines) {
      final Map<String, dynamic> configData = <String, dynamic>{};

      // Loop through the config lines
      fileLines.forEach((final String line) {
        // Make sure this is a config data line (e.g. not a comment, section title, etc.)
        if (line.startsWith('[') == false && // section title
            line.startsWith('#') == false && // comment
            line.contains('=')) // other
        {
          final Map<String, dynamic> lineVal = ConfigReader._interpretLine(line);

          configData.addAll(lineVal);
        }
      });

      completer.complete(configData);
    }, onError: completer.completeError);

    return completer.future;
  }

  /**
   * Read the config file and return its values as key/value pairs.
   */
  Future<Map<String, dynamic>> readConfig() {
    print('ConfigReader.readConfig()');

    final Completer<Map<String, dynamic>> completer = new Completer<Map<String, dynamic>>();

    this.configFile.readAsLines().then((final List<String> fileLines) {
      // Loop through the config lines
      fileLines.forEach((final String line) {
        // Make sure this is a config data line (e.g. not a comment, section title, etc.)
        if (line.startsWith('[') == false && // section title
            line.startsWith('#') == false && // comment
            line.contains('=')) // other
        {
          final Map<String, dynamic> lineVal = ConfigReader._interpretLine(line);

          this.configData.addAll(lineVal);
        }
      });

      completer.complete(this.configData);
    }, onError: completer.completeError);

    return completer.future;
  }

  /**
   * Break the key/value pair from the String containing the "=" and return the created Map.
   */
  static Map<String, dynamic> _interpretLine(final String line) {
    final List<String> linePieces = line.split('=');
    dynamic valPiece;

    if (linePieces[1] == "false" || linePieces[1] == "true") {
      if (linePieces[1] == "false") {
        valPiece = false;
      } else if (linePieces[1] == "true") {
        valPiece = true;
      }
    } else if (new RegExp(r'^\d+$').hasMatch(linePieces[1])) {
      valPiece = int.parse(linePieces[1]);
    } else if (new RegExp(r'^\d+\.\d{1,10}$').hasMatch(linePieces[1])) {
      valPiece = double.parse(linePieces[1]);
    } else {
      valPiece = linePieces[1];
    }

    return <String, dynamic>{
      linePieces[0]: valPiece
    };
  }
}