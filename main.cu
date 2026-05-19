#include "cute/stride.hpp"
#include <cute/util/print_latex.hpp>

#include <cstdio>
#include <fcntl.h>
#include <string>
#include <unistd.h>

using namespace cute;

namespace {

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

  cute::print_latex(layout);
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

int main() {
  auto row_major_30x10 = make_layout(make_tuple(Int<30>{}, Int<10>{}), LayoutRight());
  auto col_major_30x10 = make_layout(make_tuple(Int<30>{}, Int<10>{}), LayoutLeft());

  if (!print_latex_to_file("row_major_30x10.tex", row_major_30x10)) {
    return 1;
  }

  if (!print_latex_to_file("col_major_30x10.tex", col_major_30x10)) {
    return 1;
  }

  return 0;
}
