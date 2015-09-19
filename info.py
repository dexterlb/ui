#!/usr/bin/python3

import i3ipc
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
            self.refresh()
        self.i3.on('workspace::focus', workspace_event)

        self.i3.main()

    def refresh(self):
        print(self.i3.get_workspaces())


WindowInfo().loop(None)
