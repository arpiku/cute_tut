// cute_colored_layout.cu
//
// Reproduces the colored tile visualizations from CuTe's documentation
// for a layout A = (9,(4,8)):(59,(13,1)) tiled by B = <3:3, (2,4):(1,8)>.
//
// Build:
//   nvcc -std=c++17 -I /path/to/cutlass/include -x cu \
//        cute_colored_layout.cu -o cute_colored_layout
//
// Run:
//   ./cute_colored_layout 1 > top.tex     && pdflatex top.tex
//   ./cute_colored_layout 2 > bottom.tex  && pdflatex bottom.tex
//
// Why the stock `print_latex(layout)` gives grayscale:
//   The default color functor is TikzColor_BWx8, which returns 8 shades
//   of "black!XX" — that's the gray output you observed.
//
//   You CAN pass a custom RGB color functor as the 2nd argument to
//   `print_latex(layout, color_fn)`. The signature is `color_fn(idx)`
//   where `idx = layout(m,n)` (i.e. the layout's INDEX value). That's
//   enough for thread/value-style coloring, but it does NOT match the
//   doc screenshot — the doc colors cells by which TILE of the divide
//   they belong to, not by the layout's index value. Two cells in the
//   same tile have different `idx`, so a `color(idx)`-only callback
//   can't recover the tile id.
//
//   Solution: write a small custom printer (below). It walks the
//   `zipped_divide(A, B)` to learn which (m,n) belongs to which tile,
//   then emits LaTeX with one pastel RGB color per tile. The palette
//   used here is exactly TikzColor_TV from print_latex.hpp.

#include <cute/tensor.hpp>
#include <cute/util/print_latex.hpp>
#include <cstdio>
#include <cstdlib>
#include <vector>

using namespace cute;

// The TikzColor_TV palette from print_latex.hpp -- pastel RGB.
// Marked host-device so it can be called from any context the CuTe
// templates instantiate (most CuTe utilities are host/device dual).
CUTE_HOST_DEVICE
char const* tile_color(int idx)
{
  char const* color_map[8] = {
    "{rgb,255:red,175;green,175;blue,255}",
    "{rgb,255:red,175;green,255;blue,175}",
    "{rgb,255:red,255;green,255;blue,175}",
    "{rgb,255:red,255;green,175;blue,175}",
    "{rgb,255:red,210;green,210;blue,255}",
    "{rgb,255:red,210;green,255;blue,210}",
    "{rgb,255:red,255;green,255;blue,210}",
    "{rgb,255:red,255;green,210;blue,210}"
  };
  return color_map[((idx % 8) + 8) % 8];
}

// ---------------------------------------------------------------------
// Custom printer: prints the ORIGINAL layout as an M x N grid, where
// each cell is colored by which tile-of-B it belongs to.
//
// `layout` is the original rank-2 layout A (after appending <_1,_0> if rank-1).
// `tiler`  is the tiler B used to define tile membership.
// We use zipped_divide(A, B) to map every original (m,n) position to
// a "tile-outer" coordinate -- that's the tile id used for coloring.
// ---------------------------------------------------------------------
template <class Layout, class Tiler>
void
print_latex_tiled(Layout const& layout, Tiler const& tiler)
{
  CUTE_STATIC_ASSERT_V(rank(layout) == Int<2>{});

  // The divided layout has shape ((tile_inner...), (tile_outer...))
  auto divided = zipped_divide(layout, tiler);

  // Sizes of the original 2-D grid we are drawing.
  auto [M, N] = product_each(shape(layout));

  // Build an inverse-map: given an (m,n) in the original grid, find its
  // tile-outer linear id. We do this by enumerating divided coordinates.
  auto tile_inner_size = size<0>(divided);   // points per tile
  auto tile_outer_size = size<1>(divided);   // number of tiles

  // tile_id[m * N + n] -> outer tile id
  // (filled by walking the divided layout)
  std::vector<int> tile_id(int(M) * int(N), -1);

  // The original index produced by divided(i, j) equals layout(m, n) for
  // some (m, n). We need (m, n), not the index value. Use an identity
  // tensor composed with the same divide to recover (m, n).
  // Use product_each(shape) to get a *flat* rank-2 shape so the recovered
  // coordinates are plain integers, not hierarchical tuples.
  auto identity   = make_identity_tensor(product_each(shape(layout)));
  auto id_divided = zipped_divide(identity, tiler);

  for (int j = 0; j < int(tile_outer_size); ++j) {
    for (int i = 0; i < int(tile_inner_size); ++i) {
      auto mn = id_divided(i, j);  // a cute::tuple<int,int>
      int m = int(get<0>(mn));
      int n = int(get<1>(mn));
      tile_id[m * int(N) + n] = j;
    }
  }

  // Emit the LaTeX.
  printf("%% Layout: ");        print(layout); printf("\n");
  printf("%% Tiler:  ");        print(tiler);  printf("\n");
  printf("%% Divided: ");       print(divided);printf("\n");
  printf("\\documentclass[convert]{standalone}\n"
         "\\usepackage{tikz}\n\n"
         "\\begin{document}\n"
         "\\begin{tikzpicture}["
         "x={(0cm,-1cm)},y={(1cm,0cm)},"
         "every node/.style={minimum size=1cm, outer sep=0pt}]\n\n");

  for (int m = 0; m < int(M); ++m) {
    for (int n = 0; n < int(N); ++n) {
      int idx = int(layout(m, n));
      int tid = tile_id[m * int(N) + n];
      printf("\\node[fill=%s] at (%d,%d) {%d};\n",
             tile_color(tid), m, n, idx);
    }
  }
  printf("\\draw[color=black,thick,shift={(-0.5,-0.5)}] (0,0) grid (%d,%d);\n\n",
         int(M), int(N));
  for (int m =  0, n = -1; m < int(M); ++m)
    printf("\\node at (%d,%d) {\\Large{\\texttt{%d}}};\n", m, n, m);
  for (int m = -1, n =  0; n < int(N); ++n)
    printf("\\node at (%d,%d) {\\Large{\\texttt{%d}}};\n", m, n, n);

  printf("\\end{tikzpicture}\n\\end{document}\n");
}

