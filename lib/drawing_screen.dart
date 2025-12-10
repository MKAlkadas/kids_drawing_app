import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  // قائمة بجميع النقاط المرسومة
  List<DrawingPoint> drawingPoints = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 5.0;
  bool isErasing = false;

  List<Color> colors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.teal,
  ];

  // متغيرات لتتبع اللمس
  Offset? _previousPoint;
  bool _isDrawing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          '🎨 عالم الرسم السحري',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              setState(() {
                drawingPoints.clear();
              });
            },
          ),
          IconButton(
            icon: Icon(
              isErasing ? Icons.brush : Icons.auto_fix_normal,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isErasing = !isErasing;
                if (isErasing) {
                  selectedColor = Colors.white;
                } else {
                  selectedColor = colors.first;
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // لوحة الرسم
          Expanded(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.purple, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: DrawingPainter(drawingPoints),
                  size: Size.infinite,
                ),
              ),
            ),
          ),

          // أدوات التحكم
          _buildToolsBar(),
        ],
      ),

      // زر الحفظ
      floatingActionButton: FloatingActionButton(
        onPressed: _showSaveDialog,
        backgroundColor: Colors.green,
        child: const Icon(Icons.save, color: Colors.white),
      ),
    );
  }

  Widget _buildToolsBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // حجم الفرشاة
          Row(
            children: [
              const Text(
                'حجم الفرشاة:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Slider(
                  value: strokeWidth,
                  min: 2,
                  max: 30,
                  activeColor: Colors.purple,
                  onChanged: (value) {
                    setState(() {
                      strokeWidth = value;
                    });
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  strokeWidth.toStringAsFixed(0),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // الألوان
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: colors.length + 1,
              itemBuilder: (context, index) {
                if (index == colors.length) {
                  return GestureDetector(
                    onTap: _showColorPicker,
                    child: Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.purple, width: 2),
                      ),
                      child: const Icon(Icons.color_lens, color: Colors.purple),
                    ),
                  );
                }

                final color = colors[index];
                final isSelected = selectedColor == color && !isErasing;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = color;
                      isErasing = false;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // وظائف التعامل مع اللمس
  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDrawing = true;
      _previousPoint = details.localPosition;

      drawingPoints.add(
        DrawingPoint(
          points: [details.localPosition],
          color: isErasing ? Colors.white : selectedColor,
          strokeWidth: strokeWidth,
        ),
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDrawing || _previousPoint == null) return;

    setState(() {
      final currentPoint = details.localPosition;

      // إضافة نقطة جديدة
      drawingPoints.last.points.add(currentPoint);

      // للحصول على خط أكثر سلاسة، نضيف نقاط بينية
      final distance = (currentPoint - _previousPoint!).distance;
      if (distance > 10) {
        _previousPoint = currentPoint;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDrawing = false;
      _previousPoint = null;

      // إضافة نقطة فارغة للإشارة إلى نهاية الخط
      drawingPoints.add(
        DrawingPoint(points: [], color: Colors.transparent, strokeWidth: 0),
      );
    });
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('اختر لون مخصص'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                setState(() {
                  selectedColor = color;
                  isErasing = false;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('تم', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.yellow[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Column(
            children: [
              Icon(Icons.celebration, size: 60, color: Colors.purple),
              SizedBox(height: 10),
              Text(
                'أحسنت! 🎨',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          content: const Text(
            'رسمتك رائعة!\nيمكنك الاستمرار في الرسم أو مشاركته مع أصدقائك.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('متابعة الرسم'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // هنا يمكن إضافة وظيفة حفظ حقيقية
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                    child: const Text(
                      'حفظ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class DrawingPoint {
  List<Offset> points;
  Color color;
  double strokeWidth;

  DrawingPoint({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;

  DrawingPainter(this.drawingPoints);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < drawingPoints.length; i++) {
      final drawingPoint = drawingPoints[i];

      if (drawingPoint.points.isNotEmpty) {
        final paint = Paint()
          ..color = drawingPoint.color
          ..strokeWidth = drawingPoint.strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..isAntiAlias = true;

        // رسم الخطوط
        for (int j = 0; j < drawingPoint.points.length - 1; j++) {
          final startPoint = drawingPoint.points[j];
          final endPoint = drawingPoint.points[j + 1];

          if (startPoint.dx.isFinite &&
              startPoint.dy.isFinite &&
              endPoint.dx.isFinite &&
              endPoint.dy.isFinite) {
            canvas.drawLine(startPoint, endPoint, paint);
          }
        }

        // رسم نقاط فردية للأماكن التي لم تكن فيها حركة كافية
        if (drawingPoint.points.length == 1) {
          canvas.drawCircle(
            drawingPoint.points.first,
            drawingPoint.strokeWidth / 2,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
