# =============
# READING FILES
# =============

FILE = "titanic.tsv"
# import data as a list of strings,
# one per row in the file
with open(FILE, 'r') as src:
    header = src.readline() #read first line
    data = src.readlines() # read rest

# see what imported data looks like
header
data[5]
data[3:5]

# data is an ORDERED list of rows


# =============================================
# CREATE A DICTIONARY WITH KEYS AS COLUMN NAMES
# =============================================
# Dictionary. Keys - Values
# What could be one problem with this approach?

header = header.strip().split("\t") # turn string into list of column names

# create a dictionary with empty lists as values
# dictionary comprehensions exist too!
dataDict = {colName:[] for colName in header} 

# alternative non pythonic way
#-----------------------------
#dataDict = {}
#for colName in header:
#    dataDict[colName] = []


# split rows
def splitRow(row):
    row = row.strip("\r\n")
    row = row.split('\t') 
    # missing data to None, string digits to floats
    for i in range(len(row)): # LISTS ARE MUTABLE. CAREFUL!!
        elem = row[i]
        if elem == "":
            row[i] = None
        elif elem.isdigit(): # another string method!
            row[i] = float(elem) # turn all numbers into floats
            # coercion from float to int is automatic; not so otherwise
    return row

# now let's populate the dictionary
for row in data:
    row = splitRow(row)
    
    # since rows and header have the same length and positions are matched...    
    for i in range(len(header)):
        dataDict[header[i]].append(row[i])  


# ============================
# ASK QUESTIONS ABOUT THE DATA
# ============================

# QUESTIONS USING ONE COLUMN
# Number of passengers by class
classes = list(set(dataDict['Pclass']))
passengersByClass = {int(cl):0 for cl in classes}

for cl in classes:
    passengersByClass[cl] = dataDict['Pclass'].count(cl)

# Same as before, but now a function
def totalByLevel(category):   
    levels = set(dataDict[category])   
    byCategory = {level:[] for level in levels}   
    for level in levels:       
        byCategory[level] = dataDict[category].count(level)    
    return byCategory

totalByLevel("Pclass")
totalByLevel("Sex")

# QUESTIONS USING TWO COLUMNS
def pctSurvival(category):
    # total number of passengers per group in that category
    total = totalByLevel(category)
    
    levels = total.keys()
    survivors = {level:0 for level in levels} # init counter
    
    for i, p in enumerate(dataDict["Survived"]):
        if p == 1:
            survivors[dataDict[category][i]] += 1
        
    print(category)
    print("==========")
    for level in levels:
        print("-- " + str(level))
        print("{}% survived".format((float(survivors[level]) / 
        total[level] * 100)))


pctSurvival("Pclass")
pctSurvival("Sex")


   














