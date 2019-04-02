import numpy as np
import random
import matplotlib.pyplot as plt


class Gene:
    # Gene class, has point coords


class Chromosome:
    # Chromosome class, has sequence of Genes


class Population:
    # Population class, has multiple Chromosomes


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
                # Mutate
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

def main():
    np.random.seed(1)
    random.seed(1)


if __name__ == "__main__":
    main()