import java.io.File;
import java.io.IOException;
//the following imports are used in optional code blocks found below
//methodPrintOutput
import java.io.PrintWriter;
import java.io.FileWriter;

public class TextAnalyzer {
	
	/**
	 * Garth Mortensen
	 *  
	 * This program calculates readability measures of a text file
	 * located on a Windows machine at C:\twain.txt, or test.txt
	 * found inside of the current project.
	 * 
	 *  The Flesch and Flesch-Kincaid measures are both calculated.  
	 *  These calculations require three input variables, pulled
	 *  from your chosen text file:
	 *  
	 *  1) Total sentences (delimited by ".", "!", and "?")
	 *  2) Total words (delimited by " ")
	 *  3) Total syllables (derived from vowels)
	 * 
	 * Both measures are then interpreted and printed to console.
	 * 
	 * For more information on the measures, and their interpretations, visit:
	 * https://en.wikipedia.org/wiki/Flesch%E2%80%93Kincaid_readability_tests
	 * 
	 * @param args
	 * @throws IOException 
	 */
	public static void main(String[] args) throws IOException {
		
		//define explicit path to the imported text file
//		File importedFile = new File("C:\\twain.txt");	//Option 1
		File importedFile = new File("test.txt");	//OPTION 2 (default)
		System.out.println("importedFile: " + importedFile);

		In inRef = new In(importedFile);
		
		//this creates a string array consisting of all strings
		String[] allWords = inRef.readAllStrings();
		
		//methods for counting grammar components
		int countSentences = methodCountSentences(allWords);
		int countWords = methodCountWords(allWords);
		int countSyllables = methodCountSyllables(allWords);
		double flesch = methodFlesch(countSentences, countWords, countSyllables);
		double fleschKincaid = methodFleschKincaid(countSentences, countWords, countSyllables);
		
		//print results	
		System.out.printf("Flesch reading ease score: %.1f", flesch);	
		methodReadingLevel(flesch);
		System.out.printf("Flesch-Kincaid grade level score: %.1f\n", fleschKincaid);
		System.out.print("Sentences: " + countSentences + "     ");
		System.out.print("Words: " + countWords + "     ");
		System.out.print("Syllables: " + countSyllables);
//		System.out.print("\n" + countSentences + "	" + countWords + "	" + countSyllables + "	" + flesch + "	" + fleschKincaid);	//print tab delimited for pasting into spreadsheet
		
		//OPTIONAL: print results to file
		//methodPrintOutput(flesch, fleschKincaid, countSentences, countWords, countVowels);	
	}

	
	//OPTIONAL: print results to file
	/**
	 * This is an optional method to print results to the explicit file
	 * C:\\final\\many\\output.txt
	 * 
	 * @param flesch
	 * @param fleschKincaid
	 * @param countSentences
	 * @param countWords
	 * @param countSyllables
	 */
	/*
	private static void methodPrintOutput(double flesch, double fleschKincaid, int countSentences, int countWords, int countSyllables) throws IOException 
	{
			PrintWriter out = new PrintWriter(new FileWriter("C:\\many\\output.txt")); 
			out.print("\nSentences: " + countSentences + "     ");	
			out.print("Words: " + countWords + "     ");
			out.println("Syllables: " + countSyllables);
			out.printf("Flesch reading ease score: %.1f", flesch);	
			out.println("");
			out.printf("Flesch-Kincaid grade level score: %.1f", fleschKincaid);
			out.close();
	}
	*/

	/**
	 * methodCountSentences adds 1 to the instance variable countSentences
	 * for each period, exclamation mark and question mark in the string array.
	 * It then returns countSentences back to main.
	 * 
	 * @param allWords
	 * @return
	 */
	static int methodCountSentences(String[] allWords) 
	{
		int countSentences = 0;
		
		//count sentences
		for (String s: allWords)
		{
			//Optionally include ";" and ":"
			if(s.contains(".") || s.contains("!") || s.contains("?"))
			{
				countSentences = countSentences + 1;
			}
		}		
		
//		System.out.println("Sentences: " + countSentences);
		return countSentences;	
	}

	/**
	 * methodCountWords adds 1 to the instance variable countWords
	 * for each element in the string array, approximating word count.
	 * It then returns countWords back to main.
	 * 
	 * @param allWords
	 * @return
	 */
	static int methodCountWords(String[] allWords) 
	{
		int countWords = 0;
		
		//count words
		for (int i = 0; i < allWords.length; i++)
		{
			//each element in the array adds one to word count
			countWords = countWords + 1;
		}	
		
//		System.out.println("Words: " + countWords);
		return countWords;
	}
	
