#!/usr/bin/python3

import os
from collections import defaultdict
import subprocess

from raster import Raster
from visual import PanelVisual
from panel_strip import PanelStrip

class Panel:
    dzen_executable = [
        'dzen2',
        '-fg', PanelVisual.default,
        '-fn', PanelVisual.font,
        '-ta', 'l',
        '-h', str(PanelVisual.height),
        '-dock'
    ]

    def __init__(self):
        self.items = defaultdict(PanelStrip)
        self.width = Raster.image_width(PanelVisual.background_image)

    def update(self, item):
        self.items[item.key] = item
        self.render()

    def render(self):
        separator = PanelStrip().text('| ', colour=PanelVisual.active)

        if self.items['notification']:
            background_image = PanelVisual.background_image_notification
            right = sum([
                self.items['notification'],
                PanelStrip().move(15)
            ], PanelStrip()).trim(2 * (self.width // 3))
        else:
            background_image = PanelVisual.background_image
            right = sum([
                self.items['music'],
                PanelStrip().text(' '),
                separator,
                self.items['system_info'],
                separator,
                self.items['clock'],
                PanelStrip().move(8)
            ], PanelStrip())

        left = sum([
            PanelStrip().image(background_image, background=True),
            PanelStrip().image(PanelVisual.logo_image).move(15),
            self.items['workspaces'],
            self.items['mode'],
            separator,
        ], PanelStrip())
        mid = sum([
            self.items['current_window']
        ], PanelStrip())

        if mid.width > self.width - left.width - right.width:
            mid.set_width(self.width - left.width - right.width - separator.width)
            mid += separator
        else:
            mid.set_width(self.width - left.width - right.width)

        panel = left + mid + right

        self.dzen.stdin.write(panel.data())
        self.dzen.stdin.flush()

    def start(self):
        self.dzen = subprocess.Popen(
            self.dzen_executable,
            stdin=subprocess.PIPE
        )
