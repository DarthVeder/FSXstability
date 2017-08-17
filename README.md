### Description
Find for a given static flight condition (climb, cruise, descent) the required trim angle versus weight and center of gravity position. The code works for FSX aircraft. 

Users are required to extract data from aircraft.cfg and .air file (using AAM). See the [wiki](https://github.com/DarthVeder/FSXstability/wiki/FSX-Stability) pages for more details.
 
### Installation
Copy the clone FSXstability to MATLAB toolbox directory. Rember to add the new toolbox to the path.

### Usage
From inside MATLAB run one of the following script:
+ testISA.m : generates ISA 1962 profiles for pressure, density, temperature and speed of sound up to 31 km. UK unit.
+ snapshot_stability.m : find elevator trim angle for a given weight and flight condition.
+ CG_trim.m : find the elevator trim angle envelope for different weight and center of gravity positions.

### License
Licensed under the GPL v3.0 license.
