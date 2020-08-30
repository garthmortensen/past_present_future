# -*- coding: utf-8 -*-
"""
Created on Sat Jun 20 15:49:35 2020

@author: morte
   _____                                   _____               _____  _                
  / ____|                                 / ____|             |  __ \(_)                 
 | |     __ _ _ __ _ __ ___   ___ _ __   | (___   __ _ _ __   | |  | |_  ___  __ _  ___  
 | |    / _` | '__| '_ ` _ \ / _ \ '_ \   \___ \ / _` | '_ \  | |  | | |/ _ \/ _` |/ _ \ 
 | |___| (_| | |  | | | | | |  __/ | | |  ____) | (_| | | | | | |__| | |  __/ (_| | (_) |
  \_____\__,_|_|  |_| |_| |_|\___|_| |_| |_____/ \__,_|_| |_| |_____/|_|\___|\__, |\___/ 
                                                                              __/ |      
                                                                             |_gm/
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
