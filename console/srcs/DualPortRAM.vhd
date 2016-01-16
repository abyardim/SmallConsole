
library STD;
use			STD.TextIO.all;

library	IEEE;
use			IEEE.std_logic_1164.all;
use			IEEE.numeric_std.all;
use			IEEE.std_logic_textio.all;

entity DualPortRAM is
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
end DualPortRAM;


architecture Behavioral of DualPortRAM is

    constant DEPTH : natural := 2 ** ADDR_BITS;

    -- data types
    subtype word_t  is std_logic_vector( WORD_SIZE - 1 downto 0);
    type    ram_t   is array(0 to DEPTH - 1) of word_t;
    
    -- the ram intializer
    impure function readBinFile(FileName : STRING) return ram_t is
      file FileHandle       : TEXT open READ_MODE is FileName;
      variable CurrentLine  : LINE;
      variable TempWord     : STD_LOGIC_VECTOR( WORD_SIZE - 1 downto 0);
      variable Result       : ram_t    := (others => (others => '0'));
    
    begin
      for i in 0 to DEPTH - 1 loop
        exit when endfile(FileHandle);
    
        readline(FileHandle, CurrentLine);
        read(CurrentLine, TempWord);
        Result(i)    := TempWord;
      end loop;
    
      return Result;
    end function;
    
    -- the ram array:
    signal ramData : ram_t := readBinFile( INIT_FILE);
    
--    signal a1_reg		: std_logic_vector( ADDR_BITS-1 downto 0);
--    signal a2_reg        : std_logic_vector( ADDR_BITS-1 downto 0);
begin

    process (clk1, clk2)
    begin    -- process
        if rising_edge(clk1) then
            if en1 = '1' then
                if we1 = '1' then
                    ramData( to_integer( unsigned( addr1))) <= din1;
                end if;
                dout1 <= ramData( to_integer( unsigned( addr1)));  
            end if;
        end if;
    
        if rising_edge(clk2) then
            if en2 = '1' then
                dout2 <= ramData( to_integer( unsigned( addr2)));  
            end if;
        end if;
    end process;
                
          -- returns new data
       -- returns new data
        
end Behavioral;