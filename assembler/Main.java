// generates the 16-bit binary representations of the given instructions
// reads from the file passed as a parameter

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Scanner;

public class Main {
	public static void main ( String[] args) throws Exception
	{
		
		System.out.println( "Processing: " + args[0]);
		
		String code = "";
		
		try {
			code = new Scanner(new File(args[0])).useDelimiter("\\Z").next();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}

		String[] lines = trimCode(code);
		
		buildLUT( lines);
		
		System.out.println();
		System.out.println();
		System.out.println();
		
		for( int i = 0; i < lines.length; i++)
		{
			System.out.println( doInstr( lines[i], i));
		}
	}
	
	// trim code from unnecessary parts
	public static String[] trimCode ( String code)
	{
		String lines[] = code.split("\\r?\\n");
		String[] trimmedArray;
		ArrayList<String> trimmedLines = new ArrayList<String>();
		
		for ( int i = 0; i < lines.length; i++)
		{
			int offset = lines[i].indexOf(";;");

			// remove any comments
			if ( -1 != offset) {
				lines[i] = lines[i].substring(0, offset);
			}
			
			lines[i] = lines[i].trim();
			
			if ( ! lines[i].isEmpty())
				trimmedLines.add( lines[i]);
		}
		
		trimmedArray = new String[trimmedLines.size()];
		
		trimmedArray = trimmedLines.toArray(trimmedArray);
		
		return trimmedArray;
	}
	
	public static boolean isNumerical(String str)
	{
		return str.charAt( 0) == '\'' || 
			Character.isDigit( str.charAt(0)) ||
			str.charAt( 0) == '-';
	}
	
	public static String getNumerical( String str, int bsize)
	{
		if ( str.charAt( 0) == '\'' )
		{
			str = str.substring( 1);
			if ( str.length() > bsize)
			{
				str = str.substring( str.length() - bsize, str.length());
			}
			else if ( str.length() < bsize)
			{
				str = Strings.padLeft( str, bsize ).replace(' ', str.length() == 32 ? str.charAt(0) : '0');
			}
			
			return str;
		}
		
		return Strings.getBinary( Integer.parseInt( str), bsize);
	}
	
	public static boolean isRegister ( String str)
	{
		str = str.toLowerCase();
		
		return str.equals( "r0") || str.equals( "r1") ||str.equals( "r2") ||str.equals( "r3" )||str.equals( "r4") ||str.equals( "r5")||
				str.equals( "f0") ||str.equals( "f1" )||str.equals( "f2") ||str.equals( "f3") ||str.equals( "f4") ||str.equals( "f5" )||str.equals( "f6") ||str.equals( "f7") ||
				str.equals( "mr") ||str.equals( "sp") || str.equals( "pc");
	}
	
	public static String getRegisterID ( String reg)
	{
		switch ( reg.toLowerCase())
		{
		case "r0":	return "0000";
		case "r1":	return "0001";
		case "r2":	return "0010";
		case "r3":	return "0011";
		case "r4":	return "0100";
		case "r5":	return "0101";
		case "f0":	return "0110";
		case "f1":	return "0111";
		case "f2":	return "1000";
		case "f3":	return "1001";
		case "f4":	return "1010";
		case "f5":	return "1011";
		case "f6":	return "1100";
		case "mr":	return "1101";
		case "sp":	return "1110";
		case "pc":	return "1111";
		}
		
		return "-err-reg";
	}
	
	public static HashMap<String, Integer> labels;
	
	// builds the LUT
	
	public static void buildLUT ( String[] code) throws Exception
	{
		labels = new HashMap<String, Integer>();
		
		for ( int i = 0; i < code.length; i++)
		{
			String first = Strings.getWord( code[i], 1);
			if ( first.equals( ".data"))
			{
				if ( labels.containsKey( Strings.getWord( code[i], 2)))
					throw new Exception( "duplicate label");
				labels.put( Strings.getWord( code[i], 2), i);
				// code[i] = code[i].substring(5).trim();
			}
			else if ( first.charAt( first.length() - 1) == ':')
			{
				if ( labels.containsKey( first.substring( 0, first.length() - 1)))
					throw new Exception( "duplicate label");
				
				labels.put( first.substring( 0, first.length() - 1), i);
				code[i] = code[i].substring( first.length()).trim();
			}
		}
	}
	
	public static String getAddr16 ( String name)
	{
		String addr = Strings.getBinary( labels.get( name), 16);
		
		return addr;
	}
	
