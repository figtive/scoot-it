float[][] in = new float[][]{{ 279.5329, 203.40085, 0.0 }, { 372.82462, 341.26685, 0.0 }, { 169.87051, 390.5711, 0.0 }, { 1170.7555, 243.83423, 0.0 }, { 22.46096, 251.0839, 0.0 }, { 128.64104, 211.51483, 0.0 }, { 544.96045, 152.75974, 0.0 }, { 636.8578, 136.5153, 0.0 }, { 349.62845, 374.3303, 0.0 }, { 956.3422, 115.21788, 0.0 }, { 207.49612, 140.23593, 0.0 }, { 509.006, 314.22595, 0.0 }, { 69.27173, 331.65973, 0.0 }, { 1036.0334, 294.22574, 0.0 }, { 602.8348, 264.09482, 0.0 }, { 176.3081,132.23543, 0.0 }, { 190.02034, 356.01437, 0.0 }, { 1165.8201, 19.736217, 0.0}, { 746.44476, 9.52208, 0.0 }, { 455.8177, 277.3942, 0.0 }};

int count = 20;
PVector[] targets = new PVector[count];
int[] order = new int[count];

int[] bestOrder = new int[count];
float bestDist = Float.POSITIVE_INFINITY;

int totalPerm;
int asc = 0;

void setup() {
  frameRate(120);
  size(1200, 800);
  for (int i = 0; i < count; i++) {
      // targets[i] = new PVector(random(0,1200), random(0,400));
      targets[i] = new PVector(in[i][0], in[i][1]);
  }
  for (int i = 0; i < count; i++) {
     order[i] = i;
  }
  arrayCopy(order, bestOrder);
  totalPerm = factorial(count);
  println(targets);
}

void draw() {
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


void drawPath(int[] order, int offset, String text) {
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

void swap(int[] arr, int a, int b) {
  int temp = arr[b];
  arr[b] = arr[a];
  arr[a] = temp;
}

float calcDist(int[] arr) {
  float sum = 0;
  for (int i = 0; i < order.length - 1; i++) {
    //sum += Math.sqrt(Math.pow((targets[i + 1].x - targets[i].x), 2) + Math.pow((targets[i + 1].y - targets[i].y), 2));
    sum += dist(targets[order[i]].x, targets[order[i]].y, targets[order[i + 1]].x, targets[order[i + 1]].y);
  }
  return sum;
}

void nextOrder() {
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

int factorial(int n) {
  if (n == 1) {
    return 1;
  } else {
    return n * factorial(n - 1);
  }
}
