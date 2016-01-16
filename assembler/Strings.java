// String helpers

import java.util.regex.Pattern;

public class Strings {
	
	
	public static String getWord ( String str, int no )
	{
		String[] array = str.split("\\s+");
		
		return array[no - 1];

	}
	
	public static String padLeft(String s, int n) {
	    return String.format("%1$" + n + "s", s);  
	  }
	
	public static String getBinary( int num, int size)
	{
		String t = Integer.toBinaryString( num);
		
		if ( t.length() > size)
		{
			t = t.substring( t.length() - size, t.length());
		}
		else if ( t.length() < size)
		{
			t = padLeft( t, size ).replace(' ', t.length() == 32 ? t.charAt(0) : '0');
		}
		
		return t;
	}
	
	public static int countWords ( String str)
	{
		int words;
		char prev_char, cur_char;

		if ( str.length() == 0)
			return 0;
		if ( str.length() == 1)
			return Character.isWhitespace( str.charAt( 0)) ? 1 : 0;

		words = 0;
		prev_char = str.charAt( 0);

		for ( int i = 1; i < str.length(); i++)
		{
			cur_char = str.charAt( i);

			// if we are at a word end
			if ( Character.isWhitespace( cur_char) && !Character.isWhitespace( prev_char))
				words++;

			prev_char = cur_char;
		}

		// check if we ended with a word
		if ( !Character.isWhitespace( str.charAt( str.length() - 1)))
			words++;

		return words;
	}
}
