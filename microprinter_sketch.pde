#include <SoftwareSerial.h>

#define rxPin 6
#define txPin 7

SoftwareSerial printer = SoftwareSerial(rxPin, txPin);

const byte command = 0x1B;

const byte fullcut = 0x69;
const byte partialcut = 0x6D;

const byte doubleprint = 0x47;
const byte flipchars = 0x7B;
const byte rotatechars = 0x56;

const byte commandBarcode = 0x1D;
const byte commandBarcodePrint = 0x6B;
const byte commandBarcodeWidth = 0x77;
const byte commandBarcodeHeight = 0x68;
const byte commandBarcodeTextPosition = 0x48;

const byte barcodeNarrow = 0x02;
const byte barcodeMedium = 0x03;
const byte barcodeWide = 0x04;

const byte barcodePrintNone = 0x00;
const byte barcodePrintAbove = 0x01;
const byte barcodePrintBelow = 0x02;
const byte barcodePrintBoth = 0x03;

// (0 = UPC-A, 1 = UPC-E, 2 = JAN13 (EAN), 3 = JAN 8 (EAN), 
//  4 = code 39, 5 = ITF, 6 = codabar, 7 = code 128)
const byte barcodeModeUPCA = 0x00;
const byte barcodeModeUPCE = 0x01;
const byte barcodeModeJAN13AEN = 0x02;
const byte barcodeModeJAN8EAN = 0x03;
const byte barcodeModeCODE39 = 0x04;
const byte barcodeModeITF= 0x05;
const byte barcodeModeCODEABAR= 0x06;
const byte barcodeModeCODE128 = 0x07;

void setup() {
  pinMode(rxPin, INPUT);
  pinMode(txPin, OUTPUT);
  printer.begin(9600);
  Serial.begin(9600); //open the USB connection too

  delay(1000);

  feed();
  
  println("Hello, World!");
  
  feed();
  
  setBarcodeHeight(50);
  setBarcodeWidth(barcodeNarrow);
  setBarcodeTextPosition(barcodePrintBelow);
  printBarcode("123456789012");
  
  feed();
  cut();
}

void print(char text[]) {
  printer.print(text);
}

void println(char text[]) {
  printer.println(text);
}

void printBarcode(char barcode[]) {
  printBarcode(barcode, barcodeModeUPCA);
}

void feed() {
  printer.println("");
  printer.println("");
  printer.println("");
}

void cut() {
  printer.print(command, BYTE);
  printer.print(fullcut, BYTE);
}

void partialCut() {
  printer.print(command, BYTE);
  printer.print(partialcut, BYTE);
}

void printBarcode(char barcode[], byte barcodeMode) {
  printer.print(commandBarcode, BYTE); //"[1D]h + [6B]h + n + Dn + [00]h"
  printer.print(commandBarcodePrint, BYTE); 
  printer.print(barcodeMode, BYTE); //barcode system. 
  printer.print(barcode);  //barcode value
  printer.print(0x00, BYTE); //end barcode sequence
}

void setBarcodeHeight(byte height) { //in dots. default = 162
  printer.print(commandBarcode, BYTE); //"[1d]H + [68]H + N"
  printer.print(commandBarcodeHeight, BYTE); 
  printer.print(height, BYTE); //barcode height in dots. default = 162
}

void setBarcodeWidth(byte width) { // 2, 3 or 4. default = 3
  if (width < 2) width = 2;
  if (width > 4) width = 4;
  printer.print(commandBarcode, BYTE); //"[1d]H + [77]H + N" (where N = 2, 3 or 4)
  printer.print(commandBarcodeWidth, BYTE);
  printer.print(width, BYTE); 
}

void setBarcodeTextPosition(byte position) {
  if (position < 0) position = 0;
  if (position > 3) position = 3;
  printer.print(commandBarcode, BYTE); // "[1d]H + [48]H + N"
  printer.print(commandBarcodeTextPosition, BYTE);
  printer.print(position, BYTE); // 0 = none, 1 = above, 2 = below, 3 = both
}

void setDoublePrintOn() {
  setDoublePrint(0x01);
}

void setDoublePrintOff() {
  setDoublePrint(0x00);
}

void setDoublePrint(byte mode) {
  printer.print(command, BYTE);
  printer.print(doubleprint, BYTE);
  printer.print(mode, BYTE);
}

void loop() {
  // while there are bytes to read from the computer, retransmit them
  if (Serial.available() > 0) {
    byte inchar = Serial.read();
    printer.print(inchar);
  }
}
