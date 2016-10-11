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

from visual import PanelVisual
from raster import Raster
from music import Music
from notifications import NotificationMonitor
from system_info import SystemInfo, Clock
from panel import Panel
from panel_strip import PanelStrip
from window_manager import WindowManager, UserCommand

class EventLoop:
    def __init__(self):
        self.window_manager = WindowManager()
        self.events = Queue()
        self.panel = Panel()
        self.clock = Clock()
        self.notification_monitor = NotificationMonitor()

        try:
            with open(os.path.expanduser('~/.config/mpd/credentials.conf'), 'r') as f:
                mpd_settings = json.load(f)
        except FileNotFoundError:
            self.music = Music()
        else:
            self.music = Music(**mpd_settings)
        self.music_controller = self.music.clone()

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
        elif isinstance(event, UserCommand):
            try:
                command = event.command.split()
                if command[0] == 'music_pause':
                    self.music_controller.pause()
                elif command[0] == 'music_stop':
                    self.music_controller.stop()
                elif command[0] == 'music_home':
                    self.music_controller.seek(0)
                elif command[0] == 'music_next':
                    self.music_controller.next()
                elif command[0] == 'music_previous':
                    self.music_controller.previous()
                elif command[0] == 'music_volume':
                    if command[1].startswith('+') or command[1].startswith('-'):
                        is_relative = True
                    else:
                        is_relative = False
                    self.music_controller.volume(int(command[1]), is_relative)
                elif command[0] == 'notification_next':
                    self.notification_monitor.history_next(self.events)
            except:
                sys.stderr.write(
                    "failed executing command. details: \n" +
                    traceback.format_exc()
                )

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
        self.notification_monitor_thread = self.start_thread(
            self.notification_monitor.loop
        )

        self.panel.start()

        while True:
            self.process_event(self.events.get())

if __name__ == '__main__':
    EventLoop().loop()