	/**
	 * methodVowels adds 1 to the variable countVowels
	 * for each vowel (a, e, i, o, u, y) in the string array.
	 * It then returns countVowels back to main.
	 * 
	 * Dipthongs must be removed from vowel count to determine
	 * syllable count. Dipthongs are are calculated as a substring 
	 * of length 2.
	 * 
	 * Trailing 'e' characters must be removed from vowel count
	 * to determine syllable count. A trailing e is calculated using
	 * endsWith.
	 * 
	 * Dipthong and trailing e counts are then subtracted from vowel
	 * counts to determine total syllables in the text.
	 * 
	 * This method requires additional refinement before methodVowels
	 * can be used to approximate syllable count, an input for methodFlesch.
	 * 
	 * @param allWords
	 * @return
	 */
	static int methodCountSyllables(String[] allWords) 
	{		
		int countVowels = 0;
		int countDipthongs = 0;
		int countE = 0;
		
		for (String s: allWords)
		{		
			//1 - count total vowels
			for (int i = 0; i < s.length(); i++) 
			{
				char ch = s.charAt(i);
				if (ch == 'a' || ch == 'e' || ch == 'i' || ch == 'o' || ch == 'u' || ch == 'y' || ch == 'A' || ch == 'E'
						|| ch == 'I' || ch == 'O' || ch == 'U' || ch == 'Y') 
				{
					countVowels = countVowels + 1;
				}
			}
			
						
			//2 - dipthongs should be reduced from two vowels to a single syllable
			//e.g. "ai", "au", "ay", "ie", "oi", "oo", "ow", "oy", "ou", "ye"
			for (int i = 0; i < s.length() - 1; i++) 
			{
				String sub = s.substring(i, i + 2);
				if (sub.equals("ai") || sub.equals("au") || sub.equals("ay") || sub.equals("ie")
						 || sub.equals("oi") || sub.equals("oo") || sub.equals("ow")
						 || sub.equals("oy") || sub.equals("ou") || sub.equals("ye")
						 || sub.equals("ea") || sub.equals("ee")
						 || sub.equals("Ai") || sub.equals("Au") || sub.equals("Ay") 
						 || sub.equals("Ie") || sub.equals("Oi") || sub.equals("Oo") 
						 || sub.equals("Ow") || sub.equals("Oy") || sub.equals("Ou") 
						 || sub.equals("Ye") || sub.equals("Ea") || sub.equals("Ee"))
				{
					countDipthongs = countDipthongs + 1;
				}
			}
				
			//3 - the final e in a word does not increase syllable count
			if(s.endsWith("e") || s.endsWith("e.") || s.endsWith("e!") || s.endsWith("e?"))
			{
				countE = countE + 1;
			}
			
		}
		
		//calculate syllables
		int countSyllables = countVowels - countDipthongs - countE;
		
//		System.out.println("countVowels: " + countVowels);
//		System.out.println("countDipthongs: " + countDipthongs);
//		System.out.println("countE: " + countE);
//		System.out.println("countSyllables: " + countSyllables);	
		
		return countSyllables;
	}
	
	/**
	 * methodFlesch calculates the Flesch index number given predetermined
	 * variables countSentences, countWords and countVowels. Average sentence 
	 * length and average syllables per word are the main focus.
	 * 
	 *  The index is calculated as; 
	 *  flesch = 206.835 - 1.015 * (sum words / sum sentences) - 84.6 * (sum syllables / sum words)
	 * 
	 * @param countSentences
	 * @param countWords
	 * @param countVowels
	 * @return
	 */
	static double methodFlesch(int countSentences, int countWords, int countSyllables) 
	{
		double flesch = 0.0;
		double A = 206.835;
		double B = 1.015;
		double D = 84.6;
		double countSentencesD = countSentences;
		double countWordsD = countWords;
		double countSyllablesD = countSyllables;
		
		//exception handling for case divide by 0 or result is 0
		try {
		//Calculate and print flesh index
		flesch = A - (B * (countWordsD / countSentencesD)) 
				- (D * (countSyllablesD / countWordsD));
		
		} catch (Exception e) {
			//print error message
			System.out.println("Flesch Error: " + e.getMessage());
			//show exactly what went wrong
			e.printStackTrace();
		}
		
		return flesch;	
	}
	
	/**
	 * 	/**
	 * methodFleschKincaid calculates the Flesch-Kincaid index number given predetermined
	 * variables countSentences, countWords and countVowels. Average sentence 
	 * length and average syllables per word are the main focus.
	 * 
	 * 
	 *  The index is calculated as; 
	 *  flesch = 0.39 * (sum words / sum sentences) + 11.8 * (sum syllables / sum words) - 15.59
	 * 
	 * @param countSentences
	 * @param countWords
	 * @param countSyllables
	 * @return
	 */
	static double methodFleschKincaid(int countSentences, int countWords, int countSyllables) 
	{
		double fleschKincaid = 0.0;
		double A = 0.39;
		double B = 11.8;
		double C = 15.59;
		double countSentencesD = countSentences;
		double countWordsD = countWords;
		double countSyllablesD = countSyllables;

		//exception handling for case divide by 0 or result is 0
		try {
		//Calculate and print flesh index
		fleschKincaid = A * (countWordsD / countSentencesD)
				+ B * (countSyllablesD / countWordsD) - C;
		
		} catch (Exception e) {
			//print error message
			System.out.println("Flesch-Kincaid Error: " + e.getMessage());
			//show exactly what went wrong
			e.printStackTrace();
		}
		
		return fleschKincaid;
	}

	
	/**
	 * methodReadingLevel uses instance variable double flesch from methodFlesch
	 * to determine and print the corresponding reading level. It does not return anything.
	 * 
	 * @param flesch
	 */
	private static void methodReadingLevel(double flesch) 
	{		
		//print Flesch reading level score
		if (flesch >= 90)
		{
			System.out.println(", best for 5th grade.");
		}
		
		else if (flesch >= 80)
		{
			System.out.println(", best for 6th grade.");
		}
		
		else if (flesch >= 70)
		{
			System.out.println(", best for 7th grade.");
		}
		
		else if (flesch >= 60)
		{
			System.out.println(", best for 8th & 9th grade.");
		}
		
		else if (flesch >= 50)
		{
			System.out.println(", best for 10th & 12th grade.");
		}
		
		else if (flesch >= 30)
		{
			System.out.println(", best for college.");
		}
		
		else
		{
			System.out.println(", best for college graduate.");
		}
	}


}