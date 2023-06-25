import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

/**
 * CSE 2046 Analysis of Algorithms
 *      Homework 1
 * 
 * Group Members:
 * Serkan Korkut - 150119036
 * Sule Koca - 150119057
 * Omer Faruk Kıslakcı - 150119689
 * Bihter Nilufer Akdem - 150119810
 */
public class SerkanKorkut_SuleKoca_OmerFarukKislakci_BihterNiluferAkdem {
    public static void main(String[] args) throws IOException {
        //** INPUTS */
        //String htmlFile = Files.readString(Paths.get("input1.html"));
        String htmlFile = Files.readString(Paths.get("input.html"), StandardCharsets.ISO_8859_1);
        String text = htmlFile.substring(htmlFile.indexOf("<body>") + 6, htmlFile.indexOf("</body>")).trim();
        String pattern = "AT_THAT";

        //** PRINT BAD SYMBOL AND GOOD SUFFIX TABLES */
        int[] badSymbol = getBadSymbolTable(pattern);
        int[] goodSuffix = getGoodSuffixTable(pattern);
        int i;
        System.out.printf("Bad symbol table for %s:\n", pattern);
        for (i = 0; i < 256; i++) {
            System.out.printf("%c => %d\n", (char) (i), badSymbol[i]);
        }

        System.out.printf("Good suffix table for %s:\n", pattern);
        for (i = 0; i < goodSuffix.length; i++) {
            System.out.printf("%d => %d\n", i, goodSuffix[i]);
        }

        //** BRUTE FORCE */
        long bfStartTime = System.nanoTime();
        String newHTML = bruteForceStringMatch(text, pattern);
        long bfEndTime = System.nanoTime();
        Files.write(Paths.get("output_bf.html"), newHTML.getBytes());
        System.out.println("Execution Time of Brute-Force Algorithm: " + (bfEndTime - bfStartTime) / 1000000.0 + "ms");

        //** HORSPOOL */
        long hpStartTime = System.nanoTime();
        String newHTML2 = horspool(text, pattern);
        long hpEndTime = System.nanoTime();
        Files.write(Paths.get("output_hp.html"), newHTML2.getBytes());
        System.out.println("Execution Time of Horspool's Algorithm: " + (hpEndTime - hpStartTime) / 1000000.0 + "ms");

        //** BOYER MOORE */
        long bmStartTime = System.nanoTime();
        String newHTML3 = boyerMoore(text, pattern);
        long bmEndTime = System.nanoTime();
        Files.write(Paths.get("output_bm.html"), newHTML3.getBytes());
        System.out.println("Execution Time of Boyer Moore Algorithm: " + (bmEndTime - bmStartTime) / 1000000.0 + "ms");
    }

    //******************************  BRUTE FORCE ALGORITHM ************************//
    public static String bruteForceStringMatch(String text, String pattern) {
        //StringBuffer newBody = new StringBuffer(text);
        // Create a StringBuilder to modify the text
        StringBuilder newBody = new StringBuilder(text);

        // Get the lengths of the text and pattern
        int n = text.length();
        int m = pattern.length();

        int comparisons = 0;
        int count = 0;
        int lastOccurrence = -999;
        int j;
        // Iterate over the text
        for (int i = 0; i <= n - m; i++) {
            // Iterate over the pattern
            for (j = 0; j < m; j++) {
                // Compare characters at corresponding positions
                if (text.charAt(i + j) != pattern.charAt(j)) {
                    comparisons++;
                    break;
                }
                comparisons++;
            }
            // If j equals m, a match is found
            if (j == m) {
                // Check if it's a consecutive match or a new match
                if ((i - lastOccurrence) < m) {
                    // Delete the previous end mark and insert the new end mark
                    newBody.delete(lastOccurrence + m + (count - 1) * 13 + 6,
                            lastOccurrence + m + (count - 1) * 13 + 6 + 7);
                    newBody.insert(i + m + (count - 1) * 13 + 6, "</mark>");
                } else {
                    // Insert the start and end marks for the match
                    newBody.insert(i + m + count * 13, "</mark>");
                    newBody.insert(i + count * 13, "<mark>");
                    count++;
                }
                // Update the last occurrence
                lastOccurrence = i;
            }
        }
        // Print the number of comparisons made during the algorithm
        System.out.println("Number of Comparisons of Brute-Force String Match Algorithm: " + comparisons);
        // Add HTML tags to the modified text
        newBody.insert(0, "<html><body>");
        newBody.append("</body></html>");
        // Convert the modified text to a string and return it
        return newBody.toString();
    }

