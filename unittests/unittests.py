from unittest import TestCase
from framework import AssemblyTest, print_coverage


class TestAbs(TestCase):
    def test_zero(self):
        t = AssemblyTest(self, "abs.s")
        # load 0 into register a0
        t.input_scalar("a0", 0)
        # call the abs function
        t.call("abs")
        # check that after calling abs, a0 is equal to 0 (abs(0) = 0)
        t.check_scalar("a0", 0)
        # generate the `assembly/TestAbs_test_zero.s` file and run it through venus
        t.execute()

    def test_one(self):
        # same as test_zero, but with input 1
        t = AssemblyTest(self, "abs.s")
        t.input_scalar("a0", 1)
        t.call("abs")
        t.check_scalar("a0", 1)
        t.execute()

    def test_minus_one(self):
        t = AssemblyTest(self, "abs.s")
        t.input_scalar("a0", -1)
        t.call("abs")
        t.check_scalar("a0", 1)
        t.execute()

    @classmethod
    def tearDownClass(cls):
        print_coverage("abs.s", verbose=False)


class TestRelu(TestCase):
    def test_simple(self):
        t = AssemblyTest(self, "relu.s")
        # create an array in the data section
        array0 = t.array([1, -2, 3, 0, 5, -6, 7, -8, 9])
        # load address of `array0` into register a0
        t.input_array("a0", array0)
        # set a1 to the length of our array
        t.input_scalar("a1", len(array0))
        # call the relu function
        t.call("relu")
        # check that the array0 was changed appropriately
        t.check_array(array0, [1, 0, 3, 0, 5, 0, 7, 0, 9])
        # generate the `assembly/TestRelu_test_simple.s` file and run it through venus
        t.execute()

    def test_exception(self):
        t = AssemblyTest(self, "relu.s")
        # create an array in the data section
        array0 = t.array([])
        # load address of `array0` into register a0
        t.input_array("a0", array0)
        # set a1 to the length of our array
        t.input_scalar("a1", len(array0))
        # call the relu function
        t.call("relu")
        # generate the `assembly/TestRelu_test_simple.s` file and run it through venus
        t.execute(code=78)

    @classmethod
    def tearDownClass(cls):
        print_coverage("relu.s", verbose=False)


class TestArgmax(TestCase):
    def test_simple(self):
        t = AssemblyTest(self, "argmax.s")
        # create an array in the data section
        array0 = t.array([-2, 0, 0, 9, 9, -1])
        # load address of the array into register a0
        t.input_array("a0", array0)
        # set a1 to the length of the array
        t.input_scalar("a1", len(array0))
        # call the `argmax` function
        t.call("argmax")
        # check that the register a0 contains the correct output
        t.check_scalar("a0", 3)
        # generate the `assembly/TestArgmax_test_simple.s` file and run it through venus
        t.execute()

    def test_exception(self):
        t = AssemblyTest(self, "argmax.s")
        # create an array in the data section
        array0 = t.array([])
        # load address of the array into register a0
        t.input_array("a0", array0)
        # set a1 to the length of the array
        t.input_scalar("a1", len(array0))
        # call the `argmax` function
        t.call("argmax")
        # generate the `assembly/TestArgmax_test_simple.s` file and run it through venus
        t.execute(code=77)

    @classmethod
    def tearDownClass(cls):
        print_coverage("argmax.s", verbose=False)


