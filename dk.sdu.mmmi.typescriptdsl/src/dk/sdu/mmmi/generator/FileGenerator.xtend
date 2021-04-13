package dk.sdu.mmmi.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2

interface FileGenerator {
	def void generate(Resource resource, IFileSystemAccess2 fsa)
}