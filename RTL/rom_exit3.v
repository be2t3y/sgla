/* FE Release Version: 3.4.22 */
/* lang compiler Version: 3.0.4 */
//
//       CONFIDENTIAL AND PROPRIETARY SOFTWARE OF ARM PHYSICAL IP, INC.
//      
//       Copyright (c) 1993 - 2023 ARM Physical IP, Inc.  All Rights Reserved.
//      
//       Use of this Software is subject to the terms and conditions of the
//       applicable license agreement with ARM Physical IP, Inc.
//       In addition, this Software is protected by patents, copyright law 
//       and international treaties.
//      
//       The copyright notice(s) in this Software does not indicate actual or
//       intended publication of this Software.
//
//      Verilog model for Synchronous Single-Port Rom
//
//       Instance Name:              rom_exit3
//       Words:                      1920
//       Bits:                       7
//       Mux:                        8
//       Drive:                      6
//       Write Mask:                 Off
//       Write Thru:                 Off
//       Extra Margin Adjustment:    On
//       Redundant Rows:             0
//       Redundant Columns:          0
//       Test Muxes                  On
//       Power Gating:               On
//       Retention:                  Off
//       Pipeline:                   Off
//       Weak Bit Test:	        Off
//       Read Disturb Test:	        Off
//       
//       Creation Date:  Fri Jul 28 13:24:59 2023
//       Version: 	r4p1
//
//      Modeling Assumptions: This model supports full gate level simulation
//          including proper x-handling and timing check behavior.  Unit
//          delay timing is included in the model. Back-annotation of SDF
//          (v3.0 or v2.1) is supported.  SDF can be created utilyzing the delay
//          calculation views provided with this generator and supported
//          delay calculators.  All buses are modeled [MSB:LSB].  All 
//          ports are padded with Verilog primitives.
//
//      Modeling Limitations: None.
//
//      Known Bugs: None.
//
//      Known Work Arounds: N/A
//
`timescale 1 ns/1 ps
// If ARM_UD_MODEL is defined at Simulator Command Line, it Selects the Fast Functional Model
`ifdef ARM_UD_MODEL

// Following parameter Values can be overridden at Simulator Command Line.

// ARM_UD_DP Defines the delay through Data Paths, for Memory Models it represents BIST MUX output delays.
`ifdef ARM_UD_DP
`else
`define ARM_UD_DP #0.001
`endif
// ARM_UD_CP Defines the delay through Clock Path Cells, for Memory Models it is not used.
`ifdef ARM_UD_CP
`else
`define ARM_UD_CP
`endif
// ARM_UD_SEQ Defines the delay through the Memory, for Memory Models it is used for CLK->Q delays.
`ifdef ARM_UD_SEQ
`else
`define ARM_UD_SEQ #0.01
`endif

`celldefine
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
module rom_exit3 (VDDE, VSSE, CENY, AY, Q, CLK, CEN, A, EMA, TEN, BEN, TCEN, TA, TQ,
    PGEN, STOV, KEN);
`else
module rom_exit3 (CENY, AY, Q, CLK, CEN, A, EMA, TEN, BEN, TCEN, TA, TQ, PGEN, STOV,
    KEN);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 7;
  parameter WORDS = 1920;
  parameter MUX = 8;
  parameter WP_SIZE = 7 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;

  output  CENY;
  output [10:0] AY;
  output [6:0] Q;
  input  CLK;
  input  CEN;
  input [10:0] A;
  input [2:0] EMA;
  input  TEN;
  input  BEN;
  input  TCEN;
  input [10:0] TA;
  input [6:0] TQ;
  input  PGEN;
  input  STOV;
  input  KEN;
