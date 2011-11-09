package net.danieldietrich.protectedregions.xtext;

import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.util.Collection;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import net.danieldietrich.protectedregions.support.IFileSystemReader;
import net.danieldietrich.protectedregions.support.IPathFilter;
import net.danieldietrich.protectedregions.support.IProtectedRegionSupport;

import org.apache.commons.io.FileUtils;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;
import org.eclipse.xtext.generator.OutputConfiguration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author Daniel Dietrich - Initial contribution and API
 * @author Hendy Irawan
 */
public class BidiJavaIoFileSystemAccess extends JavaIoFileSystemAccess implements IFileSystemReader {

	private transient Logger logger = LoggerFactory.getLogger(BidiJavaIoFileSystemAccess.class);

	private final IProtectedRegionSupport support;
	private IPathFilter filter;

	public BidiJavaIoFileSystemAccess(IProtectedRegionSupport support) {
		this.support = support;
	}

	protected IProtectedRegionSupport getSupport() {
		return support;
	}

	@Override
	public void setOutputConfigurations(Map<String, OutputConfiguration> outputs) {
		super.setOutputConfigurations(outputs);
		if (outputs != null) {
			for (OutputConfiguration output : outputs.values()) {
				readRegions(output.getName(), output.getOutputDirectory());
			}
		}
	}
	
	@Override
	public void setOutputPath(String path) {
		setOutputPath(DEFAULT_OUTPUT, path);
	}

	@Override
	public void setOutputPath(String outputName, String path) {
		super.setOutputPath(outputName, path);
		readRegions(outputName, path);
	}

	@Override
	public void generateFile(String fileName, CharSequence contents) {
		URI uri = getUri(fileName);
		logger.debug("Generating {} at {} => {}", new Object[] { fileName, DEFAULT_OUTPUT, uri });
		CharSequence mergedContents = support.mergeRegions(this, fileName, DEFAULT_OUTPUT, contents);
		super.generateFile(fileName, mergedContents);
	}

	@Override
	public void generateFile(String fileName, String slot, CharSequence contents) {
		URI uri = getUri(fileName, slot);
		logger.debug("Generating {} at {} => {}", new Object[] { fileName, slot, uri });
		CharSequence mergedContents = support.mergeRegions(this, fileName, slot, contents);
		super.generateFile(fileName, slot, mergedContents);
	}

	//@Override
	public IPathFilter getFilter() {
		return filter;
	}

	//@Override
	public void setFilter(IPathFilter filter) {
		this.filter = filter;
	}

	//@Override
	public boolean exists(URI uri) {
		return new File(uri).exists();
	}

	//@Override
	public CharSequence readFile(URI uri) throws IllegalArgumentException, IOException {
		final File file = new File(uri);
		return FileUtils.readFileToString(file);
	}

	//@Override
	public Set<URI> listFiles(URI path) {
		Collection<File> files = FileUtils.listFiles(new File(path), null, true);
		Set<URI> result = new HashSet<URI>();
		for (File file : files) {
			if (filter == null || filter.accept(file.toURI())) {
				result.add(file.toURI());
			}
		}
		return result;
	}

	//@Override
	public boolean hasFiles(URI uri) {
		return new File(uri).isDirectory();
	}

	//@Override
	public boolean isFile(URI uri) {
		return new File(uri).isFile();
	}

	//@Override
	public String getCanonicalPath(URI uri) {
		try {
			return new File(uri).getCanonicalPath();
		} catch (IOException e) {
			logger.warn("Cannot get canonical path for {}.", uri);
			return uri.getRawPath();
		}
	}

	//@Override
	public URI getUri(String relativePath) {
		return getUri(relativePath, DEFAULT_OUTPUT);
	}

	//@Override
	public URI getUri(String relativePath, String slot) {
		Map<String, String> pathes = getPathes();
		if (pathes.size() == 0) {
			throw new IllegalStateException("No slots initialized!? Call #setOutputPath(...)");
		}
		String slotPath = pathes.get((slot == null) ? DEFAULT_OUTPUT : slot);
		if (slotPath == null) {
			throw new IllegalStateException("Slot " + slot + " not found.");
		}
		return new File(slotPath + "/" + relativePath).toURI();
	}
	
	private void readRegions(String slot, String path) {
		logger.info("Adding slot {} => {}", slot, path);
		support.readRegions(this, slot);
	}

}
