import sys
from mpd import MPDClient
from mpd import MPDError
from time import sleep
from panel_strip import PanelStrip
from visual import PanelVisual

class Music:
    def __init__(self, hostname='localhost', port='6600', password=None):
        self.hostname = hostname
        self.port = port
        self.password = password
        self.mpd = MPDClient()

    def clone(self):
        return Music(self.hostname, self.port, self.password)

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

        info.icon('music')
        info += PanelStrip().text(song['artist']).trim(200).text(' - ')

        if status['state'] == 'play':
            colour = PanelVisual.active
        else:
            colour = None
        info += PanelStrip().text(song['title'], colour).trim(200)
        info.move(8).icon('volume').move(3)
        return info.text(status['volume'])

    def safe_call(self, method, *args, **kwargs):
        try:
            return getattr(self.mpd, method)(*args, **kwargs)
        except (MPDError, ConnectionError):
            self.mpd.kill()
            self.connect()
            return getattr(self.mpd, method)(*args, **kwargs)

    def play(self):
        return self.safe_call('play')

    def pause(self):
        return self.safe_call('pause')

    def stop(self):
        return self.safe_call('stop')

    def seek(self, position):
        return self.safe_call('seekcur', position)

    def next(self):
        return self.safe_call('next')

    def previous(self):
        return self.safe_call('previous')

    def volume(self, volume, relative=False):
        if relative:
            old_volume = int(self.safe_call('status')['volume'])
            return self.safe_call('setvol', old_volume + volume)
        else:
            return self.safe_call('setvol', volume)

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
