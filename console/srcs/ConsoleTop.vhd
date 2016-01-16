-- The top most entry of the design
-- Combines the processor, memory mappers and the VGA module

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CPUBoard is
    Port (  clk : in std_logic;
            sw : in std_logic_vector( 15 downto 0 );    -- on board switches
            an : out std_logic_vector( 3 downto 0);     -- SSD
            dp : out std_logic;
            seg : out std_logic_vector( 6 downto 0);        
            led : out std_logic_vector( 15 downto 0);   -- LEDs
            gplatch, gpclock : out std_logic;           -- controller 1
            gpdata : in std_logic;
            gplatch2, gpclock2 : out std_logic;         -- controller 2
            gpdata2 : in std_logic;
            vgaRed, vgaBlue, vgaGreen : out std_logic_vector( 3 downto 0);  -- vga output
            hsync, vsync : out std_logic);
end CPUBoard;

architecture Behavioral of CPUBoard is
    component MemoryMapper 
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
    end component;
    
       signal mem_addr : std_logic_vector( 15 downto 0);
       signal mem_in : std_logic_vector( 15 downto 0);
       signal mem_out : std_logic_vector( 15 downto 0);
       signal mem_write : std_logic;
       
    component CPUCore
       Port (  clk : in std_logic;
                mem_addr : out std_logic_vector( 15 downto 0);
                mem_in : out std_logic_vector( 15 downto 0);
                mem_out : in std_logic_vector( 15 downto 0);
                mem_write : out std_logic
                );
    end component;    
    
    component VGAOut
        Port ( clk : in std_logic;
               vgaRed, vgaBlue, vgaGreen : out std_logic_vector( 3 downto 0);
               hsync, vsync : out std_logic;
               
               vram_clk : in std_logic;
                vram_out : out std_logic_vector( 15 downto 0);
                vram_in : in std_logic_vector( 15 downto 0);
                vram_write : in std_logic;
                vram_addr : in std_logic_vector(16 downto 0));
    end component;

    signal vram_clk : std_logic;
    signal vram_out : std_logic_vector( 15 downto 0);
    signal vram_in : std_logic_vector( 15 downto 0);
    signal vram_write : std_logic;
    signal vram_addr : std_logic_vector(16 downto 0);

begin
    
    cpu : CPUCore port map ( clk, mem_addr, mem_in, mem_out, mem_write);
    
    memory_inst : MemoryMapper port map ( clk, sw, an, dp, seg, led, gplatch, gpclock, gpdata, gplatch2, gpclock2, gpdata2,
                                          vram_clk, vram_out, vram_in, vram_write, vram_addr,
                                          mem_addr, mem_in, mem_write, mem_out);
    
    vport : VGAOut port map ( clk, vgaRed, vgaBlue, vgaGreen, hsync, vsync, vram_clk, vram_out, vram_in, vram_write, vram_addr);

end Behavioral;
