"""
Reads FSX aircraft.cfg and an exported air file with AAM.

Use config.ini for setting the directories for input aircraft.cfg and
aircraft air file in [paths] block.

Author : Marco Messina
Copyright : 2017-
Version : 1.1
"""

from sys import exit
import configparser
import logging

# FSX data
fuel_tank = ('Left', 'Right', 'Center', 'External', 'Tip')

# set up logging to file - see previous section for more details
logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s %(name)-12s %(funcName)-12s %(levelname)-8s %(message)s',
                    datefmt='%d/%m %H:%M:%S',
                    filename='.\\myapp.log',
                    filemode='w')
# define a Handler which writes INFO messages or higher to the sys.stderr
console = logging.StreamHandler()
console.setLevel(logging.INFO)
# set a format which is simpler for console use
formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')
# tell the handler to use this format
console.setFormatter(formatter)
# add the handler to the root logger
logging.getLogger('').addHandler(console)

# Now, we can log to the root logger, or any other logger. First the root...
logging.info('Starting the program')

# Now, define a couple of other loggers which might represent areas in your
# application:

logger1 = logging.getLogger('myapp.readers')

# Constants
comments = ('//',';','#')
# FSX Engine types
engine_type = ('piston','jet','none','helo-tubine','rocket','turboprop')
# Data to exctract from air file
data_to_extract = ('CD0','Cd_df','CDg','CL_de','CL_dh','CL_df',\
                   'Cmo','Cm_de','Cm_h','Cm_dT','Cm_dt','Cm_df','Cmg','Cn_dr')
end = -1

def read_config_file():
    """ Read config file"""

    config_file_name = 'config.ini'
    config = configparser.ConfigParser(comment_prefixes=comments, inline_comment_prefixes=comments)
    config.read('config.ini')

    logger1.debug('Reading config.ini')

    aircraft_cfg_file = config['paths']['aircraft_cfg']
    data_aam_file = config['paths']['data_aam_file']

    logger1.debug('Files with data: '+aircraft_cfg_file+' AND '+data_aam_file)

    return (aircraft_cfg_file, data_aam_file)
    

def read_aircraft_cfg(aircraft_cfg_file):
    """ Reads FSX aircraft.cfg file. All fields are rendered lower case.        

        Input:
            aircraft_cfg_file : aircraft.cfg file
    """    
    config = configparser.ConfigParser(comment_prefixes=comments, inline_comment_prefixes=comments)
    config.optionxform = str
    logger1.info('Reading :'+ aircraft_cfg_file)
    config.read(aircraft_cfg_file)
    

    logger1.debug( config.sections() )

    if 'flaps.1' in config:
        logger1.debug( 'Found flaps.1' )
        complex_flap = True
    acft_geo = config['airplane_geometry']
    for key in acft_geo:
        value = float(acft_geo[key])
        logger1.debug( str(key) + ' ' + str(value) )
    
    return config


def _read_table(fin):
    """ Read a table inside aircraft air file. Internal usage.

        Input:
            fin : the file with the data

        Output:
            deriv : dictionary with the extracted linear stability derivatives
                    data from data_to_extract.
                    
                    deriv[data_to_extract[i]] = val_i
    """

    is_in_table = True
    deriv = {}
    ldata = list(data_to_extract)

    while is_in_table:
        word = fin.readline().split()
        for datai in ldata:             
            if datai == word[0]:
                deriv[datai] = word[end]
                ldata.remove(datai)
        # Check to see if the table is ended
        table = word[0]
        if table.isdigit() and len(table) == 5:
            is_in_table = False

    return deriv

def read_aircraft_air(data_aam_file):
    """ Reads FSX aircraft air file. Extracting only table 01101.

        Input:
            data_aam_file : file with air data
    """
    logger1.info('Reading :'+ data_aam_file)

    stab_deriv = {}
    inside_table = False

    with open(data_aam_file,'r') as fin:
        for line in fin:
            word = line.split()
            table = word[0]
            if table.isdigit() and len(table) == 5 and table == '01101': # select table 01101
                logger1.info('Found table '+table)
                stab_deriv = _read_table(fin)

    #logger1.debug(stab_deriv)
    for key in stab_deriv:
        value = float(stab_deriv[key])
        logger1.debug( key + ' ' + str(value) )

    return stab_deriv

def extract_cfg_section(section_name):
    """ 
    This function extract section_name taking care of lowercase or upper case

    Input:
        section_name : string with section name to recover, either all lowercase or all uppercase.

    Output:
        section : the extracted section
    """    
    try:
        lst = acft[section_name.lower()]
        logger1.info('Extracting cfg section "'+section_name+'"')
        return lst
    except KeyError:
        try:
            lst = acft[section_name.upper()]
            logger1.info('Extracting cfg section "'+section_name+'"')
            return lst
        except KeyError:            
            error_msg = 'No all upper or all lower section with name "' + section_name +'"'
            logger1.error(error_msg)
            exit(1)

def piston_engine():
    logger1.error(piston_engine.__name__ + ' not yet implemented')
    exit(1)
    

def jet_engine(fout, acft):
    """ Read jet engine data from cfg file

        Input:
            fout : output file name
            lst : acft data as ConfigParser()
    """
    lst = acft['TurbineEngineData']
    logger1.info('Extracting cfg section "TurbineEngineData"')
    [fout.write('acft.'+str(w)+'='+lst[w]+';\n') for w in lst]

    lst = extract_cfg_section('jet_engine')
    [fout.write('acft.'+str(w)+'='+lst[w]+';\n') for w in lst]
        
def turboprop_engine():
    logger1.error(turboprop_engine.__name__ + ' not yet implemented')
    exit(1)

#############################################
###                 MAIN                  ###
#############################################

