package dk.sdu.mmmi.generator

import dk.sdu.mmmi.typescriptdsl.And
import dk.sdu.mmmi.typescriptdsl.Attribute
import dk.sdu.mmmi.typescriptdsl.CompareConstraint
import dk.sdu.mmmi.typescriptdsl.IntervalConstraint
import dk.sdu.mmmi.typescriptdsl.Or
import dk.sdu.mmmi.typescriptdsl.RegexConstraint
import dk.sdu.mmmi.typescriptdsl.Table
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import dk.sdu.mmmi.typescriptdsl.Constraint

class ConstraintsGenerator implements FileGenerator {
	
	override generate(Resource resource, IFileSystemAccess2 fsa) {
		val tables = resource.allContents.filter(Table).toList
		
		fsa.generateFile("constraints.ts", tables.filter(Table).map[generateConstraints].join("\n"))
	}
	
	def generateConstraints(Table table) '''
		const «Helpers.toCamel(table.name)»Constraints: Constraints<«table.name»> = {
			«FOR a: table.attributes.filter[it.constraint !== null] SEPARATOR ','» 
			«a.generateAttributeConstraints»
			«ENDFOR»
		}
	'''
	
	Attribute currentAttr
	
	def generateAttributeConstraints(Attribute attribute) {
		currentAttr = attribute
		'''«attribute.name»: value => «attribute.constraint.constraints»'''
	}
	
	def CharSequence constraints(Constraint cons) {
		switch cons {
			Or: '''«cons.left.constraints» || «cons.right.constraints»'''
			And: '''«cons.left.constraints» && «cons.right.constraints»'''
			RegexConstraint: '''new RegExp('«cons.value»').test(value.«currentAttr.name»)'''
			CompareConstraint: '''value.«currentAttr.name» «cons.operator» «cons.value»'''
			IntervalConstraint: '''value.«currentAttr.name» >= «cons.min» && value.«currentAttr.name» <= «cons.max»'''
			default: "unknown"
		}
	}
} 