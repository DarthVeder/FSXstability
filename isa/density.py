from isa.pressure import pressure
from isa.temperature import temperature


def density(h, unit=None):
    '''DENSITY ISA atmosphere density up to 32 km
    Model from Eshelby "Aircraft Performance: Theory and Practice" pag. 274
    App. C.
    Input: 
        h : ft or m. See unit.
        unit : either 'uk' or 'si'. By default 'si'.
    Output: 
        rho : kg/m^3 (default) or slugs/ft^3

    See pressure for an example'''

    k = 1
    if unit:  # 'uk' unit required as output and given as input
        h = h * 0.3042  # ft -> m
        k = 0.00194032  # kg/m^3 -> slug/ft^3

    R = 287.05287  # Nm/kgK

    return pressure(h) / (R * temperature(h))

