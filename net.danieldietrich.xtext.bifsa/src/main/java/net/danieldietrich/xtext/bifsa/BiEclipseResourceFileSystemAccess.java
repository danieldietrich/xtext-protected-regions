/**
 * 
 */
package net.danieldietrich.xtext.bifsa;

import java.io.IOException;

import org.apache.commons.io.IOUtils;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.Path;
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess;

import com.google.inject.Inject;

/**
 * {@link EclipseResourceFileSystemAccess} subclass supporting {@link IBiFileSystemAccess}.
 * @author ceefour
 */
public class BiEclipseResourceFileSystemAccess extends
		EclipseResourceFileSystemAccess implements IBiFileSystemAccess {

	@Inject IWorkspaceRoot root;
	
	@Override
	public void setRoot(IWorkspaceRoot root) {
		super.setRoot(root);
		this.root = root;
	}
	
	@Override
	public boolean fileExists(String fileName) {
		IFile file = root.getFile(new Path(fileName));
		return file.exists();
	}

	@Override
	public String getFileContents(String fileName) throws IOException {
		IFile file = root.getFile(new Path(fileName));
		try {
			return IOUtils.toString(file.getContents());
		} catch (CoreException e) {
			throw new IOException("Error reading " + file, e);
		}
	}

}
