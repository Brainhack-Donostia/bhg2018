# =============
# READING FILES
# =============

def readTSV(path):
    # import data as a list of strings,
    # one per row in the file
    with open(path, 'r') as src:
        header = src.readline() #read first line
        data = src.readlines() # read rest
    return header, data


# =============================================
# CREATE A DICTIONARY WITH KEYS AS COLUMN NAMES
# =============================================
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


def createDict(header, data):
    header = header.strip().split("\t") # turn string into list of column names
    
    # create a dictionary with empty lists as values
    dataDict = {colName:[] for colName in header} 
    
    # now let's populate the dictionary
    for row in data:
        row = splitRow(row)
        
        # since rows and header have the same length and positions are matched...    
        for i in range(len(header)):
            dataDict[header[i]].append(row[i])  
    return dataDict

# ============================
# ASK QUESTIONS ABOUT THE DATA
# ============================


# Same as before, but now a function
def totalByLevel(category, dataDict):   
    levels = set(dataDict[category])   
    byCategory = {level:[] for level in levels}   
    for level in levels:       
        byCategory[level] = dataDict[category].count(level)    
    return byCategory



# QUESTIONS USING TWO COLUMNS
def pctSurvival(category, dataDict):
    # total number of passengers per group in that category
    total = totalByLevel(category, dataDict)
    
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

# =================
# USE THE FUNCTIONS
# =================

header, data = readTSV("titanic.tsv")
dataDict = createDict(header, data)
pctSurvival("Pclass", dataDict)
pctSurvival("Sex", dataDict)














