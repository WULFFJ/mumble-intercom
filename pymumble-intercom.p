#This will setup the base for you to setup a mumble client to work with your Mumble server.
#This was setup with a USB soundcard, which makes things a little tricky
#To make this easier blacklist the default Raspberry Pi audio card
# in Linux sudo nano /etc/modprobe.d/raspi-blacklist.conf and add blacklist snd_bcm2835
# next sudo nano /lib/modprobe.d/aliases.conf and comment out options snd-usb-audio index=-2
#reboot and for some odd reason, I had to reboot and then sudo systemctl restart mumble-server.service
#This will be a work in progress to get full functionality

import pymumble_py3 as pymumble
from pymumble_py3.callbacks import PYMUMBLE_CLBK_SOUNDRECEIVED as PCS
import pyaudio

# Connection details for mumble server. Hardcoded for now, will have to be
# command line arguments eventually
pwd = "XXXXXXXXXXX"  # password
server = "XXXXXXXXXX"  # server address
nick = "XXXXXXXXX"
port = 64738  # port number


# pyaudio set up
CHUNK = 1024
FORMAT = pyaudio.paInt16  # pymumble soundchunk.pcm is 16 bits
CHANNELS = 1
RATE = 44100  # pymumble soundchunk.pcm is 48000Hz

p = pyaudio.PyAudio()
stream_listen = p.open(format=FORMAT,
                channels=CHANNELS,
                rate=RATE,
                input=True,  # enable both talk
                output=True,  # and listen
                frames_per_buffer=CHUNK)

stream_talk = p.open(format=FORMAT,
                channels=CHANNELS,
                rate=RATE,
                input=True,  # enable both talk
                #output=True,  # and listen
                frames_per_buffer=CHUNK)

# mumble client set up
def sound_received_handler(user, soundchunk):
    """ play sound received from mumble server upon its arrival """
    stream_listen.write(soundchunk.pcm)


# Spin up a client and connect to mumble server
mumble = pymumble.Mumble(server, nick, password=pwd, port=port)
# set up callback called when PCS event occurs
mumble.callbacks.set_callback(PCS, sound_received_handler)
mumble.set_receive_sound(1)  # Enable receiving sound from mumble server
mumble.start()
mumble.is_ready()  # Wait for client is ready


# constant capturing sound and sending it to mumble server
while True:
    data = stream_talk.read(CHUNK,exception_on_overflow=False)
    mumble.sound_output.add_sound(data)



