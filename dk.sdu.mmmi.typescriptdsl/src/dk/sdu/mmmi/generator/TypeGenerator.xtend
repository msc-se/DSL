package dk.sdu.mmmi.generator

import dk.sdu.mmmi.typescriptdsl.Attribute
import dk.sdu.mmmi.typescriptdsl.DateType
import dk.sdu.mmmi.typescriptdsl.IntType
import dk.sdu.mmmi.typescriptdsl.StringType
import dk.sdu.mmmi.typescriptdsl.Table
import dk.sdu.mmmi.typescriptdsl.TableType
import org.eclipse.emf.ecore.resource.Resource
import static extension dk.sdu.mmmi.generator.Helpers.toPascalCase

class TypeGenerator implements IntermidateGenerator {
	override generate(Resource resource) {
		val tables = resource.allContents.filter(Table).toList

		tables.filter(Table).map[generateTypes].join("\n")
	}
	
	private def CharSequence generateTypes(Table table) {
		newArrayList(
			table.generateTable,
			table.generateFindArgs,
			table.generateSelect,
			table.generateInclude,
			table.generateGetPayload
		).join('\n')
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
			where?: WhereInput<«table.name»>
			select?: «table.name»Select | null
			«IF table.hasRelations»include?: «table.name»Include | null«ENDIF»
		}
	'''
	
	private def generateInclude(Table table) {
		if (!table.hasRelations) return ''
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
			IntType: 'number'
			StringType: 'string'
			DateType: 'Date'
			default: 'unknown'
		}
		
		'''«attribute.name»: «typeName»«attribute.optional ? ' | null'»'''
	}
	
	private def generateGetPayload(Table table) {
		val hasRelations = table.hasRelations
		'''
		export type «table.name»GetPayload<
			S extends boolean | null | undefined | «table.name»Args,
			U = keyof S
		> = S extends true
			? «table.name» : S extends undefined
				? never : S extends «table.name»Args
					? «hasRelations ? table.generatePayloadInclude : table.generatePayloadSelect»
					«hasRelations ? ': ' + table.generatePayloadSelect»
			: «table.name»
		'''
	}
	
	private def generatePayloadInclude(Table table) {
		if (!table.hasRelations) return ''
		'''
		'include' extends U
			? «table.name» & {
				[P in TrueKeys<S['include']>] :
				«FOR a: table.attributes.filter[it.type instanceof TableType]»
				P extends '«a.name»' ? «Helpers.toPascal(a.name)»GetPayload<S['include'][P]> «a.optional ? '| null'» :
				«ENDFOR»
				never
			}
		'''
	}
	
	private def generatePayloadSelect(Table table) '''
		'select' extends U
		? {
			[P in TrueKeys<S['select']>]: P extends keyof «table.name» ? «table.name»[P] :
			«FOR a: table.attributes.filter[it.type instanceof TableType]»
				P extends '«a.name»' ? «Helpers.toPascal(a.name)»GetPayload<S['select'][P]> «a.optional ? '| null'» :
			«ENDFOR»
			never
		} : «table.name»
	'''
	
	private def generateUtilityTypes() '''
		type SelectAndInclude = {
		  select: any
		  include: any
		}

		type HasSelect = {
			select: any
		}
		type HasInclude = {
			include: any
		}

		export type CheckSelect<T, S, U> = T extends SelectAndInclude
			? 'Please either choose `select` or `include`'
			: T extends HasSelect
				? U
				: T extends HasInclude
					? U
					: S

		type Enumerable<T> = T | Array<T>

		type StringFilter = {
		  equals?: string
		  in?: Enumerable<string>
		  // notIn?: Enumerable<string>
		  lt?: string
		  lte?: string
		  gt?: string
		  gte?: string
		  contains?: string
		  startsWith?: string
		  endsWith?: string
		  // not?: NestedStringFilter | string
		}

		type IntFilter = {
		  equals?: number
		  in?: Enumerable<number>
		  // notIn?: Enumerable<number>
		  lt?: number
		  lte?: number
		  gt?: number
		  gte?: number
		  // not?: NestedIntFilter | number
		}

		type DateTimeNullableFilter = {
		  equals?: Date | string | null
		  in?: Enumerable<Date> | Enumerable<string> | null
		  // notIn?: Enumerable<Date> | Enumerable<string> | null
		  lt?: Date | string
		  lte?: Date | string
		  gt?: Date | string
		  gte?: Date | string
		  // not?: NestedDateTimeNullableFilter | Date | string | null
		}

		type Select<T extends Record<string, any>> = Partial<Record<keyof T, boolean>>
		type WhereInput<T extends Record<string, any>> = WhereInputProp<T> & WhereInputConditionals<T>
		type WhereInputProp<T extends Record<string, any>> = {
		  [K in keyof T]?: WhereInputFilter<T[K]>
		}

		type WhereInputConditionals<T> = {
		  AND?: Enumerable<WhereInputProp<T>>
		  OR?: Enumerable<WhereInputProp<T>>
		  NOT?: Enumerable<WhereInputProp<T>>
		}

		type WhereInputFilter<T extends number | string | Date> =
		  | (T extends number ? IntFilter | number : never)
		  | (T extends string ? StringFilter | string : never)
		  | (T extends Date ? DateTimeNullableFilter : never)

		export type SelectSubset<T, U> = {
		  [key in keyof T]: key extends keyof U ? T[key] : never
		} &
		  (T extends SelectAndInclude
		    ? 'Please either choose `select` or `include`.'
		    : {})

		/**
		 * From T, pick a set of properties whose keys are in the union K
		 */
		type PropUnion<T, K extends keyof T> = {
		  [P in K]: T[P]
		}

		type RequiredKeys<T> = {
		  [K in keyof T]-?: {} extends PropUnion<T, K> ? never : K
		}[keyof T]

		type TruthyKeys<T> = {
		  [key in keyof T]: T[key] extends false | undefined | null ? never : key
		}[keyof T]

		type TrueKeys<T> = TruthyKeys<PropUnion<T, RequiredKeys<T>>>
	'''
}