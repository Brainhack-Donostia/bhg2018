# =============
# READING FILES
# =============

# read csv line by line
FILE = "titanic.tsv"
# import data as a list of strings,
# one per row in the file
with open(FILE, 'r') as src:
    header = src.readline() #read first line
    data = src.readlines() # read rest

# see what imported data looks like
print(header)
print(data[5])
# data is an ORDERED list of rows


# =============================================
# CREATE A DICTIONARY WITH KEYS AS COLUMN NAMES
# =============================================
# Dictionary. Keys - Values
# What could be one problem with this approach?

# String methods
# strip()  https://docs.python.org/2/library/string.html#string.strip
# split()  https://docs.python.org/2/library/string.html#string.split

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
        if row[i] == "":
            row[i] = None
        elif row[i].isdigit(): # another string method!
            row[i] = float(elem) # turn all numbers into floats
            # coercion from float to int is automatic; not so otherwise

    return row

# now let's populate the dictionary
# FOR LOOPS
# IF - ELSE statements
for row in data:
    row = splitRow(row)

    # since rows and header have the same length...
    for i in range(len(header)):
        dataDict[header[i]].append(row[i]) # APPEND. List method


# How do access the data now?
# we can access it by column name and by row number

# Percentage of adults and children who survived

# Percentage of passengers in the boat
classes = list(set(dataDict['Pclass']))
passengers = []
for c in classes:
    passengers.append(dataDict['Pclass'].count(c))

total = float(sum(passengers))

#round
for i, c in enumerate(classes):
    print("Passengers in class {}: {}.\n\t {} % of total passengers").\
    format(c, passengers[i], passengers[i]/total * 100)

# Percentage of passengers that survived
sum(dataDict["Survived"])/len(dataDict["Survived"])

# But what we really want to know is the  percentage of passengers
# in each class that survived

survivedSex = {"male":0, "female":0}
survivedClass = {1:0, 2:0, 3:0}
for i, p in enumerate(dataDict["Survived"]):
    if p == 1:
        survivedSex[dataDict["Sex"][i]] += 1
        survivedClass[dataDict["Pclass"][i]] += 1

# SCOPE (DATADICT)
def totalByLevel(category):
    levels = list(set(dataDict[category]))
    totalDict = {level:[] for level in levels}
    for level in levels:
        totalDict[level] = dataDict[category].count(level)
    return totalDict

def pctSurvival(category):
    # total number of passengers per group in that category
    total = totalByLevel(category)
    
    # initialize counter in 0
    levels = list(set(dataDict[category]))
    survivors = {level:0 for level in levels}
    
    for i, p in enumerate(dataDict["Survived"]):
        if p == 1:
            survivors[dataDict[category][i]] += 1
        
    print(category)
    print("==========")
    for level in levels:
        print(level)
        print("{}% survived".format(float(survivors[level]) / total[level] * 100))






   














