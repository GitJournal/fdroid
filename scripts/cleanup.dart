import 'dart:io';

const numOldBuilds = 5;

void main() {
  var cwd = Directory.current.path;
  var reposDir = '$cwd/repo';

  var devBuilds = <String>[];
  var prodBuilds = <String>[];

  for (var f in Directory(reposDir).listSync()) {
    if (f.statSync().type != FileSystemEntityType.file) continue;

    var name = f.path.substring(f.path.lastIndexOf('/') + 1);
    if (!name.endsWith('.apk')) continue;

    var isDev = name.contains('gitjournal.dev');
    if (isDev) {
      devBuilds.add(name);
    } else {
      prodBuilds.add(name);
    }
  }

  devBuilds.sort();
  devBuilds = devBuilds.sublist(0, devBuilds.length - 5);

  var devVc = parseVersionCode('metadata/io.gitjournal.gitjournal.dev.yml');

  for (var name in devBuilds) {
    if (fetchVersionCode(name) == devVc) continue;

    var fullPath = '$reposDir/$name';
    File(fullPath).deleteSync();
    File('$fullPath.asc').deleteSync();
  }

  prodBuilds.sort();
  prodBuilds = prodBuilds.sublist(0, prodBuilds.length - 5);

  var prodVc = parseVersionCode('metadata/io.gitjournal.gitjournal.yml');

  for (var name in prodBuilds) {
    if (fetchVersionCode(name) == prodVc) continue;

    var fullPath = '$reposDir/$name';
    File(fullPath).deleteSync();
    File('$fullPath.asc').deleteSync();
  }

  Directory('$reposDir/icons').deleteSync(recursive: true);
  Directory('$reposDir/icons-120').deleteSync(recursive: true);
  Directory('$reposDir/icons-160').deleteSync(recursive: true);
  Directory('$reposDir/icons-240').deleteSync(recursive: true);
  Directory('$reposDir/icons-320').deleteSync(recursive: true);
  Directory('$reposDir/icons-480').deleteSync(recursive: true);
  Directory('$reposDir/icons-640').deleteSync(recursive: true);
}

int fetchVersionCode(String name) {
  if (!name.endsWith('.apk')) throw Exception('Must be an apk file');

  var withoutExt = name.substring(0, name.lastIndexOf('.'));
  return int.parse(name.substring(withoutExt.length - 4, withoutExt.length));
}

int parseVersionCode(String filePath) {
  const h = 'CurrentVersionCode: ';
  var contents = File(filePath).readAsLinesSync();
  for (var c in contents) {
    if (!c.startsWith(h)) continue;
    return int.parse(c.substring(h.length));
  }

  return 0;
}
