#!/usr/bin/env python
# coding: utf-8

# In[47]:


import pandas as pd
import numpy as np
pd.options.mode.chained_assignment = None

#Read dataset1 which only contains customer info
df_cust = pd.read_csv('dataset1.csv', sep=',')
#read dataset2 that has all the transaction details, manually defined type for data pre-processing purpose
df_txn = pd.read_csv('dataset2.csv', sep=',',dtype={0:'object', 1:'object',2:'int64',3:'float64',4:'object'})


# In[2]:


df_cust.head()


# In[7]:


df_txn.head()


# In[18]:


# splitting cust_name to first_name and last name
df_cust[['first_name','last_name']] = df_cust['cust_name'].str.rsplit(" ",1, expand=True)

df_cust.head()


# In[50]:


#merge the dataset
df_merge = df_cust.merge(df_txn, how='left', on='cust_id')
# remove record with empty customer name
df_output = df_merge[(df_merge['cust_name'].notnull()) & (df_merge['cust_name'].str.strip()!="")]
#remove leading zeros in amount
df_output['amount'] = df_output.amount.str.lstrip('0').astype(np.int64)
#create a flag that indicate amount > 100
df_output['above_100'] = df_output['amount']>100


# In[51]:


df_output.to_csv('output.csv', index=False, header=True)

