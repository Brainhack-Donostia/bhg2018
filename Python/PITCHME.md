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
## Let's read our file!

Check the **alternative and safer** syntax!

```{Python}
FILE = "titanic.tsv"

with open(FILE, 'r') as src:
    header = src.readline() # read first line
    data = src.readlines() # read rest
```
---
## Lists
The **variable** *data* is storing a **list** of strings. Each strings is a line of the original file.

Examples of lists

```{Python}
myList = ['a', 'b', 'c']
myList2 = [1, "Lola", 3.45, True]

```

Lists:

*  are ORDERED

```{Python}
myList[0] # access the first element
myList2[1:4] # access ["Lola", 3.45, True]
```
*  are MUTABLE

```{Python}
myList[0] = 'w' # change the first element
```

*  can contain different types of objects


