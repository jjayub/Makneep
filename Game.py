from __future__ import (absolute_import, division,
                        print_function, unicode_literals)
from UI import *
from Board import *
from game_init import *
from pygame.locals import *


class Game:
    def __init__(self):
        self.ui = UI(menu=True)
        self.board = Board()

        self.turn = BLUE
        self.selected_piece = None
        self.selected_legal_moves = []
        self.ai_turn = False
        self.ai = False

    def setup(self):
        """
        Set up game's window
        """
        self.ui.setup_window()

    def to_menu_page(self):
        """
        Chenge game page
        """
        self.ui = UI(menu=True)
        self.board = Board()
        self.turn = BLUE

    def new_game(self):
        """
        When press new game button
        """
        self.ui = UI()
        self.board.retract_board()
        self.board = Board()
        self.turn = BLUE
        self.selected_legal_moves = []
        self.selected_piece = None

    def menu_event_loop(self):
        logic = True
        while logic:
            mouse_pos = pygame.mouse.get_pos()

            for event in pygame.event.get():
                if event.type == QUIT:
                    self.terminate()
                elif event.type == MOUSEBUTTONDOWN:
                    if self.ui.menu_button_select(mouse_pos) == "human":
                        logic = False
                    elif self.ui.menu_button_select(mouse_pos) == "ai":
                        logic = False
                        self.play_ai()
                    elif self.ui.menu_button_select(mouse_pos) == "exit":
                        self.terminate()

    def game_event_loop(self):
        logic = True
        while logic:
            # Check mouse location on board
            self.mouse_pos = self.ui.piece_cell_coord(pygame.mouse.get_pos())
            self.raw_mouse_pos = pygame.mouse.get_pos()

            for event in pygame.event.get():
                if event.type == QUIT:
                    self.terminate()

                elif event.type == MOUSEBUTTONDOWN and self.ai_turn == False:
                    if self.ui.back_button_select(self.raw_mouse_pos):
                        self.ai_turn = False
                        self.ai = False
                        logic = False
                    elif self.ui.new_game_button_select(self.raw_mouse_pos):
                        self.new_game()
                    # if select something (which is on board)
                    elif self.click_on_board(self.raw_mouse_pos):
                        # if our turn select our piece, piece we click is now our selected piece
                        if self.select_our_piece():
                            self.selected_piece = self.mouse_pos
                            self.selected_legal_moves = self.board.get_move(self.selected_piece)
                        # else if we already select piece, move piece we selected before
                        elif self.move_selected_piece():
                            self.board.move_piece(self.selected_piece, self.mouse_pos)
                            if self.check_eat(self.mouse_pos, self.turn):
                                self.eat_piece(self.turn)
                            self.next_turn()
            self.update()  # Update display in-game

            if self.ai_turn and not self.is_end():
                self.ai_play()
            self.score()


    def score(self):
        red, blue = self.board.count_piece()

        self.ui.show_score(red, blue)

    def click_on_board(self, pos):
        x, y = pos
        if 30 <= x <= 830 and 28 <= y <= 828:
            return True
        return False

    def eat_piece(self, color):
        """
        Perform eating
        """
        self.board.eat_piece(color)

    def is_end(self):
        red, blue = self.board.count_piece()
        return red == 0 or blue == 0

    def check_eat(self, coord, turn):
        """
        Check whether it eats enemy?
        """
        return self.board.check_eat(coord, turn)

    def move_selected_piece(self):
        """
        Move piece we just selected
        """
        return self.selected_piece is not None and list(self.mouse_pos) in self.board.get_move(self.selected_piece)

    def select_our_piece(self):
        """
        Check whether the clicked piece is our
        """
        return self.board.location(self.mouse_pos) is not None and self.board.location(self.mouse_pos).color == self.turn

    def update(self):
        """
        Update Screen
        """
        self.ui.update_display(self.board, self.selected_legal_moves, self.selected_piece, self.turn)

    def next_turn(self):
        """
        End turn of each player
        """
        if self.turn == BLUE and self.ai:
            self.ai_turn = True
            self.turn = RED
        elif self.turn == BLUE:
            self.turn = RED
        else:
            self.turn = BLUE

        self.selected_piece = None
        self.selected_legal_moves = []
        self.check_game_over()

    def check_game_over(self):
        """
        Check if someone win, lose or draw
        """
        red, blue = self.board.count_piece()
        if blue == 0:
            self.ui.show_result("RED WIN!")
            self.turn = RED
        elif red == 0:
            self.ui.show_result("BLUE WIN!")
            self.turn = BLUE
        elif red == blue == 1:
            self.ui.show_result("DRAW!")

    def terminate(self):
        """
        Quit program
        """
        exit(1)

    def main_loop(self):
        self.setup()

        while True:
            self.menu_event_loop()  # event loop for menu

            self.new_game()  # Go to game page

            self.game_event_loop()  # event loop for game

            self.to_menu_page()  # Go to menu page

    def play_ai(self):
        """
        Play with AI
        """
        self.ai = True

    def ai_play(self):
        self.board.ai_move_prolog()
        self.turn = BLUE
        self.ai_turn = False
        self.check_game_over()
        self.update()


if __name__ == "__main__":
    game = Game()
    game.main_loop()
