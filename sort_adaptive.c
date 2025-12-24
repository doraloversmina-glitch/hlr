#include "push_swap.h"

/*
** Adaptive Algorithm - Selects strategy based on disorder metric
** Low disorder (< 0.2): O(n) - optimized for nearly sorted
** Medium disorder (0.2-0.5): O(n√n) - chunk-based
** High disorder (>= 0.5): O(n log n) - radix sort
*/

static void	sort_low_disorder(t_data *data)
{
	int	size;
	int	min_pos;

	/* For low disorder, use insertion-like approach - O(n) for nearly sorted */
	data->strategy_name = "Adaptive / O(n)";
	size = stack_size(data->a);
	while (!is_sorted(data->a) && size > 0)
	{
		min_pos = find_min_pos(data->a);
		if (min_pos == 0)
		{
			pb(data, 1);
			size--;
		}
		else if (min_pos <= size / 2)
			ra(data, 1);
		else
			rra(data, 1);
	}
	while (data->b)
		pa(data, 1);
}

static void	sort_medium_disorder(t_data *data)
{
	/* Use chunk-based sorting for medium disorder */
	data->strategy_name = "Adaptive / O(n√n)";
	sort_medium(data);
}

static void	sort_high_disorder(t_data *data)
{
	/* Use radix sort for high disorder */
	data->strategy_name = "Adaptive / O(n log n)";
	sort_complex(data);
}

void	sort_adaptive(t_data *data)
{
	if (is_sorted(data->a))
	{
		data->strategy_name = "Adaptive / O(1) - Already Sorted";
		return ;
	}
	if (data->size <= 3)
	{
		data->strategy_name = "Adaptive / O(1) - Small Stack";
		sort_three(data);
		return ;
	}
	if (data->size <= 5)
	{
		data->strategy_name = "Adaptive / O(1) - Small Stack";
		sort_five(data);
		return ;
	}
	data->disorder = calculate_disorder(data->a);
	if (data->disorder < 0.2)
		sort_low_disorder(data);
	else if (data->disorder < 0.5)
		sort_medium_disorder(data);
	else
		sort_high_disorder(data);
}
