#include "push_swap.h"

static void	rotate(t_stack **stack)
{
	t_stack	*first;
	t_stack	*last;

	if (!*stack || !(*stack)->next)
		return ;
	first = *stack;
	last = stack_last(*stack);
	*stack = first->next;
	first->next = NULL;
	last->next = first;
}

void	ra(t_data *data, int print)
{
	rotate(&data->a);
	data->op_count++;
	data->ra_count++;
	if (print)
		ft_putendl_fd("ra", 1);
}

void	rb(t_data *data, int print)
{
	rotate(&data->b);
	data->op_count++;
	data->rb_count++;
	if (print)
		ft_putendl_fd("rb", 1);
}

void	rr(t_data *data, int print)
{
	rotate(&data->a);
	rotate(&data->b);
	data->op_count++;
	data->rr_count++;
	if (print)
		ft_putendl_fd("rr", 1);
}
