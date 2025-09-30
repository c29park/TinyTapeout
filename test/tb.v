`timescale 1ns/1ps
module tb;
  reg clk=0, rst_n=0, en=0, load=0, oe=0;
  reg [7:0] load_val=8'h00;
  wire [7:0] y_tri, q;

  // DUT
  prog_counter8 dut (
    .clk(clk), .rst_n(rst_n), .en(en), .load(load),
    .load_val(load_val), .oe(oe), .y_tri(y_tri), .q(q)
  );

  // 100 MHz clock
  always #5 clk = ~clk;

  initial begin
    $dumpfile("tb_prog_counter8.vcd"); $dumpvars(0, tb);

    // release reset
    repeat(2) @(negedge clk); rst_n = 1; @(negedge clk);

    // load A5
    load_val = 8'hA5; load = 1; @(negedge clk); load = 0; @(negedge clk);

    // count 3 cycles -> A8
    en = 1; repeat(3) @(negedge clk); en = 0; @(negedge clk);

    // enable tri-state output
    oe = 1; @(negedge clk);

    $display("q=%h y_tri=%h", q, y_tri);
    $finish;
  end
endmodule
