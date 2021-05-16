#!/usr/bin/env python
# coding: utf-8

# In[4]:


import requests
import json
import pandas as pd
import plotly.graph_objects as go


# In[5]:


url = "https://api.covid19api.com/country/singapore/status/confirmed?from=2020-01-01T00:00:00Z&to=2021-05-10T00:00:00Z"
#get the data from API
response = requests.request("GET", url)
#print(response.text)


# In[6]:


#load the data into json
r = json.loads(response.text)
#print(r)


# In[7]:


#normalize json into flat dataframe format
df = pd.json_normalize(r)
#convert date format
df['Date'] = df['Date'].astype('datetime64[ns]')

df.head()


# In[8]:


#PLOTTING a bar chart over time to indicate covid trends over the course of the pandemic. 
#Chart is provided with slider to zoom to specific timeframe

fig = go.Figure()

fig.add_trace(
    go.Bar(x=list(df.Date), y=list(df.Cases)))

# Set title
fig.update_layout(
    title_text=" COVID19 cases in Singapore over time"
)

# Add range slider
fig.update_layout(
    xaxis=dict(
        rangeselector=dict(
            buttons=list([
                dict(count=1,
                     label="1m",
                     step="month",
                     stepmode="backward"),
                dict(count=6,
                     label="6m",
                     step="month",
                     stepmode="backward"),
                dict(count=1,
                     label="YTD",
                     step="year",
                     stepmode="todate"),
                dict(count=1,
                     label="1y",
                     step="year",
                     stepmode="backward"),
                dict(step="all")
            ])
        ),
        rangeslider=dict(
            visible=True
        ),
        type="date"
    )
)

fig.show()


# In[ ]:




