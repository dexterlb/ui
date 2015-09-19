#!/usr/bin/python3

import i3ipc
import threading
import subprocess
from collections import defaultdict
from queue import Queue

class PanelItem:
    def __init__(self, key=None):
        self.key = key
        self.panel_data = ''

    def __add__(self, other):
        return PanelItem().raw(self.panel_data).raw(other.panel_data)

    def escape(self, string):
        return string.replace('^', '^^')

    def raw(self, data):
        self.panel_data += data
        return self

    def text(self, text):
        self.panel_data += self.escape(text)
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
            info.text(workspace.name + ' ')
        events.put(info)

    def set_window(self, events, window_container):
        events.put(PanelItem('current_window').text(window_container.name))

class Panel:
    dzen_executable = ['dzen2']

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
        if event.panel_data:
            self.panel.update(event)

    def loop(self):
        self.window_manager_thread = self.start_thread(
            self.window_manager.loop
        )

        self.panel.start()

        while True:
            self.process_event(self.events.get())

EventLoop().loop()
