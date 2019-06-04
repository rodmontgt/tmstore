/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package oauthtester;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.util.Scanner;
import org.apache.commons.codec.binary.Base64;

/**
 *
 * @author Ankur
 */
public class Utils {

    public static String executeCommand(String command) {
        System.out.println("-- executeCommand [" + command + "] --");
        StringBuffer output = new StringBuffer();
        Process p;
        try {
            p = Runtime.getRuntime().exec(command);
            p.waitFor();
            BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
            String line = "";
            while ((line = reader.readLine()) != null) {
                output.append(line + "\n");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return output.toString();
    }

    public static String executeCommand(String[] command) {
        System.out.println("-- executeCommandArray --");
        for (int i = 0; i < command.length; i++) {
            System.out.println("[" + command[i] + "]");
        }
        StringBuffer output = new StringBuffer();
        Process p;
        try {
            p = Runtime.getRuntime().exec(command);
            p.waitFor();
            BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
            String line = "";
            while ((line = reader.readLine()) != null) {
                output.append(line + "\n");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return output.toString();
    }

    public static boolean executeCommandInFile(String[] command, File outputFile) {
        System.out.println("-- executeCommandInFile --");
        try {
            ProcessBuilder builder = new ProcessBuilder(command); //"sh", "somescript.sh");
            builder.redirectOutput(outputFile);
            builder.redirectError(outputFile);
            Process p = builder.start(); // throws IOException
            return outputFile.exists();
            //String result = new VerboseProcess(new ProcessBuilder(command)).stdout();
            //System.out.println("-- result: ["+result+"] --");
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
    }

    public static String readFile(String pathname) throws IOException {
        return readFile(new File(pathname));
    }

    public static String readFile(File file) throws IOException {
        StringBuilder fileContents = new StringBuilder((int) file.length());
        Scanner scanner = new Scanner(file);
        String lineSeparator = System.getProperty("line.separator");
        try {
            while (scanner.hasNextLine()) {
                fileContents.append(scanner.nextLine() + lineSeparator);
            }
            return fileContents.toString();
        } finally {
            scanner.close();
        }
    }

    public static void writeInFile(File file, String content) throws IOException {
        OutputStreamWriter outputStreamWriter;
        FileOutputStream fileOutputStream = new FileOutputStream(file);
        outputStreamWriter = new OutputStreamWriter(fileOutputStream, StandardCharsets.UTF_8);
        outputStreamWriter.write(content);
        outputStreamWriter.close();
        fileOutputStream.close();
    }

    public static void replaceInFile(String path, String target, String replacement) throws IOException {
        File file = new File(path);
        String content = readFile(file);
        content = content.replaceAll(target, replacement);
        writeInFile(file, content);
    }

    public static String encrypt(final String data, String key) {
        //return Base64.encodeToString(xor(data.getBytes(), key), Base64.NO_WRAP);
        return new String(Base64.encodeBase64(xor(data.getBytes(), key)));
    }

    private static byte[] xor(final byte[] input, String key) {
        final byte[] output = new byte[input.length];
        final byte[] secret = key.getBytes();
        int spos = 0;
        for (int pos = 0; pos < input.length; ++pos) {
            output[pos] = (byte) (input[pos] ^ secret[spos]);
            spos += 1;
            if (spos >= secret.length) {
                spos = 0;
            }
        }
        return output;
    }

    public static boolean isEmptyString(String str) {
        return str == null || str.length() == 0 || str.equals("null");
    }
}