`ifdef POWER_PINS
  inout VDDE;
  inout VSSE;
`endif

  reg [6:0] mem [0:WORDS-1];
  reg [6:0] Q_int;
  reg LAST_CLK;

  reg NOT_CEN, NOT_A10, NOT_A9, NOT_A8, NOT_A7, NOT_A6, NOT_A5, NOT_A4, NOT_A3, NOT_A2;
  reg NOT_A1, NOT_A0, NOT_EMA2, NOT_EMA1, NOT_EMA0, NOT_TEN, NOT_TCEN, NOT_TA10, NOT_TA9;
  reg NOT_TA8, NOT_TA7, NOT_TA6, NOT_TA5, NOT_TA4, NOT_TA3, NOT_TA2, NOT_TA1, NOT_TA0;
  reg NOT_PGEN, NOT_STOV, NOT_KEN;
  reg NOT_CLK_PER, NOT_CLK_MINH, NOT_CLK_MINL;
  reg clk0_int;

  wire  CENY_;
  wire [10:0] AY_;
  wire [6:0] Q_;
 wire  CLK_;
  wire  CEN_;
  reg  CEN_int;
  wire [10:0] A_;
  reg [10:0] A_int;
  wire [2:0] EMA_;
  reg [2:0] EMA_int;
  wire  TEN_;
  reg  TEN_int;
  wire  BEN_;
  reg  BEN_int;
  wire  TCEN_;
  reg  TCEN_int;
  wire [10:0] TA_;
  reg [10:0] TA_int;
  wire [6:0] TQ_;
  reg [6:0] TQ_int;
  wire  PGEN_;
  reg  PGEN_int;
  wire  STOV_;
  reg  STOV_int;
  wire  KEN_;
  reg  KEN_int;

  assign CENY = CENY_; 
  assign AY[0] = AY_[0]; 
  assign AY[1] = AY_[1]; 
  assign AY[2] = AY_[2]; 
  assign AY[3] = AY_[3]; 
  assign AY[4] = AY_[4]; 
  assign AY[5] = AY_[5]; 
  assign AY[6] = AY_[6]; 
  assign AY[7] = AY_[7]; 
  assign AY[8] = AY_[8]; 
  assign AY[9] = AY_[9]; 
  assign AY[10] = AY_[10]; 
  assign Q[0] = Q_[0]; 
  assign Q[1] = Q_[1]; 
  assign Q[2] = Q_[2]; 
  assign Q[3] = Q_[3]; 
  assign Q[4] = Q_[4]; 
  assign Q[5] = Q_[5]; 
  assign Q[6] = Q_[6]; 
  assign CLK_ = CLK;
  assign CEN_ = CEN;
  assign A_[0] = A[0];
  assign A_[1] = A[1];
  assign A_[2] = A[2];
  assign A_[3] = A[3];
  assign A_[4] = A[4];
  assign A_[5] = A[5];
  assign A_[6] = A[6];
  assign A_[7] = A[7];
  assign A_[8] = A[8];
  assign A_[9] = A[9];
  assign A_[10] = A[10];
  assign EMA_[0] = EMA[0];
  assign EMA_[1] = EMA[1];
  assign EMA_[2] = EMA[2];
  assign TEN_ = TEN;
  assign BEN_ = BEN;
  assign TCEN_ = TCEN;
  assign TA_[0] = TA[0];
  assign TA_[1] = TA[1];
  assign TA_[2] = TA[2];
  assign TA_[3] = TA[3];
  assign TA_[4] = TA[4];
  assign TA_[5] = TA[5];
  assign TA_[6] = TA[6];
  assign TA_[7] = TA[7];
  assign TA_[8] = TA[8];
  assign TA_[9] = TA[9];
  assign TA_[10] = TA[10];
  assign TQ_[0] = TQ[0];
  assign TQ_[1] = TQ[1];
  assign TQ_[2] = TQ[2];
  assign TQ_[3] = TQ[3];
  assign TQ_[4] = TQ[4];
  assign TQ_[5] = TQ[5];
  assign TQ_[6] = TQ[6];
  assign PGEN_ = PGEN;
  assign STOV_ = STOV;
  assign KEN_ = KEN;

  assign `ARM_UD_DP CENY_ = TEN_ ? CEN_ : TCEN_;
  assign `ARM_UD_DP AY_ = TEN_ ? A_ : TA_;
  assign `ARM_UD_SEQ Q_ = BEN_ ? (PGEN_ ? {7{1'bx}} : Q_int) : TQ_;

  initial begin
    $readmemb("rom_exit3_verilog.rcf", mem);
  end

  always @ CLK_ begin
    if ((CLK_ === 1'bx || CLK_ === 1'bz) && (PGEN_ !== 1'b1 || CEN_ !== 1'b1)) begin
      Q_int = {7{1'bx}};
    end else if (CLK_ === 1'b1 && LAST_CLK === 1'b0) begin
      CEN_int = TEN_ ? CEN_ : TCEN_;
      A_int = TEN_ ? A_ : TA_;
      EMA_int = EMA_;
      TEN_int = TEN_;
      BEN_int = BEN_;
      TCEN_int = TCEN_;
      TA_int = TA_;
      TQ_int = TQ_;
      PGEN_int = PGEN_;
      STOV_int = STOV_;
      KEN_int = KEN_;
      clk0_int = 1'b0;
      // Reading port 0
      if (^{CEN_int, EMA_int, (STOV_int && !CEN_int), KEN_int} === 1'bx || (^A_int === 1'bx && CEN_int != 1'b1)) begin
        Q_int = {7{1'bx}};
      end else if (CEN_int == 1'b0) begin
        if (A_int > 1919)
          Q_int = {7{1'bx}};
        else
          Q_int = mem[A_int];
      end
      // done reading
    end
    LAST_CLK = CLK_;
  end

  always @ PGEN_ begin
    if (PGEN_ === 1'bx || PGEN_ === 1'bz) begin
      Q_int = {7{1'bx}};
    end else if (PGEN_ === 1'b1 && (CEN_ === 1'b0 || TCEN_ === 1'b0)) begin
      Q_int = {7{1'bx}};
    end
    if( PGEN_ === 1'b0 ) begin
      Q_int = {7{1'bx}};
    end
    PGEN_int = PGEN_;
  end

endmodule
`endcelldefine
`else
`celldefine
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
module rom_exit3 (VDDE, VSSE, CENY, AY, Q, CLK, CEN, A, EMA, TEN, BEN, TCEN, TA, TQ,
    PGEN, STOV, KEN);