// ---------------------------------------------------------------------
// Print the zipped_divide RESULT as a grid where each column is a tile,
// each column gets a uniform color. This reproduces the second (bottom)
// image in the documentation.
// ---------------------------------------------------------------------
template <class Layout, class Tiler>
void
print_latex_zipped(Layout const& layout, Tiler const& tiler)
{
  auto divided = zipped_divide(layout, tiler);

  // After zipped_divide, axis 0 = tile-inner, axis 1 = tile-outer (the tile id)
  int Mi = int(size<0>(divided));
  int No = int(size<1>(divided));

  printf("%% Layout: ");        print(layout);   printf("\n");
  printf("%% Tiler:  ");        print(tiler);    printf("\n");
  printf("%% Zipped:  ");       print(divided);  printf("\n");
  printf("\\documentclass[convert]{standalone}\n"
         "\\usepackage{tikz}\n\n"
         "\\begin{document}\n"
         "\\begin{tikzpicture}["
         "x={(0cm,-1cm)},y={(1cm,0cm)},"
         "every node/.style={minimum size=1cm, outer sep=0pt}]\n\n");

  // Color by column (tile-outer) -- each column == one tile, one color.
  for (int i = 0; i < Mi; ++i) {
    for (int j = 0; j < No; ++j) {
      int idx = int(divided(i, j));
      printf("\\node[fill=%s] at (%d,%d) {%d};\n",
             tile_color(j), i, j, idx);
    }
  }
  printf("\\draw[color=black,thick,shift={(-0.5,-0.5)}] (0,0) grid (%d,%d);\n\n",
         Mi, No);
  for (int m =  0, n = -1; m < Mi; ++m)
    printf("\\node at (%d,%d) {\\Large{\\texttt{%d}}};\n", m, n, m);
  for (int m = -1, n =  0; n < No; ++n)
    printf("\\node at (%d,%d) {\\Large{\\texttt{%d}}};\n", m, n, n);

  printf("\\end{tikzpicture}\n\\end{document}\n");
}

int main(int argc, char** argv)
{
  // A = (9, (4, 8)) : (59, (13, 1))
  auto A = make_layout(
      make_shape (Int<9>{}, make_shape(Int<4>{}, Int<8>{})),
      make_stride(Int<59>{}, make_stride(Int<13>{}, Int<1>{}))
  );

  // B = <3:3, (2,4):(1,8)>
  auto B = make_tile(
      Layout<Int<3>, Int<3>>{},
      Layout<Shape<Int<2>, Int<4>>, Stride<Int<1>, Int<8>>>{}
  );

  int which = (argc > 1) ? std::atoi(argv[1]) : 1;

  if (which == 1) {
    // Top image: original layout with tiles highlighted in color
    print_latex_tiled(A, B);
  } else if (which == 2) {
    // Bottom image: zipped_divide layout, columns = tiles, colored per column
    print_latex_zipped(A, B);
  } else if (which == 3) {
    // Also demonstrate the stock print_latex with a TV-style RGB color functor.
    // This colors by `layout(m,n) % 8`, NOT by tile -- so it looks scattered,
    // but at least it's RGB instead of gray. Shown here for completeness.
    struct RgbByIdx {
      CUTE_HOST_DEVICE char const* operator()(int idx) const { return tile_color(idx); }
    };
    print_latex(A, RgbByIdx{});
  }

  return 0;
}
