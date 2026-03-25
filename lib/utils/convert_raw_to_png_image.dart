import 'dart:convert';
import 'package:image/image.dart' as img;

String convertRawToPngBase64(
  List<int> bytes,
  int width,
  int height,
  String encoding,
) {
  img.Image image = img.Image(width: width, height: height);

  int pixelIndex = 0;
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      if (encoding == "rgb8") {
        image.setPixelRgb(
          x,
          y,
          bytes[pixelIndex],
          bytes[pixelIndex + 1],
          bytes[pixelIndex + 2],
        );
        pixelIndex += 3;
      } else if (encoding == "bgr8") {
        image.setPixelRgb(
          x,
          y,
          bytes[pixelIndex + 2],
          bytes[pixelIndex + 1],
          bytes[pixelIndex],
        );
        pixelIndex += 3;
      }
    }
  }

  final pngBytes = img.encodePng(image);
  return base64Encode(pngBytes);
}
