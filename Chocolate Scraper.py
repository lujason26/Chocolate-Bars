import requests
from bs4 import BeautifulSoup
import pandas as pd

url = 'https://flavorsofcacao.com/database_w_REF.html'
html = requests.get(url)

s = BeautifulSoup(html.text, 'html.parser')

results = s.findAll('table')[0].findAll('tr')
#print(len(results))
#print(results[1])

company_list = []

for row in results[1:]: #index 0 is the headers, which returns error if used
    dic = {}
    dic['Company'] = row.find_all('td')[1].text
    dic['Company Location'] = row.find_all('td')[2].text
    dic['Country of Bean Origin'] = row.find_all('td')[4].text
    dic['Cocoa Percent'] = row.find_all('td')[6].text.replace('%','')
    dic['Ingredients'] = row.find_all('td')[7].text
    dic['Most Memorable Characteristics'] = row.find_all('td')[8].text
    dic['Rating'] = row.find_all('td')[9].text

    company_list.append(dic)
#print(company_list[0])

df = pd.DataFrame(company_list)
df.to_excel('chocolate_data.xlsx', index=False)
df.to_csv('chocolate_data.csv', index=False)

