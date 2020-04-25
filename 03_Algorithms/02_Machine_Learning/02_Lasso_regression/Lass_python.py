# -*- coding: utf-8 -*-
"""
Created on Thu Jun 14 18:39:06 2018

@author: G
"""

# coding: utf-8

# # SEIS 763: Machine Learning
# 
# Garth Mortensen, mort0052@stthomas.edu
# 
# 2018.06.14
# 
# ### Assignment 2 - Linear Regression on Patient Dataset

# In[68]:

import numpy as np
import pandas as pd
import scipy.stats as stats
import matplotlib.pyplot as plt
import sklearn
from sklearn.preprocessing import LabelEncoder, OneHotEncoder
from sklearn import datasets
from sklearn.model_selection import cross_val_score
from sklearn.model_selection import train_test_split
from sklearn import svm
from sklearn import linear_model
from sklearn.linear_model import Lasso
from sklearn import preprocessing 


# In[69]:

# Load data
# Because there is header column, set header=0
patients = pd.read_csv("C:/tmp/patients.csv", header=0)

# Backup patients, just in case we need it later
patientsBackup = patients

# ####  First split matrix into y (dependent) and x (independent)
# *Remember, Python is 0-offset! The "3rd" entry is at position 2.*
# 
# patientsY = Systolic
# patientsX = Everything else *exluding LastName and Systolic*

# In[61]:


#split dependent variable and independent variables

patientsY = patients["Systolic"]

patientsX = patients[["Age", "Gender", "Height", "Location", "SelfAssessedHealthStatus", "Weight"]]
patientsXNumeric = patients[["Age", "Height", "Weight"]]

# Smoker is not pulled with the other categorical data, so this next code line was added
patientsXBinary = patients[["Smoker"]]


# In[62]:

#Standardize
patientsXNumeric = patients[["Age", "Height", "Weight"]]
patientsXNumeric_scaled = preprocessing.scale(patientsXNumeric, axis=0)

# **Standardizing removed the header from the row. I need to fix this.**

# In[63]:


#Return only object datatypes (non-numeric here)
categoriesX = patientsX.select_dtypes(include=[object]).copy()
categoriesX.head()

# ##### One-Hot Encoding

# As said **[in this terrific one-hot tutorial](https://www.datacamp.com/community/tutorials/categorical-data)**:
# >There are many libraries out there that support one-hot encoding but the simplest one is using pandas' .get_dummies() method.
# >
# >There are mainly three arguments important here, the first one is the DataFrame you want to encode on, second being the columns argument which lets you specify the columns you want to do encoding on, and third, the prefix argument which lets you specify the prefix for the new columns that will be created after encoding.
# 
# *LastName is not to be included in the linear regression.*

# In[34]:

categoriesX_onehot = categoriesX.copy()
categoriesX_onehot = pd.get_dummies(categoriesX, columns=["Gender", "Location", "SelfAssessedHealthStatus"], prefix = ["Gender", "Location", "SelfAssessedHealthStatus"])
categoriesXBinary_onehot = pd.get_dummies(patientsXBinary, columns=["Smoker"], prefix = ["Smoker"])

# Return results
print(categoriesX_onehot.head());
print(categoriesXBinary_onehot.head());


# Now that one-hot encoding has split the categorical attributes into many dummy attributes, they must be concatenated back together. This can be done via pandas' .concat() method. The axis argument is set to 1 as you want to merge on columns.

# In[35]:


print("categoriesX_onehot is: ", type(categoriesX_onehot))
print(categoriesX_onehot.shape)

print("categoriesXBinary_onehot is: ", type(categoriesXBinary_onehot))
print(categoriesXBinary_onehot.shape)

print("patientsXNumeric_scaled is: ", type(patientsXNumeric_scaled))
print(patientsXNumeric_scaled.shape)


# patientsXNumeric_scaled is an array. I used [this SO post](https://stackoverflow.com/questions/20763012/creating-a-pandas-dataframe-from-a-numpy-array-how-do-i-specify-the-index-colum) to convert it to a dataframe.

# In[36]:

patientsXNumeric_scaleddf = pd.DataFrame(patientsXNumeric_scaled)


# In[37]:

print("patientsXNumeric_scaleddf is: ", type(patientsXNumeric_scaleddf))


# In[38]:

print(patientsXNumeric_scaleddf.head())


# Looks better, but it still needs column names.

# In[39]:

patientsXNumeric_scaleddf.columns = ["Age", "Height", "Weight"]

# Now we bring all the columns back together as one dataframe.

# In[40]:


#Bring them back together
#patientsXAll = pd.concat([categoriesX_onehot, patientsXNumeric, categoriesXBinary_onehot], axis=1)
patientsXAll = pd.concat([categoriesX_onehot, patientsXNumeric_scaleddf, categoriesXBinary_onehot], axis=1)

#top 3 rows
print(patientsXAll.head(3))


# In[40]:

#Bring them back together
#patientsXAll = pd.concat([categoriesX_onehot, patientsXNumeric, categoriesXBinary_onehot], axis=1)
patientsXAll = pd.concat([categoriesX_onehot, patientsXNumeric_scaleddf, categoriesXBinary_onehot], axis=1)

#top 3 rows
print(patientsXAll.head(3))



##########################################################################################################
#lasso = linear_model.Lasso()
#print("Cross Val Score: " + str(cross_val_score(lasso, patientsXAll, patientsY, cv=10)))  










patientsYdf = pd.DataFrame(patientsY)

import numpy as np
import matplotlib.pyplot as plt
from sklearn import linear_model
from sklearn.linear_model import lasso_path, lars_path, Lasso, enet_path
#dataset = np.genfromtxt("D:/GradeExample.csv", delimiter = ',')

print("Regularization path using lars_path") # least angle regression
alphas1, active1, coefs1 = lars_path(patientsXAll, patientsYdf, method='lasso', verbose=True)

