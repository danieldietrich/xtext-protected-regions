/**
 * 
 */
package net.danieldietrich.xtext;

import static org.junit.Assert.*;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

import net.danieldietrich.xtext.generator.protectedregionsupport.runtime.IDocument;
import net.danieldietrich.xtext.generator.protectedregionsupport.runtime.ProtectedRegionUtil;

import org.apache.commons.io.IOUtils;
import org.junit.Test;

/**
 * @author Daniel Dietrich - Initial contribution and API
 * @author ceefour
 *
 */
public class ProtectedRegionUtilTest {

	@Test
	public void mergeShouldMatchExpected() throws FileNotFoundException, IOException {
	    IDocument _generated = ProtectedRegionUtil.parse("test/generated.txt");
	    IDocument _protected = ProtectedRegionUtil.parse("test/protected.txt");
	    
	    IDocument _merged = ProtectedRegionUtil.merge(_generated, _protected);
	    String mergedContents = _merged.getContents();
	    String expectedContents = IOUtils.toString(new FileReader("test/expected.txt"));
	    
	    assertEquals(expectedContents, mergedContents);
	}

}
