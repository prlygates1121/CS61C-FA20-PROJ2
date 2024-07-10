# fa20-proj2-starter

```
.
├── inputs (test inputs)
├── outputs (some test outputs)
├── README.md
├── src
│   ├── argmax.s (partA)
│   ├── classify.s (partB)
│   ├── dot.s (partA)
│   ├── main.s (do not modify)
│   ├── matmul.s (partA)
│   ├── read_matrix.s (partB)
│   ├── relu.s (partA)
│   ├── utils.s (do not modify)
│   └── write_matrix.s (partB)
├── tools
│   ├── convert.py (convert matrix files for partB)
│   └── venus.jar (RISC-V simulator)
└── unittests
    ├── assembly (contains outputs from unittests.py)
    ├── framework.py (do not modify)
    └── unittests.py (partA + partB)
```


## Here's what I did in project 2:

### read_matrix
Below is the test function for `read_matrix`:
```python
def do_read_matrix(self, file_name, n_rows, n_cols, result, fail='', code=0):
    t = AssemblyTest(self, "read_matrix.s")
    # load address to the name of the input file into register a0
    t.input_read_filename("a0", "inputs/test_read_matrix/" + file_name)

    # allocate space to hold the rows and cols output parameters
    rows = t.array([-1])
    cols = t.array([-1])

    # load the addresses to the output parameters into the argument registers
    t.input_array("a1", rows)
    t.input_array("a2", cols)

    # call the read_matrix function
    t.call("read_matrix")

    # check the output from the function
    t.check_array(rows, n_rows)
    t.check_array(cols, n_cols)
    t.check_array_pointer("a0", result)  # stored somewhere in the heap memory, accessible via pointers

    # generate assembly and run it through venus
    t.execute(fail=fail, code=code)
```
Below is how we call the test function:
```python
def test_simple(self):
    self.do_read_matrix("test_input.bin", [3], [3], [1, 2, 3, 4, 5, 6, 7, 8, 9])
```
Since `a1`, `a2` are `int` pointers that will point to the number of rows and columns of the matrix, in the test function 
they are assigned with `t.array([-1])`, which essentially allocates the size of an integer for each of them. After the function
is executed, the values in the array they point to are updated and checked with `t.check_array(rows, n_rows)`.

`read_matrix` returns the address of the new matrix in heap memory in `a0`. Its content is checked with 
`t.check_array_pointer("a0", result)`, which first gets the array that `a0` points to and then compares it with the result array.

