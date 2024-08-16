module DSP (A,B,D,C,CLK,CARRYIN,OPMODE,BCIN,RSTA,RSTB,RSTM,
RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE,CEA,CEB,CEM,CEP,CEC,CED,
CECARRYIN,CEOPMODE,PCIN,BCOUT,PCOUT,P,M,CARRYOUT,CARRYOUTF);
parameter A0REG=0;
parameter A1REG=1 ; 
parameter B0REG=0;  
parameter B1REG=1;
parameter CREG=1; 
parameter DREG=1; 
parameter MREG=1; 
parameter PREG=1; 
parameter CARRYINREG=1; 
parameter CARRYOUTREG=1; 
parameter OPMODEREG=1; 
parameter CARRYINSEL="OPMODE5";
parameter B_INPUT ="DIRECT";
parameter RSTTYPE ="SYNC";
input [17:0] A,B,D,BCIN;
input [47:0] C,PCIN;
input [7:0] OPMODE;
input CLK,CARRYIN,RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,
RSTOPMODE,RSTP,CEA,CEB,CECARRYIN,CEC,CED,CEM,CEOPMODE,CEP;
output [17:0] BCOUT;
output [47:0]PCOUT;
output[47:0] P;
output[35:0] M;
output CARRYOUT,CARRYOUTF;
wire[17:0]D_out,B0_out,A0_out,A1_out
,B_out,PRE_ADD_OUT;
reg[17:0] B0_in,B1_in;
wire[35:0]mult_out;
wire[7:0]OPMODE_out;
wire CYin;
wire cin,cout;
reg [47:0] x_out,z_out;
wire [47:0]POST_ADD_OUT,C_out;
/*  OPMODEreg    */
mux_dff#(.WIDTH(8),.sync(RSTTYPE),.sel(OPMODEREG)) 
OPMODE_REG(.CLK(CLK),.rst(RSTOPMODE),.in(OPMODE),.out(OPMODE_out),.CE(CEOPMODE));
/*  DREG   */
mux_dff#(.WIDTH(18),.sync(RSTTYPE),.sel(DREG)) 
D_REG(.CLK(CLK),.rst(RSTD),.in(D),.out(D_out),.CE(CED));
/*  A0REG   */
mux_dff#(.WIDTH(18),.sync(RSTTYPE),.sel(A0REG)) 
A0_REG(.CLK(CLK),.rst(RSTA),.in(A),.out(A0_out),.CE(CEA));
/*  SELECT INPUT OF B0*/
always @(*) begin
        if (B_INPUT == "DIRECT") 
            B0_in =B ;
         else if (B_INPUT == "CASCADE") 
            B0_in = BCIN;
         else 
            B0_in = 0;
    end

/*  B0REG    */
mux_dff#(.WIDTH(18),.sync(RSTTYPE),.sel(B0REG)) 
B0_REG(.CLK(CLK),.rst(RSTB),.in(B0_in),.out(B0_out),.CE(CEB));
/*  CREG   */
mux_dff#(.WIDTH(48),.sync(RSTTYPE),.sel(CREG)) 
C_REG(.CLK(CLK),.rst(RSTC),.in(C),.out(C_out),.CE(CEC));
/*  SELECT ADD OR SUB BEFORE B1   */
assign PRE_ADD_OUT=(OPMODE_out[6]==1)? (D_out-B0_out):(D_out+B0_out);
    /*  SELECT INPUT B1 */
always @(*) begin
    if (OPMODE_out[4] == 0) 
            B1_in = B0_out;
         else 
            B1_in = PRE_ADD_OUT;
end

/*  B1REG    */
mux_dff#(.WIDTH(18),.sync(RSTTYPE),.sel(B1REG)) 
B1_REG(.CLK(CLK),.rst(RSTB),.in(B1_in),.out(BCOUT),.CE(CEB));
/*  A1REG    */
mux_dff#(.WIDTH(18),.sync(RSTTYPE),.sel(A1REG)) 
A1_REG(.CLK(CLK),.rst(RSTA),.in(A0_out),.out(A1_out),.CE(CEA));
/*  MULTIPLY    */
assign mult_out = BCOUT*A1_out;
/*  Mreg    */
mux_dff#(.WIDTH(36),.sync(RSTTYPE),.sel(MREG)) 
M_REG(.CLK(CLK),.rst(RSTM),.in(mult_out),.out(M),.CE(CEM));
/*  CARRYIN SEL    */
assign CYin=(CARRYINSEL=="OPMODE5")? OPMODE_out[5]:(CARRYINSEL=="CARRYIN")?CARRYIN:0;
/*  CYI   */
mux_dff#(.WIDTH(1),.sync(RSTTYPE),.sel(CARRYINREG)) 
CYI(.CLK(CLK),.rst(RSTCARRYIN),.in(CYin),.out(cin),.CE(CECARRYIN));
/*  selector X  */
always @(*) begin
        if (OPMODE_out[1:0] == 0) 
        x_out=0;
        else if (OPMODE_out[1:0] == 1) 
        x_out={12'b0,M};
        else if (OPMODE_out[1:0] == 2)
         x_out=PCOUT;   
        else
        x_out={D_out[11:0], A1_out[17:0],BCOUT[17:0]};
    end

/*  selector Z  */


always @(*) begin
        if (OPMODE_out[3:2] == 0) 
        z_out=0;
        else if (OPMODE_out[3:2] == 1) 
        z_out=PCIN;
        else if (OPMODE_out[3:2] == 2)
        z_out=PCOUT;   
        else
        z_out={12'b0,C_out};
    end
/*   POST ADDER    */
assign {cout,POST_ADD_OUT}=(OPMODE_out[7]==1)? (z_out-(x_out+cin)):z_out+x_out+cin;
/*  Preg    */
mux_dff#(.WIDTH(48),.sync(RSTTYPE),.sel(PREG)) 
P_REG(.CLK(CLK),.rst(RSTP),.in(POST_ADD_OUT),.out(P),.CE(CEP));
/*  CYO   */
mux_dff#(.WIDTH(1),.sync(RSTTYPE),.sel(CARRYOUTREG)) 
CYO_REG(.CLK(CLK),.rst(RSTCARRYIN),.in(cout),.out(CARRYOUT),.CE(CECARRYIN));
/*  Copies   */
assign PCOUT=P;
assign CARRYOUTF=CARRYOUT;
endmodule