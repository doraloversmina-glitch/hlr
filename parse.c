#include "push_swap.h"

void	error_exit(t_data *data)
{
	ft_putendl_fd("Error", 2);
	if (data)
	{
		stack_clear(&data->a);
		stack_clear(&data->b);
	}
	exit(1);
}

static int	has_duplicates(t_stack *stack)
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

void	assign_indices(t_data *data)
{
	t_stack	*current;
	t_stack	*compare;
	int		index;

	current = data->a;
	while (current)
	{
		index = 0;
		compare = data->a;
		while (compare)
		{
			if (compare->value < current->value)
				index++;
			compare = compare->next;
		}
		current->index = index;
		current = current->next;
	}
}

static int	add_number_to_stack(t_data *data, char *str)
{
	long	num;
	t_stack	*new;

	if (!validate_number(str))
		return (0);
	num = ft_atol(str);
	new = stack_new((int)num);
	if (!new)
		return (0);
	stack_add_back(&data->a, new);
	return (1);
}

static int	parse_single_arg(t_data *data, char *arg)
{
	char	**numbers;
	int		i;

	numbers = ft_split(arg, ' ');
	if (!numbers)
		return (0);
	i = 0;
	while (numbers[i])
	{
		if (!add_number_to_stack(data, numbers[i]))
		{
			free_split(numbers);
			return (0);
		}
		i++;
	}
	free_split(numbers);
	return (1);
}

int	parse_args(int argc, char **argv, t_data *data, t_strategy *strategy)
{
	int	i;
	int	start;

	*strategy = ADAPTIVE;
	start = 1;
	if (argc > 1 && argv[1][0] == '-' && argv[1][1] == '-')
	{
		if (ft_strcmp(argv[1], "--simple") == 0)
			*strategy = SIMPLE;
		else if (ft_strcmp(argv[1], "--medium") == 0)
			*strategy = MEDIUM;
		else if (ft_strcmp(argv[1], "--complex") == 0)
			*strategy = COMPLEX;
		else if (ft_strcmp(argv[1], "--adaptive") == 0)
			*strategy = ADAPTIVE;
		else if (ft_strcmp(argv[1], "--bench") != 0)
			return (0);
		if (ft_strcmp(argv[1], "--bench") == 0)
			data->bench_mode = 1;
		else
			start = 2;
		if (argc > 2 && ft_strcmp(argv[2], "--bench") == 0)
		{
			data->bench_mode = 1;
			start = 3;
		}
	}
	i = start;
	while (i < argc)
	{
		if (!parse_single_arg(data, argv[i]))
			return (0);
		i++;
	}
	if (!data->a || has_duplicates(data->a))
		return (0);
	data->size = stack_size(data->a);
	assign_indices(data);
	return (1);
}
