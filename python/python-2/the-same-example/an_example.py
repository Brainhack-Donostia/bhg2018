# Titanic Data Analysis

# importing some useful libraries
from time import time 
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# to get pretty plots
sns.set_style('whitegrid')

titanic_path = 'train.csv'

# read csv into a pandas dataframe
titanic_df = pd.read_csv(titanic_path)

# print the first three rows
print titanic_df.head(3), '\n'

# age distribution of all
ax = titanic_df['Age'].hist()
ax.set_xlabel('Age (years)')
ax.set_ylabel('Frequency')
plt.savefig('age_all.png')

# age distribution of those who survived
gr_sur = titanic_df.groupby('Survived')
sur = gr_sur.get_group(1)

# simple discriptive analysis
# what percentage of people survived the disaster and 
# what was their mean age?
print 'people that survived: {}%'.format((sur.shape[0] / float(titanic_df.shape[0])) * 100)
print 'mean age of these people: {}yrs'.format(sur['Age'].mean())

ax = sur['Age'].hist()
ax.set_xlabel('Age (years)')
ax.set_ylabel('Frequency')
plt.savefig('age_survived.png')

# pclass distribution of all
plt.figure()
ax = titanic_df['Pclass'].hist()
ax.set_xlabel('Pclass')
ax.set_ylabel('Frequency')
plt.savefig('pclass_all.png')

# pclass distribution of those who survived
ax = sur['Pclass'].hist()
ax.set_xlabel('Pclass')
ax.set_ylabel('Frequency')
plt.savefig('pclass_survived.png')