class TestDot(TestCase):
    def test_simple(self):
        t = AssemblyTest(self, "dot.s")
        # create arrays in the data section
        array0 = t.array([1, 2, 3, -4])
        array1 = t.array([2, 3, -4, 5])
        # load array addresses into argument registers
        t.input_array("a0", array0)
        t.input_array("a1", array1)
        # load array attributes into argument registers
        t.input_scalar("a2", len(array0))
        t.input_scalar("a3", 1)
        t.input_scalar("a4", 1)
        # call the `dot` function
        t.call("dot")
        # check the return value
        t.check_scalar("a0", -24)
        t.execute()

    def test_stride(self):
        t = AssemblyTest(self, "dot.s")
        # create arrays in the data section
        array0 = t.array([1, 1, 1, 1, 1])
        array1 = t.array([2, 3, -4, 5, 8])
        # load array addresses into argument registers
        t.input_array("a0", array0)
        t.input_array("a1", array1)
        # load array attributes into argument registers
        t.input_scalar("a2", 3)
        t.input_scalar("a3", 2)
        t.input_scalar("a4", 2)
        # call the `dot` function
        t.call("dot")
        # check the return value
        t.check_scalar("a0", 6)
        t.execute()

    def test_stride_2(self):
        t = AssemblyTest(self, "dot.s")
        # create arrays in the data section
        array0 = t.array([1, 2, 3, 4, 5, 6, 7, 8, 9])
        array1 = t.array([1, 2, 3, 4, 5, 6, 7, 8, 9])
        # load array addresses into argument registers
        t.input_array("a0", array0)
        t.input_array("a1", array1)
        # load array attributes into argument registers
        t.input_scalar("a2", 3)
        t.input_scalar("a3", 1)
        t.input_scalar("a4", 3)
        # call the `dot` function
        t.call("dot")
        # check the return value
        t.check_scalar("a0", 30)
        t.execute()

    def test_stride_3(self):
        t = AssemblyTest(self, "dot.s")
        # create arrays in the data section
        array0 = t.array([4, 5, 6, 7, 8, 9])
        array1 = t.array([1, 2, 3, 4, 5, 6, 7, 8, 9])
        # load array addresses into argument registers
        t.input_array("a0", array0)
        t.input_array("a1", array1)
        # load array attributes into argument registers
        t.input_scalar("a2", 3)
        t.input_scalar("a3", 1)
        t.input_scalar("a4", 3)
        # call the `dot` function
        t.call("dot")
        # check the return value
        t.check_scalar("a0", 66)
        t.execute()

    def test_stride_4(self):
        t = AssemblyTest(self, "dot.s")
        # create arrays in the data section
        array0 = t.array([4, 5, 6, 7, 8, 9])
        array1 = t.array([2, 3, 4, 5, 6, 7, 8, 9])
        # load array addresses into argument registers
        t.input_array("a0", array0)
        t.input_array("a1", array1)
        # load array attributes into argument registers
        t.input_scalar("a2", 3)
        t.input_scalar("a3", 1)
        t.input_scalar("a4", 3)
        # call the `dot` function
        t.call("dot")
        # check the return value
        t.check_scalar("a0", 81)
        t.execute()

    def test_stride_5(self):
        t = AssemblyTest(self, "dot.s")
        # create arrays in the data section
        array0 = t.array([7, 8, 9])
        array1 = t.array([2, 3, 4, 5, 6, 7, 8, 9])
        # load array addresses into argument registers
        t.input_array("a0", array0)
        t.input_array("a1", array1)
        # load array attributes into argument registers
        t.input_scalar("a2", 3)
        t.input_scalar("a3", 1)
        t.input_scalar("a4", 3)
        # call the `dot` function
        t.call("dot")
        # check the return value
        t.check_scalar("a0", 126)
        t.execute()

    def test_75(self):
        t = AssemblyTest(self, "dot.s")
        # create arrays in the data section
        array0 = t.array([])
        array1 = t.array([2, 3, -4, 5])
        # load array addresses into argument registers
        t.input_array("a0", array0)
        t.input_array("a1", array1)
        # load array attributes into argument registers
        t.input_scalar("a2", len(array0))
        t.input_scalar("a3", 1)
        t.input_scalar("a4", 1)
        # call the `dot` function
        t.call("dot")
        t.execute(code=75)

    def test_76(self):
        t = AssemblyTest(self, "dot.s")
        # create arrays in the data section
        array0 = t.array([4, 4, 4, 4])
        array1 = t.array([2, 3, -4, 5])
        # load array addresses into argument registers
        t.input_array("a0", array0)
        t.input_array("a1", array1)
        # load array attributes into argument registers
        t.input_scalar("a2", len(array0))
        t.input_scalar("a3", 7)
        t.input_scalar("a4", 0)
        # call the `dot` function
        t.call("dot")
        t.execute(code=76)

    @classmethod
    def tearDownClass(cls):
        print_coverage("dot.s", verbose=False)


