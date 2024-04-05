import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:quick_usb/quick_usb.dart';

void main() {
  runApp(MyHome());
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: MyApp(),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return _buildColumn();
  }

  void log(String info) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(info)));
  }

  Widget _buildColumn() {
    return Column(
      children: [
        _init_exit(),
        _getDeviceList(),
        _getDevicesWithDescription(),
        _getDeviceDescription(),
        if (Platform.isLinux) _setAutoDetachKernelDriver(),
        _has_request(),
        _open_close(),
        _get_set_configuration(),
        _claim_release_interface(),
        _bulk_transfer(),
      ],
    );
  }

  Widget _init_exit() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          child: Text('init'),
          onPressed: () async {
            var init = await QuickUsb.init();
            log('init $init');
          },
        ),
        TextButton(
          child: Text('exit'),
          onPressed: () async {
            await QuickUsb.exit();
            log('exit');
          },
        ),
      ],
    );
  }

  List<UsbDevice> _deviceList=[];

  Widget _getDeviceList() {
    return TextButton(
      child: Text('getDeviceList'),
      onPressed: () async {
        _deviceList = await QuickUsb.getDeviceList();
        log('deviceList $_deviceList');
      },
    );
  }

  Widget _has_request() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          child: Text('hasPermission'),
          onPressed: () async {
            var hasPermission = await QuickUsb.hasPermission(_deviceList.first);
            log('hasPermission $hasPermission');
          },
        ),
        TextButton(
          child: Text('requestPermission'),
          onPressed: () async {
            await QuickUsb.requestPermission(_deviceList.first);
            log('requestPermission');
          },
        ),
      ],
    );
  }

  Widget _open_close() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          child: Text('openDevice'),
          onPressed: () async {
            var openDevice = await QuickUsb.openDevice(_deviceList.first);
            log('openDevice $openDevice');
          },
        ),
        TextButton(
          child: Text('closeDevice'),
          onPressed: () async {
            await QuickUsb.closeDevice();
            log('closeDevice');
          },
        ),
      ],
    );
  }

  late UsbConfiguration _configuration;

  Widget _get_set_configuration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          child: Text('getConfiguration'),
          onPressed: () async {
            _configuration = await QuickUsb.getConfiguration(0);
            log('getConfiguration $_configuration');
          },
        ),
        TextButton(
          child: Text('setConfiguration'),
          onPressed: () async {
            var setConfiguration =
                await QuickUsb.setConfiguration(_configuration);
            log('setConfiguration $setConfiguration');
          },
        ),
      ],
    );
  }

  Widget _claim_release_interface() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          child: Text('claimInterface'),
          onPressed: () async {
            var claimInterface =
                await QuickUsb.claimInterface(_configuration.interfaces[0]);
            log('claimInterface $claimInterface');
          },
        ),
        TextButton(
          child: Text('releaseInterface'),
          onPressed: () async {
            var releaseInterface =
                await QuickUsb.releaseInterface(_configuration.interfaces[0]);
            log('releaseInterface $releaseInterface');
          },
        ),
      ],
    );
  }

  Widget _bulk_transfer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          child: Text('bulkTransferIn'),
          onPressed: () async {
            var endpoint = _configuration.interfaces[0].endpoints
                .firstWhere((e) => e.direction == UsbEndpoint.DIRECTION_IN);
            var bulkTransferIn = await QuickUsb.bulkTransferIn(endpoint, 1024);
            log('bulkTransferIn ${hex.encode(bulkTransferIn)}');
          },
        ),
        TextButton(
          child: Text('bulkTransferOut'),
          onPressed: () async {
            var data = Uint8List.fromList(utf8.encode(''));
            var endpoint = _configuration.interfaces[0].endpoints
                .firstWhere((e) => e.direction == UsbEndpoint.DIRECTION_OUT);
            var bulkTransferOut =
                await QuickUsb.bulkTransferOut(endpoint, data);
            log('bulkTransferOut $bulkTransferOut');
          },
        ),
      ],
    );
  }

  Widget _getDevicesWithDescription() {
    return TextButton(
      child: Text('getDevicesWithDescription'),
      onPressed: () async {
        var descriptions = await QuickUsb.getDevicesWithDescription();
        _deviceList = descriptions.map((e) => e.device).toList();
        print('descriptions $descriptions');
      },
    );
  }

  Widget _getDeviceDescription() {
    return TextButton(
      child: Text('getDeviceDescription'),
      onPressed: () async {
        var description =
            await QuickUsb.getDeviceDescription(_deviceList.first);
        print('description ${description.toMap()}');
      },
    );
  }

  bool _autoDetachEnabled = false;
  Widget _setAutoDetachKernelDriver() {
    return TextButton(
      child: Text('setAutoDetachKernelDriver'),
      onPressed: () async {
        await QuickUsb.setAutoDetachKernelDriver(!_autoDetachEnabled);
        _autoDetachEnabled = !_autoDetachEnabled;
        log('setAutoDetachKernelDriver: $_autoDetachEnabled');
      },
    );
  }
}
