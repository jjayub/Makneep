from __future__ import (absolute_import, division,
                        print_function, unicode_literals)
class Piece:
    def __init__(self, color, king=False):
        self.color = color
        self.king = king
