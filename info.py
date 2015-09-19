#!/usr/bin/python3

import i3ipc
import threading
import subprocess
from collections import defaultdict
from queue import Queue

class PanelVisual:
    default = '#efebe5'
    semiactive = '#7cd4fc'
    active = '#ebac54'
    urgent = '#ff0000'

    height = 24
    font = '-*-droid sans mono-*-*-*-*-15-*-*-*-*-*-*-*'

class PanelItem:
    def __init__(self, key=None):
        self.key = key
        self.panel_data = ''

    def __add__(self, other):
        return PanelItem().raw(self.panel_data).raw(other.panel_data)

    def move(self, offset):
        return self.raw('^p(' + str(offset) + ')')

    def moveTo(self, position):
        return self.raw('^pa(' + str(position) + ')')

    def escape(self, string):
        return string.replace('^', '^^')

    def colour(self, colour=None):
        if colour:
            return self.raw('^fg(' + colour + ')')
        else:
            return self.raw('^fg()')

    def background(self, colour=None):
        if colour:
            return self.raw('^bg(' + colour + ')^ib(0)')
        else:
            return self.raw('^bg()^ib(1)')

    def raw(self, data):
        self.panel_data += data
        return self

    def text(self, text, colour=None, background=None):
        if (colour):
            self.colour(colour)
        if (background):
            self.background(background)

        self.panel_data += self.escape(text)

        if (colour):
            self.colour()
        if (background):
            self.background()
        return self

    def data(self):
        return (self.panel_data + "\n").encode()

class WindowManager:
    def __init__(self):
        self._i3 = None

    @property
    def i3(self):
        if not self._i3:
            self._i3 = i3ipc.Connection()
        return self._i3

    def loop(self, events):
        def workspace_event(connection, event):
            self.refresh_workspaces(events)
        self.i3.on('workspace::focus', workspace_event)

        def window_event(connection, event):
            self.set_window(events, event.container)
        self.i3.on('window', window_event)

        self.refresh_workspaces(events)
        self.i3.main()

    def refresh_workspaces(self, events):
        info = PanelItem('workspaces')
        for workspace in self.i3.get_workspaces():
            colour, background = None, None
            if workspace.visible:
                colour = PanelVisual.semiactive
            if workspace.focused:
                colour = PanelVisual.active
            if workspace.urgent:
                background = PanelVisual.urgent
            info.text(workspace.name, colour, background).text(' ')

        events.put(PanelItem('current_window').text(':)'))
        events.put(info)

    def set_window(self, events, window_container):
        if window_container.urgent:
            self.refresh_workspaces(events)
        if window_container.focused:
            events.put(PanelItem('current_window').text(window_container.name))

class Panel:
    dzen_executable = [
        'dzen2',
        '-fg', PanelVisual.default,
        '-fn', PanelVisual.font,
        '-ta', 'l',
        '-h', str(PanelVisual.height)
    ]

    def __init__(self):
        self.items = defaultdict(PanelItem)

    def update(self, item):
        self.items[item.key] = item
        self.render()

    def render(self):
        panel = sum([
            self.items['workspaces'],
            PanelItem().text('| '),
            self.items['current_window']
        ], PanelItem())

        self.dzen.stdin.write(panel.data())
        print(panel.data())
        self.dzen.stdin.flush()

    def start(self):
        self.dzen = subprocess.Popen(
            self.dzen_executable,
            stdin=subprocess.PIPE
        )

class EventLoop:
    def __init__(self):
        self.window_manager = WindowManager()
        self.events = Queue()
        self.panel = Panel()

    def start_thread(self, loop):
        thread = threading.Thread(
            target=loop,
            kwargs={'events': self.events}
        )
        thread.daemon = True
        thread.start()
        return thread

    def process_event(self, event):
        if isinstance(event, PanelItem):
            self.panel.update(event)

    def loop(self):
        self.window_manager_thread = self.start_thread(
            self.window_manager.loop
        )

        self.panel.start()

        while True:
            self.process_event(self.events.get())

EventLoop().loop()
