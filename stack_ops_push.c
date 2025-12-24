#include "push_swap.h"

static void	push(t_stack **src, t_stack **dst)
{
	t_stack	*tmp;

	if (!*src)
		return ;
	tmp = *src;
	*src = (*src)->next;
	tmp->next = *dst;
	*dst = tmp;
}

void	pa(t_data *data, int print)
{
	push(&data->b, &data->a);
	data->op_count++;
	data->pa_count++;
	if (print)
		ft_putendl_fd("pa", 1);
}

void	pb(t_data *data, int print)
{
	push(&data->a, &data->b);
	data->op_count++;
	data->pb_count++;
	if (print)
		ft_putendl_fd("pb", 1);
}
