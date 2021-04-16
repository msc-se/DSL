package dk.sdu.mmmi.generator

import dk.sdu.mmmi.typescriptdsl.Table
import java.util.List

class UtilityTypesGenerator implements IntermediateGenerator {
	
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