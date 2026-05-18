CUTLASS_DIR ?= /workspace/cutlass
NVCC ?= nvcc
TARGET ?= main
SRC ?= main.cu

NVCCFLAGS := -std=c++17 --expt-relaxed-constexpr --extended-lambda -arch=sm_120
INCLUDES := -I$(CUTLASS_DIR)/include

.PHONY: all build run clean

all: build

build: $(TARGET)

$(TARGET): $(SRC)
	$(NVCC) $(NVCCFLAGS) $(INCLUDES) -o $@ $<

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET)