if __name__ == '__main__':
    # Reading config file
    aircraft_cfg_file, data_aam_file = read_config_file()

    # Reading aircraft.cfg
    # acft is ConfigParser()
    acft = read_aircraft_cfg(aircraft_cfg_file)

    # Reading air file and adding data acft file
    acft_stability_deriv = read_aircraft_air(data_aam_file)
    acft['stability_derivatives'] = acft_stability_deriv # adding stability derivatives data
    
    # Writing output for MATLAB FSXstability tool
    base_file_name = acft['fltsim.0']['sim'].replace('-','_')
    file_cfg_out = base_file_name+'data.m'
    logger1.info('Writing FSXstability data file: '+file_cfg_out)
    #####################################
    ##      airplane_geometry          ##
    #####################################
    with open(file_cfg_out,'w') as fout:
        fout.write('% airplane_geometry\n')
        lst = extract_cfg_section('airplane_geometry')
        [fout.write('acft.'+str(w)+'='+lst[w]+';\n') for w in lst]
        fout.write('acft.alpha0_deg =fsolve(@(x) R404(x),0.0)/pi*180;\n')

    #####################################
    ##      flight_tuning              ##
    #####################################
    with open(file_cfg_out,'a') as fout:
        fout.write('% flight_tuning\n')
        lst = extract_cfg_section('flight_tuning')
        [fout.write('acft.'+str(w)+'='+lst[w]+';\n') for w in lst]
    #####################################
    ##      stability_derivatives      ##
    #####################################
    with open(file_cfg_out,'a') as fout:
        fout.write('% stability_derivatives\n')
        lst = extract_cfg_section('stability_derivatives')
        [fout.write('acft.'+str(w)+'='+lst[w]+';\n') for w in lst]

    #####################################
    ##           flaps.0               ##
    #####################################
    with open(file_cfg_out,'a') as fout:        
        fout.write('% flaps.0\n')
        lst = extract_cfg_section('flaps.0')
        [fout.write('acft.'+str(w.replace('-','_'))+'='+lst[w]+';\n') for w in lst if w.find('flaps-position.')==-1]

    #####################################
    ##      contact_points             ##
    #####################################    
    with open(file_cfg_out,'a') as fout:
        fout.write('% contact_points\n')
        lst = extract_cfg_section('contact_points')
        for w in lst:
            if w.find('point.') != -1:
                ptype = lst[w][0]                 
                if ptype == '1': # gear
                    nw = w.replace('.','_')
                    fout.write('acft.'+str(nw)+'=['+",".join(lst[w].split(',')[1:4])+'];\n')

    #####################################
    ##      weight_and_balance         ##
    #####################################
    with open(file_cfg_out,'a') as fout:
        fout.write('% weight_and_balance\n')
        lst = extract_cfg_section('weight_and_Balance')
        for w in lst:
            if w.find('reference_datum_position') != -1 or w.find('empty_weight_CG') != -1:               
                fout.write('acft.'+str(w)+'=['+ lst[w]+'];\n')                
            elif w.find('MOI') != -1:
                fout.write('acft.'+str(w)+'='+ lst[w]+';\n')
            elif w.find('weight') != -1:
                fout.write('acft.'+str(w)+'='+ lst[w]+';\n')
                

    #####################################
    ##      GeneralEngineData          ##
    #####################################
    with open(file_cfg_out,'a') as fout:
        fout.write('% GeneralEngineData\n')
        lst = acft['GeneralEngineData']
        logger1.info('Extracting cfg section "GeneralEngineData"')
        neng = 0
        engine_name = []
        for e in lst:
            if e.find('Engine.') != -1:
                engine_name.append('Engine.'+str(neng))
                neng = neng + 1
        logger1.info('Aircraft with '+str(neng)+' engines')
        fout.write('acft.neng='+str(neng)+';\n')
        [fout.write('acft.'+str(w.replace('.','_'))+'=['+lst[w]+'];\n') for w in engine_name]
        etype = lst['engine_type']
        if etype == '0':
            piston_engine()
        elif etype == '1':
            jet_engine(fout, acft)
        elif etype == '5':
            turboprop_engine()
        else:
            logger1.error('Engine type not implemented')

    #########################################################
    ###             Adding acft load stations             ###
    #########################################################
    file_cfg_out = base_file_name+'station_loads.m'
    logger1.info('Writing FSXstability station_loads file: '+file_cfg_out)

    #######################################
    ## weight_and_balance->load_stations ##
    #######################################    
    with open(file_cfg_out,'w') as fout:
        fout.write('% weight_and_balance\n')
        lst = extract_cfg_section('weight_and_Balance')
        first_station_load = True
        # Finding number of station loads:
        nstations = 0
        for w in lst:
            if w.find('station_load.') != -1:
                nstations = nstations + 1
        logger1.info('Found '+str(nstations)+' load stations')

        _nstations = 1
        for w in lst:
            if w.find('station_load.') != -1:
                if first_station_load == True:
                    fout.write('acft.'+str(w.split('.')[0])+'=['+ lst[w]+';\n')
                    first_station_load = False                        
                else:
                    fout.write(lst[w]+';\n')                    
                    
        fout.write('];\n')

    #####################################
    ##             fuel                ##
    #####################################
    with open(file_cfg_out,'a') as fout:        
        fout.write('% fuel\n')
        lst = extract_cfg_section('fuel')
        ntanks = 0
        first_tank = True
        fout.write('acft.fuel =[\n')
        for w in lst:
            for t in fuel_tank:
                if w.find(t) != -1:
                    ntanks = ntanks + 1
                    fout.write(lst[w][1:-1].replace(',','')+';\n')
        fout.write('];\n')

        logger1.info('Found '+str(ntanks)+' fuel tanks')        