    //******************************  HORSPOOL'S ALGORITHM ************************//
    public static String horspool(String text, String pattern) {
        //StringBuffer newBody = new StringBuffer(text);
        // Create a StringBuilder to modify the text
        StringBuilder newBody = new StringBuilder(text);

        // Compute the shift table
        int[] shiftTable = getBadSymbolTable(pattern);

        // Get the lengths of the text and pattern
        int n = text.length();
        int m = pattern.length();

        int i, j, k, d1;
        int comparisons = 0;
        int count = 0;
        int lastOccurrence = -999;

        // Start the search at the last character of the pattern
        i = m - 1;
        // Loop until the end of the text is reached
        while (i < n) {
            k = 0;
            // Compare characters from right to left
            for (j = 0; j < m; j++) {
                comparisons++;
                // If k > 0, continue comparing characters
                if (k > 0) {
                    // Check if the characters match
                    if (text.charAt(i - k) != pattern.charAt(m - 1 - k)) {
                        // Compute the shift based on the shift table
                        d1 = shiftTable[(int) (text.charAt(i))];
                        i = i + d1;
                        //comparisons++;
                        break;
                    } else {
                        k++;
                        //comparisons++;
                    }
                    // If k equals m, a match is found
                    if (k == m) {
                        // Check if it's a consecutive match or a new match
                        if ((i - lastOccurrence) < m) {
                            // Delete the previous end mark and insert the new end mark
                            newBody.delete(lastOccurrence + 1 + (count - 1) * 13 + 6,
                                    lastOccurrence + 1 + (count - 1) * 13 + 6 + 7);
                            newBody.insert(i + 1 + (count - 1) * 13 + 6, "</mark>");
                        } else {
                            // Insert the start and end marks for the match
                            newBody.insert(i + 1 + count * 13, "</mark>");
                            newBody.insert(i + 1 - m + count * 13, "<mark>");
                            count++;
                        }
                        // Update the last occurrence and move to the next character
                        lastOccurrence = i;
                        i++;
                        continue;

                    }
                }
                // If k equals 0, compare characters starting from the right
                if (k == 0) {
                    if (text.charAt(i) == pattern.charAt(m - 1 - j)) {
                        k++;
                        //comparisons++;
                    } else {
                        // Compute the shift based on the shift table
                        i = i + shiftTable[(int) (text.charAt(i))];
                        //comparisons++;
                        break;
                    }
                }
            }
        }
        // Print the number of comparisons made during the algorithm
        System.out.println("Number of Comparisons of Horspool's Algorithm: " + comparisons);
        // Add HTML tags to the modified text
        newBody.insert(0, "<html><body>");
        newBody.append("</body></html>");
        // Convert the modified text to a string and return it
        return newBody.toString();
    }

