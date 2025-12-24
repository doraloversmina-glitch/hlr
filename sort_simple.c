#include "push_swap.h"

/*
** Simple O(n²) Algorithm - Selection Sort Adaptation
** Repeatedly finds minimum and pushes to stack B, then pushes all back
*/

void	sort_simple(t_data *data)
{
	int	size;
	int	min_pos;
	int	i;

	data->strategy_name = "Simple / O(n²)";
	if (is_sorted(data->a))
		return ;
	if (data->size == 2)
	{
		sa(data, 1);
		return ;
	}
	if (data->size == 3)
	{
		sort_three(data);
		return ;
	}
	if (data->size <= 5)
	{
		sort_five(data);
		return ;
	}
	size = data->size;
	i = 0;
	while (i < size)
	{
		min_pos = find_min_pos(data->a);
		if (min_pos <= stack_size(data->a) / 2)
		{
			while (min_pos-- > 0)
				ra(data, 1);
		}
		else
		{
			while (min_pos++ < stack_size(data->a))
				rra(data, 1);
		}
		pb(data, 1);
		i++;
	}
	while (data->b)
		pa(data, 1);
}