class TestMatmul(TestCase):

    def do_matmul(self, m0, m0_rows, m0_cols, m1, m1_rows, m1_cols, result, code=0):
        t = AssemblyTest(self, "matmul.s")
        # we need to include (aka import) the dot.s file since it is used by matmul.s
        t.include("dot.s")

        # create arrays for the arguments and to store the result
        array0 = t.array(m0)
        array1 = t.array(m1)
        array_out = t.array([0] * len(result))

        # load address of input matrices and set their dimensions
        t.input_array("a0", array0)
        t.input_scalar("a1", m0_rows)
        t.input_scalar("a2", m0_cols)
        t.input_array("a3", array1)
        t.input_scalar("a4", m1_rows)
        t.input_scalar("a5", m1_cols)
        # load address of output array
        t.input_array("a6", array_out)

        # call the matmul function
        t.call("matmul")

        # check the content of the output array
        t.check_array(array_out, result)

        # generate the assembly file and run it through venus, we expect the simulation to exit with code `code`
        t.execute(code=code)

    def test_simple(self):
        self.do_matmul(
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3,
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3,
            [30, 36, 42, 66, 81, 96, 102, 126, 150]
        )

    def test_72(self):
        self.do_matmul(
            [], 0, 0,
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3,
            [0, 0, 0, 0, 0, 0, 0, 0, 0], code=72
        )

    def test_73(self):
        self.do_matmul(
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3,
            [], 0, 0,
            [0, 0, 0, 0, 0, 0, 0, 0, 0], code=73
        )

    def test_74(self):
        self.do_matmul(
            [1, 2, 3], 1, 3,
            [1, 2, 3], 1, 3,
            [0, 0, 0, 0, 0, 0, 0, 0, 0], code=74
        )

    def test_non_square(self):
        self.do_matmul(
            [1, 2, 3], 1, 3,
            [1, 2, 3], 3, 1,
            [14]
        )

    def test_non_square_2(self):
        self.do_matmul(
            [1, 2, 3], 1, 3,
            [1, 2, 3, 4, 5, 6, 3, 4, 5, 6, 9, 2, 1, 0, 7], 3, 5,
            [40, 14, 14, 14, 38]
        )

    def test_non_square_3(self):
        self.do_matmul(
            [1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3,
            [1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3], 3, 4,
            [38, 17, 23, 29, 83, 44, 59, 74, 128, 71, 95, 119]
        )

    @classmethod
    def tearDownClass(cls):
        print_coverage("matmul.s", verbose=False)


class TestReadMatrix(TestCase):

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

    def test_simple(self):
        self.do_read_matrix("test_input.bin", [3], [3], [1, 2, 3, 4, 5, 6, 7, 8, 9])

    def test_simple_2(self):
        self.do_read_matrix("test_input_2.bin", [2], [9],
                            [1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16, 17, 18, 19])

    def test_fopen_90(self):
        self.do_read_matrix("test_input.bin", [3], [3], [1, 2, 3, 4, 5, 6, 7, 8, 9], "fopen", 90)

    def test_malloc_88(self):
        self.do_read_matrix("test_input.bin", [3], [3], [1, 2, 3, 4, 5, 6, 7, 8, 9], "malloc", 88)

    def test_fread_91(self):
        self.do_read_matrix("test_input.bin", [3], [3], [1, 2, 3, 4, 5, 6, 7, 8, 9], "fread", 91)

    def test_fclose_92(self):
        self.do_read_matrix("test_input.bin", [3], [3], [1, 2, 3, 4, 5, 6, 7, 8, 9], "fclose", 92)

    @classmethod
    def tearDownClass(cls):
        print_coverage("read_matrix.s", verbose=False)


class TestWriteMatrix(TestCase):

    def do_write_matrix(self, matrix, n_rows, n_cols, output, expected, fail='', code=0):
        t = AssemblyTest(self, "write_matrix.s")
        outfile = "outputs/test_write_matrix/" + output
        # load output file name into a0 register
        t.input_write_filename("a0", outfile)
        # load input array and other arguments
        t.input_array("a1", t.array(matrix))
        t.input_scalar("a2", n_rows)
        t.input_scalar("a3", n_cols)
        # call `write_matrix` function
        t.call("write_matrix")
        # generate assembly and run it through venus
        t.execute(fail=fail, code=code)
        if fail=='':
            # compare the output file against the reference
            t.check_file_output(outfile, "outputs/test_write_matrix/" + expected)



    def test_simple(self):
        self.do_write_matrix([1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3, "student.bin", "reference.bin")

    def test_simple_2(self):
        self.do_write_matrix([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
                              25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36], 9, 4,
                             "student_2.bin", "reference_2.bin")

    def test_fopen_93(self):
        self.do_write_matrix([1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3, "outFail", "exFail",
                             "fopen", 93)

    def test_fwrite_94(self):
        self.do_write_matrix([1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3, "outFail", "exFail",
                             "fwrite", 94)

    def test_fclose_95(self):
        self.do_write_matrix([1, 2, 3, 4, 5, 6, 7, 8, 9], 3, 3, "outFail", "exFail",
                             "fclose", 95)

    @classmethod
    def tearDownClass(cls):
        print_coverage("write_matrix.s", verbose=False)


class TestClassify(TestCase):

    def make_test(self):
        t = AssemblyTest(self, "classify.s")
        t.include("argmax.s")
        t.include("dot.s")
        t.include("matmul.s")
        t.include("read_matrix.s")
        t.include("relu.s")
        t.include("write_matrix.s")
        return t

    def test_simple0_input0(self):
        t = self.make_test()
        out_file = "outputs/test_basic_main/student0.bin"
        ref_file = "outputs/test_basic_main/reference0.bin"
        args = ["inputs/simple0/bin/m0.bin", "inputs/simple0/bin/m1.bin",
                "inputs/simple0/bin/inputs/input0.bin", out_file]
        # call classify function
        t.call("classify")
        # generate assembly and pass program arguments directly to venus
        t.execute(args=args)

        # compare the output file and
        raise NotImplementedError("TODO")
        # TODO
        # compare the classification output with `check_stdout`

    @classmethod
    def tearDownClass(cls):
        print_coverage("classify.s", verbose=False)


class TestMain(TestCase):

    def run_main(self, inputs, output_id, label):
        args = [f"{inputs}/m0.bin", f"{inputs}/m1.bin", f"{inputs}/inputs/input0.bin",
                f"outputs/test_basic_main/student{output_id}.bin"]
        reference = f"outputs/test_basic_main/reference{output_id}.bin"
        t = AssemblyTest(self, "main.s", no_utils=True)
        t.call("main")
        t.execute(args=args, verbose=False)
        t.check_stdout(label)
        t.check_file_output(args[-1], reference)

    def test0(self):
        self.run_main("inputs/simple0/bin", "0", "2")

    def test1(self):
        self.run_main("inputs/simple1/bin", "1", "1")
