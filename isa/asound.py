from math import sqrt
from temperature import temperature


def asound(h, unit='si'):
    '''ASOUND ISA atmosphere sound speed up to 32 km
    Model from Eshelby "Aircraft Performance: Theory and Practice" pag. 274
    App. C.
    Input: 
        h :  ft or m. See unit
        unit : either 'uk' or 'si'. By default 'si'.
    Output: 
        a : sound speed m/s (default) or kt'''

    if nargin == 2:  # 'uk' unit required as output and given as input
        h = h * 0.3042; # ft -> m

    k = 1
    if nargin == 2:  # 'uk' unit required as output and given as input
        k = 1.94384 # m/s -> kt
    R = 287.05287 # J/(kg*K)
    gamma = 1.4
    return k * sqrt( gamma*R*temperature(h) )

