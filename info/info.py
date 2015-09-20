#!/usr/bin/python3

import i3ipc
import threading
import os
import subprocess
import psutil
import json
from collections import defaultdict
from queue import Queue
from datetime import datetime
from time import sleep

from visual import PanelVisual
from raster import Raster
from music import Music
from panel import PanelStrip, Panel

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

        workspace_event()
        self.refresh_workspaces(events)

        self.i3.main()

    def loop(self, events):
        while True:
            try:
                self.single_instance_loop(events)
            except (FileNotFoundError, BrokenPipeError):
                self.reconnect()

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

class Clock:
    def loop(self, events):
        while True:
            time = datetime.now().strftime('%a %h %Y-%m-%d %H:%M')
            events.put(PanelStrip('clock').text(time))
            sleep(60 - datetime.now().second)    # wait until next minute

class Battery:
    def __init__(self, battery_folder):
        self.battery_folder = battery_folder

    def read_file(self, filename):
        with open(os.path.join(self.battery_folder, filename), 'r') as f:
            return f.read().strip()

    def status(self):
        return self.read_file('status')

    def exists(self):
        return (int(self.read_file('present')) == 1)

    def current_charge(self):
        return int(self.read_file('charge_now')) // 1000

    def percent(self):
        return int(self.read_file('capacity'))

class SystemInfo:
    def __init__(self):
        self.battery = Battery('/sys/class/power_supply/BAT1')

    def load(self):
        return "%.1f" % os.getloadavg()[0]

    def ram(self):
        return str(int(psutil.virtual_memory().percent)) + '%'

    def cpu(self, wait_time):
        return str(int(psutil.cpu_percent(interval=wait_time))) + '%'

    def loop(self, events):
        cpu = '--'
        while True:
            info = PanelStrip('system_info')
            if self.battery.exists():
                info.text(self.battery.status() + ': ')
                info.text(str(self.battery.current_charge()) + 'mAh')
                info.text(' (' + str(self.battery.percent()) + '%)')
            info.text(' cpu: ' + cpu + ' ram: ' + self.ram())
            info.text(' load: ' + self.load())
            events.put(info)

            cpu = self.cpu(5)   # wait 5 seconds and measure cpu


class EventLoop:
    def __init__(self):
        self.window_manager = WindowManager()
        self.events = Queue()
        self.panel = Panel()
        self.clock = Clock()

        try:
            with open(os.path.expanduser('~/.mpd_data.conf'), 'r') as f:
                mpd_settings = json.load(f)
        except FileNotFoundError:
            self.music = Music()
        else:
            self.music = Music(**mpd_settings)

        self.system_info = SystemInfo()

    def start_thread(self, loop):
        thread = threading.Thread(
            target=loop,
            kwargs={'events': self.events}
        )
        thread.daemon = True
        thread.start()
        return thread

    def process_event(self, event):
        if isinstance(event, PanelStrip):
            self.panel.update(event)

    def loop(self):
        self.window_manager_thread = self.start_thread(
            self.window_manager.loop
        )
        self.clock_thread = self.start_thread(
            self.clock.loop
        )
        self.system_info_thread = self.start_thread(
            self.system_info.loop
        )
        self.music_thread = self.start_thread(
            self.music.loop
        )

        self.panel.start()

        while True:
            self.process_event(self.events.get())

if __name__ == '__main__':
    EventLoop().loop()
