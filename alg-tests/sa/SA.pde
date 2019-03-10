import java.util.Random;

float[][] in = new float[][]{{ 279.5329, 203.40085, 0.0 }, { 372.82462, 341.26685, 0.0 }, { 169.87051, 390.5711, 0.0 }, { 1170.7555, 243.83423, 0.0 }, { 22.46096, 251.0839, 0.0 }, { 128.64104, 211.51483, 0.0 }, { 544.96045, 152.75974, 0.0 }, { 636.8578, 136.5153, 0.0 }, { 349.62845, 374.3303, 0.0 }, { 956.3422, 115.21788, 0.0 }, { 207.49612, 140.23593, 0.0 }, { 509.006, 314.22595, 0.0 }, { 69.27173, 331.65973, 0.0 }, { 1036.0334, 294.22574, 0.0 }, { 602.8348, 264.09482, 0.0 }, { 176.3081,132.23543, 0.0 }, { 190.02034, 356.01437, 0.0 }, { 1165.8201, 19.736217, 0.0}, { 746.44476, 9.52208, 0.0 }, { 455.8177, 277.3942, 0.0 }};

int count = 10;

PVector[] targets = new PVector[count];
int[] order = new int[count];

int[] bestOrder = new int[count];
float bestDist = Float.POSITIVE_INFINITY;

float temperature = 10;
float initTemperature = temperature;
float coolingRate = 0.0005;

FloatList progress = new FloatList();

void setup() {
  frameRate(300);
  size(1200, 800);
  for (int i = 0; i < count; i++) {
      targets[i] = new PVector(random(0,1200), random(0,800));
      // targets[i] = new PVector(in[i][0], in[i][1]);
  }
  for (int i = 0; i < count; i++) {
     order[i] = i;
  }
  arrayCopy(order, bestOrder);
}

void draw() {
  background(0);
  textSize(32);
  text("Temp: " + temperature, 10, 60);
  for (int i = 0; i < progress.size(); i++) {
    stroke(255, 255, 10);
    circle(20 + 69*(i*coolingRate/initTemperature), 300 + 20*(progress.get(i)/2000), 1);
  }


  if (temperature > 1) {
    int[] newOrder = new int[count];
    arrayCopy(order, newOrder);

    int pos1 = newOrder[(int) (count * random(1))];
    int pos2 = newOrder[(int) (count * random(1))];

    swap(newOrder, pos1, pos2);
    println("-----------------");
    println(order);
    println(newOrder);

    float currTemperature = calcDist(order);
    float nextTemperature = calcDist(newOrder);
    text("Curr: " + (nextTemperature), 10, 94);
    progress.append(currTemperature);

    if (acceptanceProbability(currTemperature, nextTemperature, temperature) >= random(1)) {
      arrayCopy(newOrder, order);
    }

    if (currTemperature < bestDist) {
      bestDist = currTemperature;
      arrayCopy(newOrder, bestOrder);
    }
    temperature *= 1 - coolingRate;
  }
  drawPath(bestOrder, 0, Float.toString(bestDist));
}

public static double acceptanceProbability(float energy, float newEnergy, double temperature) {
    // If the new solution is better, accept it
    if (newEnergy < energy) {
        return 1.0;
    }
    // If the new solution is worse, calculate an acceptance probability
    return Math.exp((energy - newEnergy) / temperature);
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
