import sys
from mpd import MPDClient
from mpd import MPDError
from time import sleep
from panel import PanelStrip
from visual import PanelVisual

class Music:
    def __init__(self, hostname='localhost', port='6600', password=None):
        self.hostname = hostname
        self.port = port
        self.password = password
        self.mpd = MPDClient()

    def connect(self):
        self.mpd.connect(self.hostname, self.port)
        if self.password:
            self.mpd.password(self.password)

    def render(self):
        status = self.mpd.status()
        song = self.mpd.currentsong()
        info = PanelStrip('music')

        if status['state'] not in ('play', 'pause'):
            return info.text("DON'T PANIC!")

        info += PanelStrip().text(song['artist']).trim(200).text(' - ')

        if status['state'] == 'play':
            colour = PanelVisual.active
        else:
            colour = None
        info += PanelStrip().text(song['title'], colour).trim(200)

        return info.text(' vol: ' + status['volume'])

    def play(self):
        self.mpd.play()

    def pause(self):
        self.mpd.pause()

    def stop(self):
        self.mpd.stop()

    def seek(self, position):
        self.mpd.seekcur(position)

    def next(self):
        self.mpd.next()

    def previous(self):
        self.mpd.previous()

    def loop(self, events):
        while True:
            try:
                self.connect()
                while True:
                    events.put(self.render())
                    self.mpd.idle()
            except MPDError:
                print(sys.exc_info())
                events.put(PanelStrip('music').text('PANIC!!!'))
                sleep(20)
