#include "push_swap.h"

static void	reverse_rotate(t_stack **stack)
{
	t_stack	*last;
	t_stack	*second_last;

	if (!*stack || !(*stack)->next)
		return ;
	second_last = NULL;
	last = *stack;
	while (last->next)
	{
		second_last = last;
		last = last->next;
	}
	if (second_last)
		second_last->next = NULL;
	last->next = *stack;
	*stack = last;
}

void	rra(t_data *data, int print)
{
	reverse_rotate(&data->a);
	data->op_count++;
	data->rra_count++;
	if (print)
		ft_putendl_fd("rra", 1);
}

void	rrb(t_data *data, int print)
{
	reverse_rotate(&data->b);
	data->op_count++;
	data->rrb_count++;
	if (print)
		ft_putendl_fd("rrb", 1);
}

void	rrr(t_data *data, int print)
{
	reverse_rotate(&data->a);
	reverse_rotate(&data->b);
	data->op_count++;
	data->rrr_count++;
	if (print)
		ft_putendl_fd("rrr", 1);
}
