import 'dart:io';
import 'dart:math';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:excel/excel.dart';

import 'package:flutter_application_1_o/colores.dart';

final Color darkBlue = Color.fromARGB(255, 254, 254, 254);

class DemoApp extends StatefulWidget {
  DemoApp({
    Key? key,
  }) : super(key: key);

  @override
  _DemoAppState createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  FilePickerResult? result;
  String? _filename;
  PlatformFile? pickedfile;
  bool isLoading = false;
  File? fileToDisplay;
  List<_SalesData> data = [];
  List<_SalesData> data1 = [];

  List f = [];
  List e = [];
  List a = [];
  List g = [];

  var maxnm;

//filepici
  void pickfile() async {
    try {
      setState(() {
        isLoading = true;
      });
      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null) {
        _filename = result!.files.first.name;
        pickedfile = result!.files.first;
        fileToDisplay = File(pickedfile!.path.toString());
        print('File Name $_filename');
        var file = pickedfile!.path.toString();
        var bytes = File(file).readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        for (var table in excel.tables.keys) {
          print(table); //sheet Name

          var maxnm = excel.tables[table]?.maxRows;
          print('max row $maxnm');
          for (var row in excel.tables[table]!.rows) {
            // ignore: prefer_typing_uninitialized_variables
            a = row;
            var maxnum = excel.tables[table]?.maxRows;
            //mathe formul
            var d = a[0]; //Depth
            var p = a[1]; //pore pressure gradiant
            var pr = 0.4; // poison Ratio
            var o = 1; //over-burden gradient
            double fg; //fraetuze gradient
            var ppr = pr / (1 - pr);
            var op = (o - p);
            var oppr = ppr * op;
            fg = oppr + p;

            fg = roundDouble(fg, 2); // fg in psi

            print('FG $fg');
            double dd = d.toDouble();
            double dp = p.toDouble();
            dp = 19.25 * dp;

            double rdp = roundDouble(
                dp, 2); //roundede & converted pore pressure gradiant

            print('RDP$rdp');

            f.add(dd);
            g.add(rdp);
            e.add(fg * 100);
          }
        }
        print('f $f');
        print('g $g');
        print(g.length);
        int max = g.length;
        for (var i = 0; i <= max - 1; i++) {
          data.add(
            _SalesData(g[i], f[i], e[i]),
          );
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (f) {
      print(f);
    }

    data1 = [];
    f.clear();
    g.clear();
  }

  late ZoomPanBehavior _zoom;

  @override
  void initState() {
    _zoom = ZoomPanBehavior(
        enableDoubleTapZooming: true,
        enablePinching: true,
        enableMouseWheelZooming: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 203, 223, 235),
      appBar: AppBar(
        backgroundColor: deepPurple400,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(40),
          ),
        ),
        title: const Text(
          "Petro",
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Center(
            child: isLoading
                ? CircularProgressIndicator()
                : TextButton(
                    onPressed: () {
                      pickfile();
                      data.clear();
                    },
                    child: const Text(
                      "Uplod Exle File",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
          ),
          SfCartesianChart(
              zoomPanBehavior: _zoom,
              primaryXAxis: CategoryAxis(opposedPosition: true),
              primaryYAxis: NumericAxis(
                  // X axis will be inversed
                  isInversed: true,
                  interval: 0.1,
                  minimum: 0),
              // Chart title

              // Enable legend
              legend: Legend(isVisible: true),
              // Enable tooltip
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries<_SalesData, double>>[
                SplineSeries<_SalesData, double>(
                    dataSource: data,
                    xValueMapper: (_SalesData sales, _) => sales.Depth,
                    yValueMapper: (_SalesData sales, _) => sales.porep,
                    name: 'PPG',
                    // Enable data label
                    dataLabelSettings: DataLabelSettings(isVisible: true)),
                SplineSeries<_SalesData, double>(
                    dataSource: data,
                    xValueMapper: (_SalesData sales, _) => sales.Depth,
                    yValueMapper: (_SalesData sales, _) => sales.fg,
                    name: 'FG',
                    // Enable data label
                    dataLabelSettings: DataLabelSettings(isVisible: true)),
              ]),
        ],
      ),
    );
  }
}

class _SalesData {
  _SalesData(this.porep, this.Depth, this.fg);

  final double porep;
  final double Depth;
  final double fg;
}

double roundDouble(double value, int places) {
  num mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}
