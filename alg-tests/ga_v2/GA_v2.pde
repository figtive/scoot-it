float[][] in = new float[][]{{ 1120.7008, 40.672447, 0.0 }, { 25.517963, 314.26483, 0.0 }, { 1085.6746, 16.152382, 0.0 }, { 612.34674, 554.5987, 0.0 }, { 42.678165, 176.5224, 0.0 }, { 550.2458, 175.26622, 0.0 }, { 266.4603, 277.49878, 0.0 }, { 248.54314, 380.9767, 0.0 }, { 581.62335, 757.07086, 0.0 }, { 620.9317, 705.03705, 0.0}};


int count = 10;

int popSize = 5000;
float mutationRate = 0;
int stopGen = 10000;

IntList[] order = new IntList[popSize];
PVector[] cities = new PVector[count];

FloatList fitness = new FloatList();

float bestDist = Float.POSITIVE_INFINITY;
IntList bestOrder = new IntList();

FloatList topFit = new FloatList();

int gen = 0;
int currSum = 0;

void setup() {
    size(1200, 800);
    frameRate(120);
    for (int i = 0; i < cities.length; i++) {
        // cities[i] = new PVector(random(0, width), random(0, height));
        cities[i] = new PVector(in[i][0], in[i][1]);
    }
    println(cities);
    for (int i = 0; i < popSize; i++) {
        order[i] = new IntList();
        for (int j = 0; j < count; j++) {
            order[i].append(j);
        }
        order[i].shuffle();
    }
}

void draw() {
    background(0);

    // GA
    while(gen < stopGen) {
        gen++;
        calculateFitness();
        selectionAndCrossover();
        println(gen);
    }

    beginShape();
    stroke(255,255,10);
    fill(0);
    for (int i = 0; i < topFit.size(); i++) {
        vertex(100.0 + (width - 200)*((float) i/topFit.size()), -600 + 1200*(topFit.get(i)/topFit.max()));
    }
    endShape();
    drawPath(bestOrder, "Dist: " + bestDist + "\nGen: " + gen);
    if (gen >= stopGen) noLoop();
}

void calculateFitness() {
    float sum = 0;
    for (int i = 0; i < popSize; i++) {
        float dist = calcDist(order[i]);
        fitness.set(i, dist);
        sum += dist;
        if (dist < bestDist) {
            bestDist = dist;
            bestOrder = order[i].copy();
        }
    }
    // topFit.append(1/bestDist);
    for (int i = 0; i < popSize; i++) {
        fitness.set(i, fitness.get(i) / sum);
    }
    // for (int i = 0; i < popSize; i++) {
    //     fitness.set(i, fitness.min() / fitness.get(i));
    // }
    currSum = 0;
    float s = 0;
    for (int i = 0; i < popSize; i++) {
        s += calcDist(order[i]);
        currSum += fitness.get(i);
    }
    topFit.append(fitness.min());
}

void selectionAndCrossover() {
    int eliteCount = 1;
    IntList[] newOrder = new IntList[popSize];

    for (int i = 0; i < popSize; i++) {
        IntList child = new IntList();

        IntList best1 = pickOne(order, fitness);
        IntList best2 = pickOne(order, fitness);

        int crossPoint = (int) (count * random(0, 1));
        
        for (int j = 0; j < count; j++) {
            if (j < crossPoint) {
                child.append(best1.get(j));
            } else {
                child.append(getNextGene(child, best2));
            }
        }

        if (mutationRate < random(0, 1)) {
            int t1 = (int) random(0, child.size());
            int t2 = (int) random(0, child.size());
            int temp = child.get(t2);
            child.set(t2, child.get(t1));
            child.set(t1, temp);
        }
        newOrder[i] = child;
    }
    arrayCopy(newOrder, order);
}

int getNextGene(IntList child, IntList best2) {
    int index = 0;
    int next = -1;
    while(next < 0) {
        if (!child.hasValue(best2.get(index))) {
            next = best2.get(index);
        }
        index++;
    }
    return next;
}

IntList pickOne(IntList[] list, FloatList prob) {
    float r = random(0, currSum);
    float s = 0;
    int index = 0;
    while (s < r) {
        s += prob.get(++index);
    }
    if (index >= popSize) index--;
    return list[index].copy();
}

// IntList pickOne(IntList[] list, FloatList prob) {
//   int index = 0;
//   float r = random(1);

//   while (r > 0 && index < prob.size()) {
//     r = r - prob.get(index);
//     index++;
//   }
//   if (index > 0) index--;
//   return list[index].copy();
// }




void drawPath(IntList order) {
    drawPath(order, "");
}

void drawPath(IntList order, String text) {
    noFill();
    strokeWeight(2);
    beginShape();
    for (int i : order) {
        stroke(255);
        ellipse(cities[i].x, cities[i].y, 15, 15);
        stroke(128);
        vertex(cities[i].x, cities[i].y);
    }
    endShape(CLOSE);
    textSize(32);
    text(text, 10, 30);
}

float calcDist(IntList order) {
  float sum = 0;
  for (int i = 0; i < order.size() - 1; i++) {
    sum += dist(cities[order.get(i)].x, cities[order.get(i)].y, cities[order.get(i + 1)].x, cities[order.get(i + 1)].y);
  }
  return sum;
}

IntList shuffle(IntList array) {
    //   Random rng = new Random();
    //   IntList out = array.copy();
    //   for (int i = out.size(); i > 1; i--) {
    //     int j = rng.nextInt(i);
    //     int tmp = out.get(j);
    //     out.set(j, out.get(i - 1));
    //     out.set(i - 1, tmp);
    //   }
    //   return out;
    IntList out = array.copy();
    out.shuffle();
    return out;
}


