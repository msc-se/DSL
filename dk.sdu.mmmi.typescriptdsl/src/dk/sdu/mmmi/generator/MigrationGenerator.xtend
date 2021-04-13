package dk.sdu.mmmi.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import dk.sdu.mmmi.typescriptdsl.Table
import dk.sdu.mmmi.typescriptdsl.Attribute
import dk.sdu.mmmi.typescriptdsl.TableType
import dk.sdu.mmmi.typescriptdsl.AttributeType
import dk.sdu.mmmi.typescriptdsl.IntType
import dk.sdu.mmmi.typescriptdsl.StringType
import dk.sdu.mmmi.typescriptdsl.DateType

class MigrationGenerator implements FileGenerator {
	override generate(Resource resource, IFileSystemAccess2 fsa) {
		val tables = resource.allContents.filter(Table).toList
		
		fsa.generateFile("createTables.ts", generateCreateFile(tables))
		fsa.generateFile("dropTables.ts", generateDropFile(tables)) 
	}
	
	private def generateDropFile(Iterable<Table> tables) '''
		import { Knex } from 'knex'
		
		export async function dropTables(knex: Knex): Promise<void> {
			await knex.raw('set foreign_key_checks = 0;')
			
			let query = knex.schema
			
			«FOR t: tables»
			query = query.dropTableIfExists('«t.name.toLowerCase»')
			«ENDFOR»

			return query
		}
	'''
	
	private def generateCreateFile(Iterable<Table> tables) '''
		import { Knex } from 'knex'
		
		export function createTables(knex: Knex): Promise<void> {
			let query = knex.schema
			
			«FOR t: tables»
			«t.generateCreateTable»
			«ENDFOR»
			«FOR t: tables.filter[it.attributes.exists[it.type instanceof TableType]]»
			«t.generateRelationsAlterTable»
			«ENDFOR»
			return query
		}
	'''
	
	private def generateCreateTable(Table table) '''
		query = query.createTable('«table.name.toLowerCase»', function (table) {
			«FOR d: table.attributes»
			«d.generateCreateAttribute»
			«ENDFOR»
		})
	'''
	
	private def generateRelationsAlterTable(Table table) '''
		query = query.alterTable('«table.name.toLowerCase»', function (table) {
			«FOR d: table.attributes.filter[it.type instanceof TableType]»
			«d.generateCreateRelationAttribute»
			«ENDFOR»
		})
	'''
	
	private def generateCreateAttribute(Attribute attribute) '''
		table.«attribute.generateFunctionCalls»«IF !attribute.optional && !attribute.primary».notNullable()«ENDIF»
	'''
	
	def generateFunctionCalls(Attribute attr) {
		val attrType = attr.type
		switch attrType {
			IntType: {
				'''«attr.primary ? "increments" : "integer"»('«attr.name»')'''
			}
			StringType: {
				'''string('«attr.name»')«IF attr.primary».primary()«ENDIF»'''
			}
			DateType: {
				'''timestamp('«attr.name»')'''
			}
			TableType: {
				val primary = attrType.table.primaryColumn
				'''«primary.type.generateForeignFunctionCall('''«attr.name»_«primary.name»''')»'''
			}
			default: throw new Exception("Unknown type for create!")
		}
	}
	
	def generateCreateRelationAttribute(Attribute attribute) '''
		table.«attribute.generateRelationsFunctionCalls»
	'''
	
	def generateRelationsFunctionCalls(Attribute attr) {
		if (!(attr.type instanceof TableType)) throw new Exception('''Attribute «attr.name» is not a foreign key''')
		val type = attr.type as TableType
		val primary = type.table.primaryColumn
		'''foreign('«attr.name»_«primary.name»').references('«type.table.name.toLowerCase».«primary.name»')'''
	}
	
	def generateForeignFunctionCall(AttributeType type, String name) {
		switch type {
			IntType: '''integer('«name»').unsigned()'''
			StringType: '''string('«name»')'''
			default: throw new Exception("Unknown type for foreign create!")
		}
	}
	
	def getPrimaryColumn(Table table) {
		val primaries = table.attributes.filter[it.primary]
		if (primaries.size == 0) throw new Exception('''No primary key for table «table.name»''')
		if (primaries.size > 1) throw new Exception('''Only one primary key can be defined for «table.name»''')
		primaries.head
	}	
}