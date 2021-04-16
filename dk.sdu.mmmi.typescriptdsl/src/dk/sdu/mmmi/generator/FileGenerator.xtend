package dk.sdu.mmmi.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import java.util.List
import dk.sdu.mmmi.typescriptdsl.Table

interface FileGenerator {
	def void generate(Resource resource, IFileSystemAccess2 fsa)
}

interface IntermediateGenerator {
	def CharSequence generate(List<Table> tables)
}