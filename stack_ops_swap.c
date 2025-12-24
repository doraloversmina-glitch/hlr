#include "push_swap.h"

static void	swap(t_stack **stack)
{
	t_stack	*first;
	t_stack	*second;

	if (!*stack || !(*stack)->next)
		return ;
	first = *stack;
	second = first->next;
	first->next = second->next;
	second->next = first;
	*stack = second;
}

void	sa(t_data *data, int print)
{
	swap(&data->a);
	data->op_count++;
	data->sa_count++;
	if (print)
		ft_putendl_fd("sa", 1);
}

void	sb(t_data *data, int print)
{
	swap(&data->b);
	data->op_count++;
	data->sb_count++;
	if (print)
		ft_putendl_fd("sb", 1);
}

void	ss(t_data *data, int print)
{
	swap(&data->a);
	swap(&data->b);
	data->op_count++;
	data->ss_count++;
	if (print)
		ft_putendl_fd("ss", 1);
}
