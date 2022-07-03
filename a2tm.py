#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# -----------------------------------------------------------------
# a2tm - aria2 python script for manage url and torrent downloads |
# https://aria2.github.io/                                        |
# Created by q3aql (q3aql@duck.com)                               |
# Licensed by GPL v2.0                                            |
# Last update: 30-03-2021                                         |
# Builds:                                                         |
#   * https://github.com/q3aql/aria2-static-builds/releases       |
#   * https://github.com/tatsuhiro-t/aria2/releases               |
# Compatible with Python 3.x                                      |
# -----------------------------------------------------------------
version="0.1"

#Import python-modules
import subprocess
import os
import sys
import shutil

#Check if your system use Python 3.x
if sys.version_info<(3,0):
  print ("")
  print ("# You need python 3.x to run this program.")
  print ("")
  exit()

#Function to clear screen
def ClearScreen():
  if sys.platform == "cygwin":
    os.system("clear")
  elif os.name == "posix":
    os.system("clear")
  elif os.name == "nt":
    os.system("cls")
  else:
    print ("# Error: Unable clear screen")

# Detect system & PATH of user folder
if os.name == "posix":
  os.chdir(os.environ["HOME"])
  ConfigFile=os.environ["HOME"]+"/.aria2/a2tm.conf"
  FilesTorrent="/*.torrent"
  TorrentFolderInput=os.environ["HOME"]+"/A2TM"
  TorrentFilesInput=os.environ["HOME"]+"/A2TM/files"
  print ("# POSIX detected")
elif os.name == "nt":
  os.chdir(os.environ["USERPROFILE"])
  ConfigFile=os.environ["USERPROFILE"]+"\\.aria2\\a2tm.conf"
  FilesTorrent="\\*.torrent"
  os.chdir("C:\\")
  TorrentFolderInput="C:\\\\A2TM"
  TorrentFilesInput="C:\\\\A2TM\\\\files"
  print ("# Windows detected")
  
# Create default folder for downloads
if not os.path.exists("A2TM"):
  os.makedirs("A2TM")
  os.chdir("A2TM")
if os.path.exists("A2TM"):
  os.chdir("A2TM")
if not os.path.exists("files"):
  os.makedirs("files")

# Create aria2 folder if no exists
if os.name == "posix":
  os.chdir(os.environ["HOME"])
elif os.name == "nt":
  os.chdir(os.environ["USERPROFILE"])
  
if not os.path.exists(".aria2"):
  os.makedirs(".aria2")
  os.chdir(".aria2")
if os.path.exists(".aria2"):
  os.chdir(".aria2")

#Check if exists 'aria2.conf'
if os.path.isfile("aria2.conf"):
  print ("aria2.conf exists")
else:
  print ("aria2.conf created")
  acf=open('aria2.conf','w')
  acf.close()
  acf=open('aria2.conf','a')
  acf.write('# Sample configuration file of aria2c\n')
  acf.close()

#Check if exists 'a2tm.conf'
if os.path.isfile("a2tm.conf"):
  print ("a2tm.conf exists")
else:
  abcf=open('a2tm.conf','w')
  abcf.close()
  abcf=open('a2tm.conf','a')
  abcf.write('# Sample configuration file of a2tm\n')
  abcf.write('\n')
  #abcf.write('DiscFiles="C:" # Only for Windows\n')
  abcf.write('# Folder for save downloads\n')
  abcf.write('TorrentFolder="'+TorrentFolderInput+'"\n')
  abcf.write('\n')
  abcf.write('# Folder from load torrent files\n')
  abcf.write('TorrentFiles="'+TorrentFilesInput+'"\n')
  abcf.write('\n')
  abcf.write('# Set the maximum download speed\n')
  abcf.write('MaxSpeedDownload="300K"\n')
  abcf.write('\n')
  abcf.write('# Set the maximum upload speed\n')
  abcf.write('MaxSpeedUpload="5K"\n')
  abcf.write('\n')
  abcf.write('# Set the maximum peer connections\n')
  abcf.write('BtMaxPeers="25"\n')
  abcf.write('\n')
  abcf.write('# Set the maximum active downloads\n')
  abcf.write('MaxDownloads="25"\n')
  abcf.write('\n')
  abcf.write('# Enable or disable encryptation (values: yes, no)\n')
  abcf.write('Encryptation="yes"\n')
  abcf.write('\n')
  abcf.write('# Enable or disable RPC (values: yes, no)\n')
  abcf.write('Rpc="yes"\n')
  abcf.write('\n')
  abcf.write('# Set port for RPC (when Rpc=yes)\n')
  abcf.write('RpcPort="6800"\n')
  abcf.write('\n')
  abcf.write('# Enable or disable seeding (values: yes, no)\n')
  abcf.write('Seeding="yes"\n')
  abcf.write('\n')
  abcf.write('# Set seed ratio (0.0 is infinite)\n')
  abcf.write('SeedRatio="0.0"\n')
  abcf.write('\n')
  abcf.write('# Enable or disable debug mode\n')
  abcf.write('aria2Debug="no"\n')
  abcf.write('\n')
  abcf.write('# Set debug level (values: debug, info, notice, warn, error)\n')
  abcf.write('DebugLevel="info"\n')
  abcf.write('\n')
  abcf.write('# Set file allocation (values: none, prealloc, trunc, falloc)\n')
  abcf.write('FileAllocation="none"\n')
  abcf.write('\n')
  abcf.write('# Enable or disable CA-Certificates (values: yes, no)\n')
  abcf.write('CaCertificate="no"\n')
  abcf.write('\n')
  abcf.write('# Path for CA-Certificates (values: yes, no)\n')
  abcf.write('CaCertificateFile="/etc/ssl/certs/ca-certificates.crt"\n')
  abcf.close()

