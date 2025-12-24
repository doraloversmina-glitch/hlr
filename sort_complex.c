#include "push_swap.h"

/*
** Complex O(n log n) Algorithm - Radix Sort (LSD)
** Sorts by processing bits from least significant to most significant
*/

static int	get_max_bits(int size)
{
	int	bits;

	bits = 0;
	while ((size - 1) >> bits)
		bits++;
	return (bits);
}

void	sort_complex(t_data *data)
{
	int	max_bits;
	int	i;
	int	j;
	int	size;

	data->strategy_name = "Complex / O(n log n)";
	if (is_sorted(data->a))
		return ;
	if (data->size <= 5)
	{
		sort_simple(data);
		return ;
	}
	max_bits = get_max_bits(data->size);
	i = 0;
	while (i < max_bits)
	{
		size = data->size;
		j = 0;
		while (j < size)
		{
			if (((data->a->index >> i) & 1) == 0)
				pb(data, 1);
			else
				ra(data, 1);
			j++;
		}
		while (data->b)
			pa(data, 1);
		i++;
	}
}
