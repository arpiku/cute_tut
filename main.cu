#include "cute/stride.hpp"
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



int main() {
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



   return 0;
}
