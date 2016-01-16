-- the VGA signal generator
-- uses the VRAM contents to output proper pixel values with the vga clock

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity VGAOut is
    Port ( clk : in std_logic;
           vgaRed, vgaBlue, vgaGreen : out std_logic_vector( 3 downto 0);
           hsync, vsync : out std_logic;
           
           vram_clk : in std_logic;
            vram_out : out std_logic_vector( 15 downto 0);
            vram_in : in std_logic_vector( 15 downto 0);
            vram_write : in std_logic;
            vram_addr : in std_logic_vector(16 downto 0));
end VGAOut;

architecture Behavioral of VGAOut is

    component vga_controller_800_60
    port(
       rst         : in std_logic;
       pixel_clk   : in std_logic;
    
       HS          : out std_logic;
       VS          : out std_logic;
       hcount      : out std_logic_vector(10 downto 0);
       vcount      : out std_logic_vector(10 downto 0);
       blank       : out std_logic
    );
    end component;

    ---------- VGA signals
    signal hcount : std_logic_vector(10 downto 0);
    signal vcount : std_logic_vector(10 downto 0);
    
    signal blank : std_logic;

    -------- VRAM
    
    component VideoDataRAM
        Port ( vram_clk, vram_wea : in std_logic;
               vram_addr : in std_logic_vector( 16 downto 0);
               vram_din : in std_logic_vector( 15 downto 0);
               vram_dout : out std_logic_vector( 15 downto 0);
               
               pxClock : in std_logic;
               
               tileX, tileY : in std_logic_vector( 3 downto 0);
               tileIdIn : in std_logic_vector( 5 downto 0);
               tX, tY   : in std_logic_vector( 4 downto 0);
               colIDIn : in std_logic_vector( 3 downto 0);
               
               tileIdOut : out std_logic_vector( 5 downto 0);
               colIdOut : out std_logic_vector( 3 downto 0);
               color : out std_logic_vector( 11 downto 0)
               );
    end component;
    
    signal tileX, tileY : std_logic_vector( 3 downto 0);
    signal tileId : std_logic_vector( 5 downto 0);
    signal tX, tY   : std_logic_vector( 4 downto 0);
    signal colID : std_logic_vector( 3 downto 0);
    signal color : std_logic_vector( 11 downto 0);

    ---------- 40 MHz clock generator:
    
    component clk_wiz_40m
        port
         (-- Clock in ports
          clk_in1           : in     std_logic;
          -- Clock out ports
          clk_out1          : out    std_logic
         );
    end component;
    
    
    component clk_wiz_120m
            port
             (-- Clock in ports
              clk_in1           : in     std_logic;
              -- Clock out ports
              clk_out1          : out    std_logic
             );
   end component;
    
    -- pixel clock
    signal clkPx : std_logic;
    
    signal clkVRAM : std_logic;

    signal colR, colG, colB : std_logic_vector( 3 downto 0);

begin

    vram_map : VideoDataRAM port map ( vram_clk, vram_write, vram_addr, vram_in, vram_out, clkVRAM, tileX, tileY, tileId, tX, tY, colId, tileId, colId, color);
   
    clock_map : clk_wiz_40m port map ( clk, clkPx);
     clock_map2 : clk_wiz_120m port map ( clk, clkVRAM);
    
    vgaController : vga_controller_800_60 port map ('0', clkPx, hsync, vsync, hcount,  vcount, blank);
    
    vgaRed <= "0000" when blank = '1' or to_integer( unsigned( hcount)) > 511 or to_integer( unsigned( vcount)) > 511 else
              colR;
    vgaBlue <= "0000" when blank = '1' or to_integer( unsigned( hcount)) > 511 or to_integer( unsigned( vcount)) > 511 else
              colB;
    vgaGreen <= "0000" when blank = '1' or to_integer( unsigned( hcount)) > 511 or to_integer( unsigned( vcount)) > 511 else
              colG;
              
    tileX <= hcount( 8 downto 5);
    tileY <= vcount( 8 downto 5);
    
    tX <= hcount( 4 downto 0);  
    tY <= vcount( 4 downto 0);   
    
    colR <= color( 11 downto 8);
    colG <= color( 7 downto 4);
    colB <= color( 3 downto 0);

end Behavioral;
