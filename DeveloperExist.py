import psycopg2
import matplotlib.pyplot as plt    
import requests
from scipy import stats
import numpy as np
import pandas as pd
import random

conn = psycopg2.connect(config)
cur = conn.cursor()

cur.execute('select dev.id, array_agg(app.store_url) from (select distinct developer from app_exist ex, playstore_apps ap where ex.url_exist=false and ap.id=ex.id) as ap, playstore_apps app, developers dev where ap.developer=app.developer and ap.developer=dev.id group by dev.id',())
web=cur.fetchall()

cur.close()
if conn is not None:
        conn.close()
        print('Database connection closed.')
print("")

totals = []
exists = []
percent = []
i=0
for (x,y) in web:
    t=0
    e=0
    p=0
    for (z) in y:
        request = requests.get(z)
        if request.status_code == 200:
            e+=1
        t+=1
    p=(e/t)*100
    totals.append(t)
    exists.append(e)
    percent.append(p)
    i+=1
    print(i)

conn = psycopg2.connect(config)
cur = conn.cursor()
for i in range(0,len(percent)):
    cur.execute('insert into developer_exist(developer,total_apps,still_exist,percent_exist) values %s',((web[i][0],totals[i],exists[i],percent[i]),))
    
cur.close()
conn.commit()
if conn is not None:
        conn.close()
        print('Database connection closed.')
