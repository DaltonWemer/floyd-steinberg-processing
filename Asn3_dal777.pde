// Dalton Wemer

/* This program simulates indexed color. It loads a color palette
   calculated using the k-means algorithm. These colors are
   substituted for the original pixel colors in the image.
   '1' displays the original image; '2' displays the indexed image;
   '3' displays the dithered image; 'c' displays the color palette
   'h': color counts in indexed image; 'd' color counts in dithered image
THIS VERSION USES A PREVIOUSLY SAVED PALETTE - IT DOES NOT DO K-MEANS
*/
final int HUGENUM = 500; //Bigger than any color distance
String fname1 = "ColoredSquares.jpg", fname2 = "colorful-1560.jpg";
String fname3 = "Lizard.jpg";
String loadName = fname2; //This is the file to load
int ncolors = 8;  //number of colors in the table
color[] colorTable = new color[ncolors];  //This is the color palette; loaded for you
int[] pHist = new int[ncolors]; //Shows counts of colors in indexed image; you'll fill this
int[] dHist = new int[ncolors]; //Shows counts of colors in dithered image; you'll fill this
PImage[] img = new PImage[3];  //original, indexed, dithered, images
/* indices is same length as pixel array and will hold color indexes.
   For example, when indexing img[0], indices[0] will hold the index of
   the matching palette color for img[0].pixels[0].
*/
int[] indices;  //You'll fill this; indices[x] will hold the color palette index for img.pixels[x]
int imgIndex = 0;  //Determines which image to display

void setup() {
  //Don't change setup()
  size(500, 500);
  surface.setResizable(true);
  img[0] = loadImage(loadName);
  surface.setSize(img[0].width, img[0].height);
  img[0].loadPixels();
  indices = new int[img[0].pixels.length];  //Will hold matching palette index for each pixel
  //The next lines create paletteName; assumes loadName extension is 4 chars (ex: ".jpg")
  String fileName = loadName;
  int nc = ncolors;
  String paletteName = "palettes" + File.separator + fileName.substring(0, fileName.length()-4) + 
                "_" + str(nc) + ".bmp";
  readPalette(paletteName, colorTable);  //Read the color palette into colorTable
  matchTable(indices, colorTable, img[0]);  //Match the pixels w/colors from colorTable
  //Now index img[0] - put the result in img[1]
  img[1] = indexImage(indices, colorTable, img[0].width, img[0].height);
  img[2] = img[0].get();  //Get a copy of img[0]
  dither(img[2], colorTable);  //Index img[2] and dither it
}
void readPalette(String paletteName, color[] palette) {
  //Load the palette into the color table; don't change this function
  //For convenience, the palette is stored as pixels in an image
  PImage paletteImage = loadImage(paletteName);
  paletteImage.loadPixels();
  for (int i = 0; i < palette.length; i++) {
    palette[i] = paletteImage.pixels[i];
  }
}
void draw() {
}
float cdist(color c1, color c2) {
  //Returns the distance between c1 and c2; don't change this function
  float r1 = red(c1), r2 = red(c2);
  float g1 = green(c1), g2 = green(c2);
  float b1 = blue(c1), b2 = blue(c2);
  float d = sqrt(sq(r1-r2) + sq(g1-g2) + sq(b1-b2));
  return d;
} 

// Gets the index of a pixel in a pixel array
// taking in the parameters x and y (helper function)
int indexPixel(int x, int y){
  return x + y * img[0].width;
}

void matchTable(int[] indices, color[] table, PImage img) {
  /* This function matches each pixel in img to the color table
     and puts the closest-matching index into the corresponding
     entry in the indices array. For example, if table[7] is the
     closest color match to img.pixels[4912] then indices[4912]
     will get a value of 7.
  */
 
  for(int y=0; y < img.height; y++)
  {
    for(int x=0; x < img.width; x++)
    {
      // Grab the color at the current pixel
      color c = img.get(x,y);
      // Initially set the minimum distance to the first color in the table
      float minDist = cdist(c, table[0]);
      // The position of the current closests 
      int minDistPos = 0;
      
      // Loop through the color table and find the color that is closest
      // to the given pixels color
      for(int i=0; i < table.length; i++)
      {
       float dist = cdist(c, table[i]); 
       if(dist < minDist)
       {
         minDist = dist;
         minDistPos = i;
       }
      }
      // Update the pixel we are on with the color in our color table that most
      // accurately represets it 
      int currentPixel = indexPixel(x,y);
      indices[currentPixel] = minDistPos;
    }
  }
}

PImage indexImage(int[] indices, color[] table, int w, int h) {
  /* Returns a new image with each pixel replaced by the closest
     matching color in table. For example, if indices[47219] has
     a value of 7, then target.pixels[47219] will be replaced by
     the color in table[7].
  */
  PImage target = createImage(w, h, RGB);
  target.loadPixels();
  //Put your code here to replace pixels with colors from the palette
  for(int i = 0; i < target.pixels.length; i++)
  {
    target.pixels[i] = table[indices[i]];
  }
  target.updatePixels();
  return target;
}

