
import psycopg2
import matplotlib.pyplot as plt    
import requests
from scipy import stats
import numpy as np
import pandas as pd
import random

conn = psycopg2.connect(config)
cur = conn.cursor()
cur.execute('select id,store_url,0 from children_apps',())
data=cur.fetchall()

i=0
for (x,y,z) in data:
    request = requests.get(y)
    if request.status_code == 200:
        z_=1
        print(i,request.status_code)
    else:
        z_=0
        print(i)
    data[i] = (x,y,z_)
    i=i+1
    
i=0
for (x,y,z) in data:
    if z ==1:
        z_=True
    else:
        z_=False
    data[i]=(x,y,z_)
    i=i+1

conn = psycopg2.connect(config)
cur = conn.cursor()
for x in data:
    cur.execute('insert into app_exist(id,store_url,url_exist) values %s',(x,))
    
cur.close()
conn.commit()
if conn is not None:
        conn.close()
        print('Database connection closed.')
