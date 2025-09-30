import os
import pathlib
import pytest
from cocotb_test.simulator import run

ROOT = pathlib.Path(__file__).resolve().parents[1]
VERILOG_SOURCES = [str(ROOT / "src" / "prog_counter8.v")]

@pytest.mark.parametrize("sim", ["icarus"])
def test_prog_counter8(sim):
    # fixed build dir so CI artifacts are predictable
    build = ROOT / "test" / f"sim_build_{sim}"
    os.environ.setdefault("COCOTB_LOG_LEVEL", "INFO")
    run(
        verilog_sources=VERILOG_SOURCES,
        toplevel="prog_counter8",                # DUT module name
        module="cocotb_prog_counter8_tests",     # points to inline cocotb module below
        toplevel_lang="verilog",
        sim=sim,
        waves=True,                              # dump.vcd in build dir
        extra_args=["-g2012"] if sim == "icarus" else [],
        sim_build=str(build),
    )

# ---------------- inline cocotb tests ----------------
import types, sys, cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

# Create a virtual module name so cocotb can import via `module=...`
cocotb_prog_counter8_tests = types.ModuleType("cocotb_prog_counter8_tests")
sys.modules["cocotb_prog_counter8_tests"] = cocotb_prog_counter8_tests

CLK_NS = 10  # 100 MHz

async def _reset(dut):
    dut.rst_n.value = 0
    dut.en.value    = 0
    dut.load.value  = 0
    dut.oe.value    = 0
    dut.load_val.value = 0
    await Timer(CLK_NS * 2, units="ns")
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

@cocotb.test()
async def basic_count_and_bus(dut):
    """Reset → load A5 → count 3 → check tri-state bus mirrors q only when OE=1."""
    cocotb.start_soon(Clock(dut.clk, CLK_NS, units="ns").start())
    await _reset(dut)

    # load 0xA5
    dut.load_val.value = 0xA5
    dut.load.value = 1
    await RisingEdge(dut.clk)
    dut.load.value = 0
    await RisingEdge(dut.clk)
    assert int(dut.q.value) == 0xA5

    # count 3 cycles -> A8
    dut.en.value = 1
    for _ in range(3):
        await RisingEdge(dut.clk)
    dut.en.value = 0
    assert int(dut.q.value) == 0xA8

    # OE=0 -> tri-state bus should be Z
    dut.oe.value = 0
    await RisingEdge(dut.clk)
    assert dut.y_tri.value.binstr.lower() == "zzzzzzzz"

    # OE=1 -> bus mirrors q
    dut.oe.value = 1
    await RisingEdge(dut.clk)
    assert int(dut.y_tri.value) == int(dut.q.value)

@cocotb.test()
async def wraparound(dut):
    """FE -> FF -> 00 with enable asserted."""
    cocotb.start_soon(Clock(dut.clk, CLK_NS, units="ns").start())
    await _reset(dut)

    dut.load_val.value = 0xFE
    dut.load.value = 1
    await RisingEdge(dut.clk)
    dut.load.value = 0
    await RisingEdge(dut.clk)
    assert int(dut.q.value) == 0xFE

    dut.en.value = 1
    await RisingEdge(dut.clk)  # FE -> FF
    await RisingEdge(dut.clk)  # FF -> 00
    dut.en.value = 0
    assert int(dut.q.value) == 0x00
