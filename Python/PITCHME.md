---
# Introductory Python Course
## Part 1
---
## In this first part, we will
* Review basic Python (2.7)
 * Reading and writing files; Basic types: integers, floats, booleans; Strings; Lists and dictionaries; **For** loops; **If-else** statementes; Functions

* Learn the pythonic way to do certain things
* Ask simple questions from a data set using this basic knowledge

---
### The data

captura de pantalla

---
### Reading files

[Docs](https://docs.python.org/2/tutorial/inputoutput.html#reading-and-writing-files)

### Reading
```{Python}
FILE = "titanic.tsv"
src = open(FILE, "r") # other modes: "w", "a"
header = src.readline() #read first line
data = src.readlines() # read rest
src.close()  # remeber to close your files!
```

### Writing
```{Python}
OUTPUT = "results.txt"
tgt = open(OUTPUT, "w")
tgt.write("This will be written in results.txt\n")
tgt.close() # don"t forget this!

```

---
### Let"s read our file!

Check the **alternative and safer** syntax!

```{Python}
FILE = "titanic.tsv"

with open(FILE, "r") as src:
    header = src.readline() # read first line
    data = src.readlines() # read rest
```
---
### Lists
The **variable** *data* is storing a **list** of strings. Each string is a line of the original file.

Examples of lists

```{Python}
myList = ["a", "b", "c"]
myList2 = [3,5,7,9,12,34,5]


```

---
### Lists...

*  are ORDERED

```{Python}
myList[0] # access the first element
myList2[1:4] # access [5,7,9]
```
*  are MUTABLE

```{Python}
myList[0] = "w" # change the first element
```

*  can contain different types of objects

```{Python}
myList3 = [1, "Lola", 3.45, True]
```

---
### Up to now, we have:

* *header*: a **string** contanining the names of the columns
* *data*: a list of **strings**

But we would like to have a **dictionary** *dataDict*, where the *keys* are the columm names, and the values are *lists* of values.

---
### Why a dictionary?
Dictionaries are collections of *key:value* pairs

```{Python}
myDict = {"english":"en", "spanish:"sp", "french":"fr"}

dataDict = {"name":[passenger1, passenger2,...],
            "survived":[1,0,0,1,..], "age":[24,35,7,58,...]}
```

---
### Dictionaries:

* are UNORDERED

```{Python}
myDict[1]  # WRONG! 
myDict["spanish"] # access "sp"
```

* are MUTABLE

```{Python}
myDict["spanish"] = "es"
```

* can contain different types of objects

```{Python}
myDict = {3:"three", "ninety eight":98, 5.6:"five point six"}
```

---
### Create an empty dictionary (1)
Let's get the column names from the string header
 
 * [strip()](https://docs.python.org/2/library/string.html#string.strip) is a string method that removes empty space from the ends of a string
 * [split()](https://docs.python.org/2/library/string.html#string.split) is a string method that turns a string into a list of elements

```{Python}
# turn string into list of column names
header = header.strip().split("\t") 
```

Now, how do we turn this into a dictionary?

---

### Loops
```{Python}
for i in [0,7]:
    print(idx)

for i in range(7):
    print(idx)
    
abc = ["a", "b", "c"]
for letter in abc:
    print(letter)

for i, letter in enumerate(abc):
    print(str(i) + " " + letter)
    
```

---
### Create an empty dictionary (2)
Create the dictionary the classic way

```{Python}
# using regular loops
dataDict = {}
for colName in header:
    dataDict[colName] = []
```

Or using the pythonic way, in one line!

```{Python}
# dictionary comprehensions exist too!
dataDict = {colName:[] for colName in header} 
```

[More on list comprehensions](https://docs.python.org/3/tutorial/datastructures.html#list-comprehensions)

---
### Fill the dictionary (1)
For each line in the *data* list, we want to

1. split it on \t
2. do something to empty cells
3. change numbers to appropriate data types
4. store each value in the appropriate dataDict key list.

---
### Fill the dictionary (2)

```{Python}
row = row.strip("\r\n")
row = row.split("\t") # now row is a list!
# missing data to None, string digits to floats
for i in range(len(row)):
    elem = row[i]
    if elem == "":
        row[i] = None
    elif elem.isdigit(): # another string method
        row[i] = float(elem)
```

---
### If - else

```{Python}
if expression:
    # do something
elif expression2:
    # do something else
else:
    # do something else
```
Only the first if statement is compulsory in an if - else expression.

What form can an expression take? It has be evaluated into a boolean value: True or False.

```{Python}
x == 3
x != 3
x < 3
x > 3

```
---
### Fill the dictionary (3)
Package the previous code into a function

```{Python}
def splitRow(row):
    row = row.strip("\r\n")
    row = row.split("\t") # now row is a list!
    # missing data to None, string digits to floats
    for i in range(len(row)):
        elem = row[i]
        if elem == "":
            row[i] = None
        elif elem.isdigit(): 
            row[i] = float(elem)
    return row
```

---
### Fill the dictionary (4)

```{Python}
for row in data:
    row = splitRow(row)

    # since rows and header have the same length...
    for i in range(len(header)):
        dataDict[header[i]].append(row[i])
        
```

* [append()](https://docs.python.org/2/tutorial/datastructures.html#more-on-lists) is a list method that adds an element to the end of a list

---
# Now let's ask some questions

---


