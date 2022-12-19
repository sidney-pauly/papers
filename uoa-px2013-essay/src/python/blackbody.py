import math


planck_constant = 6.62607015e-34
boltzmann_constant = 1.380649e-23
speed_of_light = 299792458


def blackbody_radiation(wavelength, temperature):

    scaler = 2*planck_constant*(speed_of_light**2)/(wavelength**5)

    exponential = 1/(math.e**((planck_constant*speed_of_light)/(wavelength * boltzmann_constant * temperature)) - 1)

    return  scaler*exponential
