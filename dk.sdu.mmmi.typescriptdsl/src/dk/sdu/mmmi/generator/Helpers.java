package dk.sdu.mmmi.generator;

public class Helpers {
	static String toCamel(String input) {
	  char first = Character.toLowerCase(input.charAt(0));
	  return first + input.substring(1);
	}
	
	static String toPascal(String input) {
	  char first = Character.toUpperCase(input.charAt(0));
	  return first + input.substring(1);
	}
}
