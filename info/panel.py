import os
from collections import defaultdict
import subprocess

from raster import Raster
from visual import PanelVisual

class PanelItem:
    def panel_data(self, overlay_suffix=None):
        return self.data

class Colour(PanelItem):
    width = 0
    def __init__(self, colour=None):
        if colour:
            self.data = '^fg(' + str(colour) + ')'
        else:
            self.data = '^fg()'

class Background(PanelItem):
    width = 0
    def __init__(self, colour=None):
        if colour:
            self.data = '^bg(' + colour + ')^ib(0)'
        else:
            self.data = '^bg()^ib(1)'

class Move(PanelItem):
    def __init__(self, offset):
        self.width = offset
        self.data = '^p(' + str(offset) + ')'

class Text(PanelItem):
    def __init__(self, text):
        self.update(text)

    def update(self, text):
        self.text = text
        self.width = Raster.text_width(text)

    def trimmed(self, width):
        separator = PanelStrip().icon('split')

        if width < separator.width:
            return PanelStrip()

        if PanelVisual.char_width:
            side_chars = (width - separator.width) // (2 * PanelVisual.char_width)
            left_text = self.text[:side_chars]
            right_text = self.text[len(self.text) - side_chars:]
        else:
            left_text = self.text
            right_text = self.text
            fragment_width = (width - separator.width) // 2

            while Raster.text_width(left_text) > fragment_width:
                left_text = left_text[len(left_text) - 1:]
            while Raster.text_width(right_text) > fragment_width:
                right_text = right_text[1:]

        return (
            PanelStrip().text(left_text)
            + separator
            + PanelStrip().text(right_text)
        )

    def panel_data(self, overlay_suffix=None):
        return self.text.replace('^', '^^')

class Image(PanelItem):
    def __init__(self, image_file, ignore_background=False, overlay=False):
        self.width = Raster.image_width(image_file)
        self.image_file = image_file
        self.ignore_background = ignore_background
        self.overlay = overlay

    def panel_data(self, overlay_suffix):
        if self.overlay:
            overlay_file = self.image_file + overlay_suffix
            data = '^i(' + overlay_file + ')'
        else:
            data = '^i(' + self.image_file + ')'
        if self.ignore_background:
            data += '^ib(1)'
        return data


class PanelStrip:
    def __init__(self, key=None):
        self.key = key
        self.items = []
        self.background_image_file = None
        self.background_position = 0

    def __repr__(self):
        return '<PanelStrip ' + str(self.key) + '>'

    def __add__(self, other):
        strip = PanelStrip()
        strip.items = self.items + other.items
        strip.key = self.key
        if other.background_image_file:
            strip.background_image_file = other.background_image_file
            strip.background_position = self.width + other.background_position
        else:
            strip.background_image_file = self.background_image_file
            strip.background_position = self.background_position
        return strip

    def __bool__(self):
        return bool(self.items)

    def data(self):
        data = ''
        position = 0
        for item in self.items:
            overlay_suffix = (
                '.overlay/' + os.path.basename(self.background_image_file) +
                '.' + str(position) + '.xpm'
            )
            data += item.panel_data(overlay_suffix)
            position += item.width

        return (data + "\n").encode()

    @property
    def width(self):
        return sum(item.width for item in self.items)

    def move(self, offset):
        self.items.append(Move(offset))
        return self

    def colour(self, colour=None):
        self.items.append(Colour(colour))
        return self

    def background(self, colour=None):
        self.items.append(Background(colour))
        return self

    def text(self, text, colour=None, background=None):
        if (colour):
            self.colour(colour)
        if (background):
            self.background(background)

        self.items.append(Text(text))

        if (colour):
            self.colour()
        if (background):
            self.background()

        return self

    def image(self, image_file, background=False, overlay=False):
        if background:
            image = Image(image_file, ignore_background=True)

            self.background_image_file = image_file
            self.background_position = self.width

            self.items.append(image)
            self.move(-image.width)
        else:
            self.items.append(Image(image_file, overlay=overlay))
        return self

    def icon(self, icon_name):
        return self.image(
            os.path.join(PanelVisual.icon_path, icon_name + '.xpm'),
            overlay=True
        )

    def trim(self, width):
        for index in range(len(self.items) - 1, -1, -1):
            if width >= self.width:
                return self

            item = self.items[index]
            if 'trimmed' in dir(item):
                self.items[index:index + 1] = item.trimmed(
                    width - self.width + item.width
                ).items

        return self

    def set_width(self, width):
        self.trim(width)

        if self.width < width:
            return self.move(width - self.width)

        return self

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

        left = sum([
            PanelStrip().image(PanelVisual.background_image, background=True),
            PanelStrip().image(PanelVisual.logo_image).move(15),
            self.items['workspaces'],
            self.items['mode'],
            separator,
        ], PanelStrip())
        if self.items['notification']:
            right = sum([
                self.items['notification'],
                PanelStrip().move(15)
            ], PanelStrip()).trim(2 * (self.width // 3))
        else:
            right = sum([
                self.items['music'],
                PanelStrip().text(' >>> '),
                self.items['clock'],
                PanelStrip().text(' '),
                self.items['system_info']
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
