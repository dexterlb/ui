from collections import defaultdict
import subprocess

from raster import Raster
from visual import PanelVisual

class Colour:
    width = 0
    def __init__(self, colour=None):
        if colour:
            self.panel_data = '^fg(' + str(colour) + ')'
        else:
            self.panel_data = '^fg()'

class Background:
    width = 0
    def __init__(self, colour=None):
        if colour:
            self.panel_data = '^bg(' + colour + ')^ib(0)'
        else:
            self.panel_data = '^bg()^ib(1)'

class Move:
    def __init__(self, offset):
        self.width = offset
        self.panel_data = '^p(' + str(offset) + ')'

class Text:
    def __init__(self, text):
        self.update(text)

    def update(self, text):
        self.text = text
        self.width = Raster.text_width(text)

    def trimmed(self, width):
        separator = PanelStrip().text('~/~', colour=PanelVisual.semiactive)

        if width < separator.width:
            return PanelStrip()

        if PanelVisual.char_width:
            side_chars = (width - separator.width) // (2 * PanelVisual.char_width)
            left_text = self.text[:side_chars]
            print(len(self.text), side_chars)
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

    @property
    def panel_data(self):
        return self.text.replace('^', '^^')

class Image:
    def __init__(self, image_file, ignore_background=False):
        self.width = Raster.image_width(image_file)
        self.panel_data = '^i(' + image_file + ')'
        if ignore_background:
            self.panel_data += '^ib(1)'


class PanelStrip:
    def __init__(self, key=None):
        self.key = key
        self.items = []

    def __repr__(self):
        return '<PanelStrip ' + str(self.key) + '>'

    def __add__(self, other):
        strip = PanelStrip()
        strip.items = self.items + other.items
        return strip

    def data(self):
        return (''.join(item.panel_data for item in self.items) + "\n").encode()

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

    def image(self, image_file, background=False):
        if background:
            image = Image(image_file, ignore_background=True)
            self.items.append(image)
            self.move(-image.width)
        else:
            self.items.append(Image(image_file))
        return self

    def trim(self, width):
        if width >= self.width:
            return self

        for index in range(len(self.items) - 1, -1, -1):
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
        '-h', str(PanelVisual.height)
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
        right = sum([
            PanelStrip().text("foobdafhsdjhfkjsdahfkjsdhakjfhsdjkhfkjdshjakfhsajkdhfjksadhfjksdahfjkhsdjkfhjksadhfjkshadjkfhsdkarbaz"),
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
        print(panel.data(), panel.width)
        self.dzen.stdin.flush()

    def start(self):
        self.dzen = subprocess.Popen(
            self.dzen_executable,
            stdin=subprocess.PIPE
        )