    //******************************  BOYER MOORE ALGORITHM ************************//
    public static String boyerMoore(String text, String pattern) {
        //StringBuffer newBody = new StringBuffer(text);
        // Create a StringBuilder to modify the text
        StringBuilder newBody = new StringBuilder(text);

        // Compute the bad symbol and good suffix tables
        int[] badSymbol = getBadSymbolTable(pattern);
        int[] goodSuffix = getGoodSuffixTable(pattern);

        // Get the lengths of the text and pattern
        int n = text.length();
        int m = pattern.length();

        int i, j, k, d1, d2;
        int comparisons = 0;
        int count = 0;
        int lastOccurrence = -999;

        // Start the search at the last character of the pattern
        i = m - 1;
        // Loop until the end of the text is reached
        while (i < n) {
            k = 0;
            // Compare characters from right to left
            for (j = 0; j < m; j++) {
                comparisons++;
                // If k > 0, continue comparing characters
                if (k > 0) {
                    // Check if the characters match
                    if (text.charAt(i - k) != pattern.charAt(m - 1 - k)) {
                        // Compute the shifts based on the bad symbol and good suffix tables
                        d1 = badSymbol[(int) (text.charAt(i - k))] - k;
                        d2 = goodSuffix[k];
                        i = i + Math.max(d1, d2);
                        //comparisons++;
                        break;
                    } else {
                        k++;
                        //comparisons++;
                    }
                    // If k equals m, a match is found
                    if (k == m) {
                        // Check if it's a consecutive match or a new match
                        if ((i - lastOccurrence) < m) {
                            // Delete the previous end mark and insert the new end mark
                            newBody.delete(lastOccurrence + 1 + (count - 1) * 13 + 6,
                                    lastOccurrence + 1 + (count - 1) * 13 + 6 + 7);
                            newBody.insert(i + 1 + (count - 1) * 13 + 6, "</mark>");
                        } else {
                            // Insert the start and end marks for the match
                            newBody.insert(i + 1 + count * 13, "</mark>");
                            newBody.insert(i + 1 - m + count * 13, "<mark>");
                            count++;
                        }
                        lastOccurrence = i;
                        i++;
                        continue;
                    }
                }
                // If k equals 0, compare characters starting from the right
                if (k == 0) {
                    if (text.charAt(i) == pattern.charAt(m - 1 - j)) {
                        k++;
                        //comparisons++;
                    } else {
                        // Compute the shift based on the bad symbol table
                        i = i + badSymbol[(int) (text.charAt(i))];
                        //comparisons++;
                        break;
                    }
                }
            }
        }
        // Print the number of comparisons made during the algorithm
        System.out.println("Number of Comparisons of Boyer Moore Algorithm: " + comparisons);
        // Add HTML tags to the modified text
        newBody.insert(0, "<html><body>");
        newBody.append("</body></html>");
        // Convert the modified text to a string and return it
        return newBody.toString();
    }

    public static int[] getBadSymbolTable(String pattern) {
        // Initialize the size of the character set to 256 (ASCII)
        int charNumber = 256;
        // Create an integer array to store the bad symbol table
        int[] badSymbol = new int[charNumber];

        // Set all values in the bad symbol table to the length of the pattern
        int i, j;
        for (i = 0; i < charNumber; i++) {
            badSymbol[i] = pattern.length();
        }
        // Fill in the bad symbol table by iterating over the pattern from right to left
        for (i = pattern.length() - 2, j = 1; i >= 0; i--, j++) {
            if (badSymbol[(int) (pattern.charAt(i))] > j) {
                badSymbol[(int) (pattern.charAt(i))] = j;
            }
        }
        // Return the completed bad symbol table
        return badSymbol;
    }

    public static int[] getGoodSuffixTable(String pattern) {
        // Create an integer array to store the good suffix table
        int[] goodSuffix = new int[pattern.length()];
        int i, j, k, t;
        int count;
        boolean isDone;
        String suffix;
        char preSuffix;
        // Iterate over the pattern from right to left
        for (i = pattern.length() - 2, k = 1; i >= 0; i--, k++) {
            // Get the suffix and the character preceding the suffix
            suffix = pattern.substring(pattern.length() - k);
            preSuffix = pattern.charAt(pattern.length() - k - 1);
            count = 0;
            isDone = false;
            // Compare the suffix with substrings of the pattern
            for (j = pattern.length() - 2; j >= 0; j--) {
                for (t = j; t >= 0; t--) {
                    // If the characters match, increment the count
                    if (pattern.charAt(t) == suffix.charAt(suffix.length() - 1 - count)) {
                        count++;
                    } else {
                        // If characters don't match, update the good suffix table and exit the loop
                        if (t == 0) {
                            goodSuffix[k] = pattern.length();
                            isDone = true;
                        }
                        count = 0;
                        break;
                    }
                    // If the entire suffix matches and there are more characters in the pattern
                    if (count == suffix.length() && t != 0) {
                        // Update the good suffix table with the appropriate value
                        if (preSuffix != pattern.charAt(t - 1)) {
                            goodSuffix[k] = pattern.length() - count - t;
                            isDone = true;
                            break;
                        } else {
                            count = 0;
                            break;
                        }
                    }
                    // If there are no more characters in the pattern
                    if (t == 0) {
                        goodSuffix[k] = pattern.length() - count;
                        isDone = true;
                        break;
                    }
                }
                count = 0;
                // If the good suffix table is updated, exit the loop
                if (isDone)
                    break;
            }
        }
        // Return the completed good suffix table
        return goodSuffix;
    }
}