package dk.sdu.mmmi.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2

class IndexGenerator implements FileGenerator {
	
	override generate(Resource resource, IFileSystemAccess2 fsa) {
		val generators = newArrayList(new TypeGenerator, new TableTypesGenerator)

		fsa.generateFile('index.ts', generators.map[generate(resource)].join('\n'))
	}
	
}