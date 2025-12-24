# Push_swap

*This project has been created as part of the 42 curriculum by doraloversmina-glitch.*

## Description

Push_swap is an algorithm project that challenges you to sort data on a stack with a limited set of operations, using the lowest possible number of actions. The project requires implementing multiple sorting strategies with different complexity classes and selecting the most appropriate one based on the input characteristics.

### Project Goals

- Understand algorithmic complexity in practice (Big-O notation)
- Implement and compare different sorting algorithms
- Optimize performance under constraints
- Work with stack data structures using linked lists

## Instructions

### Compilation

```bash
# Compile the main program
make

# Compile the bonus checker
make bonus

# Clean object files
make clean

# Clean all compiled files
make fclean

# Recompile everything
make re
```

### Usage

```bash
# Basic usage with adaptive strategy (default)
./push_swap 4 67 3 87 23

# Force a specific strategy
./push_swap --simple 5 4 3 2 1
./push_swap --medium 5 4 3 2 1
./push_swap --complex 5 4 3 2 1
./push_swap --adaptive 5 4 3 2 1

# Enable benchmark mode
./push_swap --bench 4 67 3 87 23

# Combine strategy selector with benchmark
./push_swap --complex --bench 4 67 3 87 23

# Test with the checker (bonus)
./push_swap 4 67 3 87 23 | ./checker 4 67 3 87 23

# Count operations
./push_swap 4 67 3 87 23 | wc -l
```

### Performance Benchmarks

The implementation meets the following performance targets:

**For 100 random numbers:**
- Excellent: < 700 operations
- Good: < 1500 operations
- Pass: < 2000 operations

**For 500 random numbers:**
- Excellent: < 5500 operations
- Good: < 8000 operations
- Pass: < 12000 operations

## Algorithm Implementations

### 1. Simple Algorithm - O(n²)

**Implementation:** Selection Sort Adaptation

**How it works:**
- Repeatedly finds the minimum element in stack A
- Rotates it to the top
- Pushes it to stack B
- Finally pushes everything back to A in sorted order

**Best for:** Small datasets (< 10 elements)

**Complexity:**
- Time: O(n²) - Nested loops for finding minimum
- Space: O(1) - Only uses the two stacks

### 2. Medium Algorithm - O(n√n)

**Implementation:** Chunk-Based Sorting

**How it works:**
- Divides the stack into √n chunks based on indices
- Pushes elements to stack B chunk by chunk
- Always pushes back the largest element from B to A
- Results in partially sorted intermediate states

**Best for:** Medium-sized datasets (10-100 elements)

**Complexity:**
- Time: O(n√n) - √n chunks, each processed in O(n) time
- Space: O(1) - Only uses the two stacks

**Example with n=100:**
- Creates 10 chunks (√100 = 10)
- Each chunk contains ~10 elements
- Processes systematically for optimal operation count

### 3. Complex Algorithm - O(n log n)

**Implementation:** Radix Sort (LSD - Least Significant Digit)

**How it works:**
- Sorts numbers by processing bits from least to most significant
- For each bit position:
  - If bit is 0: push to B
  - If bit is 1: rotate in A
- After processing all elements, push everything back from B to A
- Repeat for each bit position (log₂n iterations)

**Best for:** Large datasets (> 100 elements)

**Complexity:**
- Time: O(n log n) - log₂n bit positions, each processed in O(n) time
- Space: O(1) - Only uses the two stacks

**Why Radix Sort:**
- Doesn't require comparisons
- Works perfectly with indexed values
- Very efficient for integer sorting with stack operations

### 4. Adaptive Algorithm - Custom Design

**Implementation:** Disorder-based Strategy Selection

**How it works:**

The adaptive algorithm measures the "disorder" of the input stack before sorting:

```
disorder = (number of inversions) / (total pairs)
```

An inversion is a pair of elements where a larger number appears before a smaller one.

**Strategy Selection:**

1. **Low Disorder (< 0.2) → O(n) approach**
   - Input is nearly sorted
   - Uses insertion-like approach
   - Only moves elements that are out of place
   - Minimal operations needed

2. **Medium Disorder (0.2 - 0.5) → O(n√n) approach**
   - Input has moderate randomness
   - Uses chunk-based sorting
   - Balances operation count and efficiency

3. **High Disorder (≥ 0.5) → O(n log n) approach**
   - Input is highly random or reverse-sorted
   - Uses radix sort
   - Most efficient for completely random data

4. **Special Cases:**
   - Already sorted: O(1) - no operations
   - 2-3 elements: O(1) - hardcoded optimal solutions
   - 4-5 elements: O(1) - optimized small sort

**Rationale:**
- Different disorder levels require different strategies
- Low disorder wastes operations with complex algorithms
- High disorder needs efficient sorting (radix)
- Adaptive approach achieves best average performance

**Complexity Targets:**
- Best case: O(1) for sorted or small inputs
- Low disorder: O(n) for nearly sorted
- Medium disorder: O(n√n) for moderate chaos
- High disorder: O(n log n) for random data

## Stack Operations

All sorting is performed using these operations:

