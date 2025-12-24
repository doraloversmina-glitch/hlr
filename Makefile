# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: push_swap project                         +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/12/24                            #+#    #+#              #
#    Updated: 2025/12/24                           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = push_swap
BONUS_NAME = checker

CC = cc
CFLAGS = -Wall -Wextra -Werror
RM = rm -f

# Source files
SRCS = main.c \
       parse.c \
       stack_utils.c \
       stack_ops_push.c \
       stack_ops_swap.c \
       stack_ops_rotate.c \
       stack_ops_reverse_rotate.c \
       utils.c \
       ft_split.c \
       disorder.c \
       sort_simple.c \
       sort_medium.c \
       sort_complex.c \
       sort_adaptive.c \
       sort_helpers.c \
       benchmark.c

BONUS_SRCS = checker_bonus.c \
             get_next_line_bonus.c \
             parse.c \
             stack_utils.c \
             stack_ops_push.c \
             stack_ops_swap.c \
             stack_ops_rotate.c \
             stack_ops_reverse_rotate.c \
             utils.c \
             ft_split.c

# Object files
OBJS = $(SRCS:.c=.o)
BONUS_OBJS = $(BONUS_SRCS:.c=.o)

# Colors
GREEN = \033[0;32m
RED = \033[0;31m
RESET = \033[0m

# Rules
all: $(NAME)

$(NAME): $(OBJS)
	@$(CC) $(CFLAGS) $(OBJS) -o $(NAME) -lm
	@echo "$(GREEN)✓ $(NAME) compiled successfully!$(RESET)"

bonus: $(BONUS_NAME)

$(BONUS_NAME): $(BONUS_OBJS)
	@$(CC) $(CFLAGS) $(BONUS_OBJS) -o $(BONUS_NAME) -lm
	@echo "$(GREEN)✓ $(BONUS_NAME) compiled successfully!$(RESET)"

%.o: %.c
	@$(CC) $(CFLAGS) -c $< -o $@

clean:
	@$(RM) $(OBJS) $(BONUS_OBJS)
	@echo "$(RED)✗ Object files removed$(RESET)"

fclean: clean
	@$(RM) $(NAME) $(BONUS_NAME)
	@echo "$(RED)✗ Executables removed$(RESET)"

re: fclean all

.PHONY: all bonus clean fclean re
