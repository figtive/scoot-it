import numpy as np
import random
import matplotlib.pyplot as plt


class Gene:
    # Gene class, has point coords

class Chromosome:
    # Chromosome class, has sequence of Genes
    # sequence = [1, 5, 4, 2, 7, ...]
    def __init__(self, sequence, targets):
        self.genes = []
        self.sequence = sequence[::]
        self.targets = targets
        self.dist = None
        for s in sequence:
            self.genes.append(Gene(targets[s]))

    def fitness(self):
        return self.distance() ** -1

    def distance(self):
        if self.dist is not None:
            return self.dist
        total = 0
        for s in self.sequence:
            dist = np.sqrt((self.genes[s-1].x - self.genes[s].x)**2 + (self.genes[s-1].y - self.genes[s].y)**2)
            total += dist
        self.dist = total
        return total
    def copy(self):
        return Chromosome(self.sequence[::], self.targets)

    def mutate(self, mutationRate):
        # Swap mutation
        if random.random() < mutationRate:
            n = len(self.sequence) - 1
            a = random.randint(0, n)
            b = random.randint(a, n)
            self.sequence[a], self.sequence[b] = self.sequence[b], self.sequence[a]

class Population:
    # Population class, has multiple Chromosomes
     def __init__(self, popSize, targets):
        self.chromosomes = []
        self.targets = targets
        self.popSize = popSize

    def addChromosome(self, sequence):
        self.chromosomes.append(Chromosome(sequence, self.targets))

    def getTop(self):
        # do roulette selection
        r = random.random()
        i = 0
        plist = [c.fitness() for c in self.chromosomes]
        plist = [f / sum(plist) for f in plist]   # Normalize

        while r > 0 and i < self.popSize:
            r -= plist[i]
            i += 1
        return self.chromosomes[i - 1]
    


class GA:
    # GA class, runs GA through Populations
    def __init__(self, targets, generationEnd, popSize, mutationRate):
        self.generationEnd = generationEnd
        self.popSize = popSize
        self.mutationRate = mutationRate
        self.targets = targets
        self.population = Population(self.popSize, self.targets)
        self.initPopulation()

    def initPopulation(self):
        sequence = [s for s in range(len(self.targets))]
        for _ in range(self.popSize):
            random.shuffle(sequence)
            self.population.addChromosome(sequence)

    def run(self):
        print('===== Starting GA =====')
        print('Pop. Size \t: {:d}'.format(self.popSize))
        print('Stop Gen# \t: {:d}'.format(self.generationEnd))
        print('Mutation Rate \t: {:f}'.format(self.mutationRate))
        historyFitness = []
        historyDistance = []
        bestChromosome = None
        firstChromosome = None
        for gen in range(self.generationEnd):
            historyFitness.append(max([c.fitness() for c in self.population.chromosomes]))
            historyDistance.append(min([c.distance() for c in self.population.chromosomes]))
            # print('Progress : {:0.3f}%'.format(gen/self.generationEnd*100))
            nextPopulation = Population(self.popSize, self.targets)
            for _ in range(self.popSize):
                # Selection
                c1 = self.population.getTop()
                c2 = self.population.getTop()
                # Crossover
                o1, o2 = self.crossover(c1, c2)
                # Mutation
                o1.mutate(self.mutationRate)
                o2.mutate(self.mutationRate)
                # Get Next
                newChrom = o1.sequence if o1.fitness() > o2.fitness() else o2.sequence
                nextPopulation.addChromosome(newChrom)
                newChrom = Chromosome(newChrom, self.targets)
                firstChromosome = newChrom.copy() if firstChromosome is None else firstChromosome
                bestChromosome = newChrom.copy() if bestChromosome is None or newChrom.fitness() > bestChromosome.fitness() else bestChromosome
            self.population = nextPopulation
        print("===== Complete! =====")
        print("Best Fitness\t: {:.5f}".format(max(historyFitness)))
        print("Best Distance\t: {:.5f}".format(min(historyDistance)))
        self.showGraph(historyFitness, historyDistance, range(gen + 1), bestChromosome, self.targets, firstChromosome)

    def crossover(self, c1, c2):
        # Non-Wrapping Ordered Crossover (NWOX)
        n = len(self.targets)
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
        return Chromosome(y1, self.targets), Chromosome(y2, self.targets)

    def showGraph(self, historyFitness, historyDistance, historyGeneration, bestChromosome, targets,
                  firstChromosome):
        plt.figure(1)
        plt.subplot(211)
        plt.plot(historyGeneration, historyDistance, color='g')
        plt.ylabel('Distance')
        plt.title('GA : Performance')

        plt.subplot(212)
        plt.plot(historyGeneration, historyFitness, color='b')
        plt.ylabel('Normalized Fitness')
        plt.xlabel('Generation')
        plt.show(block=False)

        plt.figure(2)
        x, y = zip(*targets)
        plt.plot(x, y, 'ro')
        last = bestChromosome.sequence[-1]
        for i, s in enumerate(bestChromosome.sequence):
            x, y = zip(targets[last], targets[s])
            last = s
            plt.plot(x, y, 'r')
        plt.title('GA : Best Path @ dist=' + str(bestChromosome.distance()))
        plt.show(block=False)

        plt.figure(3)
        x, y = zip(*targets)
        plt.plot(x, y, 'ro')
        last = firstChromosome.sequence[-1]
        for i, s in enumerate(firstChromosome.sequence):
            x, y = zip(targets[last], targets[s])
            last = s
            plt.plot(x, y, 'r')
        plt.title('GA : First Path @ dist=' + str(firstChromosome.distance()))
        plt.show()


def main():
    np.random.seed(1)
    random.seed(1)


if __name__ == "__main__":
    main()