import numpy as np
import random
import client_helper as ch


class Gene:
    # Gene class, has point coords
    def __init__(self, id):
        self.id = id


class Chromosome:
    # Chromosome class, has sequence of Genes
    # sequence = [1, 5, 4, 2, 7, ...]
    def __init__(self, sequence, mapping):
        self.genes = []
        self.sequence = sequence[::]
        self.mapping = mapping
        self.dist = None
        for id in sequence:
            self.genes.append(Gene(id))

    def fitness(self):
        return self.distance() ** -1

    def distance(self):
        if self.dist is not None:
            return self.dist
        total = 0
        for s in range(len(self.sequence)):
            total += self.mapping[(min(self.sequence[s-1], self.sequence[s]), max(self.sequence[s-1], self.sequence[s]))]
        self.dist = total
        return total

    def copy(self):
        return Chromosome(self.sequence[::], self.mapping)

    def mutate(self, mutationRate):
        # Swap mutation
        if random.random() < mutationRate:
            n = len(self.sequence) - 1
            a = random.randint(0, n)
            b = random.randint(a, n)
            self.sequence[a], self.sequence[b] = self.sequence[b], self.sequence[a]


class Population:
    # Population class, has multiple Chromosomes
    def __init__(self, popSize, mapping):
        self.chromosomes = []
        self.targets = mapping
        self.popSize = popSize


def addChromosome(self, sequence):
    self.chromosomes.append(Chromosome(sequence, self.mapping))


def getTop(self):
    # do roulette selection
    r = random.random()
    i = 0
    plist = [c.fitness() for c in self.chromosomes]
    plist = [f / sum(plist) for f in plist]  # Normalize

    while r > 0 and i < self.popSize:
        r -= plist[i]
        i += 1
    return self.chromosomes[i - 1]


class GA:
    # GA class, runs GA through Populations
    def __init__(self, mapping, generationEnd, popSize, mutationRate, destinations):
        self.generationEnd = generationEnd
        self.popSize = popSize
        self.mutationRate = mutationRate
        self.mapping = mapping
        self.destinations = destinations
        self.population = Population(self.popSize, self.mapping)
        self.initPopulation()

    def initPopulation(self):
        sequence = [s for s in range(len(self.mapping))]
        for _ in range(self.popSize):
            random.shuffle(sequence)
            self.population.addChromosome(sequence)

    def run(self):
        print('\n===== Starting GA =====')
        print('Population Size \t: {:d}'.format(self.popSize))
        print('Stop Generation \t: {:d}'.format(self.generationEnd))
        print('Mutation Rate \t: {:f}'.format(self.mutationRate))
        historyFitness = []
        historyDistance = []
        bestChromosome = None
        firstChromosome = None
        for gen in range(self.generationEnd):
            historyFitness.append(max([c.fitness() for c in self.population.chromosomes]))
            historyDistance.append(min([c.distance() for c in self.population.chromosomes]))
            # if gen % 20 == 0:
            #     print('Progress : {:0.3f}%'.format(gen/self.generationEnd*100))
            nextPopulation = Population(self.popSize, self.mapping)
            for _ in range(self.popSize):
                # Selection
                c1 = self.population.getTop()
                c2 = self.population.getTop()
                # Crossover
                o1, o2 = self.crossover(c1, c2)
                # Mutate
                o1.mutate(self.mutationRate)
                o2.mutate(self.mutationRate)
                # Get Next
                newChrom = o1.sequence if o1.fitness() > o2.fitness() else o2.sequence
                nextPopulation.addChromosome(newChrom)
                newChrom = Chromosome(newChrom, self.mapping)
                firstChromosome = newChrom.copy() if firstChromosome is None else firstChromosome
                bestChromosome = newChrom.copy() if bestChromosome is None or newChrom.fitness() > bestChromosome.fitness() else bestChromosome
            self.population = nextPopulation
        return bestChromosome.sequence, historyDistance, bestChromosome, firstChromosome

    def crossover(self, c1, c2):
        # Non-Wrapping Ordered Crossover (NWOX)
        n = len(self.mapping)
        a = random.randint(0, n)
        b = random.randint(a, n)
        x1, x2 = c1.sequence, c2.sequence
        y1 = []
        y2 = []
        for i in range(0, n):
            if x1[i] not in x2[a:b]:
                y1.append(x1[i])
            if x2[i] not in x1[a:b]:
                y2.append(x2[i])
        y1 = y1[:a] + x2[a:b] + y1[a:]
        y2 = y2[:a] + x1[a:b] + y2[a:]
        return Chromosome(y1, self.mapping), Chromosome(y2, self.mapping)


def main():
    np.random.seed(1)
    random.seed(1)

    destinations = [
        "Universitas Indonesia",
        "Bavarian Haus Puri Indah",
        "Bavarian Haus Bogor",
    ]
    # method = "duration"     # ['distance', 'duration', 'duration_in_traffic']

    for method in ['distance', 'duration', 'duration_in_traffic']:
        mapping = ch.get_matrix(destinations, method)
        print(ch.check_range(mapping, 25))

        print("\nDestinations:")
        for s in destinations:
            print("> " + s)
        print("\nOrder by: {}".format(method))

        ga = GA(mapping, 150, 20, 0.12, destinations)
        sequence, historyDistance, bestChromosome, firstChromosome = ga.run()

        ch.show_report(historyDistance, bestChromosome, firstChromosome, destinations, method)
        print("\nBest sequence:")
        for s in sequence:
            print("> " + destinations[s])

if __name__ == "__main__":
    main()