`else
module rom_exit3 (CENY, AY, Q, CLK, CEN, A, EMA, TEN, BEN, TCEN, TA, TQ, PGEN, STOV,
    KEN);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 7;
  parameter WORDS = 1920;
  parameter MUX = 8;
  parameter WP_SIZE = 7 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;

  output  CENY;
  output [10:0] AY;
  output [6:0] Q;
  input  CLK;
  input  CEN;
  input [10:0] A;
  input [2:0] EMA;
  input  TEN;
  input  BEN;
  input  TCEN;
  input [10:0] TA;
  input [6:0] TQ;
  input  PGEN;
  input  STOV;
  input  KEN;
`ifdef POWER_PINS
  inout VDDE;
  inout VSSE;
`endif

  reg [6:0] mem [0:WORDS-1];
  reg [6:0] Q_int;
  reg LAST_CLK;

  reg NOT_CEN, NOT_A10, NOT_A9, NOT_A8, NOT_A7, NOT_A6, NOT_A5, NOT_A4, NOT_A3, NOT_A2;
  reg NOT_A1, NOT_A0, NOT_EMA2, NOT_EMA1, NOT_EMA0, NOT_TEN, NOT_TCEN, NOT_TA10, NOT_TA9;
  reg NOT_TA8, NOT_TA7, NOT_TA6, NOT_TA5, NOT_TA4, NOT_TA3, NOT_TA2, NOT_TA1, NOT_TA0;
  reg NOT_PGEN, NOT_STOV, NOT_KEN;
  reg NOT_CLK_PER, NOT_CLK_MINH, NOT_CLK_MINL;
  reg clk0_int;

  wire  CENY_;
  wire [10:0] AY_;
  wire [6:0] Q_;
 wire  CLK_;
  wire  CEN_;
  reg  CEN_int;
  wire [10:0] A_;
  reg [10:0] A_int;
  wire [2:0] EMA_;
  reg [2:0] EMA_int;
  wire  TEN_;
  reg  TEN_int;
  wire  BEN_;
  reg  BEN_int;
  wire  TCEN_;
  reg  TCEN_int;
  wire [10:0] TA_;
  reg [10:0] TA_int;
  wire [6:0] TQ_;
  reg [6:0] TQ_int;
  wire  PGEN_;
  reg  PGEN_int;
  wire  STOV_;
  reg  STOV_int;
  wire  KEN_;
  reg  KEN_int;

  buf B0(CENY, CENY_);
  buf B1(AY[0], AY_[0]);
  buf B2(AY[1], AY_[1]);
  buf B3(AY[2], AY_[2]);
  buf B4(AY[3], AY_[3]);
  buf B5(AY[4], AY_[4]);
  buf B6(AY[5], AY_[5]);
  buf B7(AY[6], AY_[6]);
  buf B8(AY[7], AY_[7]);
  buf B9(AY[8], AY_[8]);
  buf B10(AY[9], AY_[9]);
  buf B11(AY[10], AY_[10]);
  buf B12(Q[0], Q_[0]);
  buf B13(Q[1], Q_[1]);
  buf B14(Q[2], Q_[2]);
  buf B15(Q[3], Q_[3]);
  buf B16(Q[4], Q_[4]);
  buf B17(Q[5], Q_[5]);
  buf B18(Q[6], Q_[6]);
  buf B19(CLK_, CLK);
  buf B20(CEN_, CEN);
  buf B21(A_[0], A[0]);
  buf B22(A_[1], A[1]);
  buf B23(A_[2], A[2]);
  buf B24(A_[3], A[3]);
  buf B25(A_[4], A[4]);
  buf B26(A_[5], A[5]);
  buf B27(A_[6], A[6]);
  buf B28(A_[7], A[7]);
  buf B29(A_[8], A[8]);
  buf B30(A_[9], A[9]);
  buf B31(A_[10], A[10]);
  buf B32(EMA_[0], EMA[0]);
  buf B33(EMA_[1], EMA[1]);
  buf B34(EMA_[2], EMA[2]);
  buf B35(TEN_, TEN);
  buf B36(BEN_, BEN);
  buf B37(TCEN_, TCEN);
  buf B38(TA_[0], TA[0]);
  buf B39(TA_[1], TA[1]);
  buf B40(TA_[2], TA[2]);
  buf B41(TA_[3], TA[3]);
  buf B42(TA_[4], TA[4]);
  buf B43(TA_[5], TA[5]);
  buf B44(TA_[6], TA[6]);
  buf B45(TA_[7], TA[7]);
  buf B46(TA_[8], TA[8]);
  buf B47(TA_[9], TA[9]);
  buf B48(TA_[10], TA[10]);
  buf B49(TQ_[0], TQ[0]);
  buf B50(TQ_[1], TQ[1]);
  buf B51(TQ_[2], TQ[2]);
  buf B52(TQ_[3], TQ[3]);
  buf B53(TQ_[4], TQ[4]);
  buf B54(TQ_[5], TQ[5]);
  buf B55(TQ_[6], TQ[6]);
  buf B56(PGEN_, PGEN);
  buf B57(STOV_, STOV);
  buf B58(KEN_, KEN);

  assign CENY_ = TEN_ ? CEN_ : TCEN_;
  assign AY_ = TEN_ ? A_ : TA_;
   `ifdef ARM_FAULT_MODELING
     rom_exit3_error_injection u1(.CLK(CLK_), .Q_out(Q_), .A(A_int), .CEN(CEN_int), .TQ(TQ_), .BEN(BEN_), .Q_in(Q_int));
  `else
  assign Q_ = BEN_ ? (PGEN_ ? {7{1'bx}} : Q_int) : TQ_;
  `endif

  initial begin
    $readmemb("rom_exit3_verilog.rcf", mem);
  end

  always @ CLK_ begin
    if ((CLK_ === 1'bx || CLK_ === 1'bz) && (PGEN_ !== 1'b1 || CEN_ !== 1'b1)) begin
      Q_int = {7{1'bx}};
    end else if (CLK_ === 1'b1 && LAST_CLK === 1'b0) begin
      CEN_int = TEN_ ? CEN_ : TCEN_;
      A_int = TEN_ ? A_ : TA_;
      EMA_int = EMA_;
      TEN_int = TEN_;
      BEN_int = BEN_;
      TCEN_int = TCEN_;
      TA_int = TA_;
      TQ_int = TQ_;
      PGEN_int = PGEN_;
      STOV_int = STOV_;
      KEN_int = KEN_;
      clk0_int = 1'b0;
      // Reading port 0
      if (^{CEN_int, EMA_int, (STOV_int && !CEN_int), KEN_int} === 1'bx || (^A_int === 1'bx && CEN_int != 1'b1)) begin
        Q_int = {7{1'bx}};
      end else if (CEN_int == 1'b0) begin
        if (A_int > 1919)
          Q_int = {7{1'bx}};
        else
          Q_int = mem[A_int];
      end
      // done reading
    end
    LAST_CLK = CLK_;
  end

  always @ PGEN_ begin
    if (PGEN_ === 1'bx || PGEN_ === 1'bz) begin
      Q_int = {7{1'bx}};
    end else if (PGEN_ === 1'b1 && (CEN_ === 1'b0 || TCEN_ === 1'b0)) begin
      Q_int = {7{1'bx}};
    end
    if( PGEN_ === 1'b0 ) begin
      Q_int = {7{1'bx}};
    end
    PGEN_int = PGEN_;
  end

  reg globalNotifier0;
  initial globalNotifier0 = 1'b0;

  always @ globalNotifier0 begin
    if ($realtime == 0) begin
    end else if (CEN_int === 1'bx || EMA_int[0] === 1'bx || EMA_int[1] === 1'bx || 
      EMA_int[2] === 1'bx || KEN_int === 1'bx || PGEN_int === 1'bx || (STOV_int && !CEN_int) === 1'bx || 
      TEN_int === 1'bx || clk0_int === 1'bx) begin
      Q_int = {7{1'bx}};
    end else begin
    if (^A_int === 1'bx && CEN_int != 1'b1) begin
      Q_int = {7{1'bx}};
    end
   end
    globalNotifier0 = 1'b0;
  end

  always @ NOT_CEN begin
    CEN_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A10 begin
    A_int[10] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A9 begin
    A_int[9] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A8 begin
    A_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A7 begin
    A_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A6 begin
    A_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A5 begin
    A_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A4 begin
    A_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A3 begin
    A_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A2 begin
    A_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A1 begin
    A_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_A0 begin
    A_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMA2 begin
    EMA_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMA1 begin
    EMA_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_EMA0 begin
    EMA_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TEN begin
    TEN_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TCEN begin
    CEN_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TA10 begin
    A_int[10] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TA9 begin
    A_int[9] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TA8 begin
    A_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TA7 begin
    A_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TA6 begin
    A_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TA5 begin
    A_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TA4 begin
    A_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TA3 begin
    A_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TA2 begin
    A_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TA1 begin
    A_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_TA0 begin
    A_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_PGEN begin
    PGEN_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_STOV begin
    STOV_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_KEN begin
    KEN_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end

  always @ NOT_CLK_PER begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLK_MINH begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CLK_MINL begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end


  wire STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andKENeq0;
  wire STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andKENeq0;
  wire STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andKENeq0;
  wire STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andKENeq0;
  wire STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andKENeq0;
  wire STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andKENeq0;
  wire STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andKENeq0;
  wire STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andKENeq0;
  wire STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andKENeq1;
  wire STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andKENeq1;
  wire STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andKENeq1;
  wire STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andKENeq1;
  wire STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andKENeq1;
  wire STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andKENeq1;
  wire STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andKENeq1;
  wire STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andKENeq1;
  wire opTENeq1andCENeq0cporopTENeq0andTCENeq0cp;

  wire STOVeq1andKENeq0, STOVeq1andKENeq1, TENeq1andCENeq0, TENeq0andTCENeq0, TENeq1;
  wire TENeq0;

  assign STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andKENeq0 = 
         (!STOV) && (!EMA[2]) && (!EMA[1]) && (!EMA[0]) && (!KEN) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andKENeq0 = 
         (!STOV) && (!EMA[2]) && (!EMA[1]) && (EMA[0]) && (!KEN) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andKENeq0 = 
         (!STOV) && (!EMA[2]) && (EMA[1]) && (!EMA[0]) && (!KEN) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andKENeq0 = 
         (!STOV) && (!EMA[2]) && (EMA[1]) && (EMA[0]) && (!KEN) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andKENeq0 = 
         (!STOV) && (EMA[2]) && (!EMA[1]) && (!EMA[0]) && (!KEN) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andKENeq0 = 
         (!STOV) && (EMA[2]) && (!EMA[1]) && (EMA[0]) && (!KEN) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andKENeq0 = 
         (!STOV) && (EMA[2]) && (EMA[1]) && (!EMA[0]) && (!KEN) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andKENeq0 = 
         (!STOV) && (EMA[2]) && (EMA[1]) && (EMA[0]) && (!KEN) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andKENeq1 = 
         (!STOV) && (!EMA[2]) && (!EMA[1]) && (!EMA[0]) && (KEN) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andKENeq1 = 
         (!STOV) && (!EMA[2]) && (!EMA[1]) && (EMA[0]) && (KEN) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andKENeq1 = 
         (!STOV) && (!EMA[2]) && (EMA[1]) && (!EMA[0]) && (KEN) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andKENeq1 = 
         (!STOV) && (!EMA[2]) && (EMA[1]) && (EMA[0]) && (KEN) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andKENeq1 = 
         (!STOV) && (EMA[2]) && (!EMA[1]) && (!EMA[0]) && (KEN) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andKENeq1 = 
         (!STOV) && (EMA[2]) && (!EMA[1]) && (EMA[0]) && (KEN) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andKENeq1 = 
         (!STOV) && (EMA[2]) && (EMA[1]) && (!EMA[0]) && (KEN) && !(TEN ? CEN : TCEN);
  assign STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andKENeq1 = 
         (!STOV) && (EMA[2]) && (EMA[1]) && (EMA[0]) && (KEN) && !(TEN ? CEN : TCEN);
  assign STOVeq1andKENeq0 = 
         (STOV) && (!KEN) && !(TEN ? CEN : TCEN);
  assign STOVeq1andKENeq1 = 
         (STOV) && (KEN) && !(TEN ? CEN : TCEN);
  assign TENeq1andCENeq0 = 
         !(!TEN || CEN);
  assign TENeq0andTCENeq0 = 
         !(TEN || TCEN);
  assign opTENeq1andCENeq0cporopTENeq0andTCENeq0cp = 
         !(TEN ? CEN : TCEN);

  assign TENeq1 = TEN;
  assign TENeq0 = !TEN;

  specify
    if (CEN == 1'b0 && TCEN == 1'b1)
       (TEN => CENY) = (1.000, 1.000);
    if (CEN == 1'b1 && TCEN == 1'b0)
       (TEN => CENY) = (1.000, 1.000);
    if (TEN == 1'b1)
       (CEN => CENY) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TCEN => CENY) = (1.000, 1.000);
    if (A[10] == 1'b0 && TA[10] == 1'b1)
       (TEN => AY[10]) = (1.000, 1.000);
    if (A[10] == 1'b1 && TA[10] == 1'b0)
       (TEN => AY[10]) = (1.000, 1.000);
    if (A[9] == 1'b0 && TA[9] == 1'b1)
       (TEN => AY[9]) = (1.000, 1.000);
    if (A[9] == 1'b1 && TA[9] == 1'b0)
       (TEN => AY[9]) = (1.000, 1.000);
    if (A[8] == 1'b0 && TA[8] == 1'b1)
       (TEN => AY[8]) = (1.000, 1.000);
    if (A[8] == 1'b1 && TA[8] == 1'b0)
       (TEN => AY[8]) = (1.000, 1.000);
    if (A[7] == 1'b0 && TA[7] == 1'b1)
       (TEN => AY[7]) = (1.000, 1.000);
    if (A[7] == 1'b1 && TA[7] == 1'b0)
       (TEN => AY[7]) = (1.000, 1.000);
    if (A[6] == 1'b0 && TA[6] == 1'b1)
       (TEN => AY[6]) = (1.000, 1.000);
    if (A[6] == 1'b1 && TA[6] == 1'b0)
       (TEN => AY[6]) = (1.000, 1.000);
    if (A[5] == 1'b0 && TA[5] == 1'b1)
       (TEN => AY[5]) = (1.000, 1.000);
    if (A[5] == 1'b1 && TA[5] == 1'b0)
       (TEN => AY[5]) = (1.000, 1.000);
    if (A[4] == 1'b0 && TA[4] == 1'b1)
       (TEN => AY[4]) = (1.000, 1.000);
    if (A[4] == 1'b1 && TA[4] == 1'b0)
       (TEN => AY[4]) = (1.000, 1.000);
    if (A[3] == 1'b0 && TA[3] == 1'b1)
       (TEN => AY[3]) = (1.000, 1.000);
    if (A[3] == 1'b1 && TA[3] == 1'b0)
       (TEN => AY[3]) = (1.000, 1.000);
    if (A[2] == 1'b0 && TA[2] == 1'b1)
       (TEN => AY[2]) = (1.000, 1.000);
    if (A[2] == 1'b1 && TA[2] == 1'b0)
       (TEN => AY[2]) = (1.000, 1.000);
    if (A[1] == 1'b0 && TA[1] == 1'b1)
       (TEN => AY[1]) = (1.000, 1.000);
    if (A[1] == 1'b1 && TA[1] == 1'b0)
       (TEN => AY[1]) = (1.000, 1.000);
    if (A[0] == 1'b0 && TA[0] == 1'b1)
       (TEN => AY[0]) = (1.000, 1.000);
    if (A[0] == 1'b1 && TA[0] == 1'b0)
       (TEN => AY[0]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (A[10] => AY[10]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (A[9] => AY[9]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (A[8] => AY[8]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (A[7] => AY[7]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (A[6] => AY[6]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (A[5] => AY[5]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (A[4] => AY[4]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (A[3] => AY[3]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (A[2] => AY[2]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (A[1] => AY[1]) = (1.000, 1.000);
    if (TEN == 1'b1)
       (A[0] => AY[0]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TA[10] => AY[10]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TA[9] => AY[9]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TA[8] => AY[8]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TA[7] => AY[7]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TA[6] => AY[6]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TA[5] => AY[5]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TA[4] => AY[4]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TA[3] => AY[3]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TA[2] => AY[2]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TA[1] => AY[1]) = (1.000, 1.000);
    if (TEN == 1'b0)
       (TA[0] => AY[0]) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b0)
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b0)
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b0 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b0 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b0 && KEN == 1'b1)
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[6] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[5] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[4] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[3] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[2] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[1] : 1'b0)) = (1.000, 1.000);
    if (PGEN == 1'b0 && BEN == 1'b1 && EMA[2] == 1'b1 && EMA[1] == 1'b1 && EMA[0] == 1'b1 && KEN == 1'b1)
       (posedge CLK => (Q[0] : 1'b0)) = (1.000, 1.000);
    if (TQ[6] == 1'b1)
       (BEN => Q[6]) = (1.000, 1.000);
    if (TQ[6] == 1'b0)
       (BEN => Q[6]) = (1.000, 1.000);
    if (TQ[5] == 1'b1)
       (BEN => Q[5]) = (1.000, 1.000);
    if (TQ[5] == 1'b0)
       (BEN => Q[5]) = (1.000, 1.000);
    if (TQ[4] == 1'b1)
       (BEN => Q[4]) = (1.000, 1.000);
    if (TQ[4] == 1'b0)
       (BEN => Q[4]) = (1.000, 1.000);
    if (TQ[3] == 1'b1)
       (BEN => Q[3]) = (1.000, 1.000);
    if (TQ[3] == 1'b0)
       (BEN => Q[3]) = (1.000, 1.000);
    if (TQ[2] == 1'b1)
       (BEN => Q[2]) = (1.000, 1.000);
    if (TQ[2] == 1'b0)
       (BEN => Q[2]) = (1.000, 1.000);
    if (TQ[1] == 1'b1)
       (BEN => Q[1]) = (1.000, 1.000);
    if (TQ[1] == 1'b0)
       (BEN => Q[1]) = (1.000, 1.000);
    if (TQ[0] == 1'b1)
       (BEN => Q[0]) = (1.000, 1.000);
    if (TQ[0] == 1'b0)
       (BEN => Q[0]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[6] => Q[6]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[5] => Q[5]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[4] => Q[4]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[3] => Q[3]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[2] => Q[2]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[1] => Q[1]) = (1.000, 1.000);
    if (BEN == 1'b0)
       (TQ[0] => Q[0]) = (1.000, 1.000);

// Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $period(posedge CLK, 3.000, NOT_CLK_PER);
   `else
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andKENeq0, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andKENeq0, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andKENeq0, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andKENeq0, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andKENeq0, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andKENeq0, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andKENeq0, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andKENeq0, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq0andEMA0eq0andKENeq1, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq0andEMA0eq1andKENeq1, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq1andEMA0eq0andKENeq1, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq0andEMA1eq1andEMA0eq1andKENeq1, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq0andEMA0eq0andKENeq1, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq0andEMA0eq1andKENeq1, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq1andEMA0eq0andKENeq1, 3.000, NOT_CLK_PER);
       $period(posedge CLK &&& STOVeq0andEMA2eq1andEMA1eq1andEMA0eq1andKENeq1, 3.000, NOT_CLK_PER);
       $period(negedge CLK &&& STOVeq1andKENeq0, 3.000, NOT_CLK_PER);
       $period(negedge CLK &&& STOVeq1andKENeq1, 3.000, NOT_CLK_PER);
   `endif

// Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $width(posedge CLK, 1.000, 0, NOT_CLK_MINH);
       $width(negedge CLK, 1.000, 0, NOT_CLK_MINL);
   `else
       $width(posedge CLK, 1.000, 0, NOT_CLK_MINH);
       $width(negedge CLK, 1.000, 0, NOT_CLK_MINL);
   `endif

    $setuphold(posedge CLK &&& TENeq1, posedge CEN, 1.000, 0.500, NOT_CEN);
    $setuphold(posedge CLK &&& TENeq1, negedge CEN, 1.000, 0.500, NOT_CEN);
    $setuphold(negedge PGEN &&& TENeq1, negedge CEN, 0.000, 0.500, NOT_PGEN);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, posedge A[10], 1.000, 0.500, NOT_A10);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, posedge A[9], 1.000, 0.500, NOT_A9);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, posedge A[8], 1.000, 0.500, NOT_A8);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, posedge A[7], 1.000, 0.500, NOT_A7);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, posedge A[6], 1.000, 0.500, NOT_A6);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, posedge A[5], 1.000, 0.500, NOT_A5);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, posedge A[4], 1.000, 0.500, NOT_A4);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, posedge A[3], 1.000, 0.500, NOT_A3);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, posedge A[2], 1.000, 0.500, NOT_A2);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, posedge A[1], 1.000, 0.500, NOT_A1);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, posedge A[0], 1.000, 0.500, NOT_A0);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, negedge A[10], 1.000, 0.500, NOT_A10);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, negedge A[9], 1.000, 0.500, NOT_A9);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, negedge A[8], 1.000, 0.500, NOT_A8);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, negedge A[7], 1.000, 0.500, NOT_A7);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, negedge A[6], 1.000, 0.500, NOT_A6);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, negedge A[5], 1.000, 0.500, NOT_A5);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, negedge A[4], 1.000, 0.500, NOT_A4);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, negedge A[3], 1.000, 0.500, NOT_A3);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, negedge A[2], 1.000, 0.500, NOT_A2);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, negedge A[1], 1.000, 0.500, NOT_A1);
    $setuphold(posedge CLK &&& TENeq1andCENeq0, negedge A[0], 1.000, 0.500, NOT_A0);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, posedge EMA[2], 1.000, 0.500, NOT_EMA2);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, posedge EMA[1], 1.000, 0.500, NOT_EMA1);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, posedge EMA[0], 1.000, 0.500, NOT_EMA0);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, negedge EMA[2], 1.000, 0.500, NOT_EMA2);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, negedge EMA[1], 1.000, 0.500, NOT_EMA1);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, negedge EMA[0], 1.000, 0.500, NOT_EMA0);
    $setuphold(posedge CLK, posedge TEN, 1.000, 0.500, NOT_TEN);
    $setuphold(posedge CLK, negedge TEN, 1.000, 0.500, NOT_TEN);
    $setuphold(posedge CLK &&& TENeq0, posedge TCEN, 1.000, 0.500, NOT_TCEN);
    $setuphold(posedge CLK &&& TENeq0, negedge TCEN, 1.000, 0.500, NOT_TCEN);
    $setuphold(negedge PGEN &&& TENeq0, negedge TCEN, 0.000, 0.500, NOT_PGEN);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, posedge TA[10], 1.000, 0.500, NOT_TA10);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, posedge TA[9], 1.000, 0.500, NOT_TA9);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, posedge TA[8], 1.000, 0.500, NOT_TA8);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, posedge TA[7], 1.000, 0.500, NOT_TA7);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, posedge TA[6], 1.000, 0.500, NOT_TA6);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, posedge TA[5], 1.000, 0.500, NOT_TA5);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, posedge TA[4], 1.000, 0.500, NOT_TA4);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, posedge TA[3], 1.000, 0.500, NOT_TA3);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, posedge TA[2], 1.000, 0.500, NOT_TA2);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, posedge TA[1], 1.000, 0.500, NOT_TA1);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, posedge TA[0], 1.000, 0.500, NOT_TA0);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, negedge TA[10], 1.000, 0.500, NOT_TA10);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, negedge TA[9], 1.000, 0.500, NOT_TA9);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, negedge TA[8], 1.000, 0.500, NOT_TA8);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, negedge TA[7], 1.000, 0.500, NOT_TA7);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, negedge TA[6], 1.000, 0.500, NOT_TA6);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, negedge TA[5], 1.000, 0.500, NOT_TA5);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, negedge TA[4], 1.000, 0.500, NOT_TA4);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, negedge TA[3], 1.000, 0.500, NOT_TA3);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, negedge TA[2], 1.000, 0.500, NOT_TA2);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, negedge TA[1], 1.000, 0.500, NOT_TA1);
    $setuphold(posedge CLK &&& TENeq0andTCENeq0, negedge TA[0], 1.000, 0.500, NOT_TA0);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, posedge PGEN, 1.000, 0.500, NOT_PGEN);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, negedge PGEN, 1.000, 0.500, NOT_PGEN);
    $setuphold(posedge CEN &&& TENeq1, posedge PGEN, 0.000, 0.500, NOT_PGEN);
    $setuphold(posedge TCEN &&& TENeq0, posedge PGEN, 0.000, 0.500, NOT_PGEN);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, posedge STOV, 1.000, 0.500, NOT_STOV);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, negedge STOV, 1.000, 0.500, NOT_STOV);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, posedge KEN, 1.000, 0.500, NOT_KEN);
    $setuphold(posedge CLK &&& opTENeq1andCENeq0cporopTENeq0andTCENeq0cp, negedge KEN, 1.000, 0.500, NOT_KEN);
  endspecify


