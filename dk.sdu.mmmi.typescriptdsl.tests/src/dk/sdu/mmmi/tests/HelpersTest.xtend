package dk.sdu.mmmi.tests

import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.Test
import static extension dk.sdu.mmmi.generator.Helpers.*

class HelpersTest {
	
	@Test
	def void toSnakeCaseTest() {		
		Assertions.assertEquals("address_name", "addressName".toSnakeCase)
		Assertions.assertEquals("address_name_age", "addressNameAge".toSnakeCase)
		Assertions.assertEquals("address_name", "AddressName".toSnakeCase)
		Assertions.assertEquals("address", "address".toSnakeCase)
		Assertions.assertEquals("", "".toSnakeCase)
		Assertions.assertEquals(null, null.toSnakeCase)
	}
	
	@Test
	def void toCamelCaseTest() {		
		Assertions.assertEquals("addressName", "address_name".toCamelCase)
		Assertions.assertEquals("addressName", "AddressName".toCamelCase)
		Assertions.assertEquals("address", "Address".toCamelCase)
		Assertions.assertEquals("", "".toCamelCase)
		Assertions.assertEquals(null, null.toCamelCase)
	}
	
	@Test
	def void toPascalCaseTest() {		
		Assertions.assertEquals("AddressName", "addressName".toPascalCase)
		Assertions.assertEquals("AddressName", "address_name".toPascalCase)
		Assertions.assertEquals("Address", "address".toPascalCase)
		Assertions.assertEquals("", "".toPascalCase)
		Assertions.assertEquals(null, null.toPascalCase)
	}
	
}