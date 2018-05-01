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
## The data

captura de pantalla
---
## Reading files

[Docs](https://docs.python.org/2/tutorial/inputoutput.html#reading-and-writing-files)

### Reading
```{Python}
FILE = "titanic.tsv"
src = open(FILE, 'r') # other modes: 'w', 'a'
header = src.readline() #read first line
data = src.readlines() # read rest
src.close()  # remeber to close your files!
```

### Writing
```{Python}
OUTPUT = "results.txt"
tgt = open(OUTPUT, 'w')
tgt.write("This will be written in results.txt\n")
tgt.close() # don't forget this!

```
---
### Let's read our file!

Check the **alternative and safer** syntax!

```{Python}
FILE = "titanic.tsv"

with open(FILE, 'r') as src:
    header = src.readline() # read first line
    data = src.readlines() # read rest
```
---
## Lists
The **variable** *data* is storing a **list** of strings. Each string is a line of the original file.

Examples of lists

```{Python}
myList = ['a', 'b', 'c']
myList2 = [3,5,7,9,12,34,5]


```
---
Lists:

*  are ORDERED

```{Python}
myList[0] # access the first element
myList2[1:4] # accesses [5,7,9]
```
*  are MUTABLE

```{Python}
myList[0] = 'w' # change the first element
```

*  can contain different types of objects

```{Python}
myList3 = [1, "Lola", 3.45, True]
```

---
Up to now, we have:

* *header*: a **string** contanining the names of the columns
* *data*: a list of **strings**

But we would like to have a **dictionary** *dataDict*, where the *keys* are the columm names, and the values are *lists* of values.
---
## Dictionaries
Collections of *key:value* pairs

```{Python}
myDict = ['english':'en', 'spanish:'sp', 'french':'fr']
```

---
Dictionaries:

* are UNORDERED

```{Python}
myDict[1]  # WRONG!
myDict['spanish']
```

* are MUTABLE

```{Python}
myDict['spanish'] = 'es'
```

* can contain different types of objects

```{Python}
myDict = [3:'three', 'ninety eight':98, 5.6:'five point six']
```
 
