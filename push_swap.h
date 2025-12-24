#ifndef PUSH_SWAP_H
# define PUSH_SWAP_H

# include <stdlib.h>
# include <unistd.h>
# include <limits.h>

/* Structures */
typedef struct s_stack
{
	int				value;
	int				index;
	struct s_stack	*next;
}	t_stack;

typedef struct s_data
{
	t_stack	*a;
	t_stack	*b;
	int		size;
	double	disorder;
	int		op_count;
	int		sa_count;
	int		sb_count;
	int		ss_count;
	int		pa_count;
	int		pb_count;
	int		ra_count;
	int		rb_count;
	int		rr_count;
	int		rra_count;
	int		rrb_count;
	int		rrr_count;
	int		bench_mode;
	char	*strategy_name;
}	t_data;

typedef enum e_strategy
{
	ADAPTIVE,
	SIMPLE,
	MEDIUM,
	COMPLEX
}	t_strategy;

/* Stack operations */
void	sa(t_data *data, int print);
void	sb(t_data *data, int print);
void	ss(t_data *data, int print);
void	pa(t_data *data, int print);
void	pb(t_data *data, int print);
void	ra(t_data *data, int print);
void	rb(t_data *data, int print);
void	rr(t_data *data, int print);
void	rra(t_data *data, int print);
void	rrb(t_data *data, int print);
void	rrr(t_data *data, int print);

/* Stack utility functions */
t_stack	*stack_new(int value);
void	stack_add_back(t_stack **stack, t_stack *new);
void	stack_add_front(t_stack **stack, t_stack *new);
int		stack_size(t_stack *stack);
t_stack	*stack_last(t_stack *stack);
void	stack_clear(t_stack **stack);
int		is_sorted(t_stack *stack);

/* Input parsing */
int		parse_args(int argc, char **argv, t_data *data, t_strategy *strategy);
int		validate_number(char *str);
long	ft_atol(const char *str);
void	assign_indices(t_data *data);

/* Error handling */
void	error_exit(t_data *data);
void	free_split(char **split);

/* Disorder calculation */
double	calculate_disorder(t_stack *stack);

/* Sorting algorithms */
void	sort_simple(t_data *data);
void	sort_medium(t_data *data);
void	sort_complex(t_data *data);
void	sort_adaptive(t_data *data);

/* Helper algorithms */
void	sort_three(t_data *data);
void	sort_five(t_data *data);
int		find_min_pos(t_stack *stack);
int		find_max_pos(t_stack *stack);
int		get_target_pos(t_stack *a, int b_index, int target_index, int target_pos);

/* Utility functions */
char	**ft_split(char const *s, char c);
int		ft_strcmp(const char *s1, const char *s2);
void	ft_putstr_fd(char *s, int fd);
void	ft_putendl_fd(char *s, int fd);
void	ft_putnbr_fd(int n, int fd);

/* Benchmark */
void	print_benchmark(t_data *data);

#endif
