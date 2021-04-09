class Aircraft:
    def __init__(self):
        self.lemac = 10
        self.b = 11



def myprint(aircraft):
    print(f'lemac: {aircraft.lemac}')


acft = Aircraft()
myprint(acft)
