from lxml import html
import requests
import random

linkToFollow = "https://en.wikipedia.org/wiki/2011_German_Census"
maxHop = 20

#make it a user input maybe?
#searchString = "six degrees of freedom".replace(" ", "+")
searchString = "i need to poop real bad. im pooping".replace(" ", "+")

wikipediaSearchLink = "https://en.wikipedia.org/w/index.php?search=" + searchString
print(wikipediaSearchLink)
page = requests.get(wikipediaSearchLink)
#parse it into a lxml tree thingie
tree = html.fromstring(page.content)

#first search result in wikipedia search, IF you didn't land directly on an article
firstSearch = tree.xpath('//*[@id="mw-content-text"]/div/ul/li[1]/div[1]/a')


# account for when you land directly on a page, like 3 degrees of seperation. by checking the URL maybe?
# there may be trouble from the firstSearch url, which was adjusted to account for 'did you mean X?'

for x in range(0, maxHop):
    print(linkToFollow)
    #get the page with requests
    page = requests.get(linkToFollow)
    #parse it into a lxml tree thingie
    tree = html.fromstring(page.content)
    #run the xpath query to find the list of spices from that above url
    links = tree.xpath('//*[@id="mw-content-text"]/div/p/a')
    #How many links do we have?
    linksCount = len(links)
    #let's grab a random one
    
    if linksCount > 0:
        whichToClick = random.randint(0,linksCount-1)
        #and scrape it again
        linkToFollow = "https://en.wikipedia.org" + links[whichToClick].attrib['href']    
        print("\nCount of links: " + str(linksCount) + ", Link chosen: " + linkToFollow + ", hop: " + str(x))
    else:
        break
        #/////


#print("done")


