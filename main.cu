#include "cute/layout.hpp"
#include "cute/layout_composed.hpp"
#include "cute/stride.hpp"
#include "cute/swizzle_layout.hpp"
#include "cute/tensor_impl.hpp"
#include <cute/util/print_latex.hpp>

#include <cstdio>
#include <fcntl.h>
#include <string>
#include <unistd.h>
#include <iostream>
#include <fstream>

#define LOG(x) std::cout << x << std::endl;

using namespace cute;

namespace {

template <class Layout, class ColorFn>
bool print_latex_to_file(std::string const& filename, Layout const& layout, ColorFn color_fn) {
  std::fflush(stdout);

  int saved_stdout = dup(STDOUT_FILENO);
  if (saved_stdout < 0) {
    std::perror("dup");
    return false;
  }

  int fd = open(filename.c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0644);
  if (fd < 0) {
    std::perror(filename.c_str());
    close(saved_stdout);
    return false;
  }

  if (dup2(fd, STDOUT_FILENO) < 0) {
    std::perror("dup2");
    close(fd);
    close(saved_stdout);
    return false;
  }

  close(fd);

  cute::print_latex(layout, color_fn);
  std::fflush(stdout);

  if (dup2(saved_stdout, STDOUT_FILENO) < 0) {
    std::perror("dup2-restore");
    close(saved_stdout);
    return false;
  }

  close(saved_stdout);
  return true;
}


template <class Layout>
bool print_latex_to_file(std::string const& filename, Layout const& layout) {
  std::fflush(stdout);

  int saved_stdout = dup(STDOUT_FILENO);
  if (saved_stdout < 0) {
    std::perror("dup");
    return false;
  }

  int fd = open(filename.c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0644);
  if (fd < 0) {
    std::perror(filename.c_str());
    close(saved_stdout);
    return false;
  }

  if (dup2(fd, STDOUT_FILENO) < 0) {
    std::perror("dup2");
    close(fd);
    close(saved_stdout);
    return false;
  }

  close(fd);

  cute::print_latex(layout);   // default Cute coloring
  std::fflush(stdout);

  if (dup2(saved_stdout, STDOUT_FILENO) < 0) {
    std::perror("dup2-restore");
    close(saved_stdout);
    return false;
  }

  close(saved_stdout);
  return true;
}



} // namespace

bool check_print(bool x) {
    if (!x) {
        std::cerr << "print_latex_to_file failed" << std::endl;
    }
    return x;
}


template <typename Shape>
void layout_exp_printer(Shape& shape, int index);
void set_5() {
    auto layout_a = make_layout( make_shape (make_shape(_4{}, _4{}), _4{}));

    int index = 100;

    auto shape = make_shape(make_shape(_4{}, _4{}), _4{});
    layout_exp_printer(shape, index);

    auto shape2 = make_shape(make_shape(_4{}, _4{}), make_shape(_4{}));
    layout_exp_printer(shape2, index);


    auto shape3 = make_shape(make_shape(_4{}), make_shape(_4{}, _4{}));
    layout_exp_printer(shape3, index);

    auto shape4 = make_shape(make_shape(_4{},_4{}, _4{}));
    layout_exp_printer(shape4, index);


    auto shape5 = make_shape(_4{},_4{}, _4{});
    layout_exp_printer(shape5, index);
}

template <typename Shape>
void layout_exp_printer(Shape& shape, int index) {
    std::cout << "Rank of shape: ";
    print(rank(shape));
    std::cout << "\nidx2crd of shape @" << index << ": ";
    print(idx2crd(index, shape));
    auto shape_layout = make_layout(shape);
    std::cout << "\nRank of layout(shape): " ;
    print(rank(shape_layout));
    std::cout << "\nidx2crd of layout @" << index << ": ";
    print(idx2crd(index, shape_layout));
    std::cout << "\n";
}

void set_6() {

    Layout a = Layout<_3,_3>{};                     // 3:1
    print_latex_to_file("3_3_layout_a.tex", a);
    Layout b = Layout<_2,_5>{};                     // 4:3
    print_latex_to_file("2_5_layout_b.tex", b);
    Layout ab = make_layout(a, b);                 // (3,4):(1,3)
    print_latex_to_file("3_3_2_5_layout_ab.tex", ab);
    Layout ba = make_layout(b, a);                 // (4,3):(3,1)
    print_latex_to_file("2_5__3_3_layout_ba.tex", ba);
    Layout abba   = make_layout(ab, ba);             // ((3,4),(4,3)):((1,3),(3,1))
    print_latex_to_file("ab__ba_layout.tex", abba);
    Layout baab   = make_layout(ba, ab);             // ((3,4),(4,3)):((1,3),(3,1))
    print_latex_to_file("ba__ab_layout.tex", baab);
    Layout abab   = make_layout(ab, ab);             // ((3,4),(4,3)):((1,3),(3,1))
    print_latex_to_file("ab__ab_layout.tex", abab);
    Layout baba   = make_layout(ba, ba);             // ((3,4),(4,3)):((1,3),(3,1))
    print_latex_to_file("ba__ba_layout.tex", baba);

}

