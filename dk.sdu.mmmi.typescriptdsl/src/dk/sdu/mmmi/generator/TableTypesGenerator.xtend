package dk.sdu.mmmi.generator

import org.eclipse.emf.ecore.resource.Resource
import dk.sdu.mmmi.typescriptdsl.Table
import java.util.List
import static extension dk.sdu.mmmi.generator.Helpers.*

class TableTypesGenerator implements IntermidateGenerator {
	
	override generate(Resource resource) {
		val tables = resource.allContents.filter(Table).toList
		
		tables.generateTablesTypes
	}
	
	private def generateTablesTypes(List<Table> tables) '''
		export interface TableType {
			typeName: string
			tableName: string
		}
		
		export const tableTypes: Record<keyof TypedClient, TableType> = {
			«FOR t: tables SEPARATOR ','»
			«t.generateTable»
			«ENDFOR»
		}
	'''
	
	private def generateTable(Table table) '''
		«table.name.toCamelCase»: {
			typeName: '«table.name.toCamelCase»',
			tableName: '«table.name.toSnakeCase»'
		}
	'''
}