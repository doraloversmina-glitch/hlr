#include "push_swap.h"
#include <math.h>

/*
** Medium O(n√n) Algorithm - Chunk-Based Sorting
** Divides the stack into √n chunks and processes them efficiently
*/

static int	find_cheapest_in_range(t_stack *stack, int min, int max)
{
	t_stack	*current;
	int		pos;

	current = stack;
	pos = 0;
	while (current)
	{
		if (current->index >= min && current->index <= max)
			return (pos);
		pos++;
		current = current->next;
	}
	return (-1);
}

static void	push_chunk_to_b(t_data *data, int min, int max)
{
	int	size;
	int	pos;

	while (1)
	{
		size = stack_size(data->a);
		pos = find_cheapest_in_range(data->a, min, max);
		if (pos == -1)
			break ;
		if (pos <= size / 2)
		{
			while (pos-- > 0)
				ra(data, 1);
		}
		else
		{
			while (pos++ < size)
				rra(data, 1);
		}
		pb(data, 1);
	}
}

static void	push_back_sorted(t_data *data)
{
	int	max_pos;
	int	size;

	while (data->b)
	{
		size = stack_size(data->b);
		max_pos = find_max_pos(data->b);
		if (max_pos <= size / 2)
		{
			while (max_pos-- > 0)
				rb(data, 1);
		}
		else
		{
			while (max_pos++ < size)
				rrb(data, 1);
		}
		pa(data, 1);
	}
}

void	sort_medium(t_data *data)
{
	int	chunk_size;
	int	num_chunks;
	int	i;
	int	min;
	int	max;

	data->strategy_name = "Medium / O(n√n)";
	if (is_sorted(data->a))
		return ;
	if (data->size <= 5)
	{
		sort_simple(data);
		return ;
	}
	num_chunks = (int)sqrt(data->size);
	if (num_chunks < 2)
		num_chunks = 2;
	chunk_size = data->size / num_chunks;
	i = 0;
	while (i < num_chunks)
	{
		min = i * chunk_size;
		max = (i + 1) * chunk_size - 1;
		if (i == num_chunks - 1)
			max = data->size - 1;
		push_chunk_to_b(data, min, max);
		i++;
	}
	push_back_sorted(data);
}
