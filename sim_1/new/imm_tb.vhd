----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/24/2023 09:57:18 PM
-- Design Name: 
-- Module Name: imm_tb - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity imm_tb is
--  Port ( );
end imm_tb;

architecture Behavioral of imm_tb is
        signal instr, extend : std_logic_vector(31 downto 0);
begin

duv: entity work.immediate 
 Port map(
 instruction_i => instr,
 immediate_extended_o => extend
 );

stim_gen: process
begin
instr <= "00101011111101011011110110000011", "11100011100011111111111110010011" after 300ns,
         "11000101011011111111011001100011" after 600ns, "00111111111111111111010110100011" after 800ns;
wait;
end process;

end Behavioral;
