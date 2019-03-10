int count = 6;
PVector[] targets = new PVector[count];
int[] order = new int[count];

int[] bestOrder = new int[count];
float bestDist = Float.POSITIVE_INFINITY;

int totalPerm;
int asc = 0;

void setup() {
  frameRate(120);
  size(600, 800);
  for (int i = 0; i < count; i++) {
      targets[i] = new PVector(random(0,600), random(0,400));
  }
  for (int i = 0; i < count; i++) {
     order[i] = i; 
  }
  arrayCopy(order, bestOrder);
}

void draw() {
  background(0);
  drawPath(bestOrder, 0, Float.toString(bestDist));
  swap(order, (int) Math.floor(random(0,order.length)), (int) Math.floor(random(0,order.length)));
  float currDist = calcDist(order);
  println(order);
  if (currDist < bestDist) {
    bestDist = currDist;
    arrayCopy(order, bestOrder);
    println("New best: " + bestDist);
  }
  drawPath(order, 400, Float.toString(currDist));

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
