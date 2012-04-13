package net.danieldietrich.protectedregions.core;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;

import com.google.common.io.CharStreams;

public class IOUtil {

	private IOUtil() {
	}
	
	public static String toString(Reader reader) throws IOException {
		try { return CharStreams.toString(reader); }
		finally { reader.close(); }
	}
	
	public static String toString(InputStream in) throws IOException {
		Reader reader = new InputStreamReader(in);
		try { return CharStreams.toString(reader); }
		finally { reader.close(); }
	}
	
	public static String toString(File file) throws FileNotFoundException, IOException {
		return toString(new FileInputStream(file));
	}

}
