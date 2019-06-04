package oauthtester;

import java.awt.Color;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.Random;
import javax.imageio.ImageIO;

public class TextToGraphics {
    
    private static boolean debugEnabled = false;
    
    public static void enableDebug () {
        debugEnabled = true;
    }

    public static void disableDebug () {
        debugEnabled = false;
    }
    
    public static void main(String args[]){
        String text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has "
                + "been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of "
                + "type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the "
                + "leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the"
                + " release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing "
                + "software like Aldus PageMaker including versions of Lorem Ipsum.";
        
        if(args != null && args.length>0) {
                text = args[0];
        }
        printDataToFile(text,",","data.png");
    }
    
    public static boolean printDataToFile(String data, String separator, String filePath) {
        try {
            //String[] lines = text.split("\n");
            String[] lines = data.split(separator);
            int maxLineSize = 0;
            for(String line : lines) {
                    maxLineSize = maxLineSize < line.length()? line.length() : maxLineSize;
            }
            BufferedImage img = new BufferedImage(maxLineSize, lines.length, BufferedImage.TYPE_INT_ARGB);
            //Graphics2D g2dBnW = img.createGraphics();
            Random random = new Random();
            for(int i=0; i<lines.length; i++) {
                String line = lines[i];
                int length = line.length();
                int blanks = (maxLineSize-length)/2;
                //System.out.println("- blanks: ["+blanks+"] -");
                int j=0;
                while(j<blanks) {
                    img.setRGB(j++, i, 0);
                    if(debugEnabled) System.out.print("0");
                }
                for(j=j-blanks; j<length; j++) {
                    int colorCode = line.charAt(j);
                    //img.setRGB(j, i, getIntFromColor(colorCode%256, colorCode-colorCode%256, random.nextInt(256)));
                    img.setRGB(j, i, getIntFromColor(colorCode, random.nextInt(256), random.nextInt(256)));
                    if(debugEnabled) System.out.print("x");
                }
                j+=blanks;
                while(j<maxLineSize) {
                    img.setRGB(j++, i, 0);
                    if(debugEnabled) System.out.print("0");
                }
                if(debugEnabled) System.out.println();
            }
            ImageIO.write(img, "png", new File(filePath));
        } catch (IOException ex) {
            ex.printStackTrace();
            return false;
        } catch (Exception ex) {
            ex.printStackTrace();
            return false;
        }
        return true;
    }

    private static int getIntFromColor(int Red, int Green, int Blue){
        Red = (Red << 16) & 0x00FF0000; //Shift red 16-bits and mask out other stuff
        Green = (Green << 8) & 0x0000FF00; //Shift Green 8-bits and mask out other stuff
        Blue = Blue & 0x000000FF; //Mask out anything not blue.
        return 0xFF000000 | Red | Green | Blue; //0xFF000000 for 100% Alpha. Bitwise OR everything together.
    }
}