# badb: Better Android Debug Bridge

The badb project is a wrapper command for adb that helps when working with multiple connected devices.

When you attempt to run a command with badb, it first prompts you to choose a device:

    [zpinter:~]$ badb shell
    1. 028841C4437OG222
    2. 3533B6D1DFC242AF
    Choose your adb device: 1
    shell@android:/ $ 

The badb command keeps a history of the last device you chose, so subsequent commands (even in different terminals) will use the same device without prompt:

    [zpinter:~]$ badb shell
    shell@android:/ $ 

If you want to find out what the current device is, run badb current or badb list:

    [zpinter:~]$ badb current
    Current device is 028841C4437OG222
     
    [zpinter:~]$ badb list
    List of devices: 
    028841C4437OG222 #current
    3533B6D1DFC242AF
    [zpinter:~]$ 
	 
As you can see, the above list of serials isn't very friendly. So, badb provides an alias command:
	
    [zpinter:~]$ badb alias
    Create an alias: 
    1. 028841C4437OG222
    2. 3533B6D1DFC242AF
    Choose your adb device: 1
    Enter an alias for 028841C4437OG222: LG Tablet

    [zpinter:~]$ badb alias
    Create an alias: 
    1. 028841C4437OG222 (LG Tablet)
    2. 3533B6D1DFC242AF
    Choose your adb device: 2
    Enter an alias for 3533B6D1DFC242AF: Nexus S 4G	 

    [zpinter:~]$ badb list
    List of devices: 
    028841C4437OG222 (LG Tablet) #current
    3533B6D1DFC242AF (Nexus S 4G)
    [zpinter:~]$ 	 

Finally if you want to change your current device, you can use badb choose:

    [zpinter:~]$ badb choose
    1. 028841C4437OG222 (LG Tablet)
    2. 3533B6D1DFC242AF (Nexus S 4G)
    Choose your adb device: 2
    [zpinter:~]$ badb current
    Current device is 3533B6D1DFC242AF (Nexus S 4G)
     		  				 
== Contributing to badb
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2012 Zachary Pinter. See LICENSE.txt for
further details.

