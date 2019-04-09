import json

from django.conf import settings
from django.http import JsonResponse, HttpResponseBadRequest
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt

from . import client_helper as ch
from . import genetic_algorithm as ga_lib


def index(request):
    return render(request, 'index/index.html', {'api_key': settings.GOOGLE_MAPS_API_KEY})


@csrf_exempt
def process(request):
    if request.method == 'POST':
        body = json.loads(request.body.decode('utf-8'))
        destinations = body['destinations']
        method = body['method']     # ['distance', 'duration', 'duration_in_traffic']
        radius = 50

        mapping = ch.get_matrix(destinations, method)
        print("Within {}km radius? {}".format(radius, ch.check_range(mapping, radius)))

        print("\nDestinations:")
        for s in destinations:
            print("> " + s)
        print("\nOrder by: {}".format(method))

        ga = ga_lib.GA(mapping, 150, 20, 0.2, destinations)
        sequence, historyDistance, bestChromosome, firstChromosome = ga.run()

        ch.show_report(historyDistance, bestChromosome, firstChromosome, destinations, method)
        print("\nBest sequence:")
        for s in sequence:
            print("> " + destinations[s])

        return JsonResponse({
            'sequence': {
                'city': [destinations[i] for i in sequence],
                'index': sequence
            },
            'method': method,
            'cost': bestChromosome.distance()
        })
    else:
        return HttpResponseBadRequest()
