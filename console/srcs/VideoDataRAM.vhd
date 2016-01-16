-- stores all the contents of the picture provessing unit
-- including the tile palette, color palette and screen placements

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VideoDataRAM is
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
end VideoDataRAM;

architecture Behavioral of VideoDataRAM is
        component DualPortRAM
            generic ( WORD_SIZE : natural;
                      ADDR_BITS : natural;
                      INIT_FILE : STRING);
            
            port ( clk1 : in std_logic;
                   clk2 : in std_logic;
                   addr1 : in std_logic_vector( ADDR_BITS - 1 downto 0);
                   addr2 : in std_logic_vector( ADDR_BITS - 1 downto 0);
                   en1 : in std_logic;
                   en2 : in std_logic;
                   we1 : in std_logic;
                   din1 : in std_logic_vector( WORD_SIZE - 1 downto 0);
                   dout1 : out std_logic_vector( WORD_SIZE - 1 downto 0);
                   dout2 : out std_logic_vector( WORD_SIZE - 1 downto 0)
                 );
        end component;
        
        signal mapperWrite : std_logic;
        signal mapperAddr : std_logic_vector( 7 downto 0);
        signal mapperDin, mapperDout : std_logic_vector( 5 downto 0);
        
        signal tdataWrite : std_logic;
        signal tdataAddr : std_logic_vector( 15 downto 0);
        signal tdataDin, tdataDout : std_logic_vector( 3 downto 0);
        
        signal cdataWrite : std_logic;
        signal cdataAddr : std_logic_vector( 3 downto 0);
        signal cdataDin, cdataDout : std_logic_vector( 11 downto 0);
begin
    tileMapper : DualPortRAM generic map ( 6, 8, "screenData.mem")
                             port map ( vram_clk, pxClock, mapperAddr, tileY & tileX, '1', '1', mapperWrite, mapperDin, mapperDout, tileIdOut);
                             
    tileData : DualPortRAM generic map ( 4, 16, "tileData.mem")
                             port map ( vram_clk, pxClock, tdataAddr, tileIdIn & tY & tX, '1', '1', tdataWrite, tdataDin, tdataDout, colIdOut);
                             
    colMap : DualPortRAM generic map ( 12, 4, "colData.mem")
                             port map ( vram_clk, pxClock, cdataAddr, colIdIn, '1', '1', cdataWrite, cdataDin, cdataDout, color);
                             
    
    ---- the screen tile interface           
    mapperWrite <= '1' when vram_wea = '1' and vram_addr( 16 downto 15) = "01" else
                   '0';
    mapperAddr <= vram_addr( 7 downto 0);
    mapperDin <= vram_din( 5 downto 0) when vram_addr( 16 downto 15) = "01" else
                 ( others => '-');
                 
    ---- the tile data interface
    tdataWrite <= '1' when vram_wea = '1' and vram_addr( 16) = '1' else
                   '0';
    tdataAddr <= vram_addr( 15 downto 0);
    tdataDin <= vram_din( 3 downto 0) when vram_addr( 16) = '1' else
                 ( others => '-');
    
    ---- the color table interface
    cdataWrite <= '1' when vram_wea = '1' and vram_addr( 16 downto 15) = "00" else
                  '0';
    cdataAddr <= vram_addr( 3 downto 0);
    cdataDin <= vram_din( 11 downto 0) when vram_addr( 16 downto 15) = "00" else
                ( others => '-');
                
                
    vram_dout <= "0000000000" & mapperDout when vram_addr( 16 downto 15) = "01" else
                 "000000000000" & tdataDout when vram_addr( 16) = '1' else
                 "0000" & cdataDout;

end Behavioral;
