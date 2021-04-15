package dk.sdu.mmmi.generator

import com.sun.org.apache.xpath.internal.operations.Variable
import dk.sdu.mmmi.typescriptdsl.And
import dk.sdu.mmmi.typescriptdsl.Attribute
import dk.sdu.mmmi.typescriptdsl.CompareConstraint
import dk.sdu.mmmi.typescriptdsl.Constraint
import dk.sdu.mmmi.typescriptdsl.Div
import dk.sdu.mmmi.typescriptdsl.Expression
import dk.sdu.mmmi.typescriptdsl.Minus
import dk.sdu.mmmi.typescriptdsl.Mult
import dk.sdu.mmmi.typescriptdsl.NumberExp
import dk.sdu.mmmi.typescriptdsl.Or
import dk.sdu.mmmi.typescriptdsl.Parenthesis
import dk.sdu.mmmi.typescriptdsl.Plus
import dk.sdu.mmmi.typescriptdsl.RegexConstraint
import dk.sdu.mmmi.typescriptdsl.Table
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2

import static extension dk.sdu.mmmi.generator.Helpers.toCamelCase
import dk.sdu.mmmi.typescriptdsl.Field

class ConstraintsGenerator implements FileGenerator {
	
	override generate(Resource resource, IFileSystemAccess2 fsa) {
		val tables = resource.allContents.filter(Table).toList
		
		fsa.generateFile("constraints.ts", tables.filter(Table).map[generateConstraints].join("\n"))
	}
	
	def generateConstraints(Table table) '''
		const «table.name.toCamelCase»Constraints: Constraints<«table.name»> = {
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
			CompareConstraint: '''«cons.left.printExp» «cons.operator» «cons.right.printExp»'''
			default: "unknown"
		}
	}
	
	def CharSequence printExp(Expression exp) {
		switch exp {
			Plus: '''«exp.left.printExp» + «exp.right.printExp»'''
			Minus: '''«exp.left.printExp» - «exp.right.printExp»'''
			Mult: '''«exp.left.printExp» * «exp.right.printExp»'''
			Div: '''«exp.left.printExp» / «exp.right.printExp»'''
			Parenthesis: '''(«exp.exp.printExp»)'''
			NumberExp: '''«exp.value»'''
			Field: '''value.«exp.attr.name»'''
			default: throw new Exception()
		}
	}
} 