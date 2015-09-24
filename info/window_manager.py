#!/usr/bin/python3

import i3ipc
import threading
import os
import subprocess
import psutil
import json
import traceback
import sys
from collections import defaultdict
from queue import Queue
from datetime import datetime
from time import sleep

from panel_strip import PanelStrip
from visual import PanelVisual

class UserCommand:
    def __init__(self, command):
        self.command = command

class WindowManager:
    def __init__(self):
        self._i3 = None

    @property
    def i3(self):
        if not self._i3:
            self._i3 = i3ipc.Connection()
        return self._i3

    def reconnect(self):
        self._i3 = None

    def single_instance_loop(self, events):
        def workspace_event(connection=None, event=None):
            events.put(PanelStrip('current_window').text(':)'))
            self.refresh_workspaces(events)
        self.i3.on('workspace::focus', workspace_event)

        def window_event(connection, event):
            self.set_window(events, event.container)
        self.i3.on('window', window_event)

        def mode_event(connection, event):
            self.set_mode(events, event.change)
        self.i3.on('mode', mode_event)

        def command_event(connection, event):
            prefix = 'nop send '
            if event.binding.command.startswith(prefix):
                events.put(UserCommand(event.binding.command[len(prefix):]))
        self.i3.on('binding', command_event)

        workspace_event()
        self.refresh_workspaces(events)

        self.i3.main()

    def loop(self, events):
        while True:
            try:
                self.reconnect()
                self.single_instance_loop(events)
            except OSError:
                sys.stderr.write(
                    "connection to i3 failed. details: \n" +
                    traceback.format_exc()
                )
                sleep(1)

    def refresh_workspaces(self, events):
        info = PanelStrip('workspaces')
        for workspace in self.i3.get_workspaces():
            colour, background = None, None
            if workspace.visible:
                colour = PanelVisual.semiactive
            if workspace.focused:
                colour = PanelVisual.active
            if workspace.urgent:
                background = PanelVisual.urgent
            info.text(workspace.name, colour, background).text(' ')

        events.put(info)

    def set_window(self, events, window_container):
        if window_container.focused:
            events.put(PanelStrip('current_window').text(window_container.name))
        self.refresh_workspaces(events)

    def set_mode(self, events, mode):
        if mode == 'default':
            events.put(PanelStrip('mode'))
        else:
            events.put(PanelStrip('mode').text(
                mode, background=PanelVisual.urgent
            ))