	// returns the binary representation of a single instruction
	public static String doInstr ( String instr, int pos)
	{
		String res = "";
		switch ( Strings.getWord( instr, 1))
		{
		case "add":
			res = "10000";
			break;
		case "adc":
			res = "10001";
			break;
		case "sub":
			res = "10010";
			break;
		case "sbc":
			res = "10011";
			break;
		case "not":
			res = "10110";
			break;
		case "inv":
			res = "10111";break;
		case "umul":
			res = "10100";break;
		case "smul":
			res = "10101";break;
		case "and":
			res = "11100";break;
		case "or":
			res = "11101";break;
		case "xor":
			res = "11110";break;
		case "asr":
			res = "11111";break;
		case "rol":
			res = "11000";break;
		case "ror":
			res = "11001";break;
		case "lsl":
			res = "11010";break;
		case "lsr":
			res = "11011";break;
		
		case "cmp":
			res = "00111";
			break;
			
		case "load":
			res = "01000" + getRegisterID( Strings.getWord( instr, 2));
			if ( isRegister( Strings.getWord( instr, 3)))
			{
				res += "1" + getRegisterID( Strings.getWord( instr, 3)) + "00";
			}
			else if ( isNumerical( Strings.getWord( instr, 3) ))
				res += "0" + getNumerical( Strings.getWord( instr, 3), 6);
			else
				res += "0" + getAddr16( Strings.getWord( instr, 3)).substring( 10); 
			return res;
	
		case "sav":
			res = "01001" + getRegisterID( Strings.getWord( instr, 2));
			if ( isRegister( Strings.getWord( instr, 3)))
			{
				res += "1" + getRegisterID( Strings.getWord( instr, 3)) + "00";
			}
			else if ( isNumerical( Strings.getWord( instr, 3) ))
				res += "0" + getNumerical( Strings.getWord( instr, 3), 6);
			else
				res += "0" + getAddr16( Strings.getWord( instr, 3)).substring( 11); 
			return res;
		case "mem":
			if ( isNumerical( Strings.getWord( instr, 2)))
				res = "01011" + getNumerical( Strings.getWord( instr, 2), 11);
			else
				res = "01011" + "0" + getAddr16( Strings.getWord( instr, 2)).substring( 0, 10);
			
			return res;
			
		case "mov":
			res = "01010" + getRegisterID( Strings.getWord( instr, 2)) + 
							( isNumerical( Strings.getWord( instr, 3)) ? "0" + getNumerical(Strings.getWord( instr, 3), 6) 
																	   : "1" + getRegisterID( Strings.getWord( instr,3)) + "00");
			return res;
			
		case "jmp":
			res = "00000";
			break;
		case "call":
			res = "01110";
			break;
		case "jz":
		case "jls":
			res = "00001";
			break;
		case "jp":
		case "jgs":
			res = "00010";
			break;
		case "jn":
		case "jeq":
			res = "00011";
			break;
		case "jc":
		case "jgu":
			res = "00100";
			break;
		case "jerr":
		case "jlu":
			res = "00101";
			break;
			
		case "ret":
			if ( Strings.countWords( instr) == 1)
				res = "0111100000000000";
			else
				res = "01111" + getNumerical( Strings.getWord( instr,  2), 11);
			return res;
			
		case "wait":
			res = "00110";
			
			if ( isRegister( Strings.getWord( instr,  2)))
				res += "1" + getRegisterID( Strings.getWord( instr,  2)) + "000000";
			else
				res += "0" + getNumerical( Strings.getWord( instr,  2), 10);
			
			return res;
			
		case "pop":
			if ( Strings.countWords( instr) == 3)
				res = "01100" + "1" + getRegisterID( Strings.getWord( instr, 2)) + "1" + getRegisterID( Strings.getWord( instr, 3)) + "0";
			else
				res = "01100" + "1" + getRegisterID( Strings.getWord( instr, 2)) + "000000";
			return res;
		case "push":
			if ( isNumerical( Strings.getWord( instr, 2)) )
				res = "01101" + "0" + getNumerical( Strings.getWord( instr, 2), 10);
			else
				res = "01101" + "1" + getRegisterID( Strings.getWord( instr, 2)) + "000000";
			return res;
		case ".data":
			if ( isNumerical( Strings.getWord( instr, 3)) )
				res = getNumerical( Strings.getWord( instr, 3), 16);
			else
				res = getNumerical( "" + labels.get( Strings.getWord( instr, 3)), 16);
			return res;
		}
		
		if ( res.charAt( 0) == '0' && !res.equals( "00111")) // jump commands
		{
			if ( isRegister( Strings.getWord( instr, 2)))
				res += "10" + getRegisterID( Strings.getWord( instr, 2)) + "00000";
			else if ( isNumerical( Strings.getWord( instr, 2) ))
				res += "0" + getNumerical( Strings.getWord( instr, 2), 10);
			else if ( Strings.getWord( instr, 2).charAt( 0) == '@')
				res += "11" + getNumerical( Strings.getWord( instr, 2).substring( 1), 9);
			else
			{
				int goNum = labels.get( Strings.getWord( instr, 2));
				
				if ( Math.abs( goNum - pos) < 512)
					res += "0" + Strings.getBinary( goNum - pos, 10);
				else
					res += "11" + getAddr16( Strings.getWord( instr, 2)).substring( 7);
			}
		}
		
		if ( res.charAt( 0) == '1' || res.equals( "00111")) // arithmetic commands
		{
			res += getRegisterID( Strings.getWord( instr, 2));
			
			if ( isRegister( Strings.getWord( instr, 3)))
			{
				res += "1" + getRegisterID( Strings.getWord( instr, 3)) + "00";
			}
			else
			{
				res += "0"+ getNumerical( Strings.getWord( instr, 3), 6);
			}
			return res;
		}
		
		return res;
	}
}
