def percentX(x, acft):
    '''PERCENT Converts a position (ft) along the aircraft longitudinal axis wrt to the mac.
  
    Sign convention:      <----------|-----*-----------|--------------o
                                  xlemac   x        xlemac-mac

           sign( val )   <0          |    >0           |   >0

    Input:
        x : distance [ft ]
        acft : the aicraft data structure
    Output: 
        val = (xlemac-x)/100 [1]. If negative x is towards the fron of the aircraft.'''

    val = (acft.lemac - x)/acft.mac
    
    return val

