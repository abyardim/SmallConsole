-- a signle port RAM
-- can be inferred as a BRAM

library STD;
use			STD.TextIO.all;

library	IEEE;
use			IEEE.std_logic_1164.all;
use			IEEE.numeric_std.all;
use			IEEE.std_logic_textio.all;

entity SinglePortRAM is
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
end SinglePortRAM;


architecture Behavioral of SinglePortRAM is

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

begin

    process ( clk)
    begin   
        if rising_edge( clk) then
            if en = '1' then
                if we = '1' then
                    ramData( to_integer( unsigned( addr))) <= din;
                end if;
                dout <= ramData( to_integer( unsigned( addr)));
            end if;
        end if;
    end process;
  
end Behavioral;