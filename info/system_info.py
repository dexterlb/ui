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
from panel import PanelStrip


class Clock:
    def loop(self, events):
        while True:
            time = datetime.now().strftime('%a %h %d %H:%M')
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

    def current(self):  # current as in mA
        return int(self.read_file('current_now')) // 1000

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

    def battery_info(self):
        if not self.battery.exists():
            return
        status = self.battery.status()

        info = PanelStrip('battery')

        if status == 'Full':
            info.icon('battery_max')
        elif status == 'Charging':
            info.icon('battery_charging')
        else:
            info.icon('battery')
        if self.battery.percent() < 15:
            background = PanelVisual.urgent
        else:
            background = None
        info.text(
            str(self.battery.percent()) + '%',
            background=background
        )
        info.text(' (' + str(self.battery.current_charge()) + 'mAh')
        if self.battery.status() == 'Discharging':
            info.text(' at ' + str(self.battery.current()) + 'mA')
        info.text(') ')

        return info

    def loop(self, events):
        cpu = '--'
        while True:
            info = PanelStrip('system_info')
            info += self.battery_info()

            info.icon('cpu').text(cpu).text(' ')
            info.icon('ram').text(self.ram()).text(' ')
            info.icon('load').text(self.load()).text(' ')
            events.put(info)

            cpu = self.cpu(5)   # wait 5 seconds and measure cpu
