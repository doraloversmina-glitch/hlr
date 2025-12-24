#include "checker_bonus.h"

static int	ft_strncmp(const char *s1, const char *s2, size_t n)
{
	size_t	i;

	i = 0;
	while (i < n && (s1[i] || s2[i]))
	{
		if (s1[i] != s2[i])
			return ((unsigned char)s1[i] - (unsigned char)s2[i]);
		i++;
	}
	return (0);
}

int	execute_operation(t_data *data, char *line)
{
	if (ft_strncmp(line, "sa\n", 3) == 0)
		sa(data, 0);
	else if (ft_strncmp(line, "sb\n", 3) == 0)
		sb(data, 0);
	else if (ft_strncmp(line, "ss\n", 3) == 0)
		ss(data, 0);
	else if (ft_strncmp(line, "pa\n", 3) == 0)
		pa(data, 0);
	else if (ft_strncmp(line, "pb\n", 3) == 0)
		pb(data, 0);
	else if (ft_strncmp(line, "ra\n", 3) == 0)
		ra(data, 0);
	else if (ft_strncmp(line, "rb\n", 3) == 0)
		rb(data, 0);
	else if (ft_strncmp(line, "rr\n", 3) == 0)
		rr(data, 0);
	else if (ft_strncmp(line, "rra\n", 4) == 0)
		rra(data, 0);
	else if (ft_strncmp(line, "rrb\n", 4) == 0)
		rrb(data, 0);
	else if (ft_strncmp(line, "rrr\n", 4) == 0)
		rrr(data, 0);
	else
		return (0);
	return (1);
}

int	read_and_execute(t_data *data)
{
	char	*line;

	line = get_next_line(0);
	while (line)
	{
		if (!execute_operation(data, line))
		{
			free(line);
			return (0);
		}
		free(line);
		line = get_next_line(0);
	}
	return (1);
}

static void	init_data(t_data *data)
{
	data->a = NULL;
	data->b = NULL;
	data->size = 0;
	data->disorder = 0.0;
	data->op_count = 0;
	data->sa_count = 0;
	data->sb_count = 0;
	data->ss_count = 0;
	data->pa_count = 0;
	data->pb_count = 0;
	data->ra_count = 0;
	data->rb_count = 0;
	data->rr_count = 0;
	data->rra_count = 0;
	data->rrb_count = 0;
	data->rrr_count = 0;
	data->bench_mode = 0;
	data->strategy_name = "Checker";
}

static int	has_duplicates_checker(t_stack *stack)
{
	t_stack	*current;
	t_stack	*compare;

	current = stack;
	while (current)
	{
		compare = current->next;
		while (compare)
		{
			if (current->value == compare->value)
				return (1);
			compare = compare->next;
		}
		current = current->next;
	}
	return (0);
}

static int	parse_single_arg_checker(t_data *data, char *arg)
{
	char	**numbers;
	int		i;
	long	num;
	t_stack	*new;

	numbers = ft_split(arg, ' ');
	if (!numbers)
		return (0);
	i = 0;
	while (numbers[i])
	{
		if (!validate_number(numbers[i]))
		{
			free_split(numbers);
			return (0);
		}
		num = ft_atol(numbers[i]);
		new = stack_new((int)num);
		if (!new)
		{
			free_split(numbers);
			return (0);
		}
		stack_add_back(&data->a, new);
		i++;
	}
	free_split(numbers);
	return (1);
}

static int	parse_checker_args(int argc, char **argv, t_data *data)
{
	int	i;

	i = 1;
	while (i < argc)
	{
		if (!parse_single_arg_checker(data, argv[i]))
			return (0);
		i++;
	}
	if (!data->a || has_duplicates_checker(data->a))
		return (0);
	data->size = stack_size(data->a);
	return (1);
}

int	main(int argc, char **argv)
{
	t_data	data;

	if (argc < 2)
		return (0);
	init_data(&data);
	if (!parse_checker_args(argc, argv, &data))
		error_exit(&data);
	if (!read_and_execute(&data))
	{
		ft_putendl_fd("Error", 2);
		stack_clear(&data.a);
		stack_clear(&data.b);
		return (1);
	}
	if (is_sorted(data.a) && !data.b)
		ft_putendl_fd("OK", 1);
	else
		ft_putendl_fd("KO", 1);
	stack_clear(&data.a);
	stack_clear(&data.b);
	return (0);
}
