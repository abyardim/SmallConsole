-- talks with the NES controller through the PMOD pins

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.std_logic_unsigned.ALL;


entity ControllerIn is
    Port ( clk : in STD_LOGIC; -- 100 MHz clock in
           nes_data    : in std_logic; -- NES data read
           nes_latch   : out std_logic := '0'; -- latch command
           nes_clk: out std_logic := '0'; -- controller pulse clock
           keys : out STD_LOGIC_VECTOR (7 downto 0)); -- key states
end ControllerIn;

architecture Behavioral of ControllerIn is

    type state_type is (s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s17,s18);
    
    signal state, state_next : state_type;
    
    signal clock_count : std_logic_vector ( 17 downto 0);
    signal nes_clock : std_logic;
    
    -- the next set of nes keys
    signal keys_next : std_logic_vector( 7 downto 0);

begin

    process ( clk)
    begin
        if rising_edge( clk) then
            clock_count <= clock_count + 1;
            keys <= keys_next;
            state <= state_next;
        end if;
    end process;

    nes_clock <= '1' when clock_count = 0 else '0';

    process ( clk)
    begin
        if nes_clock = '1' and rising_edge( clk) then
            nes_latch <= '0';	--default outputs
            nes_clk <= '0';
                    
            case state is        
                when s0 =>
                    state_next <= s1;
                    nes_latch <= '1';
                when s1 =>
                    state_next <= s2;
                    nes_latch <= '0';
                    keys_next( 0) <= not nes_data;  ----- A
                when s2 =>
                    state_next <= s3;
                    nes_clk <= '1';
                when s3 =>
                    state_next <= s4;
                    nes_clk <= '0';
                    keys_next( 1) <= not nes_data;  ----- B
                when s4 =>
                    state_next <= s5;
                    nes_clk <= '1';
                when s5 =>
                    state_next <= s6;
                    nes_clk <= '0';
                    keys_next( 6) <= not nes_data;  ----- select               
                when s6 =>
                    state_next <= s7;
                    nes_clk <= '1';
                when s7 =>
                    state_next <= s8;
                    nes_clk <= '0';
                    keys_next( 7) <= not nes_data;  ---- start
                when s8 =>
                    state_next <= s9;
                    nes_clk <= '1';
                when s9 =>
                    state_next <= s10;
                    nes_clk <= '0';
                    keys_next( 2) <= not nes_data;  ----- up
                when s10 =>
                    state_next <= s11;
                    nes_clk <= '1';
                when s11=>
                    state_next <= s12;
                    nes_clk <= '0';
                    keys_next( 3) <= not nes_data;  ---- down
                when s12 =>
                    state_next <= s13;
                    nes_clk <= '1';
                when s13 =>
                    state_next <= s14;
                    nes_clk <= '0';
                    keys_next( 4) <= not nes_data;  ---- left
                when s14 =>
                    state_next <= s15;
                    nes_clk <= '1';
                when s15 =>
                    state_next <= s16;
                    nes_clk <= '0';
                    keys_next( 5) <= not nes_data;  ---- right
                when s16 =>
                    state_next <= s17;
                    nes_clk <= '1';
                when s17 =>
                    state_next <= s18;
                    nes_clk <= '0';
                when s18 =>
                    state_next <= s0;      
            end case;  
         end if;           
    end process;

end Behavioral;
