import java.io.File;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Locale;
import java.util.Scanner;

public class ID_150119036_150119599_150120992_150119665 {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        System.out.print("Input file name: ");
        String inputFileStr = scanner.nextLine();
        System.out.print("Byte ordering: ");
        String byteOrdering = scanner.nextLine().toLowerCase();
        System.out.print("Data type: ");
        String dataType = scanner.nextLine().toLowerCase();
        System.out.print("Data type size: ");
        int dataTypeSize = scanner.nextInt();
        scanner.close();

        try {
            File inputFile = new File(inputFileStr);
            File outputFile = new File("output.txt");
            Scanner input = new Scanner(inputFile);
            FileWriter fw = new FileWriter(outputFile);

            // Read each line from input file
            while (input.hasNextLine()) {
                String line = input.nextLine();
                ArrayList<String> inputArray = new ArrayList<String>();
                String[] bytes = line.trim().split("\\s+");
                // Add each byte to an array list
                for (String eachByte : bytes) {
                    inputArray.add(eachByte);
                }

                String[] outputArray = new String[(12 / dataTypeSize)];
                //System.out.println(inputArray.toString());

                // For every number in one line
                for (int i = 0; i < (12 / dataTypeSize); i++) {
                    ArrayList<String> dataByteList = new ArrayList<String>();
                    // Put the bytes of this number in dataByteList
                    for (int j = 0; j < dataTypeSize; j++) {
                        dataByteList.add(inputArray.get(0));
                        inputArray.remove(0);
                    }
                    // If byte ordering little endian
                    if (byteOrdering.equals("little endian") || byteOrdering.equals("l")) {
                        Collections.reverse(dataByteList);
                    }
                    //System.out.println(dataByteList.toString());
                    ArrayList<Character> dataHexList = new ArrayList<Character>();
                    // Convery dataByteList to a hexadecimal list
                    for (String str : dataByteList) {
                        dataHexList.add(str.charAt(0));
                        dataHexList.add(str.charAt(1));
                    }
                    //System.out.println(dataHexList.toString());

                    // Convert hexadecimal array to a binary list
                    ArrayList<Integer> binaryList = new ArrayList<Integer>();
                    for (int k = 0; k < dataHexList.size(); k++) {
                        switch (dataHexList.get(k)) {
                            case '0':
                                binaryList.addAll(Arrays.asList(0, 0, 0, 0));
                                break;
                            case '1':
                                binaryList.addAll(Arrays.asList(0, 0, 0, 1));
                                break;
                            case '2':
                                binaryList.addAll(Arrays.asList(0, 0, 1, 0));
                                break;
                            case '3':
                                binaryList.addAll(Arrays.asList(0, 0, 1, 1));
                                break;
                            case '4':
                                binaryList.addAll(Arrays.asList(0, 1, 0, 0));
                                break;
                            case '5':
                                binaryList.addAll(Arrays.asList(0, 1, 0, 1));
                                break;
                            case '6':
                                binaryList.addAll(Arrays.asList(0, 1, 1, 0));
                                break;
                            case '7':
                                binaryList.addAll(Arrays.asList(0, 1, 1, 1));
                                break;
                            case '8':
                                binaryList.addAll(Arrays.asList(1, 0, 0, 0));
                                break;
                            case '9':
                                binaryList.addAll(Arrays.asList(1, 0, 0, 1));
                                break;
                            case 'a':
                                binaryList.addAll(Arrays.asList(1, 0, 1, 0));
                                break;
                            case 'b':
                                binaryList.addAll(Arrays.asList(1, 0, 1, 1));
                                break;
                            case 'c':
                                binaryList.addAll(Arrays.asList(1, 1, 0, 0));
                                break;
                            case 'd':
                                binaryList.addAll(Arrays.asList(1, 1, 0, 1));
                                break;
                            case 'e':
                                binaryList.addAll(Arrays.asList(1, 1, 1, 0));
                                break;
                            case 'f':
                                binaryList.addAll(Arrays.asList(1, 1, 1, 1));
                                break;
                        }
                    }
                    //System.out.println(binaryList.toString());

                    // If the number is signed integer
                    if (dataType.equals("int") || dataType.equals("signed integer")) {
                        int signedInt = 0;
                        signedInt += (-1) * binaryList.get(0) * Math.pow(2, binaryList.size() - 1);
                        for (int index = binaryList.size() - 2; index >= 0; index--) {
                            signedInt += binaryList.get(binaryList.size() - 1 - index) * Math.pow(2, index);
                        }
                        outputArray[i] = Integer.toString(signedInt);
                    }
                    // If the number is unsigned integer
                    if (dataType.equals("unsigned") || dataType.equals("unsigned integer")) {
                        long unsignedInt = 0;
                        for (int index = binaryList.size() - 1; index >= 0; index--) {
                            unsignedInt += binaryList.get(binaryList.size() - 1 - index) * Math.pow(2, index);
                        }
                        outputArray[i] = Long.toString(unsignedInt);
                    }
                    // If the number is float
                    if (dataType.equals("float") || dataType.equals("floating point")) {
                        int signBit = binaryList.get(0);
                        binaryList.remove(0);

                        int exponentPart = 2 * dataTypeSize + 2;
                        int exponentNumber = 0;
                        int bias = (int) Math.pow(2, exponentPart - 1) - 1;
                        double mantissaNumber = 0;
                        // Get exponent
                        ArrayList<Integer> exponentList = new ArrayList<Integer>();
                        for (int e = 0; e < exponentPart; e++) {
                            exponentList.add(binaryList.get(0));
                            exponentNumber += binaryList.get(0) * Math.pow(2, exponentPart - 1 - e);
                            binaryList.remove(0);
                        }

                        // Get mantissa
                        ArrayList<Integer> mantissaList = new ArrayList<Integer>();
                        mantissaList = binaryList;
                        //System.out.println(mantissaList.toString());

                        // mantissa round to even
                        if (mantissaList.size() > 13) {
                            // If least significant bit is 0 and after bits are 11
                            if (mantissaList.get(12) == 0 && mantissaList.get(13) == 1 && mantissaList.get(14) == 1) {
                                mantissaList.set(12, 1);
                                mantissaList.subList(13, mantissaList.size()).clear();
                            }
                            // If least significant bit is 0 and after bits are 10 
                            else if (mantissaList.get(12) == 0 && mantissaList.get(13) == 1
                                    && mantissaList.get(14) == 0) {
                                mantissaList.subList(13, mantissaList.size()).clear();
                            }
                            // If least significant bit is 1 and after bit are 1 
                            else if (mantissaList.get(12) == 1 && mantissaList.get(13) == 1) {
                                mantissaList.subList(13, mantissaList.size()).clear();
                                // If chopped mantissa contains 0 
                                if (mantissaList.contains(0)) {
                                    mantissaList.set(12, 0);
                                    for (int index = mantissaList.size() - 2; index >= 0; index--) {
                                        if (mantissaList.get(index) == 0) {
                                            mantissaList.set(index, 1);
                                            break;
                                        }
                                        mantissaList.set(index, 0);
                                    }
                                }
                            } else {
                                mantissaList.subList(13, mantissaList.size()).clear();
                            }
                            //System.out.println(mantissaList.toString());
                        }

                        // If exponent and mantissa all 0
                        if (!exponentList.contains(1) && !mantissaList.contains(1)) {
                            outputArray[i] = (signBit == 1) ? "-0" : "0";
                        }
                        // For denormalized values
                        else if (!exponentList.contains(1)) {
                            for (int f = 0; f < mantissaList.size(); f++) {
                                mantissaNumber += mantissaList.get(f) * Math.pow(2, 0 - (f + 1));
                            }
                            double floatNumber = (double) (Math.pow((-1), signBit) * mantissaNumber
                                    * Math.pow(2, 1 - bias));
                            //outputArray[i] = String.format("%6g", floatNumber).toLowerCase().replace(',', '.');
                            outputArray[i] = String.format(Locale.US, "%6g", floatNumber).toLowerCase();
                        }
                        // If exponent all 1 and mantissa 0
                        else if (!exponentList.contains(0) && !mantissaList.contains(1)) {
                            outputArray[i] = (signBit == 1) ? Float.toString(Float.NEGATIVE_INFINITY)
                                    : Float.toString(Float.POSITIVE_INFINITY);
                        }
                        // If exponent all 1 and mantissa contains 1
                        else if (!exponentList.contains(0) && mantissaList.contains(1)) {
                            outputArray[i] = Float.toString(Float.NaN);
                        }
                        // For normalized values
                        else {
                            mantissaNumber = 1;
                            for (int f = 0; f < mantissaList.size(); f++) {
                                mantissaNumber += mantissaList.get(f) * Math.pow(2, -(f + 1));
                            }
                            double floatNumber = (double) (Math.pow((-1), signBit) * mantissaNumber
                                    * Math.pow(2, exponentNumber - bias));
                            //outputArray[i] = String.format("%6g", floatNumber).toLowerCase().replace(',', '.');
                            outputArray[i] = String.format(Locale.US, "%6g", floatNumber).toLowerCase();
                        }
                    }
                }
                String output = String.join(" ", outputArray);
                fw.write(output);
                fw.write("\n");
            }
            input.close();
            fw.close();
        } catch (

        Exception exception) {
            exception.printStackTrace();
        }
    }
}