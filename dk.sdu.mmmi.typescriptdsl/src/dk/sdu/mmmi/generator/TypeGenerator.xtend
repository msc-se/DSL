package dk.sdu.mmmi.generator

import dk.sdu.mmmi.typescriptdsl.Attribute
import dk.sdu.mmmi.typescriptdsl.AttributeType
import dk.sdu.mmmi.typescriptdsl.DateType
import dk.sdu.mmmi.typescriptdsl.IntType
import dk.sdu.mmmi.typescriptdsl.StringType
import dk.sdu.mmmi.typescriptdsl.Table
import dk.sdu.mmmi.typescriptdsl.TableType
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import static extension dk.sdu.mmmi.generator.Helpers.toPascalCase

class TypeGenerator implements FileGenerator {
	override generate(Resource resource, IFileSystemAccess2 fsa) {
		val tables = resource.allContents.filter(Table).toList
				
		fsa.generateFile("types.ts", tables.filter(Table).map[generateTypes].join("\n"))
	}
	
	private def CharSequence generateTypes(Table table) {
		newArrayList(table.generateTable, table.generateFindArgs, table.generateSelect, table.generateInclude).join("\n")
	}
	
	private def hasRelations(Table table) {
		table.attributes.exists[it | it.type instanceof TableType]
	}
	
	private def generateTable(Table table) '''
		export type «table.name» = «IF table.superType !== null»«table.superType.name» & «ENDIF»{
			«FOR a: table.attributes»
			«a.generateAttribute»
			«ENDFOR»
		}
	'''
	
	private def generateFindArgs(Table table) '''
		export type «table.name»Args = {
			select?: «table.name»Select | null
			«IF table.hasRelations»
			include?: «table.name»Include | null
			«ENDIF»
		}
	'''
	
	private def generateInclude(Table table) {
		if (!table.hasRelations) return ""
		'''
		export type «table.name»Include = {
			«FOR a: table.attributes.filter[it | it.type instanceof TableType]»
			«a.name»?: boolean«a.type instanceof TableType ? " | " + a.name.toPascalCase + "Args" : ""»
			«ENDFOR»
		}
		'''
	}
	
	private def generateSelect(Table table) '''
		export type «table.name»Select = {
			«FOR a: table.attributes»
			«a.name»?: boolean«a.type instanceof TableType ? " | " + a.name.toPascalCase + "Args" : ""»
			«ENDFOR»
		}
	'''
	

	
	private def generateAttribute(Attribute attribute) {
		if (attribute.type instanceof TableType) return ""
		
		val typeName = switch attribute.type {
			IntType: "number"
			StringType: "string"
			DateType: "Date"
			default: "unknown"
		}
		
		'''«attribute.name»: «typeName»«attribute.optional ? "| null" : ""»'''
	}
		
	private def getTypeScriptType(AttributeType type) {
		switch type {
			IntType: "number"
			StringType: "string"
			DateType: "Date"
			TableType: type.table.name
			default: "unknown"
		}
	}	
}