import java.util.Random;

float[][] in = new float[][]{{ 1120.7008, 40.672447, 0.0 }, { 25.517963, 314.26483, 0.0 }, { 1085.6746, 16.152382, 0.0 }, { 612.34674, 554.5987, 0.0 }, { 42.678165, 176.5224, 0.0 }, { 550.2458, 175.26622, 0.0 }, { 266.4603, 277.49878, 0.0 }, { 248.54314, 380.9767, 0.0 }, { 581.62335, 757.07086, 0.0 }, { 620.9317, 705.03705, 0.0}};

int count = 10;
int popSize = 2000;
float mutationRate = 0.5;
int stopGen = 2000;

PVector[] targets = new PVector[count];
int[] order = new int[count];
int[][] population = new int[popSize][count];
float[] fitness = new float[popSize];

FloatList topFit = new FloatList();

int[] bestOrder = new int[count];
float bestDist = Float.POSITIVE_INFINITY;

int gen = 1;

void setup() {
  frameRate(120);
  size(1200, 800);
  for (int i = 0; i < count; i++) {
      targets[i] = new PVector(random(0,1200), random(0,800));
      // targets[i] = new PVector(in[i][0], in[i][1]);
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

  beginShape();
  for (int i = 0; i < topFit.size(); i++) {
    stroke(255,255,10);
    vertex(100.0 + 1000*((float) i/topFit.size()), -600 + 1200*(topFit.get(i)/topFit.max()));
  }
  endShape();

  // CALCULATE FITNESS
  for (int i = 0; i < popSize; i++) {
    float currDist = calcDist(population[i]);
    if (currDist < bestDist) {
      bestDist = currDist;
      bestOrder = population[i];
    }
    fitness[i] = 1 / (currDist);
    // drawPath(population[i], 0, Float.toString(currDist));
  }

  // NORMALIZE
  float sum = 0;
  for (float f : fitness) {
    sum += f;
  }
  for (int i = 0; i < popSize; i++) {
     fitness[i] /= sum;
  }
  topFit.append(bestDist);

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
  if (gen >= stopGen) noLoop();
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

  while (r > 0 && index < prob.length) {
    r = r - prob[index];
    index++;
  }
  if (index > 0) index--;
  int[] out = new int[count];
  arrayCopy(list[index], out);
  return out;
}

void mutate(int[] order, float rate) {
  for (int i = 0; i < count; i++) {
    if (random(1) < rate) {
      int a = floor(random(0, order.length));
      int b = floor(random(0, order.length));
      swap(order, a, b);
    }
  }
}
