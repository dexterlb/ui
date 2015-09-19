import subprocess
from functools import lru_cache
from visual import PanelVisual

class Raster:
    @staticmethod
    def text_width(text):
        if PanelVisual.__dict__.get('char_width'):
            return PanelVisual.char_width * len(text)
        return int(subprocess.check_output(['text_width', PanelVisual.font, text]))

    @staticmethod
    @lru_cache()
    def image_size(image_file):
        with open(image_file + '.size', 'r') as f:
            width, height = f.read().split()
        return (int(width), int(height))

    @classmethod
    def image_width(cls, image_file):
        return cls.image_size(image_file)[0]
