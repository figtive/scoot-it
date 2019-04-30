from django.db import models


class GAConfig(models.Model):
    generationEnd = models.IntegerField(default=150)
    populationSize = models.IntegerField(default=20)
    mutationRate = models.FloatField(default=0.2)
