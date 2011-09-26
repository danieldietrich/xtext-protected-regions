/**
 * 
 */
package net.danieldietrich.xtext.bifsa;

import java.io.File;
import java.io.IOException;
import java.util.Map;

import org.apache.commons.io.FileUtils;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;

/**
 * Java IO FileSystemAccess supporting Bi interface. 
 * @author ceefour
 */
public class BiJavaIoFileSystemAccess extends JavaIoFileSystemAccess implements
		IBiFileSystemAccess {

	protected String getFullPath(String relativePath) {
		Map<String, String> pathes = getPathes();
		String fullName = toSystemFileName( pathes.get(DEFAULT_OUTPUT) + "/" + relativePath);
		return fullName;
	}
	
	@Override
	public boolean fileExists(String fileName) {
		return new File(getFullPath(fileName)).exists();
	}
	
	@Override
	public String getFileContents(String fileName) throws IOException {
		return FileUtils.readFileToString(new File(getFullPath(fileName)));
	}
	
}
