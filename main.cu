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

    // set_7();

   auto shape = make_shape(make_shape(_4{},_8{}), _2{});

   // auto shape2 = make_shape(Int<20>{});
   auto stride = make_stride(make_stride(_16{}, _1{}), _8{});
   auto layout = make_layout(shape, stride);

   // Ampere
   auto ALayout = Layout<Shape <Shape < _4,_8>,Shape <_2>>,
                            Stride<Stride<_16,_1>,Stride<_8>>>{};

   std::cout << "Reg ALayout = "  << ALayout << "\n";
   print_latex_to_file("Ampere_example.tex", ALayout);
   std::cout << crd2idx(make_coord(0,1), ALayout) << "\n";
   std::cout << crd2idx(make_coord(31,0), ALayout) << "\n";
   std::cout << crd2idx(make_coord(31,1), ALayout) << "\n";
   std::cout << crd2idx(make_coord(28,1), ALayout) << "\n";

   auto x = make_identity_layout(Shape <_16, _4>{});
   std::cout << "x = " << x << "\n";
   auto zx = composition(ALayout, x);
   auto xz = composition(x, ALayout);
   std::cout << "zx = " << zx << "\n";
   std::cout << "xz = " << xz << "\n";


   std::cout << crd2idx(make_coord(0,1), xz) << "\n";
   std::cout << crd2idx(make_coord(31,0), xz) << "\n";
   std::cout << crd2idx(make_coord(31,1), xz) << "\n";


   // auto shapex0 = make_shape<_20{}>; // This doesn't
   // auto shape = make_shape(make_shape(_4{},_8{}), _2{}); // This works
   //

   auto shapex0 = make_shape(Int<20>{});
   auto stridex0 = make_stride(Int<2>{});


   auto shapey0 = make_shape(Int<5>{}, Int<4>{});
   auto stridey0 = make_stride(Int<4>{}, Int<1>{});

   auto l1 = make_layout(shapex0, stridex0);
   auto l2 = make_layout(shapey0, stridey0);

   std::cout << "Layout l1 = "  << l1 << "\n";
   std::cout << "Layout l2 = "  << l2 << "\n";

   auto l1_l2 = composition(l1, l2);

   std::cout << "Layout l1_l2 = "  << l1_l2 << "\n";

   auto s0 = make_shape(Int<4>{}, make_shape(Int<3>{}, Int<2>{}));
   // auto d0 = make_stride(Int<4>{}, make_stride(Int<3>{}, Int<1>{}));
   auto lc = make_layout(s0, LayoutLeft());
   auto lr = make_layout(s0, LayoutRight());


   std::cout << "Layout lc = "  << lc << "\n";
   std::cout << "Layout lr = "  << lr << "\n";
   print_latex_to_file("lc.tex", lc);
   print_latex_to_file("lr.tex", lr);

   for (int i = 0; i < cute::size(lc); ++i) {
           std::cout << "(idx2crd), lc, lr = " << idx2crd(i, lc) << ", " << idx2crd(i, lr) << "\n";

   }

   for (int i = 0; i < cute::size<0>(s0); ++i) {
       for (int j = 0; j < cute::size<1>(s0); ++j) {
           std::cout << "(i,j) = " << i << ", " << j << "\n";
           std::cout << "(crd2idx), lc, lr = " << crd2idx(make_coord(i,j), lc) << ", " << crd2idx(make_coord(i,j), lr) << "\n";
   }
   }

   // std::cout << "crd l1 = "  << crd2idx(1, l1) << "\n";
   // std::cout << "idx l1 = "  << idx2crd(1, l1) << "\n";
   // std::cout << "idx l1 = "  << idx2crd(2, l1) << "\n";

   // for (int i = 0; i < 10; ++i) {
   //     std::cout << "(crd2idx, idx2crd) = " << crd2idx(i, l1) << ", " << idx2crd(i, l1) << "\n";
   //     std::cout << " (i+1)(crd2idx, idx2crd) = " << crd2idx(i+1, l1) << ", " << idx2crd(i+1 l1) << "\n";
   // }

   // std::cout << crd2idx(make_coord(0,2), l1_l2) << "\n";
   // std::cout << crd2idx(make_coord(0,2), l2) << "\n";
   // std::cout << crd2idx(make_coord(1,0), l1_l2) << "\n";
   // std::cout << crd2idx(make_coord(1,0), l2) << "\n";




   return 0;
}
