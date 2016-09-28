import urllib.request
from bs4 import BeautifulSoup
import csv
import time

#get the webpage with the prisoner data
uri='http://www.tdcj.state.tx.us/death_row/dr_executed_offenders.html'

f = csv.writer(open("Death Row Data" + ".csv", "w", newline=''), dialect='excel')

# Write column headers as the first line
f.writerow(["Last Statement", "Last Name", "First Name", "TDCJ Num", "Age", "Date", "Race","County"])

#This lets us open the link uri
urllines = urllib.request.urlopen(uri)
pagedat = urllines.read()
urllines.close()
#we use beautifulsoup so that we can parse the HTML
soup = BeautifulSoup(pagedat)
#Finds the "tr" HTML tag which signifies a row in the table
allrows = soup.find_all("tr")
suburi = uri[:38]
for row in allrows:
    #Finds the "td" HTML tag which signifies a cell in the row
    tds = row.find_all("td")
    try:
        #You should insert some code that goes into the link and pulls the last statement of each prisoner out
        LS = "Last Statement goes here :p"
        LN = str(tds[3].get_text())
        FN = str(tds[4].get_text())
        TDCJ = str(tds[5].get_text())
        Age = str(tds[6].get_text())
        Date = str(tds[7].get_text())
        Race = str(tds[8].get_text())
        County = str(tds[9].get_text())
        print("Row processed successfully")
    except Exception:
        print("There was an Error :(")
        time.sleep(.1)
        continue
    #print [LS, LN, FN, TDCJ, Age, Date, Race, County]
    f.writerow([LS, LN, FN, TDCJ, Age, Date, Race, County])
    LS=''
