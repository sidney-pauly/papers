
import math
from typing import Tuple, Union
import numpy as np
import pandas as pd

class Sail_Material:

    def __init__(self, name = None, thickness = None, complex_refraction = None):
        self.thickness = thickness 
        self.name = name
        self.complex_refraction = complex_refraction

    thickness: float = 0

    name: str = ''

    complex_refraction = None

    def get_refraction_value(self, wavelength):
        return np.interp([wavelength], self.complex_refraction['wavelength'], self.complex_refraction['n'])[0]

    def get_absorption_value(self, wavelength):
        return np.interp([wavelength], self.complex_refraction['wavelength'], self.complex_refraction['k'])[0]

VACUUM = Sail_Material('Vacuum', 0, pd.DataFrame({'wavelength': [0, 9999], 'n': [1, 1], 'k': [0, 0]}))

class Sail_Model:

    def __init__(self, layers):
        self.sail_layers = layers

    sail_layers: list[Sail_Material] = list()


class Layer_Light_Simulator:

    __sail: Sail_Model

    __current_material_index: int = -1

    __wavelength: float = 0

    __current_intensity: float = 1

    __current_angle: float = 0

    current_material: Sail_Material

    next_material: Sail_Material

    def __init__(self, sail: Sail_Model,  wavelength: float, current_material_index: int = -1, current_intensity = 1, current_angle = 0 ):
        self.__sail = sail
        self.__current_material_index = current_material_index
        self.__current_intensity = current_intensity
        self.__current_angle = current_angle
        self.__wavelength = wavelength
        self.current_material = self.get_material()
        self.next_material = self.get_next_material()

    def calculate_light_behavior(self) -> Tuple[float, float, float]:
        """
        Calculates how much of the initial intensity gets reflected (or passed through to the other side)
        """

        remaining_intensity = self.calculate_remaining_intensity()

        reflection_rate = self.calculate_reflected()
        transmitted_rate = 1 - reflection_rate

        absorbed = self.__current_intensity - remaining_intensity
        reflected = remaining_intensity * reflection_rate
        transmitted = remaining_intensity * transmitted_rate

        return (absorbed, reflected, transmitted)

    def get_material_index(self):
        return self.__current_material_index

    def get_angle(self):
        return self.__current_angle

    def _get_material(self, index):
        if index < 0:
            return VACUUM
        if index >= len(self.__sail.sail_layers):
            return VACUUM
        return self.__sail.sail_layers[index]

    def get_material(self):
        return self._get_material(self.__current_material_index)

    def get_next_material(self):
        return self._get_material(self.get_next_material_index())

    def get_direction(self):
        return -1 if abs(self.__current_angle) > (math.pi/2) else 1

    def get_next_material_index(self):
        return self.__current_material_index + self.get_direction()

    def get_transmitted_angle(self):
        """
        Calculates the transmitted angle through snell's law\n
        n_1 sin(a_i) = n_2 sin(a_t)
        a_t = asin( n_1/n_2 * sin(a_i))
        """

        
        n_1 = self.current_material.get_refraction_value(self.__wavelength)
        n_2 = self.next_material.get_refraction_value(self.__wavelength)

        incidence_angle = self.__current_angle

        angle_ratio = (n_1/n_2) * math.sin(incidence_angle)

        # Check if the ratio is still in the range that can be calculated through asin
        if 0 <= angle_ratio <= 1:
            return math.asin(angle_ratio)
        
        # If that is not true, total internal reflection is happening, in that case return the reflected angle
        return self.__current_angle + math.pi

    def calculate_remaining_intensity(self) -> float:

        material = self.current_material

        if material == VACUUM:
            return self.__current_intensity

        distance = abs(material.thickness / math.cos(self.__current_angle))

        wavelength = self.__wavelength

        absorption_constant = material.get_absorption_value(wavelength)

        return self.__current_intensity * math.pow(math.e, (- 4 * math.pi * distance * absorption_constant / wavelength))

    def calculate_reflected(self) -> float:


        n_1 = self.current_material.get_refraction_value(self.__wavelength)
        n_2 = self.next_material.get_refraction_value(self.__wavelength)

        transmission_angle = self.get_transmitted_angle()

        direction = -1 if abs(self.__current_angle) > (math.pi/2) else 1
        transmission_direction = -1 if abs(transmission_angle) > (math.pi/2) else 1

        # Total internal reflection
        if direction != transmission_direction:
            return 1

        a_i = abs(math.cos(self.__current_angle))
        a_t = abs(math.cos(transmission_angle))

        parallel = abs((n_1*a_i - n_2*a_t)/(n_1*a_i + n_2*a_t)) ** 2
        normal = abs((n_1*a_t - n_2*a_i)/(n_1*a_t + n_2*a_i)) ** 2

        return 0.5 * (parallel + normal)


def simulate_sail_at_wavelength(sail: Sail_Model, angle: float, wavelength: float, minimal_intensity = 0.0001):
    """
    Simulates what happens to light of a given wavelength when hitting the sail

    Returns the intensity of the reflected light, how much light got through all of the sail (transmitted),
    how much light was absorbed by each layer and the individual light bounces that happened withing the material
    """

    total_reflected = 0
    total_absorbed = np.zeros(len(sail.sail_layers))
    total_transmitted = 0

    light_bounces = list()

    current_simulators = [Layer_Light_Simulator(sail, wavelength, current_angle=angle)]

    while len(current_simulators) > 0:

        next = list()

        # print(f'simulating {len(current_simulators)}')

        for simulator in current_simulators:

            direction = simulator.get_direction()
            layer_count = len(sail.sail_layers)

            (absorbed, reflected, transmitted) = simulator.calculate_light_behavior()

            light_bounces.append({
                'current_material': simulator.current_material,
                'next_material': simulator.next_material,
                'absorbed': absorbed,
                'reflected': reflected,
                'transmitted': transmitted 
            })

            total_absorbed[simulator.get_material_index()] += absorbed

            next_transmitted_index =  simulator.get_material_index() + direction
            next_reflected_index = simulator.get_material_index()

            # Case when the light is currently traveling downwards (away from light source)
            if direction > 0:

                # If at front reflector add light traveling upwards (the reflected light) to the total reflected
                if simulator.get_material_index() < 1:
                    total_reflected += reflected
                if simulator.get_material_index() >= layer_count:
                    total_transmitted += transmitted
            # Case when the light is currently traveling upwards (towards the light source)
            else:
                # If at front reflector add light traveling upwards (the transmitted light) to the total reflected
                if simulator.get_material_index() < 1:
                    total_reflected += transmitted
                if simulator.get_material_index() >= layer_count:
                    total_transmitted += reflected


            if reflected > minimal_intensity and -1 < next_reflected_index < layer_count:
                # The reflected angle is the inverse of the insedent angle
                angle = simulator.get_angle() + math.pi
                next.append(Layer_Light_Simulator(sail, wavelength, next_reflected_index, reflected, angle))

            if transmitted > minimal_intensity and -1 < next_transmitted_index < layer_count:
                # The reflected angle is the inverse of the insedent angle
                angle = simulator.get_angle()
                next.append(Layer_Light_Simulator(sail, wavelength, next_transmitted_index, transmitted, angle))

        current_simulators = next
    
    return (total_reflected, total_transmitted, total_absorbed, light_bounces)

    





