# Parsing a website using XML

# %%

from lxml import html
import requests

#get the page with requests
page = requests.get('https://silkroadspices.ca/collections/spices')

#parse it into a lxml tree thingie
tree = html.fromstring(page.content)

#run the xpath query to find the list of spices from that above url
spices = tree.xpath('//*[@id="shopify-section-collection-template"]/div/div[4]/div[1]/div/div/div/div[1]/a')

#it returns me an array, let's loop thru it
for spice in spices:

    #build the full URL of the spice. "attrib" was found using the debug and exploring the variable
    spiceUrl = "https://silkroadspices.ca" + spice.attrib['href']

    #since I now have the url of each spice, let's crawl that page, using the same code as above
    spicePage = requests.get(spiceUrl)
    spiceTree = html.fromstring(spicePage.content)

    #finding the price using xpath
    price = spiceTree.xpath('//*[@id="shopify-section-product-template"]/div[1]/div[2]/div/div/div/div[2]/p/span[2]/span/span')    

    #making it into a nice string for printing
    print(spice.text + ". Cost: " + price[0].text + ". URL: " + spiceUrl)    
print("done")

#Your challenge. After each spice and link is printed, print the description of the spice. it's in each spice's page