void hist(int[] counts) {  //Create histogram for indexed image
  /* Creates histogram of index values. Note that this
     histogram does NOT range from 0 to 255 - it
     ranges from 0 to the number of colors in colorTable;
     counts is the same size as colorTable.
     You should fill counts with the number of times
     each color is used in the image. For example,
     counts[3] will be the number of times colorTable[3]
     is used. You can get the number of times each color
     is used from the indices array. Go through the indices
     array and count the number of times each index is used.
     For example, every time you see a value of 5 in indices[],
     add one to counts[5]; every time you see a value of 0 in
     indices, add 1 to counts[0], etc.
  */
  
  // Reset the array of counts
   for(int i=0; i < counts.length; i++)
   {
      counts[i] = 0;
   }
    
    // Update the counts histogram for the indexed image
    for(int i=0; i < indices.length; i++)
    {
      counts[indices[i]]++;
    }
    
  //Your code here to fill counts with the number of times each color is used
  drawHist(counts);  //Display the counts histogram
}
void drawHist(int[] counts) {
  background(0);
  /*Your code here to display the histogram; the values are held in the
    counts array. You will first have to find the max value in counts
    and use that to scale the histogram bars. Alternatively, you can
    display the counts as text on the canvas.
  */
  
  // Find the maximum value stored in our counts array
  int maxVal = 0;
  for(int i=0; i < counts.length; i++)
  {
    if(counts[i] > maxVal)
    {
      maxVal = counts[i];
    }
  }
  
  // Loop through all of the colors in our counts array and 
  // draw a rectangle to represent the Histogram bar for each one.
  for (int i = 0;  i < counts.length; i++)
  {
    stroke(colorTable[i]);
    strokeWeight(40);
    strokeCap(SQUARE);
    int val = int(map(counts[i], 0 , maxVal, 0, height / 2));
    line((i*50) + 50, height, (i*50) + 50, height - val);
    textSize(16);
    fill(255, 255, 255);
    text(counts[i], (i*50) + 25, (height-val) - 10);
  }
}
void showColors() { //Display the color table
  // Set the background color to black
  background(0);
  /*Your code here to display the color table. It doesn't have to
    look like mine but it should be comprehensible.
  */
  noStroke();
  // Loop through all of the colors in the color palette and
  // make a full height rectangle filled with the color
  for(int i = 0; i < colorTable.length; i++)
  {
    fill(colorTable[i]);
    float rectWidth= width/colorTable.length; 
    float rectLength = height;
    rect(rectWidth * i, 0, rectWidth, rectLength);
  }
}

// Implementation of the Floyd-Steinberg Algorithm
void dither(PImage img, color[] palette) {
  img.loadPixels();
  //Put your code here to replace pixels with colors from the palette
  for(int y=0; y < img.height-1; y++)
  {
    for(int x=1; x < img.width-1; x++)
    {
      color p = img.pixels[indexPixel(x,y)];
      
      float oldR = red(p);
      float oldG = green(p);
      float oldB = blue(p);
      
      int minDistPos=0;
      float minDist = HUGENUM;
      
      for(int i=0; i < ncolors; i++)
      {
        float dist = cdist(p, palette[i]); 
        if(dist < minDist)
        {
          minDist = dist;
          minDistPos = i;
        }
      }
      
      dHist[minDistPos]++;
      
      float newR = red(palette[minDistPos]);
      float newG = green(palette[minDistPos]);
      float newB = blue(palette[minDistPos]);
      
      
      img.pixels[indexPixel(x,y)] = color(newR, newG, newB);
       
       
      float errR = oldR - newR;
      float errG = oldG - newG;
      float errB = oldB - newB;


      int index = indexPixel(x+1, y  );
      color c = img.pixels[index];
      float r = red(c);
      float g = green(c);
      float b = blue(c);
      r = r + errR * 7/16.0;
      g = g + errG * 7/16.0;
      b = b + errB * 7/16.0;
      img.pixels[index] = color(r, g, b);

      index = indexPixel(x-1, y+1  );
      c = img.pixels[index];
      r = red(c);
      g = green(c);
      b = blue(c);
      r = r + errR * 3/16.0;
      g = g + errG * 3/16.0;
      b = b + errB * 3/16.0;
      img.pixels[index] = color(r, g, b);

      index = indexPixel(x, y+1);
      c = img.pixels[index];
      r = red(c);
      g = green(c);
      b = blue(c);
      r = r + errR * 5/16.0;
      g = g + errG * 5/16.0;
      b = b + errB * 5/16.0;
      img.pixels[index] = color(r, g, b);


      index = indexPixel(x+1, y+1);
      c = img.pixels[index];
      r = red(c);
      g = green(c);
      b = blue(c);
      r = r + errR * 1/16.0;
      g = g + errG * 1/16.0;
      b = b + errB * 1/16.0;
      img.pixels[index] = color(r, g, b);
    }
  }
  
  img.updatePixels();
}
void keyReleased() {
  if (key == '1') image(img[0], 0, 0);
  else if (key == '2') image(img[1], 0, 0);
  else if (key == '3') image(img[2], 0, 0);
  else if (key == 'h') hist(pHist);
  else if (key == 'd') drawHist(dHist);
  else if (key == 'c') showColors();
}
