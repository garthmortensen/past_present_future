# -*- coding: utf-8 -*-
"""
Created on Sat Jun 20 15:49:35 2020

@author: morte

.__                                         __         .__     
|  |__   ____ ______     ______ ____  _____/  |_  ____ |  |__  
|  |  \ /  _ \\____ \   /  ___// ___\/  _ \   __\/ ___\|  |  \ 
|   Y  (  <_> )  |_> >  \___ \\  \__(  <_> )  | \  \___|   Y  \
|___|  /\____/|   __/  /____  >\___  >____/|__|  \___  >_gm|  /
     \/       |__|          \/     \/                \/     \/ 

using NordVPN (perhaps others?), you can cycle through IP addresses

"""

# %%

import subprocess  # for cmd
import time  # for timer

# do your thing here

	try:
		something = "something"

	except json.decoder.JSONDecodeError:
		print("<<<YOU PROBABLY HIT LIMIT. RECONNECTING>>>")

		# disconnect
		process = subprocess.Popen(["nordvpn", "-d"],
								   shell=True,
								   stdout=subprocess.PIPE,
								   stderr=subprocess.PIPE)
		time.sleep(15)  # time to process

		# reconnect
		srv = "United States"
		process = subprocess.Popen(["nordvpn", "-c", "-g", srv],
								   shell=True,
								   stdout=subprocess.PIPE,
								   stderr=subprocess.PIPE)
		time.sleep(30)

		# give it another go
		something = "something"

else:
	something = "something"
