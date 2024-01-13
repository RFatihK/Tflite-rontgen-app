import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

class BoneDetector extends StatefulWidget {
  const BoneDetector({Key? key}) : super(key: key);

  @override
  State<BoneDetector> createState() => _BoneDetectorState();
}

class _BoneDetectorState extends State<BoneDetector> {
  File? file;
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  var _tanimaSonuclari;

  @override
  void initState() {
    super.initState();
    modeliYukle().then((value) {
      setState(() {});
    });
  }

  modeliYukle() async {
    await Tflite.loadModel(
        model: "assets/data/bone_tflite/bone_tflite_model_unquant.tflite",
        labels: "assets/data/bone_tflite/bone_tflite_labels.txt");
  }

  Future<void> resmiTani(File resim) async {
    int baslangicZamani = DateTime.now().millisecondsSinceEpoch;
    var tanimaSonuclari = await Tflite.runModelOnImage(
      path: resim.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    int bitisZamani = DateTime.now().millisecondsSinceEpoch;

    setState(() {
      _tanimaSonuclari = tanimaSonuclari;
    });
    if (_tanimaSonuclari != null && _tanimaSonuclari.isNotEmpty) {
      _sonucAlertGoster(_tanimaSonuclari, baslangicZamani, bitisZamani);
    }
  }

  void _hataAlertGoster(String hataMesaji) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hata'),
          content: Text(hataMesaji),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resimSec(ImageSource kaynak) async {
    try {
      final XFile? resim = await _picker.pickImage(
        source: kaynak,
      );
      if (resim != null) {
        setState(() {
          _image = resim;
          file = File(resim.path);
        });
        resmiTani(file!);
      }
    } catch (e) {
      _hataAlertGoster('Resim seçme hatası: $e');
    }
  }

  Future<void> _resmiCek() async {
    _resimSec(ImageSource.camera);
  }

  void _sonucAlertGoster(
      List<dynamic> sonuclar, int baslangicZamani, int bitisZamani) {
    double confidence = (sonuclar[0]['confidence'] ?? 0) * 100;
    String hastalikLabel = sonuclar[0]['label'];

    String sonucMetni1 = 'Sonuç: ${confidence.toStringAsFixed(2)}% yüzdesi ile';
    String sonucMetni2 = '$hastalikLabel hastalığı saptandı.';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sonuçlar : ${bitisZamani - baslangicZamani}ms sürdü.'),
          content: Column(
            children: [
              if (_image != null)
                Image.file(File(_image!.path),
                    height: 200, width: 200, fit: BoxFit.cover)
              else
                const Center(
                    child: Text(
                  ' Kemik hastalığı  şüphesi taşıyan kişinin X-ray görüntüsünü yükleyin',
                )),
              const SizedBox(height: 20),
              Text(sonucMetni1),
              Text(sonucMetni2),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null)
              Image.file(
                File(_image!.path),
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              )
            else
              const Center(
                child: Center(
                  child: Text(
                      ' Kemik hastalığı şüphesi taşıyan kişinin X-ray görüntüsünü yükleyin '),
                ),
              ),
            const SizedBox(height: 100),
            ElevatedButton(
                onPressed: () => _resimSec(ImageSource.gallery),
                child: const Text('Galeriden Resim Seç')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resmiCek,
              child: const Text('Kameradan Resim Çek'),
            ),
          ],
        ),
      ),
    );
  }
}
