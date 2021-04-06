from pressure import pressure
from temperature import temperature


def density(h, unit='si'):
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
    if nargin == 2  # 'uk' unit required as output and given as input
        h = h * 0.3042  # ft -> m
        k = 0.00194032  # kg/m^3 -> slug/ft^3

    R = 287.05287  # Nm/kgK
    rho = pressure(h) / (R * temperature(h))

