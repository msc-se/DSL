package dk.sdu.mmmi.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import dk.sdu.mmmi.typescriptdsl.Table

class IndexGenerator implements FileGenerator {
	
	override generate(Resource resource, IFileSystemAccess2 fsa) {
		val tables = resource.allContents.filter(Table).toList
		val generators = newArrayList(new UtilityTypesGenerator, new TypeGenerator, new DelegateGenerator, new TableTypesGenerator, new ConstraintsGenerator)

		fsa.generateFile('index.ts', generators.map[generate(tables)].join('\n'))
	}
	
}