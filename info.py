#!/usr/bin/python3

import i3ipc
import threading
from queue import Queue

class PanelItem:
    def __init__(self, key):
        self.key = key
        self.panel_data = ''

    def text(self, text):
        self.panel_data += text
        return self

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

        self.i3.main()

    def refresh_workspaces(self, events):
        info = PanelItem('workspaces')
        for workspace in self.i3.get_workspaces():
            info.text(workspace.name + ' ')
        events.put(info)


class EventLoop:
    def __init__(self):
        self.window_manager = WindowManager()
        self.events = Queue()

    def start_thread(self, loop):
        thread = threading.Thread(
            target=loop,
            kwargs={'events': self.events}
        )
        thread.daemon = True
        thread.start()
        return thread

    def loop(self):
        self.window_manager_thread = self.start_thread(
            self.window_manager.loop
        )

        while True:
            print(self.events.get().panel_data)

EventLoop().loop()
