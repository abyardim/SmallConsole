-- maps IO registers and memories to memory locations

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MemoryMapper is
    Port (  clk_in: in std_logic;
            sw_in : in std_logic_vector( 15 downto 0);
            
            anode_out : out std_logic_vector( 3 downto 0);
            dp_out : out std_logic;
            seg_out: out std_logic_vector( 6 downto 0);
            
            led_out: out std_logic_vector( 15 downto 0);
            
            gplatch, gpclock : out std_logic;
            gpdata : in std_logic;
            
            gplatch2, gpclock2 : out std_logic;
            gpdata2 : in std_logic;
            
            vram_clk : out std_logic;
            vram_out : in std_logic_vector( 15 downto 0);
            vram_in : out std_logic_vector( 15 downto 0);
            vram_write : out std_logic;
            vram_addr : out std_logic_vector(16 downto 0);
            
            address : in std_logic_vector( 15 downto 0);
            data_in : in std_logic_vector( 15 downto 0);
            write : in std_logic;
            data_out : out std_logic_vector( 15 downto 0));
end MemoryMapper;

architecture Behavioral of MemoryMapper is

    component SevenSegmentOut
       Port ( digit0, digit1, digit2, digit3: in std_logic_vector( 7 downto 0);
              clk_in: in std_logic;
              anode_out : out std_logic_vector( 3 downto 0);
              dp_out : out std_logic;
              seg_out: out std_logic_vector( 6 downto 0));
    end component;     

    component SinglePortRAM
            generic ( WORD_SIZE : natural;
                      ADDR_BITS : natural;
                      INIT_FILE : STRING);
    
            port ( clk : in std_logic;
                   addr : in std_logic_vector( ADDR_BITS - 1 downto 0);
                   en : in std_logic;
                   we : in std_logic;
                   din : in std_logic_vector( WORD_SIZE - 1 downto 0);
                   dout : out std_logic_vector( WORD_SIZE - 1 downto 0)
                 );
    end component;
    
    signal ram_addr : std_logic_vector( 14 downto 0);
    signal ram_in : std_logic_vector( 15 downto 0);
    signal ram_out : std_logic_vector( 15 downto 0);
    signal ram_wrt : std_logic := '0';
    
    component ControllerIn
        Port ( clk : in STD_LOGIC; -- 100 MHz clock in
               nes_data    : in std_logic; -- NES data read
               nes_latch   : out std_logic := '0'; -- latch command
               nes_clk: out std_logic := '0'; -- controller pulse clock
               keys : out STD_LOGIC_VECTOR (7 downto 0)); -- key states
    end component;
    
    -- controllers
    signal controllerState1 : std_logic_vector( 7 downto 0);
    signal controllerState2 : std_logic_vector( 7 downto 0);
    
    -- on board switches / LEDs
    signal leds : std_logic_vector( 15 downto 0) := ( others => '0');
    signal sw_word : std_logic_vector( 15 downto 0);

    -- SSD states
    signal seg_word1 : std_logic_vector( 7 downto 0) := "11111111";
    signal seg_word2 : std_logic_vector( 7 downto 0) := "11111111";
    signal seg_word3 : std_logic_vector( 7 downto 0) := "11111111";
    signal seg_word4 : std_logic_vector( 7 downto 0) := "11111111";
    
    -- current tile reference
    signal tileref : std_logic_vector( 5 downto 0) := "000000";
begin

    ram : SinglePortRAM generic map ( 16, 15, "ramInit.mem") 
                        port map ( clk_in, ram_addr, '1', ram_wrt, ram_in, ram_out);

    controller_reader1 : ControllerIn port map( clk_in, gpdata, gplatch, gpclock, controllerState1);
    controller_reader2 : ControllerIn port map( clk_in, gpdata2, gplatch2, gpclock2, controllerState2);
    
    seven_segment : SevenSegmentOut port map ( seg_word1, seg_word2, seg_word3, seg_word4, clk_in, anode_out, dp_out, seg_out); 
    
    led_out <= leds;
    
    -- block ram ports:
    ram_wrt <= write when address( 15) = '0' else
               '0';  
    ram_in <= data_in;
    ram_addr <= address( 14 downto 0);
    
    -- vram ports
    vram_clk <= clk_in;
    vram_in <= data_in;
    vram_addr <= "1" & tileref & address( 9 downto 0) when address( 15 downto 12) = "1101" else -- tile data
                 "01-------" & address( 7 downto 0) when address( 15 downto 12) = "1100" else    -- screen data
                 "00-----------" & address( 3 downto 0) when address( 15 downto 12) = "1111" else
                 ( others => '0');
                 
    vram_write <= write when address( 15 downto 14) = "11" else
                  '0';
    
    -- the top memory out port:
    data_out <= ram_out when address( 15) = '0' else
                vram_out when address( 15 downto 13) = "110" or address( 15 downto 12) = "1111" else
                
                "00000000" & controllerState1 when address( 15 downto 14) = "10" and address( 2 downto 0) = "110" else
                "00000000" & controllerState2 when address( 15 downto 14) = "10" and address( 2 downto 0) = "111" else
                
                sw_word when address( 15 downto 14) = "10" and address( 2 downto 0) = "100" else
                leds when address( 15 downto 14) = "10" and address( 2 downto 0) = "101" else
                
                "00000000" & seg_word1 when address( 15 downto 14) = "10" and address( 2 downto 0) = "000" else
                "00000000" & seg_word2 when address( 15 downto 14) = "10" and address( 2 downto 0) = "001" else
                "00000000" & seg_word3 when address( 15 downto 14) = "10" and address( 2 downto 0) = "010" else
                "00000000" & seg_word4 when address( 15 downto 14) = "10" and address( 2 downto 0) = "011" else
                
                "0000000000" & tileref when address( 15 downto 12) = "1110" else

                ( others => '0');
                
    
    process ( clk_in)
    begin
        if rising_edge( clk_in) then
            sw_word <= sw_in;
            
            if address( 15 downto 14) = "10" and address( 2 downto 0) = "101" and write = '1' then
                leds <= data_in;
            elsif address( 15 downto 14) = "10" and address( 2 downto 0) = "000" and write = '1' then
                seg_word1 <= data_in( 7 downto 0);
            elsif address( 15 downto 14) = "10" and address( 2 downto 0) = "001" and write = '1' then
                seg_word2 <= data_in( 7 downto 0);
            elsif address( 15 downto 14) = "10" and address( 2 downto 0) = "010" and write = '1' then
                seg_word3 <= data_in( 7 downto 0);
            elsif address( 15 downto 14) = "10" and address( 2 downto 0) = "011" and write = '1' then
                seg_word4 <= data_in( 7 downto 0);
            elsif address( 15 downto 12) = "1110" and write = '1' then
                tileref <= data_in( 5 downto 0);
            end if;
             
        end if;        
    end process;

end Behavioral;
