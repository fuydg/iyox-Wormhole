import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iyox_wormhole/gen/ffi.dart';
import 'package:iyox_wormhole/pages/qrCodeScannerPage.dart';
import 'package:iyox_wormhole/pages/sendPage.dart';
import 'package:iyox_wormhole/type_helpers.dart';
import 'package:iyox_wormhole/utils/paths.dart';

class ReceivePage extends StatefulWidget {
  const ReceivePage({Key? key}) : super(key: key);

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  String code = '';
  int totalReceiveBytes = 0;
  int receivedBytes = 0;
  bool transferring = false;
  bool downloadStarted = false;

  StreamController<TUpdate> controller = StreamController<TUpdate>();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 2000),
        child: Padding(
          padding: const EdgeInsets.all(11.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: TextEditingController(text: code),
                      enabled: !transferring,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        label: Text('Code'),
                      ),
                      autocorrect: false,
                      onChanged: (value) =>
                          setState(
                                () => code = value,
                          ),
                    ),
                  ),
                  IconButton(
                      onPressed: !transferring
                          ? _onQrButtonClicked
                          : null,
                      icon: const Icon(Icons.qr_code)),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              FilledButton.icon(
                onPressed: !transferring ? _onReceiveButtonClick : null,
                style: largeButtonStyle,
                label: const Text('Receive'),
                icon: const Icon(Icons.download_outlined),
              ),
              if (transferring)
                Column(
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    LinearProgressIndicator(
                      value: downloadStarted ? receivedBytes / totalReceiveBytes : null,
                      minHeight: 14,
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onQrButtonClicked() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const QRScannerPage()));

    if (!mounted) return;

    if (result != null) {
      setState(() {
        code = result;
      });
    }

    _onReceiveButtonClick();
  }

  void _onReceiveButtonClick() async {
    //if (!isCodeValid(text) || !mounted) {
    //return;
    //}

    if (code.isEmpty) {
      return;
    }

    final downloadPath = await getDownloadPath() ?? '';

    debugPrint('code: $code');
    final stream = api.requestFile(passphrase: code, storageFolder: downloadPath);

    setState(() {
      transferring = true;
      downloadStarted = false;
    });

    stream.listen((e) {
      debugPrint(e.event.toString());
      switch (e.event) {
        case Events.StartTransfer:
          setState(() {
            downloadStarted = true;
          });
        case Events.Finished:
          setState(() {
            transferring = false;
          });
          break;

        case Events.Sent:
          setState(() {
            receivedBytes = e.getValue();
          });
          break;
        case Events.Total:
          setState(() {
            totalReceiveBytes = e.getValue();
          });
          break;

        case Events.Error:
          debugPrint('Error: ${e.getValue()}');

          setState(() {
            transferring = false;
          });
        case Events.ConnectionType:
        //connectionType = (e.value as Value_ConnectionType).field0;
        //connectionTypeName = (e.value as Value_ConnectionType).field1;
          break;
        default:
          break;
      }
    });
  }
}
