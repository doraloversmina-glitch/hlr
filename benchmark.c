#include "push_swap.h"

static void	ft_putstr_stderr(char *s)
{
	ft_putstr_fd(s, 2);
}

static void	ft_putnbr_stderr(int n)
{
	ft_putnbr_fd(n, 2);
}

static void	print_disorder_percentage(double disorder)
{
	int	percentage;
	int	decimal;

	percentage = (int)(disorder * 100);
	decimal = (int)((disorder * 10000)) % 100;
	ft_putstr_stderr("[bench] disorder: ");
	ft_putnbr_stderr(percentage);
	ft_putstr_stderr(".");
	if (decimal < 10)
		ft_putstr_stderr("0");
	ft_putnbr_stderr(decimal);
	ft_putstr_stderr("%\n");
}

void	print_benchmark(t_data *data)
{
	if (!data->bench_mode)
		return ;
	print_disorder_percentage(data->disorder);
	ft_putstr_stderr("[bench] strategy: ");
	ft_putstr_stderr(data->strategy_name);
	ft_putstr_stderr("\n[bench] total_ops: ");
	ft_putnbr_stderr(data->op_count);
	ft_putstr_stderr("\n[bench] sa: ");
	ft_putnbr_stderr(data->sa_count);
	ft_putstr_stderr(" sb: ");
	ft_putnbr_stderr(data->sb_count);
	ft_putstr_stderr(" ss: ");
	ft_putnbr_stderr(data->ss_count);
	ft_putstr_stderr(" pa: ");
	ft_putnbr_stderr(data->pa_count);
	ft_putstr_stderr(" pb: ");
	ft_putnbr_stderr(data->pb_count);
	ft_putstr_stderr("\n[bench] ra: ");
	ft_putnbr_stderr(data->ra_count);
	ft_putstr_stderr(" rb: ");
	ft_putnbr_stderr(data->rb_count);
	ft_putstr_stderr(" rr: ");
	ft_putnbr_stderr(data->rr_count);
	ft_putstr_stderr(" rra: ");
	ft_putnbr_stderr(data->rra_count);
	ft_putstr_stderr(" rrb: ");
	ft_putnbr_stderr(data->rrb_count);
	ft_putstr_stderr(" rrr: ");
	ft_putnbr_stderr(data->rrr_count);
	ft_putstr_stderr("\n");
}
