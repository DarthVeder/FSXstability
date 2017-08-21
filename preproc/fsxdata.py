"""
Useful FSX constants
"""
# FSX data
fuel_tank = ('Left', 'Right', 'Center', 'External', 'Tip')
# FSX Engine types
engine_type = ('piston','jet','none','helo-tubine','rocket','turboprop') # same order as MSDN 
# Data to exctract from air file
data_to_extract = ('CD0','Cd_df','CDg','CL_de','CL_dh','CL_df',\
                   'Cmo','Cm_de','Cm_h','Cm_dT','Cm_dt','Cm_df','Cmg','Cn_dr')
# FSX Mach numbers
mach_number = ('0','0.2','0.4','0.6','0.8',\
                '1.0','1.2','1.4','1.6','1.8',\
                '2.0','2.2','2.4','2.6','2.8',\
                '3.0','3.2')
