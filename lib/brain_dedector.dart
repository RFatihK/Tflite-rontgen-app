import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

class BrainDedector extends StatefulWidget {
  const BrainDedector({Key? key}) : super(key: key);

  @override
  State<BrainDedector> createState() => _BrainDedectorState();
}

class _BrainDedectorState extends State<BrainDedector> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  var _tanimaSonuclari;

  @override
  void initState() {
    super.initState();
    modeliYukle().then((value) {
      setState(() {});
    });
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

  void _sonucAlertGoster(List<dynamic> sonuclar) {
    String sonucMetni =
        'Sonuç: ${sonuclar[0]['label']} - Güvenilirlik: ${((sonuclar[0]['confidence'] ?? 0) * 100).toStringAsFixed(2)}%';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sonuçlar'),
          content: Column(
            children: [
              if (_image != null)
                Image.file(File(_image!.path),
                    height: 200, width: 200, fit: BoxFit.cover)
              else
                const Center(
                    child: Text(
                        'Beyin hastalığı  şüphesi taşıyan kişinin X-ray görüntüsünü yükleyin')),
              const SizedBox(height: 20),
              Text(sonucMetni),
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

  modeliYukle() async {
    await Tflite.loadModel(
      model: "assets/data/brain_converted_tflite/brain_model_unquant.tflite",
      labels: "assets/data/brain_converted_tflite/brain_labels.txt",
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

  Future<void> resmiCek() async {
    _resimSec(ImageSource.camera);
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
    print("Çıkarsama süresi ${bitisZamani - baslangicZamani}ms");

    setState(() {
      _tanimaSonuclari = tanimaSonuclari;
    });

    if (_tanimaSonuclari != null && _tanimaSonuclari.isNotEmpty) {
      _sonucAlertGoster(_tanimaSonuclari);
    }
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
                child: Text(
                    ' Beyin hastalığı şüphesi taşıyan kişinin X-ray görüntüsünü yükleyin'),
              ),
            const SizedBox(height: 100),
            ElevatedButton(
              onPressed: () => _resimSec(ImageSource.gallery),
              child: const Text('Galeriden Resim Seç'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: resmiCek,
              child: const Text('Kameradan Resim Çek'),
            ),
          ],
        ),
      ),
    );
  }
}
