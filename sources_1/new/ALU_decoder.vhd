----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2023 01:02:25 PM
-- Design Name: 
-- Module Name: ALU_decoder - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU_decoder is
Port (
--******** Controlpath ulazi *********
alu_2bit_op_i : in std_logic_vector(1 downto 0);
--******** Polja instrukcije *******
funct3_i : in std_logic_vector (2 downto 0);
funct7_i : in std_logic_vector (6 downto 0);
--******** Datapath izlazi ********
alu_op_o : out std_logic_vector(4 downto 0)
);
end ALU_decoder;

architecture Behavioral of ALU_decoder is

begin

aluop_gen: process(alu_2bit_op_i, funct3_i, funct7_i)
begin
 
  if(alu_2bit_op_i = "00") then                      -- lw, sw, sh, sb instrukcija
   alu_op_o <= "00010";
  elsif(alu_2bit_op_i  = "10") then 
    if(funct7_i = "0000000" and funct3_i = "000") then     -- add instrukcija
      alu_op_o <= "00010";                                  -- sabiranje
    elsif(funct7_i = "0100000" and funct3_i = "000") then  -- sub instrukcija 
      alu_op_o <= "00110";                                  -- oduzimanje
    elsif(funct7_i = "0000000" and funct3_i = "111") then  -- and instrukcija
      alu_op_o <= "00000";                                  -- and 
    else                                                    -- or instrukcija
      alu_op_o <= "00001";                                  -- or 
    end if;
  elsif(alu_2bit_op_i = "01") then         --beq instrukcija
   alu_op_o <= "00110";                    --sv1 je
  else                                     --addi instrukcija
   alu_op_o <= "00010";                    --sabiranje   
  end if;
 
end process;


end Behavioral;