endmodule
`endcelldefine
`endif
`timescale 1ns/1ps
module rom_exit3_error_injection (Q_out, Q_in, CLK, A, CEN, BEN, TQ);
   output [6:0] Q_out;
   input [6:0] Q_in;
   input CLK;
   input [10:0] A;
   input CEN;
   input BEN;
   input [6:0] TQ;
   parameter LEFT_RED_COLUMN_FAULT = 2'd1;
   parameter RIGHT_RED_COLUMN_FAULT = 2'd2;
   parameter NO_RED_FAULT = 2'd0;
   reg [6:0] Q_out;
   reg entry_found;
   reg list_complete;
   reg [18:0] fault_table [239:0];
   reg [18:0] fault_entry;
initial
begin
   `ifdef DUT
      `define pre_pend_path TB.DUT_inst.CHIP
   `else
       `define pre_pend_path TB.CHIP
   `endif
   `ifdef ARM_NONREPAIRABLE_FAULT
      `pre_pend_path.READONLY_LVISION_MBISTPG_ASSEMBLY_UNDER_TEST_INST.MEM0_MEM_INST.u1.add_fault(11'd1446,3'd4,2'd1,2'd0);
   `endif
end
   task add_fault;
   //This task injects fault in memory
   //In order to inject fault in redundant column for Bit 0 to 2, column address
   //should have value in range of 4 to 7
   //In order to inject fault in redundant column for Bit 3 to 6, column address
   //should have value in range of 0 to 3
      input [10:0] address;
      input [2:0] bitPlace;
      input [1:0] fault_type;
      input [1:0] red_fault;
 
      integer i;
      reg done;
   begin
      done = 1'b0;
      i = 0;
      while ((!done) && i < 239)
      begin
         fault_entry = fault_table[i];
         if (fault_entry[0] === 1'b0 || fault_entry[0] === 1'bx)
         begin
            fault_entry[0] = 1'b1;
            fault_entry[2:1] = red_fault;
            fault_entry[4:3] = fault_type;
            fault_entry[7:5] = bitPlace;
            fault_entry[18:8] = address;
            fault_table[i] = fault_entry;
            done = 1'b1;
         end
         i = i+1;
      end
   end
   endtask
//This task removes all fault entries injected by user
task remove_all_faults;
   integer i;
begin
   for (i = 0; i < 240; i=i+1)
   begin
      fault_entry = fault_table[i];
      fault_entry[0] = 1'b0;
      fault_table[i] = fault_entry;
   end
end
endtask
task bit_error;
// This task is used to inject error in memory and should be called
// only from current module.
//
// This task injects error depending upon fault type to particular bit
// of the output
   inout [6:0] q_int;
   input [1:0] fault_type;
   input [2:0] bitLoc;
begin
   if (fault_type === 2'd0)
      q_int[bitLoc] = 1'b0;
   else if (fault_type === 2'd1)
      q_int[bitLoc] = 1'b1;
   else
      q_int[bitLoc] = ~q_int[bitLoc];
end
endtask
task error_injection_on_output;
// This function goes through error injection table for every
// read cycle and corrupts Q output if fault for the particular
// address is present in fault table
//
// If fault is redundant column is detected, this task corrupts
// Q output in read cycle
//
// If fault is repaired using repair bus, this task does not
// courrpt Q output in read cycle
//
   output [6:0] Q_output;
   reg list_complete;
   integer i;
   reg [7:0] row_address;
   reg [2:0] column_address;
   reg [2:0] bitPlace;
   reg [1:0] fault_type;
   reg [1:0] red_fault;
   reg valid;
begin
   entry_found = 1'b0;
   list_complete = 1'b0;
   i = 0;
   Q_output = Q_in;
   while(!list_complete)
   begin
      fault_entry = fault_table[i];
      {row_address, column_address, bitPlace, fault_type, red_fault, valid} = fault_entry;
      i = i + 1;
      if (valid == 1'b1)
      begin
         if (red_fault === NO_RED_FAULT)
         begin
            if (row_address == A[10:3] && column_address == A[2:0])
            begin
               if (bitPlace < 3)
                  bit_error(Q_output,fault_type, bitPlace);
               else if (bitPlace >= 3 )
                  bit_error(Q_output,fault_type, bitPlace);
            end
         end
      end
      else
         list_complete = 1'b1;
      end
   end
   endtask
   always @ (Q_in or CLK or A or CEN or BEN or TQ)
   begin
   if (CEN === 1'b0 && BEN === 1'b1)
      error_injection_on_output(Q_out);
   else if (BEN === 1'b0)
      Q_out = TQ;
   else
      Q_out = Q_in;
   end
endmodule
