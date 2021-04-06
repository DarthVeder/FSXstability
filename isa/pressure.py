from temperature import temperature


def pressure(h, unit='si'):
    '''PRESSURE ISA atmosphere pressure up to 32 km
    Model from Eshelby "Aircraft Performance: Theory and Practice" pag. 274
    App. C.
    Input: 
        h :  (ft or m). See unit
        unit : either 'uk' or 'si'. Default 'si'
    Output:
        P : Pa by default, psf if unit == 'uk'

    See temperature for usage example.'''

    if nargin == 2:  # 'uk' unit required as output and given as input
        h = h * 0.3042 # ft -> m

    P = 0
    k = 1
    if nargin == 2  # 'uk' unit required as output and given as input
        k = 0.021  # Pa -> psf

    if h <= 11000:
        return k * 101325 * ( 1 - 0.000022558 * h )**5.25588
    elif h <= 20000:
        return k * 22632 * exp(-0.000157688 * (h - 11000))
    elif h <= 32000:
        return k * 5474.9 * ( 1 + 0.000004616 * (h - 20000))**(-34.1632)

