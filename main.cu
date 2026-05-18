#include <cute/util/print_latex.hpp>

int main() {
  // auto layout = cute::make_layout(cute::Shape<cute::_2, cute::_3>{});
  auto layout = cute::make_layout(cute::Shape< cute::Shape <cute::_2, cute::_3> , cute::_4>{});
  cute::print_latex(layout);
  return 0;
}
