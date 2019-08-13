import psycopg2
import matplotlib.pyplot as plt    
import requests
from scipy import stats
import numpy as np
import pandas as pd
import random

conn = psycopg2.connect(config)
cur = conn.cursor()

cur.execute('select c.company as hosts ,p.perm from company_domains c, (select h.id, unnest(h.hosts) as u from app_hosts h, children_apps c where h.id=c.id) h, (select c.id, unnest(p.permissions) as perm from children_apps c, app_perms p where c.id=p.id) p where h.u like %s || c.domain || %s  and p.id=h.id',('%','%',))
data=cur.fetchall()

cur.close()
if conn is not None:
        conn.close()
        print('Database connection closed.')
print("")

unique = list(set(data))
#print(len(unique))
x=[row[0] for row in data]
y=[row[1] for row in data]
comp=pd.get_dummies(x)
perm=pd.get_dummies(y)
pair = []


for u in unique:
    c = u[0]
    p = u[1]
    tbl=pd.crosstab(comp[c],perm[p])
    (_,prob,_,exp) = stats.chi2_contingency(tbl)
    if prob<(0.05/(len(comp.columns)*len(perm.columns))) and all(i>=5 for i in np.concatenate(exp)) and tbl[1][1] > exp [1][1]:
        #print(tbl)
        #print(exp)
        pair.append((c,p))
        print(c,p)



conn = psycopg2.connect(config)
cur = conn.cursor()
for x in pair:
    cur.execute('insert into company_perm(company,perm) values %s',(x,))
    
cur.close()
conn.commit()
if conn is not None:
        conn.close()
        print('Database connection closed.')
