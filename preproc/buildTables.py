from log import *
from fsxdata import *

def build_special_air_table(tab_name):
    """
    Build special air table missing in the air file, but required in Y. Guilluame formulation.
    By default all values of the special table are set to '1'.

    Input:
        tab_name : numeric name of the table. 3 or 4 digits (ex 1525 or 536). No leading zeros on the name.
    """
    fout_name = 'R' + tab_name + '.m' # R536.m with method R536(angle_deg)
    with open(fout_name,'w') as fout:
        fout.write('function val = R'+tab_name+'(alpha_deg)\n')
        fout.write('% in: angle of attach, deg\n% out: Table '+tab_name+' value\n')
        fout.write('TBL'+tab_name+'=[\n')
        fout.write('-360 1.0;\n')
        fout.write('360 1.0;];\n')
        fout.write('val = interp1(TBL'+tab_name+'(:,1),TBL'+tab_name+'(:,2),alpha_deg);\n\nend\n')

def build_matlab_air_tables(f_name):
    """
    Build air table in matlab format. The code converts all file with filename *TAB*.txt.

    Input:
        f_name : input table file name found in data directory.
    """
    with open(f_name,'r') as fin:
        logger1.debug('Opening file '+f_name)
        points = fin.readline().split()[1]
        logger1.debug('Found '+points+' points')

        # Reading table
        table = []
        for n in range(int(points)):
            table.append(fin.readline().split()) # each row is stored as [val1, val2] if ncols = 2,
                                                 # otherwise as [val1] if ncols = 1
        # Finding the number of columns    
        ncols = len(table[0])

        tab_name = f_name.split('TAB')[1].split('.')[0]
        if tab_name[0] == '0':
            tab_name = tab_name[1:]

    fout_name = 'R'+tab_name+'.m'
    logger1.debug('Building '+fout_name)

    with open(fout_name,'w') as fout:
        fout.write('function val = R'+tab_name+'(M)\n')
        fout.write('% in: mach number M\n% out: Table '+tab_name+' value\n')
        fout.write('TBL'+tab_name+'=[\n')
        if ncols == 2:
            [fout.write(' '.join(t)+';\n') for t in table]
        else:
            [fout.write(mach_number[i]+' '+table[i][0]+';\n') for i in range(len(table))] 
                       
        fout.write('];\n')
        fout.write('val = interp1(TBL'+tab_name+'(:,1),TBL'+tab_name+'(:,2),M);\n\nend\n')

if __name__ == '__main__':
    import glob
    files = glob.glob('*TAB*.txt')
    print('Found: '+str(files)+'\n')

    for f_name in files:
        build_matlab_air_tables(f_name)
                    
                