void set_7() {
        auto shape = make_shape( make_tuple(make_tuple( make_shape(_4{},_3{}), make_shape(_3{}, _4{}))));
        auto shape2 = make_shape( make_tuple(make_tuple( make_shape(_5{},_7{}), make_shape(_9{}, _10{}))));
        Layout a = Layout<decltype(shape)>{};
        Layout b = Layout<decltype(shape2)>{};

        std::cout << "rank(a) = " << rank(a) << "\n";
        std::cout << "rank(shape) = " << rank(shape) << "\n";
        std::cout << "Layout a = "  << a << "\n";
        std::cout << "Flatten(a) = " << flatten(a) << "\n";
        std::cout << "Flatten(shape) = " << flatten(shape) << "\n";
        std::cout << "Coalesced(a) = " << coalesce(a) << "\n";
        std::cout << "Coalesced(shape) = " << coalesce(shape) << "\n";


        std::cout << "rank(b) = " << rank(b) << "\n";
        std::cout << "rank(shape2) = " << rank(shape2) << "\n";
        std::cout << "Layout b = "  << b << "\n";
        std::cout << "Flatten(b) = " << flatten(b) << "\n";
        std::cout << "Flatten(shape2) = " << flatten(shape2) << "\n";
        std::cout << "Coalesced(b) = " << coalesce(b) << "\n";
        std::cout << "Coalesced(shape2) = " << coalesce(shape2) << "\n";


        auto xx = Layout<decltype(make_shape(make_tuple(_6{}, _6{}, _6{})))>{};
        auto yy = Layout<decltype(make_shape(make_tuple(_9{}, _9{}, _9{})))>{};

        auto xz = make_layout(make_shape(_6{}, _6{}, _6{}), make_stride(_7{}, _8{}, _9{}));
        std::cout << "Layout xz = "  << xz << "\n";
        std::cout << "Coalesced(xz) = " << coalesce(xz) << "\n";

        auto yz = Layout<decltype(make_shape(make_tuple(_9{}, _9{}, _9{})))>{};


        std::cout << "Composition(a, b) = " << composition(a, b) << "\n";
        std::cout << "Composition(a, a) = " << composition(a, a) << "\n";
        std::cout << "Composition(a, a) = " << composition(flatten(a), flatten(a)) << "\n";

        std::cout << "Composition(xx, yy) = " << composition(xx,yy) << "\n";
        std::cout << "Composition(yy, xx) = " << composition(yy,xx) << "\n";

        std::cout << "Composition(xz, yz) = " << composition(yz,xz) << "\n";
        std::cout << "Composition(yz, xz) = " << "This won't work, will throw and error XX" << "\n"; // This will throw an error

}




