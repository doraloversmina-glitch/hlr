#include "push_swap.h"

static void	init_data(t_data *data)
{
	data->a = NULL;
	data->b = NULL;
	data->size = 0;
	data->disorder = 0.0;
	data->op_count = 0;
	data->sa_count = 0;
	data->sb_count = 0;
	data->ss_count = 0;
	data->pa_count = 0;
	data->pb_count = 0;
	data->ra_count = 0;
	data->rb_count = 0;
	data->rr_count = 0;
	data->rra_count = 0;
	data->rrb_count = 0;
	data->rrr_count = 0;
	data->bench_mode = 0;
	data->strategy_name = "Unknown";
}

static void	execute_strategy(t_data *data, t_strategy strategy)
{
	if (strategy == SIMPLE)
		sort_simple(data);
	else if (strategy == MEDIUM)
		sort_medium(data);
	else if (strategy == COMPLEX)
		sort_complex(data);
	else
		sort_adaptive(data);
}

int	main(int argc, char **argv)
{
	t_data		data;
	t_strategy	strategy;

	if (argc < 2)
		return (0);
	init_data(&data);
	if (!parse_args(argc, argv, &data, &strategy))
		error_exit(&data);
	if (is_sorted(data.a))
	{
		stack_clear(&data.a);
		return (0);
	}
	assign_indices(&data);
	execute_strategy(&data, strategy);
	print_benchmark(&data);
	stack_clear(&data.a);
	stack_clear(&data.b);
	return (0);
}
