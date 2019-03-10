import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class brute_force_order extends PApplet {

int count = 10;
PVector[] targets = new PVector[count];
int[] order = new int[count];

int[] bestOrder = new int[count];
float bestDist = Float.POSITIVE_INFINITY;

int totalPerm;
int asc = 0;

public void setup() {
  frameRate(60);
  
  for (int i = 0; i < count; i++) {
      targets[i] = new PVector(random(0,600), random(0,400));
  }
  for (int i = 0; i < count; i++) {
     order[i] = i;
  }
  arrayCopy(order, bestOrder);
  totalPerm = factorial(count);
}

public void draw() {
  background(0);
  nextOrder();
  float currDist = calcDist(order);
  if (currDist < bestDist) {
    bestDist = currDist;
    arrayCopy(order, bestOrder);
    println("New best: " + bestDist);
  }
  drawPath(bestOrder, 0, Float.toString(bestDist));
  drawPath(order, 400, String.format("%.6f", 100 * ((float) asc / (float) totalPerm)) + "%");

}


public void drawPath(int[] order, int offset, String text) {
  noFill();
  stroke(255);
  strokeWeight(2);
  beginShape();
  for (int i : order) {
    ellipse(targets[i].x, targets[i].y + offset, 10, 10);
    vertex(targets[i].x, targets[i].y + offset);
  }
  endShape(CLOSE);
  textSize(32);
  text(text, 10, 30 + offset);
}

public void swap(int[] arr, int a, int b) {
  int temp = arr[b];
  arr[b] = arr[a];
  arr[a] = temp;
}

public float calcDist(int[] arr) {
  float sum = 0;
  for (int i = 0; i < order.length - 1; i++) {
    //sum += Math.sqrt(Math.pow((targets[i + 1].x - targets[i].x), 2) + Math.pow((targets[i + 1].y - targets[i].y), 2));
    sum += dist(targets[order[i]].x, targets[order[i]].y, targets[order[i + 1]].x, targets[order[i + 1]].y);
  }
  return sum;
}

public void nextOrder() {
  asc++;

  int largestI = -1;
  for (int i = 0; i < order.length - 1; i++) {
    if (order[i] < order[i + 1]) {
      largestI = i;
    }
  }
  if (largestI == -1) {
      noLoop();
    }
    if (largestI != -1){
    int largestJ = -1;
    for (int j = 0; j < order.length; j++) {
      if (order[largestI] < order[j]) {
        largestJ = j;
      }
    }
    swap(order, largestI, largestJ);

    int size = order.length - largestI - 1;
    int[] endArray = new int[size];
    arrayCopy(order, largestI + 1, endArray, 0, size);
    endArray = reverse(endArray);
    arrayCopy(endArray, 0, order, largestI+1, size);
  }
}

public int factorial(int n) {
  if (n == 1) {
    return 1;
  } else {
    return n * factorial(n - 1);
  }
}
  public void settings() {  size(600, 800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "brute_force_order" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