#Import variables from a2tm.conf
exec(open("a2tm.conf").read())

#Check input files
try:
  if os.path.isfile(sys.argv[1]):
    ClearScreen()
    print ("")
    print ("# a2tm v"+version+" **")
    print ("")
    print ("# File detected: "+sys.argv[1])
    print ("")
    InputFile=input("# Do you want to copy file to "+TorrentFiles+" directory (y/n): ")
    if InputFile == "n":
      print ("")
      print ("# Exiting...")
    else:
      try:
        shutil.copy(sys.argv[1], TorrentFiles)
        print ("")
        print ("# File copied successfully")
        print ("")
        PauseReturn=input("# Press ENTER to continue ")
        print ("# Loading...")
      except:
        print ("")
        print ("# Failed to copy the file")
        print ("")
        PauseReturn=input("# Press ENTER to continue ")
        print ("# Loading...")
except:
  print ("# No input files")

#Define aria2c variables
SpeedOptions="--max-overall-download-limit="+MaxSpeedDownload+" --max-overall-upload-limit="+MaxSpeedUpload
PeerOptions="--bt-max-peers="+BtMaxPeers
if CaCertificate == "no":
  OtherOptions="-V -j " +MaxDownloads+" --file-allocation="+FileAllocation+" --auto-file-renaming=false --allow-overwrite=false"
elif CaCertificate == "yes":
  OtherOptions="-V -j "+MaxDownloads+" --file-allocation="+FileAllocation+" --auto-file-renaming=false --allow-overwrite=false --ca-certificate="+CaCertificateFile
if Encryptation == "no":
  TorrentOptions="--bt-require-crypto=false"
elif Encryptation == "yes":
  TorrentOptions="--bt-min-crypto-level=arc4 --bt-require-crypto=true"
if Rpc == "no":
  RpcOptions="--rpc-listen-all=false"
elif Rpc == "yes":
  RpcOptions="--enable-rpc --rpc-listen-all=true --rpc-allow-origin-all --rpc-listen-port="+RpcPort
if Seeding == "no":
  SeedOptions="--seed-time=0"
elif Seeding == "yes":
  SeedOptions="--seed-ratio="+SeedRatio
if aria2Debug == "no":
  AllOptions=TorrentOptions+" "+SpeedOptions+" "+PeerOptions+" "+RpcOptions+" "+SeedOptions
elif aria2debug == "yes":
  AllOptions=TorrentOptions+" "+SpeedOptions+" "+PeerOptions+" "+RpcOptions+" "+SeedOptions+" --console-log-level="+DebugLevel

#Check if aria2 is installed
from subprocess import PIPE, Popen
try:
  aria2Check = Popen(['aria2c', '-v'], stdout=PIPE, stderr=PIPE)
  aria2Check.stderr.close()
except:
  ClearScreen()
  print ("")
  print ("# Error: 'aria2' is not installed!")
  print ("")
  print ("# Builds:")
  print ("  * https://github.com/q3aql/aria2-static-builds/releases")
  print ("  * https://github.com/tatsuhiro-t/aria2/releases")
  print ("")
  PauseExit=input("# Press ENTER to exit ")
  exit()

# Parameter start for run as service
try:
    if sys.argv[1] == "start":
      ClearScreen()
      print ("")
      print ("# Running aria2c (Ctrl + C to stop)")
      if os.name == "posix":
        os.chdir(TorrentFiles)
        os.system('ls | grep ".torrent" > aria2-list.txt')
        os.system("aria2c "+OtherOptions+" -i aria2-list.txt "+AllOptions+" -d "+TorrentFolder)
        print ("")
        print ("# Exiting...")
        os._exit(0)
        exit()
      elif os.name == "nt":
        #os.chdir(DiscFiles)
        os.chdir(TorrentFiles)
        os.system('dir /B | find ".torrent" > aria2-list.txt')
        os.system("aria2c "+OtherOptions+" -i aria2-list.txt "+AllOptions+" -d "+TorrentFolder)
        print ("")
        print ("# Exiting...")
        os._exit(0)
        exit()
except:
  print ("# Loading a2tm...")

