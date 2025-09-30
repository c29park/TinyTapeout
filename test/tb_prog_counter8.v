`timescale 1ns/1ps
module tb_prog_counter8;
  reg clk=0, rst_n=0, en=0, load=0, oe=0;
  reg [7:0] load_val=8'h00;
  wire [7:0] y_tri, q;
  prog_counter8 dut(.clk(clk), .rst_n(rst_n), .en(en), .load(load),
                    .load_val(load_val), .oe(oe), .y_tri(y_tri), .q(q));
  always #5 clk=~clk;
  initial begin
    $dumpfile("tb_prog_counter8.vcd"); $dumpvars(0, tb_prog_counter8);
    repeat(2) @(negedge clk); rst_n=1; @(negedge clk);
    load_val=8'hA5; load=1; @(negedge clk); load=0; @(negedge clk);
    en=1; repeat(3) @(negedge clk); en=0;
    oe=1; @(negedge clk);
    $display("q=%h y=%h", q, y_tri);
    $finish;
  end
endmodule
