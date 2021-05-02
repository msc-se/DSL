package dk.sdu.mmmi.generator

import dk.sdu.mmmi.typescriptdsl.Table
import java.util.List

class UtilityTypeGenerator implements IntermediateGenerator {
	
	override generate(List<Table> tables) '''
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

		export type StringFilter = {
		  equals?: string
		  in?: Enumerable<string>
		  lt?: string
		  lte?: string
		  gt?: string
		  gte?: string
		  contains?: string
		  startsWith?: string
		  endsWith?: string
		}

		export type IntFilter = {
		  equals?: number
		  in?: Enumerable<number>
		  lt?: number
		  lte?: number
		  gt?: number
		  gte?: number
		}

		export type DateTimeNullableFilter = {
		  equals?: Date | string | null
		  in?: Enumerable<Date> | Enumerable<string> | null
		  lt?: Date | string
		  lte?: Date | string
		  gt?: Date | string
		  gte?: Date | string
		}

		export type Select<T extends Record<string, any>> = Partial<Record<keyof T, boolean>>
		export type WhereInput<T extends Record<string, any>> = WhereInputProp<T> & WhereInputConditionals<T>
		export type WhereInputProp<T extends Record<string, any>> = {
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
		  [K in keyof T]: K extends keyof U ? T[K] : never
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
		  [K in keyof T]: T[K] extends false | undefined | null ? never : K
		}[keyof T]

		type TrueKeys<T> = TruthyKeys<PropUnion<T, RequiredKeys<T>>>
	'''
}