int main() {

    auto _4x4_c = make_layout(make_shape(_4{}, _4{}), make_stride(_1{}, _4{})); // LayoutLeft()
    auto _4x4_r = make_layout(make_shape(_4{}, _4{}), make_stride(_4{}, _1{})); // LayoutRight()
    auto _2x2_ = make_tuple(_2{}, _2{});
    auto _2x2X2x2_c = make_layout(make_shape( _2x2_, _2x2_), LayoutLeft()); // LayoutLeft()
    auto _2x2X2x2_r = make_layout(make_shape( _2x2_, _2x2_), LayoutRight()); // LayoutLeft()
    auto _4x4_p = make_layout(make_shape(_4{}, _4{}), make_stride(_3{}, _5{}));
    auto _4x4_q = make_layout(make_shape(_4{}, _4{}), make_stride(Int<11>{}, Int<7>{}));

    auto _l2x2lx2_c = make_layout(make_shape(_2x2_, _2{}), LayoutLeft());
    auto _l2x2lx2_r = make_layout(make_shape(_2x2_, _2{}), LayoutRight());

    auto _2xl2x2l_c = make_layout(make_shape( _2{}, _2x2_), LayoutLeft());
    auto _2xl2x2l_r = make_layout(make_shape( _2{}, _2x2_), LayoutRight());

    auto _l2x2lx2_pc = make_layout(make_shape(_2x2_, _2{}), make_stride(make_tuple(_3{}, _5{}), Int<7>{}));
    auto _2xl2x2l_pc = make_layout(make_shape( _2{}, _2x2_), make_stride(_3{}, make_tuple(_5{}, Int<7>{})));

    auto a = make_layout(_2{}, _3{});
    auto b = make_layout(_2{}, _5{});
    auto c = make_layout(_2{}, _7{});

    std::cout << "a : " << a << std::endl;
    check_print(print_latex_to_file("a.tex", a));

    std::cout << "b : " << b << std::endl;
    check_print(print_latex_to_file("b.tex", b));

    std::cout << "c : " << c << std::endl;
    check_print(print_latex_to_file("c.tex", c));

    // auto ab = make_layout(a, b);
    // auto bc = make_layout(b, c);


    auto cb = make_layout(c, b);
    auto cb_a = make_layout(cb, a);
    auto _l2x2lx2_pr = make_layout(make_shape(_2x2_, _2{}), make_stride(make_tuple(_7{}, _5{}), Int<3>{}));

    std::cout << "cb : " << cb << std::endl;
    check_print(print_latex_to_file("cb.tex", cb));
    std::cout << "cb_a : " << cb_a << std::endl;
    check_print(print_latex_to_file("cb_a.tex", cb_a));
    std::cout << "_l2x2lx2_pr  : " << _l2x2lx2_pr << std::endl;
    check_print(print_latex_to_file("_l2x2lx2_pr.tex", _l2x2lx2_pr));

    auto ba = make_layout(b, a);
    auto c_ba = make_layout(c, ba);
    auto _2xl2x2l_pr = make_layout(make_shape( _2{}, _2x2_), make_stride(_7{}, make_tuple(_5{}, Int<3>{})));

    std::cout << "ba : " << ba << std::endl;
    check_print(print_latex_to_file("ba.tex", ba));
    std::cout << "c_ba : " << c_ba << std::endl;
    check_print(print_latex_to_file("c_ba.tex", c_ba));
    std::cout << "_2xl2x2l_pr  : " << _2xl2x2l_pr  << std::endl;
    check_print(print_latex_to_file("_2xl2x2l_pr.tex", _2xl2x2l_pr));

    auto coal_2x2X2x2_c_s1x1 = coalesce(_2x2X2x2_c, Step<_1, _1>{});
    auto coal_2x2X2x2_c_sl1x1lx1 = coalesce(_2x2X2x2_c, Step<Step<X,X>, _1>{});
    auto coal_2x2X2x2_c_sl1x1lxl1x1l = coalesce(_2x2X2x2_c, Step<Step<X,X>, Step<X,X>>{});
    // auto coal_2x2X2x2_c_sl1x1lx1 = coalesce(_2x2X2x2_c, Step<Step<_1,_1>, _1>{});
    // auto coal_b = coalesce(_2x2X2x2_c, Step<Step<_1,_1>, Step<_1,_1>>);
    std::cout << "coal_a : " << coal_2x2X2x2_c_s1x1  << std::endl;
    std::cout << "coal_b : " << coal_2x2X2x2_c_sl1x1lx1 << std::endl;
    std::cout << "coal_c : " << coal_2x2X2x2_c_sl1x1lxl1x1l  << std::endl;



    // std::cout << "_4x4_c : " << _4x4_c << std::endl;
    // check_print(print_latex_to_file("_4x4_c.tex", _4x4_c));

    // std::cout << "_4x4_r : " << _4x4_r << std::endl;
    // check_print(print_latex_to_file("_4x4_r.tex", _4x4_r));

    // std::cout << "_2x2X2x2_c : " << _2x2X2x2_c << std::endl;
    // check_print(print_latex_to_file("_2x2X2x2_c.tex", _2x2X2x2_c));

    // std::cout << "_2x2X2x2_r : " << _2x2X2x2_r << std::endl;
    // check_print(print_latex_to_file("_2x2X2x2_r.tex", _2x2X2x2_r));

    // std::cout << "_4x4_p : " << _4x4_p << std::endl;
    // check_print(print_latex_to_file("_4x4_p.tex", _4x4_p));

    // std::cout << "_4x4_q : " << _4x4_q << std::endl;
    // check_print(print_latex_to_file("_4x4_q.tex", _4x4_q));

    // std::cout << "_l2x2lx2_c : " << _l2x2lx2_c << std::endl;
    // check_print(print_latex_to_file("_l2x2lx2_c.tex", _l2x2lx2_c));

    // std::cout << "_l2x2lx2_r : " << _l2x2lx2_r << std::endl;
    // check_print(print_latex_to_file("_l2x2lx2_r.tex", _l2x2lx2_r));

    // std::cout << "_2xl2x2l_c : " << _2xl2x2l_c << std::endl;
    // check_print(print_latex_to_file("_2xl2x2l_c.tex", _2xl2x2l_c));

    // std::cout << "_2xl2x2l_r : " << _2xl2x2l_r << std::endl;
    // check_print(print_latex_to_file("_2xl2x2l_r.tex", _2xl2x2l_r));

    // std::cout << "_l2x2lx2_pc : " << _l2x2lx2_pc << std::endl;
    // check_print(print_latex_to_file("_l2x2lx2_pc.tex", _l2x2lx2_pc));

    // std::cout << "_2xl2x2l_pc : " << _2xl2x2l_pc << std::endl;
    // check_print(print_latex_to_file("_2xl2x2l_pc.tex", _2xl2x2l_pc));





   return 0;
}
