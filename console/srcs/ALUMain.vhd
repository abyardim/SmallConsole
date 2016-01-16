-- ALU used in the design
-- Currently supports 16 operations, with comparison flags always enabled


library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

entity ALUMain is
    Port ( op1, op2 : in std_logic_vector( 15 downto 0);
           opcode : in std_logic_vector( 3 downto 0);
           carry_in : in std_logic;
           result : out std_logic_vector( 15 downto 0);
           mult_result2 : out std_logic_vector( 15 downto 0);
           carry_flag, overflow_flag, negative_flag, positive_flag, zero_flag: out std_logic;
           ugreater, usmaller, equal, sgreater, ssmaller : out std_logic);
end ALUMain;

    
architecture Behavioral of ALUMain is
    signal wide_result : unsigned( 16 downto 0);
    signal mult_result : unsigned( 31 downto 0);
    

begin

    with opcode select wide_result <=
           unsigned( "0" & op1) + unsigned( "0" & op2) when "0000",                                                                                   -- add
           unsigned( "0" & op1) + unsigned( "0" & op2) + unsigned'( "0" & carry_in) when "0001",                                        -- adc
           unsigned( "0" & op1) - unsigned( "0" & op2) when "0010",                                                                                   -- sub
           unsigned( "0" & op1) - unsigned( "0" &  op2) - unsigned'( "0" & carry_in) when "0011",                                       -- sbc
           "0" & unsigned( not op1) when "0110",                                                                                              -- not
           "0" & unsigned( - signed( op1)) when "0111",                                                                               -- inv
           "0" & unsigned( op1 and op2) when "1100",                                                                                          -- and
           "0" & unsigned( op1 or op2) when "1101",                                                                                           -- or
           "0" & unsigned( op1 xor op2) when "1110",                                                                                           -- xor
           "0" & unsigned( shift_right( signed( op1), to_integer( unsigned( op2( 3 downto 0))))) when "1111",    -- asr
           "0" & ( rotate_left( unsigned( op1), to_integer( unsigned( op2( 3 downto 0))))) when "1000",                   -- rol
           "0" & ( rotate_right( unsigned( op1), to_integer( unsigned( op2( 3 downto 0))))) when "1001",                  -- ror
           shift_left( unsigned( '0' & op1), to_integer( unsigned( op2( 3 downto 0)))) when "1010",                       -- lsl
           '0' & shift_right( unsigned( op1),  to_integer( unsigned( op2( 3 downto 0)))) when "1011",             -- lsr
           ( others => '-') when others; 

                       
    with opcode select mult_result <=
           unsigned( op1) * unsigned( op2) when "0100",                              -- unsigned multiplication
           unsigned( signed( op1) * signed( op2)) when "0101", -- signed multiplication
           ( others => '-') when others;            
    
    result <= std_logic_vector( mult_result( 15 downto 0)) when opcode( 3 downto 1) = "010" else
              std_logic_vector( wide_result( 15 downto 0));
    
    mult_result2 <= std_logic_vector(  mult_result( 31 downto 16));
    
    -- flags:
    
    carry_flag <= '0' when opcode = "0100" or opcode = "0101" else
                  wide_result( 16);
                  
    overflow_flag <= wide_result( 16) xor op1( 15) xor op2( 15) xor wide_result( 15) when opcode( 3 downto 2) = "00" else   -- overflow for addition / substraction
                     -- multiplication overflow
                     '1' when mult_result( 31 downto 16) = "0000000000000000" and  opcode = "0100" else
                     '1' when opcode = "0101" and ( mult_result( 31 downto 15) = "11111111111111111" or mult_result( 31 downto 15) = "00000000000000000") else 
                     '0';
    
    zero_flag <= '1' when wide_result( 15 downto 0) = "0000000000000000" else
                 '0';
                 
    positive_flag <= not wide_result( 15) when wide_result( 15 downto 0) /= "0000000000000000" else
                     '0';
    
    negative_flag <= wide_result( 15) when wide_result( 15 downto 0) /= "0000000000000000" else
                     '0';
                     
    -- comparison flags
    ugreater <= '1' when unsigned( op1) > unsigned( op2) else
                '0';
                
    usmaller <= '1' when unsigned( op1) < unsigned( op2) else
                '0';
                                
    equal <= '1' when op1 = op2 else
             '0';
    
    sgreater <= '1' when signed( op1) > signed( op2) else
                '0';
    
    ssmaller <= '1' when signed( op1) < signed( op2) else
                '0';
    
    
end Behavioral;
