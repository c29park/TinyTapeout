# ---------------- Tiny Tapeout-friendly test Makefile ----------------
# This Makefile works for local Icarus RTL sim AND gives the TT gl_test
# action the vars it expects (TOPLEVEL and PROJECT_SOURCES).

# Your DUT sources (exact, case-sensitive paths)
PROJECT_SOURCES := ../src/prog_counter8.v ../src/tt_um_chris_counter.v

# The testbench top module the template expects
TOPLEVEL := tb

# Your testbench file(s)
TB_SOURCES := tb.v

# Tools & flags
IVERILOG ?= iverilog
VVP      ?= vvp
VFLAGS   ?= -g2012
BUILD    ?= build

# Default target: run an RTL sim locally (or in CI smoke tests)
.PHONY: all rtl clean
all: rtl

rtl: $(BUILD)/tb_rtl.vvp
	$(VVP) $@

# Compile RTL (TB + DUT)
$(BUILD)/tb_rtl.vvp: $(TB_SOURCES) $(PROJECT_SOURCES)
	@mkdir -p $(BUILD)
	$(IVERILOG) $(VFLAGS) -o $@ $^

# (Optional) gate-level sim hook (TT gl_test may set GL=1 and handle netlist)
# If you want to run a GL sim locally, provide the netlist path via GL_NETLIST:
#   make gl GL_NETLIST=../runs/<your-run>/results/final/verilog/gl/tt_um_*.v
.PHONY: gl
gl:
ifndef GL_NETLIST
	$(error "Set GL_NETLIST=<path to gate-level netlist .v> to run GL sim")
endif
	@mkdir -p $(BUILD)
	$(IVERILOG) $(VFLAGS) -o $(BUILD)/tb_gl.vvp $(TB_SOURCES) $(GL_NETLIST)
	$(VVP) $(BUILD)/tb_gl.vvp

clean:
	rm -rf $(BUILD)