#Show main menu
MainMenu = 1
while MainMenu <= 2:
  ClearScreen()
  print ("")
  print ("# a2tm v"+version+" ##")
  print ("")
  print (" # Configuration File: "+ConfigFile)
  print ("")
  print (" # Path Downloads: "+TorrentFolder)
  print (" # Torrent Files: "+TorrentFiles+FilesTorrent)
  if os.name == "posix":
    print (" # URLs File: "+TorrentFiles+"/urls.txt")
  elif os.name == "nt":
    print (" # URLs File: "+TorrentFiles+"\\urls.txt")
  print (" # Download/Upload Speed: "+MaxSpeedDownload+"/"+MaxSpeedUpload)
  print (" # Encryption: "+Encryptation)
  print (" # RPC/Port: "+Rpc+"/"+RpcPort)
  print (" # Maximum Peers/Downloads: "+BtMaxPeers+"/"+MaxDownloads)
  print (" # Seeding/Ratio: "+Seeding+"/"+SeedRatio)
  print (" # Debugging/Level: "+aria2Debug+"/"+DebugLevel)
  print (" # CA-Certificate: "+CaCertificate+" ("+CaCertificateFile+")")
  print (" # File allocation: "+FileAllocation)
  print ("")
  print ("# Options:")
  print ("")
  print (" r --> Run Aria2 Service")
  print (" l --> List Torrent Files")
  print (" m --> Create Torrent File From Magnet Link")
  print (" u --> Run Aria2 From URLs File")
  print (" q --> Quit")
  print ("")
  InputMenu=input("# Select Option (r/l/m/u/q): ")
 #Options from InputMenu variable
  if InputMenu == "r" or InputMenu == "1":
    ClearScreen()
    print ("")
    print ("# Running aria2c (Ctrl + C to stop)")
    if os.name == "posix":
      os.chdir(TorrentFiles)
      os.system('ls | grep ".torrent" > aria2-list.txt')
      os.system("aria2c "+OtherOptions+" -i aria2-list.txt "+AllOptions+" -d "+TorrentFolder)
      print ("")
      PauseExit=input("# Press ENTER to return ")
      print ("# Exiting...")
    elif os.name == "nt":
      #os.chdir(DiscFiles)
      os.chdir(TorrentFiles)
      os.system('dir /B | find ".torrent" > aria2-list.txt')
      os.system("aria2c "+OtherOptions+" -i aria2-list.txt "+AllOptions+" -d "+TorrentFolder)
      print ("")
      PauseReturn=input("# Press ENTER to return ")
      print ("# Exiting...")
  elif InputMenu == "l" or InputMenu == "2":
    ClearScreen()
    print ("")
    print ("# List of torrents that will be loaded:")
    print ("")
    if os.name == "posix":
      os.system("ls "+TorrentFiles+" | grep '.torrent'")
    elif os.name == "nt":
      os.system('dir /B '+TorrentFiles+' | find ".torrent"')
    print ("")
    print ("# List of incomplete downloads:")
    print ("")
    if os.name == "posix":
      os.system("ls "+TorrentFolder+" | grep '.aria2'")
    elif os.name == "nt":
      os.system('dir /B '+TorrentFolder+' | find ".aria2"')
    print ("")
    PauseReturn=input("# Press ENTER to return ")
    print ("# Exiting...")
  elif InputMenu == "m" or InputMenu == "3":
    ClearScreen()
    os.chdir(TorrentFiles)
    print ("")
    print ("# Make torrent file from Magnet-link")
    print ("")
    MagnetLink=input("# Type the Magnet-link (in quotes): ")
    print ("")
    os.system("aria2c --bt-metadata-only=true --bt-save-metadata=true -d "+TorrentFiles+" "+MagnetLink)
    print ("")
    PauseReturn=input("# Press ENTER to return ")
    print ("# Exiting...")
  elif InputMenu == "u" or InputMenu == "4":
    os.chdir(TorrentFiles)
    if os.path.isfile("urls.txt"):
      print (TorrentFiles+"/urls.txt exists")
    else:
      urlsfile=open('urls.txt','w')
      urlsfile.close()
      urlsfile=open('urls.txt','a')
      urlsfile.write("")
      urlsfile.close()
    ClearScreen()
    print ("")
    if os.name == "posix":
      print ("# List URLs ("+TorrentFiles+"/urls.txt):")
    elif os.name == "nt":
      print ("# List URLs ("+TorrentFiles+"\\urls.txt):")
    print ("")
    readfile=open('urls.txt', 'r')
    print(readfile.read())
    readfile.close()
    print ("")
    LoadUrls=input("# Load URLs? (y/n): ")
    if LoadUrls == "y":
      ClearScreen()
      print ("")
      print ("# Running aria2c (Ctrl + C to stop)")
      os.system("aria2c "+OtherOptions+" -i urls.txt "+AllOptions+" -d "+TorrentFolder)
      print ("")
      PauseReturn=input("+ Press ENTER to return ")
    elif LoadUrls == "n":
      print ("")
      print ("# Exiting...")
    else:
      print ("")
      print ("# Exiting...")
  elif InputMenu == "q" or InputMenu == "5":
    print ("")
    print ("# Exiting...")
    MainMenu += 2
  else:
    print ("")
    print ("# Invalid Option")
    print ("")
    PauseReturn=input("# Press ENTER to return ")
