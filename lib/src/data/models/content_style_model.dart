part of "note_model.dart";

enum ContentStyleByWord { normal, bold, italic, underline }

enum ContentStyleByLine { nomal, h1, h2 }

TextStyle getTextStyle(
  ContentStyleByWord byWord,
  ContentStyleByLine byLine,
) {
  FontWeight fontWeight = FontWeight.normal;
  FontStyle fontStyle = FontStyle.normal;
  TextDecoration textDecoration = TextDecoration.none;
  double fontSize = 13;

  if (byWord == ContentStyleByWord.bold) {
    fontWeight = FontWeight.bold;
  } else if (byWord == ContentStyleByWord.italic) {
    fontStyle = FontStyle.italic;
  } else if (byWord == ContentStyleByWord.underline) {
    textDecoration = TextDecoration.underline;
  }

  if (byLine == ContentStyleByLine.h1) {
    fontSize = 16;
  } else if (byLine == ContentStyleByLine.h2) {
    fontSize = 18;
  }

  return TextStyle(
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    decoration: textDecoration,
    fontSize: fontSize,
  );
}
