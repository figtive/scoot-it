import java.util.Random;

int count = 10;
int popSize = 1000;
float mutationRate = 2;

PVector[] targets = new PVector[count];
int[] order = new int[count];
int[][] population = new int[popSize][count];
float[] fitness = new float[popSize];

int[] bestOrder = new int[count];
float bestDist = Float.POSITIVE_INFINITY;

int gen = 1;

void setup() {
  frameRate(60);
  size(600, 400);
  for (int i = 0; i < count; i++) {
      targets[i] = new PVector(random(0,600), random(0,400));
  }
  for (int i = 0; i < count; i++) {
     order[i] = i; 
  }
  for (int i = 0; i < popSize; i++) {
    population[i] = shuffle(order);
  }
  arrayCopy(order, bestOrder);
}

void draw() {
  background(0);
  textSize(32);
  text("Gen: " + gen, 10, 60);
  
  // CALCULATE FITNESS
  for (int i = 0; i < popSize; i++) {
    float currDist = calcDist(population[i]);
    if (currDist < bestDist) {
      bestDist = currDist;
      bestOrder = population[i];
    }
    fitness[i] = 1 / (currDist + 1);
    //drawPath(population[i], 400, Float.toString(currDist));
  }
  println(population[1]);
  
  // NORMALIZE
  float sum = 0;
  for (float f : fitness) {
    sum += f;
  }
  for (int i = 0; i < popSize; i++) {
     fitness[i] /= sum;
  }
  
  // GENERATE NEXT POPULATION
  int[][] newPopulation = new int[popSize][count];
  for (int i = 0; i < popSize; i++) {
    int[] order = pickOne(population, fitness);
    mutate(order, mutationRate);
    newPopulation[i] = order;
  }
  population = newPopulation;
  
  drawPath(bestOrder, 0, Float.toString(bestDist));
  gen++;
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
  for (int i = 0; i < arr.length - 1; i++) {
    sum += dist(targets[arr[i]].x, targets[arr[i]].y, targets[arr[i + 1]].x, targets[arr[i + 1]].y);
  }
  return sum;
}

int[] shuffle(int[] array) {
  // Fisher–Yates shuffle
  
  Random rng = new Random();
  int[] out = new int[array.length];
  arrayCopy(array, out);
  for (int i = out.length; i > 1; i--) {
    int j = rng.nextInt(i);
    int tmp = out[j];
    out[j] = out[i-1];
    out[i-1] = tmp;
  }
  return out;
}

int[] pickOne(int[][] list, float[] prob) {
  int index = 0;
  float r = random(1);

  while (r > 0) {
    r = r - prob[index];
    index++;
  }
  index--;
  int[] out = new int[count];
  arrayCopy(list[index], out);
  return out;
}

void mutate(int[] order, float rate) {
  int i = floor(random(0, order.length));
  int j = floor(random(0, order.length));
  swap(order, i, j);
}
