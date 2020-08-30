import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import org.apache.commons.io.FileUtils;
import java.util.*;
import java.text.*;

public class FolderIO {

  public static void main(String[] args) throws IOException {
	  
	  File folder = new File("C:\\many");
	  File[] listOfFiles = folder.listFiles();
	  int i = 0;

	  //loop
	  for (i = 0; i < listOfFiles.length; i++) 
	  {

	    File file = listOfFiles[i];
	    if (file.isFile() && file.getName().endsWith(".txt")) 
	    {
	    	//count sentences
	    	int countSentences = 0;
	    	int countPeriods = 0;
	    	
	    	String content = FileUtils.readFileToString(file);
	    	
	    	//read file
	        System.out.println("importedFile " + i + " " + file);
	        In inRef = new In(file);
	        String[] allWords = inRef.readAllStrings();
	        
	    	//count sentences
			for (String s: allWords)
			{
				//NEXT: turn this into a method and call on it from within for loop
				//count "."
//				countPeriods = countPeriods(s, countPeriods);
//				countPeriods(s, countPeriods);
			
				//may optionally include ";" and ":"
				if(s.contains("!") || s.contains("?"))
				{
					countSentences = countSentences + 1;
				}
			}		
	        
	    	//print output
			String timestamp = new SimpleDateFormat("yyyyMMddhhmm'_'").format(new Date());
	        PrintWriter out = new PrintWriter(new FileWriter("C:\\many\\" + timestamp + file.getName()));
			out.println("countSentences: " + countSentences);
			out.println("countPeriods: " + countPeriods);
			out.println(content);
	        out.close();
	    }
	  }

  
  }  
}