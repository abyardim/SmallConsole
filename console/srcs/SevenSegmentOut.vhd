-- automatically drives the SSD for the given digits

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SevenSegmentOut is
    Port ( digit0, digit1, digit2, digit3: in std_logic_vector( 7 downto 0);
           clk_in: in std_logic;
           anode_out : out std_logic_vector( 3 downto 0);
           dp_out : out std_logic;
           seg_out: out std_logic_vector( 6 downto 0));
end SevenSegmentOut;

architecture Behavioral of SevenSegmentOut is
    signal state: std_logic_vector( 0 to 1) := "00";
    signal clk_count: std_logic_vector( 16 downto 0) := "00000000000000000";
    constant clk_div : std_logic_vector( 16 downto 0) := "11000000000000000";
begin

    dp_out <= digit0( 7) when state = "00" else -- and digit0(7) = '1' else
              digit1( 7) when state = "01" else -- and digit1(7) = '1' else
              digit2( 7) when state = "10" else -- and digit2(7) = '1' else
              digit3( 7) when state = "11" else -- and digit3(7) = '1' else
              '1';     
    
    with state select anode_out <=
                "1110" when "00",
                "1101" when "01",
                "1011" when "10",
                "0111" when "11";
    
    seg_out <=  digit0( 6 downto 0) when state = "00" else -- and digit0(7) = '1' else
                digit1( 6 downto 0) when state = "01" else -- and digit1(7) = '1' else
                digit2( 6 downto 0) when state = "10" else -- and digit2(7) = '1' else
                digit3( 6 downto 0) when state = "11" else -- and digit3(7) = '1' else
                "1111111";                 
    
    process ( clk_in)
    begin
        if rising_edge( clk_in) then
            clk_count <= clk_count + 1;
            
            if ( clk_count = clk_div) then
                state <= state + 1;
                clk_count <= "00000000000000000"; ------ TODO can omit / optimize
            end if;
        end if;
    end process;

end Behavioral;
