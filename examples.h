
void set_1() {
    auto row_major_30x10 = make_layout(make_tuple(Int<30>{}, Int<10>{}), LayoutRight());
    check_print(print_latex_to_file("row_major_30x10.tex", row_major_30x10));


    auto row_major_30x10__15x2_5x2 = make_layout(make_tuple( make_tuple(Int<15>{}, Int<2>{}), make_tuple(Int<5>{}, Int<2>{})), LayoutRight());
    check_print(print_latex_to_file("row_major_30x10__15x2_5x2.tex", row_major_30x10__15x2_5x2));


    auto col_major_30x10 = make_layout(make_tuple(Int<30>{}, Int<10>{}), LayoutLeft());
    check_print(print_latex_to_file("col_major_30x10.tex", col_major_30x10));


    auto col_major_30x10__15x2_5x2 = make_layout(make_tuple( make_tuple(Int<15>{}, Int<2>{}), make_tuple(Int<5>{}, Int<2>{})), LayoutLeft());
    check_print(print_latex_to_file("col_major_30x10__15x2_5x2.tex", col_major_30x10__15x2_5x2));

    std::cout << "row_major_30x10" << std::endl;
    cute::print_layout(row_major_30x10);
    std::cout << "row_major_30x10__15x2_5x2" << std::endl;
    cute::print_layout(row_major_30x10__15x2_5x2);
    std::cout << "col_major_30x10" << std::endl;
    cute::print_layout(col_major_30x10);
    std::cout << "col_major_30x10__15x2_5x2" << std::endl;
    cute::print_layout(col_major_30x10__15x2_5x2);

}

void set_2() {
    auto exp_major_s30x10_d10x10 = make_layout(make_shape(Int<30>{}, Int<10>{}), make_stride(Int<10>{}, Int<10>{}));
    check_print(print_latex_to_file("exp_major_s30x10_d10x10.tex", exp_major_s30x10_d10x10));


    auto exp_major_s30x10_d10x5 = make_layout(make_shape(Int<30>{}, Int<10>{}), make_stride(Int<10>{}, Int<5>{}));
    check_print(print_latex_to_file("exp_major_s30x10_d10x5.tex", exp_major_s30x10_d10x5));


    auto exp_major_s30x10_d5x10 = make_layout(make_shape(Int<30>{}, Int<10>{}), make_stride(Int<5>{}, Int<10>{}));
    check_print(print_latex_to_file("exp_major_s30x10_d10x5.tex", exp_major_s30x10_d5x10));


    auto exp_major_s10x30_d10x10 = make_layout(make_shape(Int<10>{}, Int<30>{}), make_stride(Int<10>{}, Int<10>{}));
    check_print(print_latex_to_file("exp_major_s10x30_d10x10.tex", exp_major_s10x30_d10x10));


    auto exp_major_s10x30_d10x5 = make_layout(make_shape(Int<10>{}, Int<30>{}), make_stride(Int<10>{}, Int<5>{}));
    check_print(print_latex_to_file("exp_major_s10x30_d10x5.tex", exp_major_s10x30_d10x5));


    auto exp_major_s10x30_d1x1 = make_layout(make_shape(Int<10>{}, Int<30>{}), make_stride(Int<1>{}, Int<1>{}));
    check_print(print_latex_to_file("exp_major_s10x30_d1x1.tex", exp_major_s10x30_d1x1));


    std::cout << "exp_major_s30x10_d10x10" << std::endl;
    cute::print_layout(exp_major_s30x10_d10x10);
    std::cout << "exp_major_s30x10_d10x5" << std::endl;
    cute::print_layout(exp_major_s30x10_d10x5);
    std::cout << "exp_major_s30x10_d5x10" << std::endl;
    cute::print_layout(exp_major_s30x10_d5x10);
    std::cout << "exp_major_s10x30_d10x10" << std::endl;
    cute::print_layout(exp_major_s10x30_d10x10);
    std::cout << "exp_major_s10x30_d10x5" << std::endl;
    cute::print_layout(exp_major_s10x30_d10x5);
    std::cout << "exp_major_s10x30_d1x1" << std::endl;
    cute::print_layout(exp_major_s10x30_d1x1);


}

void set_3() {
    auto shape  = Shape <_7,Shape<  _3,_9>>{};
    auto stride = Stride<_3,Stride<_12,_1>>{};

    auto exp_major_s7xL3x9L_d3xL12x1L = make_layout(shape,stride);
    check_print(print_latex_to_file("exp_major_s7xL3x9L_d3xL12x1L.tex", exp_major_s7xL3x9L_d3xL12x1L));

    std::cout << "crd2idx for the shape above" << std::endl;
    std::cout << "16:" << std::endl;
    print(crd2idx(   16, shape, stride));
    std::cout << "\n-" << std::endl;
    std::cout << "_16:" << std::endl;
    print(crd2idx(_16{}, shape, stride));
    std::cout << "\n-" << std::endl;
    std::cout << "(1,5):" << std::endl;
    print(crd2idx(make_coord(   1,   5), shape, stride));
    std::cout << "\n-" << std::endl;
    std::cout << "(_1,6):" << std::endl;
    print(crd2idx(make_coord(_1{},   6), shape, stride));
    std::cout << "\n-" << std::endl;
    std::cout << "(_2,6):" << std::endl;
    print(crd2idx(make_coord(_2{},_6{}), shape, stride));
    std::cout << "\n-" << std::endl;
    std::cout << "(5,(2,7)):" << std::endl;
    print(crd2idx(make_coord(   5,make_coord(   2,   7)), shape, stride));
    std::cout << "\n-" << std::endl;
    std::cout << "(2,(2,4)):" << std::endl;
    print(crd2idx(make_coord(_2{},make_coord(_2{},_4{})), shape, stride));

}
