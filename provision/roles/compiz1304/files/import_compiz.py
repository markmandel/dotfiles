#!/usr/bin/python
#http://askubuntu.com/questions/244333/compiz-profile-settings-export-and-import-using-command-line
import sys
import compizconfig

#The last input on the command line will be the path to save the file to.
savefile=sys.argv[-1]

context=compizconfig.Context()

context.Import(savefile)