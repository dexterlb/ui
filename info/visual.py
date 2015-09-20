import os

class Visual:
    image_path = '../images/generated'

class PanelVisual:
    default = '#efebe5'
    semiactive = '#7cd4fc'
    active = '#ebac54'
    urgent = '#ff0000'

    height = 24

    font = '-*-droid sans mono-*-*-*-*-15-*-*-*-*-*-*-*'
    char_width = 9

    background_image = os.path.join(Visual.image_path, 'panel_background.xpm')
    logo_image = os.path.join(Visual.image_path, 'logo.xpm')
