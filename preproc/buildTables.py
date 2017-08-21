import glob

# FSX Mach numbers
mach_number = ('0','0.2','0.4','0.6','0.8',\
                '1.0','1.2','1.4','1.6','1.8',\
                '2.0','2.2','2.4','2.6','2.8',\
                '3.0','3.2')

def build_matlab_air_tables(f_name):
    """
    Build air table in matlab format. The code converts all file with filename *TAB*.txt.

    Input:
        f_name : input table found in data directory.
    """
    with open(f_name,'r') as fin:
        print('Opening file '+f_name+'\n')
        points = fin.readline().split()[1]
        print('Found '+points+' points\n')

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
    print('Building '+fout_name+'\n')

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
    files = glob.glob('*TAB*.txt')
    print('Found: '+str(files)+'\n')

    for f_name in files:
        build_matlab_air_tables(f_name)
                    
                
