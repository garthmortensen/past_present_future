import org.junit.Test;
import static org.junit.Assert.*;

/**
 * These tests ensure that the included counting methods are working correctly.
 * 
 * methodCountSentences, methodCountWords and methodCountSyllables can all
 * be tested individually. Remember, however, that not all words
 * are governed by the syllable counting rules created in this program.
 * 
 * @author G
 *
 */
public class TextAnalyzerTest {
	

	@Test
	public void testCountSentences1() 
	{
		//Check to ensure sentence counter works
		int result = TextAnalyzer.methodCountSentences(new String[] {"Cheese.", "Black Olives?", "   And, macaroni!"});
		assertEquals(3, result);
	}
	
	@Test
	public void testCountSentences2() 
	{
		//Check to ensure sentence counter works
		int result = TextAnalyzer.methodCountSentences(new String[] {"Cheese.", "Black Olives?", "   And, macaroni!", ",", "!"});
		assertEquals(4, result);
	}
	
	@Test
	public void testCountSentences3() 
	{
		//Check to ensure sentence counter works, case of no sentence
		int result = TextAnalyzer.methodCountSentences(new String[] {" "});
		assertEquals(0, result);
	}
	
	@Test
	public void testCountWords1() 
	{
		//Check to ensure word counter works, try something goofy
		int result = TextAnalyzer.methodCountWords(new String[] {"Che", " and! ", "or/wda!3afaa?"});
		assertEquals(3, result);
	}
	
	@Test
	public void testCountWords2() 
	{
		//Check to ensure word counter works, another goofy attempt
		int result = TextAnalyzer.methodCountWords(new String[] {"it", "was", "   the   ", "best542" , "of!", "times/n"});
		assertEquals(6, result);
	}
	
	@Test
	public void testCountWords3() 
	{
		//Check to ensure word counter works, test that words are whitespace delimited
		int result = TextAnalyzer.methodCountWords(new String[] {"this should all be one word"});
		assertEquals(1, result);
	}
	
	@Test
	public void testCountSyllables1() 
	{
		//Check to ensure syllable counter works
		int result = TextAnalyzer.methodCountSyllables(new String[] {"Cheese", "man?"});
		assertEquals(2, result);
	}
	
	
	@Test
	public void testCountSyllables2() 
	{
		//Check to ensure syllable counter works, y is always a vowel
		int result = TextAnalyzer.methodCountSyllables(new String[] {"yo"});
		assertEquals(2, result);
	}
	
	@Test
	public void testCountSyllables3() 
	{
		//Check to ensure syllable counter works, suffix-e
		int result = TextAnalyzer.methodCountSyllables(new String[] {"e"});
		assertEquals(0, result);
	}
	
	@Test
	public void testCountSyllables4() 
	{
		//Check to ensure syllable counter works, diphthongs
		int result = TextAnalyzer.methodCountSyllables(new String[] {"ae", "oo", "ou"});
		assertEquals(3, result);
	}
	
	
}







