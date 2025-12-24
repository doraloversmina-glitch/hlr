#include "push_swap.h"

int	find_min_pos(t_stack *stack)
{
	int		min;
	int		pos;
	int		min_pos;
	t_stack	*current;

	if (!stack)
		return (-1);
	min = stack->value;
	min_pos = 0;
	pos = 0;
	current = stack;
	while (current)
	{
		if (current->value < min)
		{
			min = current->value;
			min_pos = pos;
		}
		pos++;
		current = current->next;
	}
	return (min_pos);
}

int	find_max_pos(t_stack *stack)
{
	int		max;
	int		pos;
	int		max_pos;
	t_stack	*current;

	if (!stack)
		return (-1);
	max = stack->value;
	max_pos = 0;
	pos = 0;
	current = stack;
	while (current)
	{
		if (current->value > max)
		{
			max = current->value;
			max_pos = pos;
		}
		pos++;
		current = current->next;
	}
	return (max_pos);
}

void	sort_three(t_data *data)
{
	int	a;
	int	b;
	int	c;

	if (is_sorted(data->a))
		return ;
	a = data->a->value;
	b = data->a->next->value;
	c = data->a->next->next->value;
	if (a > b && b < c && a < c)
		sa(data, 1);
	else if (a > b && b > c)
	{
		sa(data, 1);
		rra(data, 1);
	}
	else if (a > b && b < c && a > c)
		ra(data, 1);
	else if (a < b && b > c && a < c)
	{
		sa(data, 1);
		ra(data, 1);
	}
	else if (a < b && b > c && a > c)
		rra(data, 1);
}

void	sort_five(t_data *data)
{
	int	min_pos;
	int	size;

	size = stack_size(data->a);
	while (size > 3)
	{
		min_pos = find_min_pos(data->a);
		if (min_pos <= size / 2)
		{
			while (min_pos-- > 0)
				ra(data, 1);
		}
		else
		{
			while (min_pos++ < size)
				rra(data, 1);
		}
		pb(data, 1);
		size--;
	}
	sort_three(data);
	while (data->b)
		pa(data, 1);
}
