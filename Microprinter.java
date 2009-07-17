//A library for dealing with a serial printer. Specifically, developed and tested for the Citizen CBM 231 printer.
//
// depending on your setup and OS, create a new object using e.g. new Microprinter("/dev/cu.usbserial-A1001NFW")
// 
// http://rooreynolds.com/category/microprinter/
// http://microprinter.pbwiki.com/

//TODO - long text chunks drop chars after 40ish buffered lines (line = 65 chars at B font)
//TODO: implement printImage() properly. Idea: take an image file?
//TODO: using printMarkup(), *highlighting* _currently_ works for individual words. Make work for whole lines too?
//TODO: implement flip() and rotate();

package com.rooreynolds.microprinter;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.StringTokenizer;

public class Microprinter {

	private FileOutputStream fileout;
	private PrintWriter printer;
	
	static byte COMMAND = 0x1B;

	static byte FULLCUT = 0x69;
	static byte PARTIALCUT = 0x6D;

	static byte PRINT_MODE = 0x21;
	static byte DOUBLEPRINT = 0x47;
	static byte UNDERLINE = 0x2D;

	static byte COMMAND_IMAGE = 0x2A;
	static byte COMMAND_FLIPCHARS = 0x7B; //TODO
	static byte COMMAND_RORATECHARS = 0x56; //TODO

	static byte COMMAND_BARCODE = 0x1D;
	static byte COMMAND_BARCODE_PRINT = 0x6B;
	static byte COMMAND_BARCODE_WIDTH = 0x77;
	static byte COMMAND_BARCODE_HEIGHT = 0x68; 
	static byte COMMAND_BARCODE_TEXTPOSITION = 0x48;
	static byte COMMAND_BARCODE_FONT = 0x66;

	static byte BARCODE_WIDTH_NARROW = 0x02;
	static byte BARCODE_WIDTH_MEDIUM = 0x03;
	static byte BARCODE_WIDTH_WIDE = 0x04;

	static byte BARCODE_TEXT_NONE = 0x00;
	static byte BARCODE_TEXT_ABOVE = 0x01;
	static byte BARCODE_TEXT_BELOW = 0x02;
	static byte BARCODE_TEXT_BOTH = 0x03;

	static byte BARCODE_MODE_UPCA = 0x00;
	static byte BARCODE_MODE_UPCE = 0x01;
	static byte BARCODE_MODE_JAN13AEN = 0x02;
	static byte BARCODE_MODE_JAN8EAN = 0x03;
	static byte BARCODE_MODE_CODE39 = 0x04;
	static byte BARCODE_MODE_ITF = 0x05;
	static byte BARCODE_MODE_CODEABAR = 0x06;
	static byte BARCODE_MODE_CODE128 = 0x07;

	public Microprinter(String path) {
		try{ 
			fileout = new FileOutputStream(path);
			printer = new PrintWriter(fileout);
		} catch (IOException ioe) {
			System.err.println("Error: " + ioe.getMessage());
		}
	}
	
	void close() throws IOException {
		printer.close();
		fileout.close();
	}

	void feed() {
		printer.println("\n\n");
	}

	void setPrintMode(byte i) throws IOException { // 0 = font A, 1 = font B
		printer.write(COMMAND); //  [1Bh] + [21h] + n
		printer.write(PRINT_MODE);
		printer.write(i);
		printer.flush();
	}

	void printBarcode(String barcode) {
		printBarcode(BARCODE_MODE_CODE39, barcode);
	}	

	void printBarcode(byte barcodeMode, String barcode) {
		printer.write(COMMAND_BARCODE); //"[1D]h + [6B]h + n + Dn + [00]h"
		printer.write(COMMAND_BARCODE_PRINT); 
		printer.write(barcodeMode); //barcode system. 
		printer.write(barcode);  //barcode value
		printer.write(0x00); //end barcode sequence
	}

	void setBarcodeHeight(byte height) throws IOException { //in dots. default = 162
		printer.write(COMMAND_BARCODE); //"[1d]H + [68]H + N"
		printer.write(COMMAND_BARCODE_HEIGHT); 
		printer.write(height); //barcode height in dots. default = 162
		printer.flush();
	}

	void setBarcodeWidth(byte width) throws IOException { // 2, 3 or 4. default = 3
		if (width < 2) width = 2;
		if (width > 4) width = 4;
		printer.write(COMMAND_BARCODE); //"[1d]H + [77]H + N" (where N = 2, 3 or 4)
		printer.write(COMMAND_BARCODE_WIDTH);
		printer.write(width); 
		printer.flush();
	}

