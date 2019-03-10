float[][] in = new float[][]{{ 1120.7008, 40.672447, 0.0 }, { 25.517963, 314.26483, 0.0 }, { 1085.6746, 16.152382, 0.0 }, { 612.34674, 554.5987, 0.0 }, { 42.678165, 176.5224, 0.0 }, { 550.2458, 175.26622, 0.0 }, { 266.4603, 277.49878, 0.0 }, { 248.54314, 380.9767, 0.0 }, { 581.62335, 757.07086, 0.0 }, { 620.9317, 705.03705, 0.0}};


int count = 10;

float initTemperature = 25 * count;
float coolingRate = 0.00003 * count;
float stopTemp = 0.05;

IntList order = new IntList();
PVector[] cities = new PVector[count];

float bestDist = Float.POSITIVE_INFINITY;
IntList bestOrder = new IntList();

FloatList tempHist = new FloatList();
FloatList topFit = new FloatList();

float temperature = initTemperature;

void setup() {
    size(1800, 900);
    frameRate(60);
    for (int i = 0; i < cities.length; i++) {
        cities[i] = new PVector(random(0, width), random(0, height));
        // cities[i] = new PVector(in[i][0], in[i][1]);
    }
    println(cities);
    for (int i = 0; i < count; i++) {
        order.append(i);
    }
    order.shuffle();
}

void draw() {
    background(0);

    if (temperature <= stopTemp) noLoop();

    // SA

    while(temperature >= stopTemp) {
        IntList newOrder = order.copy();
        int t1 = (int) (newOrder.size() * random(0, 1));
        int t2 = (int) (newOrder.size() * random(0, 1));
        int temp = newOrder.get(t2);
        newOrder.set(t2, newOrder.get(t1));
        newOrder.set(t1, temp);

        float currEnergy = calcDist(order);
        float nextEnergy = calcDist(newOrder);

        if (currEnergy > nextEnergy) {
            order = newOrder.copy();
        } else if (accProb(currEnergy, nextEnergy, temperature) > random(0, 1)) {
            order = newOrder.copy();
        }
        topFit.append(calcDist(order));
        tempHist.append(temperature);
        temperature *= 1 - coolingRate;
    }



    drawPath(order, "Dist: " + calcDist(order) + "\nTemp: " + temperature);
    beginShape();
    stroke(255,255,10);
    for (int i = 0; i < tempHist.size(); i++) {
        vertex(100.0 + (width - 200)*((float) i/tempHist.size()), 600 - 400*(tempHist.get(i)/tempHist.max()));
    }
    endShape();
    beginShape();
    stroke(10,255,10);
    for (int i = 0; i < topFit.size(); i++) {
        vertex(100.0 + (width - 200)*((float) i/topFit.size()), 800 - 600*(topFit.get(i)/topFit.max()));
    }
    endShape();
}

double accProb(float curr, float next, float temp) {
    float delta = next - curr;
    if (delta < 0) return 1.0;
    return Math.exp(-delta / temp);
}

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
    IntList out = array.copy();
    out.shuffle();
    return out;
}