- `sa` - swap first two elements of stack A
- `sb` - swap first two elements of stack B
- `ss` - sa and sb simultaneously
- `pa` - push first element of B to top of A
- `pb` - push first element of A to top of B
- `ra` - rotate A up (first becomes last)
- `rb` - rotate B up
- `rr` - ra and rb simultaneously
- `rra` - reverse rotate A (last becomes first)
- `rrb` - reverse rotate B
- `rrr` - rra and rrb simultaneously

## Data Structures

### Linked List Stack

```c
typedef struct s_stack
{
    int             value;      // The actual number
    int             index;      // Normalized index (0 to n-1)
    struct s_stack  *next;      // Next element in stack
}   t_stack;
```

**Why Linked Lists:**
- Efficient for stack operations (O(1) push/pop at head)
- Dynamic size allocation
- Easy rotation and reversal
- No need for array reallocation

### Data Structure

```c
typedef struct s_data
{
    t_stack *a;                 // Stack A
    t_stack *b;                 // Stack B
    int     size;               // Total elements
    double  disorder;           // Disorder metric (0-1)
    int     op_count;           // Total operations
    int     sa_count, sb_count, ss_count;   // Operation counts
    int     pa_count, pb_count;
    int     ra_count, rb_count, rr_count;
    int     rra_count, rrb_count, rrr_count;
    int     bench_mode;         // Benchmark flag
    char    *strategy_name;     // Selected strategy
}   t_data;
```

## Features

### Disorder Metric

The disorder calculation measures how "unsorted" the input is:

```c
double calculate_disorder(t_stack *stack)
{
    mistakes = 0;
    total_pairs = 0;

    for each pair (i, j) where i < j:
        total_pairs++;
        if stack[i] > stack[j]:
            mistakes++;

    return mistakes / total_pairs;
}
```

**Examples:**
- `[1, 2, 3, 4, 5]` → disorder = 0.0 (sorted)
- `[5, 4, 3, 2, 1]` → disorder = 1.0 (reverse sorted)
- `[2, 1, 4, 3, 5]` → disorder = 0.2 (nearly sorted)

### Benchmark Mode

When enabled with `--bench`, displays:
- Disorder percentage
- Selected strategy and complexity class
- Total operation count
- Individual operation counts

```bash
$ ./push_swap --bench 4 67 3 87 23
pb
ra
pb
pb
pa
pa
pa
[bench] disorder: 40.00%
[bench] strategy: Adaptive / O(n√n)
[bench] total_ops: 7
[bench] sa: 0 sb: 0 ss: 0 pa: 3 pb: 3
[bench] ra: 1 rb: 0 rr: 0 rra: 0 rrb: 0 rrr: 0
```

## Testing

### Basic Tests

```bash
# Test sorting 5 numbers
./push_swap 5 4 3 2 1 | ./checker 5 4 3 2 1

# Test with 100 random numbers
ARG=$(shuf -i 0-9999 -n 100 | tr '\n' ' '); ./push_swap $ARG | wc -l

# Test with 500 random numbers
ARG=$(shuf -i 0-9999 -n 500 | tr '\n' ' '); ./push_swap $ARG | wc -l
```

### Performance Testing Script

```bash
#!/bin/bash
# Test average performance over multiple runs

COUNT=10
SUM=0

for i in $(seq 1 $COUNT); do
    ARG=$(shuf -i 0-9999 -n 100 | tr '\n' ' ')
    OPS=$(./push_swap $ARG | wc -l)
    SUM=$((SUM + OPS))
    echo "Run $i: $OPS operations"
done

AVG=$((SUM / COUNT))
echo "Average: $AVG operations"
```

## Error Handling

The program handles errors correctly:

```bash
# Non-integer arguments
./push_swap 1 2 three
Error

# Duplicate numbers
./push_swap 1 2 2 3
Error

# Numbers out of int range
./push_swap 2147483648
Error

# Empty string
./push_swap ""
Error
```

## Resources

### Algorithm References

- **Big-O Notation:** "Introduction to Algorithms" by Cormen et al. (CLRS)
- **Radix Sort:** Knuth, "The Art of Computer Programming, Vol. 3"
- **Sorting Algorithms:** [Sorting Algorithm Animations](https://www.toptal.com/developers/sorting-algorithms)

### Project-Specific Resources

- [Push_swap Visualizer](https://github.com/o-reo/push_swap_visualizer)
- [42 Push_swap Tester](https://github.com/LeoFu9487/push_swap_tester)

### AI Usage

AI tools were used in the following ways during this project:

1. **Algorithm Research:**
   - Understanding radix sort adaptation for stacks
   - Exploring chunk-based sorting strategies
   - Reviewing Big-O complexity analysis

2. **Code Generation:**
   - Initial structure for stack operations
   - Parsing and validation logic patterns
   - Makefile template

3. **Testing:**
   - Test case generation ideas
   - Performance benchmarking approaches

4. **Documentation:**
   - README structure and formatting
   - Algorithm explanation clarity
   - Usage examples

**Note:** All AI-generated code was thoroughly reviewed, tested, and modified to ensure correctness and understanding. The core sorting logic and optimization strategies were designed and implemented with full comprehension.

## Contributors

- doraloversmina-glitch - Full implementation, algorithm design, testing, documentation

## License

This project is part of the 42 school curriculum and follows the school's academic policies.