	void setBarcodeTextPosition(byte position) {
		if (position < 0) position = 0;
		if (position > 3) position = 3;
		printer.write(COMMAND_BARCODE); // "[1d]H + [48]H + N"
		printer.write(COMMAND_BARCODE_TEXTPOSITION);
		printer.write(position); // 0 = none, 1 = above, 2 = below, 3 = both
		printer.flush();
	}

	void setBarcodeFont(byte font) { //0 = A, 1 = B
		if (font < 0) font = 0;
		if (font > 1) font = 1;
		printer.write(COMMAND_BARCODE); // "[1D]h + [66]h + n"
		printer.write(COMMAND_BARCODE_FONT);
		printer.write(font); // 0 = A, 1 = B
		printer.flush();
	} 

	void printText(String message) {
		System.out.println(message);
		printer.print(message);
	}

	void printMarkup(String message) throws IOException {
		StringTokenizer st = new StringTokenizer(message, " \n\t", true);
		while (st.hasMoreTokens()) {
			String token = st.nextToken();
			if (token.startsWith("*") && token.endsWith("*") && token.length() > 2) {
			 	setDoublePrintOn();
				printer.print(token.substring(1, token.length() - 1));
				setDoublePrintOff();
			} else if (token.startsWith("_") && token.endsWith("_") && token.length() > 2) {
				setUnderlineOn();
				printer.print(token.substring(1, token.length() - 1));
				setUnderlineOff();
			} else {			
				printer.print(token);
			}			
		}
		printer.flush();
	}
	
	
	void printMarkup(int maxlinelength, String text) throws IOException {
		StringTokenizer lineTok = new StringTokenizer(text, "\n", true);
		while (lineTok.hasMoreTokens()) {
			String line = lineTok.nextToken();
			if (line.equals("#")) { //Chapters...
				line = lineTok.nextToken();
				if (line.equals("\n")) {
					feed();
					partialCut();
				}
			} else {
				StringTokenizer words = new StringTokenizer(line, "\n\t ", true);
				StringBuffer sb = new StringBuffer();
				while (words.hasMoreTokens()) {
					String word = words.nextToken();
					if (sb.length() + word.length() > maxlinelength) {
						printMarkup(sb.toString() + "\n");
						sb = new StringBuffer();
						if (word.startsWith(" ")) {
							word = word.substring(1);
						}
					}
					sb.append(word);
				}			
				printMarkup(sb.toString());
			}
		}
	}
	
	void printSparkline(String label, int[] data) throws IOException { //works well with 255 bytes of data
		printer.write(label.substring(0, 7));
		printer.flush();
		fileout.write(COMMAND);
		fileout.write(COMMAND_IMAGE);
		fileout.write((byte) 0x0); 
		fileout.write((byte) 0x0); 
		fileout.write((byte) 0x01);		
		//convert the scale...
		int max = Integer.MIN_VALUE;
		int min = Integer.MAX_VALUE;
		for (int i = 0; i < data.length; i++) {
			if (data[i] > max) max = data[i];
			if (data[i] < min) min = data[i];
		}
		for (int i = 0; i < data.length; i++) {
			data[i] = (data[i] - min) * 7 / (max - min);
			int value = (int) Math.pow(2, data[i]);
			fileout.write(value);
		}
	}
		
	void setDoublePrintOn() throws IOException {
		setDoublePrint((byte) 0x01);
	}

	void setDoublePrintOff() throws IOException {
		setDoublePrint((byte) 0x00);
	}

	void setDoublePrint(byte i) throws IOException {
		printer.write(COMMAND);
		printer.write(DOUBLEPRINT);
		printer.write(i);
		printer.flush();
	}

	void setUnderlineOn() throws IOException {
		setUnderline((byte) 1);
	}

	void setUnderlineOff() throws IOException {
		setUnderline((byte) 0);
	}

	void setUnderline(byte i) throws IOException {
		//n = 0, 1 or 2 dot underline)
		printer.write(COMMAND);
		printer.write(UNDERLINE);
		printer.write(i);
		printer.flush();
	}

	void cut() throws IOException {
		printer.write(COMMAND);
		printer.write(FULLCUT);
	}

	void partialCut() throws IOException {
		printer.write(COMMAND);
		printer.write(PARTIALCUT);
	}

	void printDateBarcode() throws IOException {
		String dateStamp = new SimpleDateFormat("/yyyy/MM/dd/").format(new Date());
		setBarcodeHeight((byte) 50);
		setBarcodeWidth(BARCODE_WIDTH_MEDIUM);
		setBarcodeTextPosition(BARCODE_TEXT_BELOW);
		setBarcodeFont((byte) 0x01);
		printBarcode(dateStamp);
	}

	void flush() throws IOException {
		printer.flush();		
	}
}
