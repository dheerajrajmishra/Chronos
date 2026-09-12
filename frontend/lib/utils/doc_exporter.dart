import 'dart:html' as html;
import 'dart:convert';
import 'package:markdown/markdown.dart' as md;

class DocExporter {
  static void downloadAsWord(String markdownContent, String filename) {
    // 1. Convert Markdown to HTML
    final htmlContent = md.markdownToHtml(markdownContent);
    
    // 2. Wrap in Word-compatible HTML structure
    final wordHtml = '''
<html xmlns:o='urn:schemas-microsoft-com:office:office' 
      xmlns:w='urn:schemas-microsoft-com:office:word' 
      xmlns='http://www.w3.org/TR/REC-html40'>
<head>
  <meta charset="utf-8">
  <title>Document</title>
  <style>
    body { font-family: "Calibri", "Arial", sans-serif; line-height: 1.6; }
    h1 { color: #2c3e50; font-size: 24pt; border-bottom: 1px solid #ccc; padding-bottom: 4px; }
    h2 { color: #34495e; font-size: 18pt; margin-top: 16px; }
    h3 { color: #34495e; font-size: 14pt; margin-top: 12px; }
    table { border-collapse: collapse; width: 100%; margin: 16px 0; }
    th, td { border: 1px solid #bdc3c7; padding: 8px; text-align: left; }
    th { background-color: #ecf0f1; }
    code { background-color: #f8f9fa; padding: 2px 4px; font-family: "Courier New", monospace; }
    pre { background-color: #f8f9fa; padding: 12px; border: 1px solid #e9ecef; border-radius: 4px; }
    blockquote { border-left: 4px solid #6366f1; margin: 0; padding-left: 16px; color: #6b7280; }
  </style>
</head>
<body>
  $htmlContent
</body>
</html>
''';

    // 3. Trigger download as .docx file
    final bytes = utf8.encode(wordHtml);
    final blob = html.Blob([bytes], 'application/msword');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename.endsWith('.docx') ? filename : '$filename.docx')
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
