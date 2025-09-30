// Pin map (typical TT03/TT04 style interface):
//   clk, rst_n, ena provided by TT harness.
//   ui_in[0]   = en
//   ui_in[1]   = load
//   ui_in[2]   = oe (drive bidir bus when 1)
//   uio_in[7:0]= load_val
//   uio_out[7:0] drives count when oe=1, otherwise high-Z via uio_oe
//   uo_out[7:0] mirrors the current count continuously (debug)
// Notes:
//   TT's `uio_*` pads are proper bidirectional pins with per-bit OE.
//   `uo_out` are output-only and cannot be tri-stated on chip pads.
module tt_um_chris_counter (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,     // not used internally, but must exist
    input  wire       clk,
    input  wire       rst_n
);
    wire en      = ui_in[0];
    wire load    = ui_in[1];
    wire oe      = ui_in[2];
    wire [7:0] load_val = uio_in;

    wire [7:0] y_tri;
    wire [7:0] q;

    prog_counter8 u_cnt (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .load(load),
        .load_val(load_val),
        .oe(oe),
        .y_tri(y_tri),
        .q(q)
    );

    // Drive bidirectional pads with tri-state using per-bit OEs
    assign uio_out = q;                // data to drive when enabled
    assign uio_oe  = {8{oe}};          // 1=drive, 0=Hi-Z on the pad

    // Also mirror the count to fixed outputs for easy observation
    assign uo_out = q;
endmodule
