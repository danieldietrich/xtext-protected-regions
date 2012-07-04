package net.danieldietrich.protectedregions.xtext

import java.util.LinkedHashMap

import org.eclipse.xtext.generator.AbstractFileSystemAccess
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.OutputConfiguration
import org.eclipse.xtext.xbase.lib.Pair

import java.util.logging.Logger

abstract class GeneratorExtensions {
	
	static val logger = Logger::getLogger(typeof(GeneratorExtensions).name)
	
	def static setOutputPaths(IFileSystemAccess fsa, Pair<String,String>... configs) {
		val outputs = configs.fold(new LinkedHashMap<String,OutputConfiguration>)[map, pair |
			map.put(
				pair.key,
				// @@UPDATE-INFO: This should match org.eclipse.xtext.generator.OutputConfigurationProvider#getOutputConfigurations()
				new OutputConfiguration(pair.key) => [
					description = "Output Folder"
					outputDirectory = pair.value
					overrideExistingResources = true
					createOutputDirectory = true
					cleanUpDerivedResources = true
					setDerivedProperty = true
				]
			)
			map
		]
		(fsa as AbstractFileSystemAccess).setOutputConfigurations(outputs)
	}
	
	def static setOutputConfigurations(IFileSystemAccess fsa, Pair<String,OutputConfiguration>... configs) {
		val outputs = configs.fold(new LinkedHashMap<String,OutputConfiguration>)[map, pair |
			map.put(pair.key, pair.value)
			map
		]
		(fsa as AbstractFileSystemAccess).setOutputConfigurations(outputs)
	}
	
}
