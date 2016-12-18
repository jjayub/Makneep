from __future__ import (absolute_import, division,
                        print_function, unicode_literals)
from Board import *


class UI:
    def __init__(self, menu=False):
        self.caption = "Mak neep"

        self.font_obj = pygame.font.Font('freesansbold.ttf', 100)
        self.score_red = self.font_obj.render("0", True, BLACK, RED)
        self.score_red_obj = self.score_red.get_rect()
        self.score_red_obj.center = (1085, 730)

        self.score_blue = self.font_obj.render("0", True, BLACK, RED)
        self.score_blue_obj = self.score_blue.get_rect()
        self.score_blue_obj.center = (1085, 785)

        if not menu:
            self.fps = 60
            self.clock = pygame.time.Clock()

            self.window_size = 800
            self.screen = pygame.display.set_mode((1181, 858))
            # self.screen = pygame.display.set_mode((800, 800))
            self.background = pygame.image.load('images/board_page.png')

            self.square_size = self.window_size // 8
            self.piece_size = self.square_size // 2

            self.message = False
        else:
            self.window_size = 850
            self.screen = pygame.display.set_mode((self.window_size, self.window_size))
            self.background = pygame.image.load('images/board_menu.png')

            # Display menu right away
            self.setup_window()
            self.screen.blit(self.background, (0, 0))
            pygame.display.update()

    def setup_window(self):
        """
        Set up the window
        """
        pygame.init()
        pygame.display.set_caption(self.caption)

    def update_display(self, board, legal_moves, selected_piece, turn):
        """
        Update Screen
        """
        self.screen.blit(self.background, (0, 0))

        self.square_select(legal_moves, selected_piece)
        self.draw_board_pieces(board, turn)

        if self.message:
            self.screen.blit(self.text_surface_obj, self.text_rect_obj)
        self.screen.blit(self.score_red, self.score_red_obj)
        self.screen.blit(self.score_blue, self.score_blue_obj)

        pygame.display.update()
        self.clock.tick(self.fps)

    def show_score(self, red, blue):
        self.font_obj = pygame.font.Font('freesansbold.ttf', 50)
        self.score_red = self.font_obj.render(str(red), True, BLACK, RED)
        self.score_blue = self.font_obj.render(str(blue), True, BLACK, RED)


    def menu_button_select(self, pos):
        x, y = pos
        if 200 <= x <= 650:
            if 70 <= y <= 270:
                return "ai"
            elif 325 <= y <= 525:
                return "human"
            elif 580 <= y <= 780:
                return "exit"
        else:
            return ""

    def back_button_select(self, pos):
        x, y = pos
        if 900 <= x <= 1120 and 60 <= y <= 160:
            return True
        return False

    def new_game_button_select(self, pos):
        x, y = pos
        if 895 <= x <= 1125 and 195 <= y <= 305:
            return True
        return False

    def square_select(self, possible_squares, selected_square):
        """
        Show square selected
        """
        # show all valid tile
        for square in possible_squares:
            pygame.draw.rect(self.screen, SELECT, (square[0] * self.square_size + 30, square[1] * self.square_size + 28, self.square_size, self.square_size))

        # show only selected piece
        if selected_square is not None:
            pygame.draw.rect(self.screen, SELECT, (selected_square[0] * self.square_size + 30, selected_square[1] * self.square_size + 28, self.square_size, self.square_size))

    def draw_board_pieces(self, board, turn):
        """
        Draw all pieces on board
        """
        for row in range(8):
            for col in range(8):
                if board.board[row][col] is not None:
                    pygame.draw.circle(self.screen, (board.board[row][col]).color, self.piece_center_coord(col, row), self.piece_size)

        pygame.draw.circle(self.screen, turn, (1010, 540), self.piece_size + 20)

    def piece_center_coord(self, x, y):
        """
        Find center of that piece
        Mainly for draw circle piece
        """
        return (x * self.square_size + self.piece_size + 30, y * self.square_size + self.piece_size + 28)

    def piece_cell_coord(self, pos):
        """
        Find cell coordinate of that piece
        """
        x, y = pos
        return ((x - 30) // self.square_size, (y - 28) // self.square_size)

    def show_result(self, message):
        """
        Show win/lose/draw result
        """
        self.message = True
        self.font_obj = pygame.font.Font('freesansbold.ttf', 100)
        self.text_surface_obj = self.font_obj.render(message, True, BLACK, GOLD)
        self.text_rect_obj = self.text_surface_obj.get_rect()
        self.text_rect_obj.center = (1181 / 2, 858 / 2)
