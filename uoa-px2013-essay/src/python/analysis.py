from blackbody import blackbody_radiation
from sail_simulation import Sail_Material, Sail_Model, simulate_sail_at_wavelength
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

def format_refraction_data(df: pd.DataFrame):
    df.columns = ['wavelength', 'n', 'k']
    df = df.fillna(method='ffill') # replace NaN with zero, as this is most consistent with the datasets
    df['wavelength'] = df['wavelength'] * 1e-6
    return df

aluminum_refraction_data = pd.read_csv(f'{__file__}\\..\\data\\RefractiveIndexAl.csv')
kapton_refraction_data = pd.read_csv(f'{__file__}\\..\\data\\RefractiveIndexKapton.csv')
aluminum_refraction_data = format_refraction_data(aluminum_refraction_data)
kapton_refraction_data = format_refraction_data(kapton_refraction_data)

front_aluminum_coating = Sail_Material()
front_aluminum_coating.name = 'Front Aluminum Layer'
front_aluminum_coating.thickness = 10e-9
front_aluminum_coating.complex_refraction = aluminum_refraction_data

structural_layer_kapton = Sail_Material()
structural_layer_kapton.name = 'Structural Kapton Layer'
structural_layer_kapton.thickness = 800e-9
structural_layer_kapton.complex_refraction = kapton_refraction_data

back_aluminum_coating = Sail_Material()
back_aluminum_coating.name = 'Back Aluminum Layer'
back_aluminum_coating.thickness = 30e-9
back_aluminum_coating.complex_refraction = aluminum_refraction_data

nasa_sail = Sail_Model()
nasa_sail.sail_layers = [front_aluminum_coating, structural_layer_kapton, back_aluminum_coating]

wavelength_to_consider = np.linspace(1e-9, 5000e-9, 200)

result_by_wavelength = [simulate_sail_at_wavelength(nasa_sail, 0.0, wavelength) for wavelength in wavelength_to_consider]
reflected = [w[0] for w in result_by_wavelength]

# plt.plot(wavelength_to_consider, reflected)

blackbody = [blackbody_radiation(w, 5500) for w in wavelength_to_consider]

plt.plot(wavelength_to_consider, blackbody)

print('x')