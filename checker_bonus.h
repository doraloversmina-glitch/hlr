#ifndef CHECKER_BONUS_H
# define CHECKER_BONUS_H

# include "push_swap.h"

# define BUFFER_SIZE 10

/* Get next line */
char	*get_next_line(int fd);
char	*ft_strjoin(char *s1, char *s2);
char	*ft_strchr(const char *s, int c);
size_t	ft_strlen(const char *s);

/* Checker operations */
int		execute_operation(t_data *data, char *line);
int		read_and_execute(t_data *data);

#endif
