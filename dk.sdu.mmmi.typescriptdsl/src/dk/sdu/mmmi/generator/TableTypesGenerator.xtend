package dk.sdu.mmmi.generator

import dk.sdu.mmmi.typescriptdsl.Table
import java.util.List
import static extension dk.sdu.mmmi.generator.Helpers.*

class TableTypesGenerator implements IntermediateGenerator {
	
	override generate(List<Table> tables) {		
		tables.generateTablesTypes
	}
	
	private def generateTablesTypes(List<Table> tables) '''
		export interface TableType {
			typeName: string
			tableName: string
			primaryColumn: string
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
			tableName: '«table.name.toSnakeCase»',
			primaryColumn: '«table.primaryColumn.name.toSnakeCase»'
		}
	'''
}