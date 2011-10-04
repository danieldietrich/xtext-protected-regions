package net.danieldietrich.protectedregions.xtext;

import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.util.Set;

import net.danieldietrich.protectedregions.support.IPathFilter;

import org.apache.commons.io.IOUtils;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.Path;
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess;

import com.google.inject.Inject;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class BidiEclipseResourceFileSystemAccess extends
		EclipseResourceFileSystemAccess implements IBidiFileSystemAccess {

	@Inject
	IWorkspaceRoot root;

	@Override
	public void setRoot(IWorkspaceRoot root) {
		super.setRoot(root);
		this.root = root;
	}
	
	protected IFile getFile(URI uri) {
		return root.getFile(new Path(uri.getPath()));
	}

	@Override
	public CharSequence readFile(URI uri) throws IOException {
		IFile file = getFile(uri);
		try {
			return IOUtils.toString(file.getContents());
		} catch (CoreException e) {
			throw new IOException("Error reading " + file, e);
		}
	}

	@Override
	public Set<URI> listFiles(URI path) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Set<URI> listFiles(URI path, IPathFilter filter) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public boolean hasFiles(URI path) {
		IFile file = getFile(path);
		return file.getType() !=  IResource.FILE;
	}

	@Override
	public boolean isFile(URI path) {
		IFile file = getFile(path);
		return file.getType() ==  IResource.FILE;
	}

	/**
	 * Return absolute path relative to workspace.
	 */
	@Override
	public String getCanonicalPath(URI path) {
		IFile file = getFile(path);
		return file.getFullPath().toString();
	}

	/**
	 * Returns relative URI.
	 */
	@Override
	public URI getUri(String fileName, String slot) {
		File f = new File(fileName);
		return f.toURI();
	}

	@Override
	public boolean exists(URI uri) {
		IFile file = getFile(uri);
		return file.exists();
	}

}
