# This is the ESX, QBOX & OX Vesion of Bowling Script

# Dependencies
[ox_lib](https://github.com/overextended/ox_lib/releases)

[ox_inventory](https://github.com/overextended/ox_inventory/releases)

[ox_target](https://github.com/overextended/ox_target/releases)

# Instruction
* 1 . Add this in ox_inventory/data/items.lua

------------------------------------

		['bowlingreceipt'] = {
			label = 'Bowling Receipt',
			weight = 1,
		},

		['bowlingball'] = {
			label = 'Bowling Ball',
			weight = 5
		}




* 2 . Add this in ox_inventory/modules/items/client.lua
------------------------------------
		Item('bowlingball', function (data)
			ox_inventory:useItem(data, function (data)
				if data then
					TriggerEvent('bp-bowling:client:itemused', data)
				end
			end)
		end) 
    
* 2 . Move the images from the icons folder to ox_inventory/web/images

* 3 . Make sure the script is started after dependenicies


# Known Bugs
No known bugs

# Support
Feel free to report any issues you have in our [Discord](https://discord.gg/3tyYuMVG)
