-- the CPU's entity
-- only assumes a clock input (100 MHz) and a RAM interface

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity CPUCore is
    Port (  clk : in std_logic;
            mem_addr : out std_logic_vector( 15 downto 0);
            mem_in : out std_logic_vector( 15 downto 0);
            mem_out : in std_logic_vector( 15 downto 0);
            mem_write : out std_logic
            );
end CPUCore;

architecture Behavioral of CPUCore is    
    ----- alu terminal
    
    component ALUMain
        Port ( op1, op2 : in std_logic_vector( 15 downto 0);
               opcode : in std_logic_vector( 3 downto 0);
               carry_in : in std_logic;
               result : out std_logic_vector( 15 downto 0);
               mult_result2 : out std_logic_vector( 15 downto 0);
               carry_flag, overflow_flag, negative_flag, positive_flag, zero_flag: out std_logic;
               ugreater, usmaller, equal, sgreater, ssmaller : out std_logic);
    end component;
    
    signal alu_op1, alu_op2 : std_logic_vector( 15 downto 0);
    signal alu_opcode : std_logic_vector( 3 downto 0);
    signal alu_result : std_logic_vector( 15 downto 0);
    signal alu_mresult : std_logic_vector( 15 downto 0);
    signal alu_flags : std_logic_vector( 4 downto 0);
    signal alu_compare_flags : std_logic_vector( 4 downto 0);
    signal alu_cin : std_logic;
    
    ------------------------- cpu internals:
    
    type register_array is array( 15 downto 0) of std_logic_vector( 15 downto 0);
    signal regs : register_array;    

    -- current instruction    
    signal instruction : std_logic_vector( 15 downto 0);

    -- internal counter for wait command
    signal wait_counter : std_logic_vector( 21 downto 0);
    
    -- the current 
    signal mem_index : std_logic_vector( 10 downto 0);
    
    -- aliases for special registers
    -- alias PC_reg is ;
    alias PC is regs(15);
    alias SP is regs(14);
    alias MULR is regs(13);
    
    -- flags
    signal CF : std_logic;
    signal OVF : std_logic;
    signal NF : std_logic;
    signal PF : std_logic;
    signal ZF : std_logic;
    
    -- state machine:
    type state_type_cpu is ( init0, fetch0, fetch1, decode0, load0, load1, sav0, sav1, adds0, adds1, cmp0, cmp1, muls0,
                             muls1, arith0, arith1, mov0, memin0, pop0, pop1, push0, gosub0, dojump0, jmpz0, jmpp0, jmpn0, jmpc0, jmpo0, 
                             wait0, wait1, ret0, ret1);
    signal state : state_type_cpu := init0;
    signal nextstate : state_type_cpu := init0;
    
    signal goto_next_state : std_logic := '0';
begin

    
    alu_map : ALUMain port map ( alu_op1, alu_op2, alu_opcode, alu_cin, alu_result, alu_mresult, alu_flags(0), alu_flags(1), alu_flags( 2), alu_flags( 3), alu_flags(4),
                                 alu_compare_flags(0), alu_compare_flags(1), alu_compare_flags(2), alu_compare_flags(3), alu_compare_flags(4));
    
    
    process ( clk)
    begin
        -- todo: add reset check
        if rising_edge( clk) then
            goto_next_state <= not goto_next_state;
            
            if goto_next_state = '1' then
                state <= nextstate;
            end if;
        end if;
    end process;

    
    ---- execute the current state
    process ( clk)
    begin
        if rising_edge( clk) and goto_next_state = '0' then
            case state is
                when init0 =>   
                                CF <= '0';
                                OVF <= '0';
                                NF <= '0';
                                PF <= '0';
                                ZF <= '0';
                                mem_index <= ( others => '0');
                                mem_write <= '0';
                                regs <= (others => "0000000000000000");
                                SP <= "0111111111111111";
                                nextstate <= fetch0;
                                
                when fetch0 =>  mem_write <= '0';
                                mem_addr <= PC;
                                nextstate <= decode0;
                                mem_write <= '0';
                                
                -- when fetch1 => state <= decode0;
                                
                when decode0 => PC <= PC + 1;
                                instruction <= mem_out;
                                
                                case mem_out( 15 downto 11) is
                                    when "10000" | "10001" | "10010" | "10011" => nextstate <= adds0;
                                    when "10100" | "10101" => nextstate <= muls0;
                                     
                                    when "00000" => nextstate <= dojump0;
                                    when "00001" => nextstate <= jmpz0;
                                    when "00010" => nextstate <= jmpp0;
                                    when "00011" => nextstate <= jmpn0;
                                    when "00100" => nextstate <= jmpc0;
                                    when "00101" => nextstate <= jmpo0;
                                    
                                    when "01000" => nextstate <= load0;
                                    when "01001" => nextstate <= sav0;
                                    when "01010" => nextstate <= mov0;
                                    when "01011" => nextstate <= memin0;
                                    
                                    when "01100" => nextstate <= pop0;
                                    when "01101" => nextstate <= push0;
                                    when "01110" => nextstate <= gosub0;
                                    when "01111" => nextstate <= ret0;
                                    
                                    when "00110" => nextstate <= wait0;
                                    
                                    when "00111" => nextstate <= cmp0;      ----- compare
                                    
                                    when others => nextstate <= adds0;         ------ TODO?
                                end case;

                when adds0 =>   alu_opcode <= instruction(14 downto 11);                                            -- add/adc/sub/sbc 
                                alu_op1 <= regs( to_integer( unsigned( instruction(10 downto 7)))); 
                                
                                if instruction(6) = '1' then
                                    if instruction( 1 downto 0) = "00" then
                                        alu_op2 <= regs( to_integer( unsigned( instruction(5 downto 2))));
                                    elsif instruction( 1 downto 0) = "01" then
                                        alu_op2 <= regs( to_integer( unsigned( instruction(5 downto 2))));
                                    elsif instruction( 1 downto 0) = "10" then 
                                        alu_op2 <= regs( to_integer( unsigned( instruction(5 downto 2))));
                                    else
                                        alu_op2 <= regs( to_integer( unsigned( instruction(5 downto 2))));
                                    end if;
                                else
                                    alu_op2 <= std_logic_vector( resize( signed( instruction( 5 downto 0)), 16));
                                end if;
                             
                                alu_cin <= CF;
                                
                                nextstate <= adds1;
                                
                when adds1 =>   regs( to_integer( unsigned( instruction(10 downto 7)))) <= std_logic_vector( alu_result);
                                CF <= alu_flags( 0);
                                OVF <= alu_flags( 1);
                                NF <= alu_flags( 2);
                                PF <= alu_flags( 3);
                                ZF <= alu_flags( 4);
                                
                                nextstate <= fetch0;
                                
                when cmp0  =>   alu_op1 <= regs( to_integer( unsigned( instruction(10 downto 7))));                                 
                                                                                                
                                if instruction(6) = '1' then
                                    if instruction( 1 downto 0) = "00" then
                                        alu_op2 <= regs( to_integer( unsigned( instruction(5 downto 2))));
                                    elsif instruction( 1 downto 0) = "01" then
                                        alu_op2 <= regs( to_integer( unsigned( instruction(5 downto 2))));
                                    elsif instruction( 1 downto 0) = "10" then 
                                        alu_op2 <= regs( to_integer( unsigned( instruction(5 downto 2))));
                                    else
                                        alu_op2 <= regs( to_integer( unsigned( instruction(5 downto 2))));
                                    end if;
                                else
                                    alu_op2 <= std_logic_vector( resize( signed( instruction( 5 downto 0)), 16));
                                end if;
                                
                                nextstate <= cmp1;
                
                when cmp1  =>   CF <= alu_compare_flags( 0);
                                OVF <= alu_compare_flags( 1);
                                NF <= alu_compare_flags( 2);
                                PF <= alu_compare_flags( 3);
                                ZF <= alu_compare_flags( 4);
                                
                                nextstate <= fetch0;
                
                when muls0 =>   alu_opcode <= instruction(14 downto 11);                                                        -- umul/smul
                                alu_op1 <= regs( to_integer( unsigned( instruction(10 downto 7)))); 
                                                                
                                if instruction(6) = '1' then
                                    if instruction( 1 downto 0) = "00" then
                                        alu_op2 <= regs( to_integer( unsigned( instruction(5 downto 2))));
                                    elsif instruction( 1 downto 0) = "01" then
                                        alu_op2 <= regs( to_integer( unsigned( instruction(5 downto 2)))) ;
                                    elsif instruction( 1 downto 0) = "10" then 
                                        alu_op2 <= regs( to_integer( unsigned( instruction(5 downto 2))));
                                    else
                                        alu_op2 <= regs( to_integer( unsigned( instruction(5 downto 2))));
                                    end if;
                                else
                                    alu_op2 <= std_logic_vector( resize( signed( instruction( 5 downto 0)), 16));
                                end if;
                                                             
                                alu_cin <= CF;
                                                                
                                nextstate <= muls1;
                                
                when muls1 =>   regs( to_integer( unsigned( instruction(10 downto 7)))) <= std_logic_vector( alu_result);
                                CF <= alu_flags( 0);
                                OVF <= alu_flags( 1);
                                NF <= alu_flags( 2);
                                PF <= alu_flags( 3);
                                ZF <= alu_flags( 4);
                                MULR <= std_logic_vector( alu_mresult);                                
                                nextstate <= fetch0;
                
                when memin0 =>  mem_index <= instruction( 10 downto 0);
                                nextstate <= fetch0;
                
                when load0 =>   if instruction( 6) = '1' then
                                    mem_addr <= regs( to_integer( unsigned( instruction( 5 downto 2))));
                                else
                                    mem_addr <= mem_index( 9 downto 0) & instruction( 5 downto 0);
                                end if;
                                
                                nextstate <= load1;
                                
                when load1 =>   regs( to_integer( unsigned( instruction( 10 downto 7)))) <= mem_out;
                                nextstate <= fetch0;
                
                when sav0  =>   mem_write <= '1';
                                if instruction( 6) = '1' then
                                    mem_addr <= regs( to_integer( unsigned( instruction( 5 downto 2))));
                                else
                                    mem_addr <= mem_index( 9 downto 0) & instruction( 5 downto 0);
                                end if;
                                
                                mem_in <= regs( to_integer( unsigned( instruction( 10 downto 7))));
                                
                                nextstate <= fetch0;
                                
                when dojump0 => mem_write <= '0';
                                if instruction( 10 downto 9) = "11" then
                                    PC <= mem_index( 9 downto 0) & instruction( 5 downto 0);
                                elsif instruction( 10 downto 9) = "10" then
                                    PC <= regs( to_integer( unsigned( instruction( 8 downto 5))));
                                else
                                    PC <= PC + std_logic_vector( resize( signed( instruction( 9 downto 0)), 16)) - 1;
                                end if;
                                nextstate <= fetch0;
                
                when mov0   =>  if instruction( 6) = '1' then
                                    regs( to_integer( unsigned( instruction( 10 downto 7)))) <= regs( to_integer( unsigned( instruction( 5 downto 2))));        -- TODO
                                else
                                    regs( to_integer( unsigned( instruction( 10 downto 7)))) <= std_logic_vector( resize( signed( instruction( 5 downto 0)), 16));
                                end if;
                                nextstate <= fetch0;
                                
                when jmpz0 =>   if ZF='1' then nextstate <= dojump0; else nextstate <= fetch0; end if;
                
                when jmpp0 =>   if PF='1' then nextstate <= dojump0; else nextstate <= fetch0; end if;
                                 
                when jmpn0 =>   if NF='1' then nextstate <= dojump0; else nextstate <= fetch0; end if;
                                   
                when jmpo0 =>   if OVF='1' then nextstate <= dojump0; else nextstate <= fetch0; end if;
                
                when jmpc0 =>   if CF='1' then nextstate <= dojump0; else nextstate <= fetch0; end if;
                
                when wait0 =>   if instruction( 10) = '0' then
                                    wait_counter <= instruction( 9 downto 0) & "000000000000";
                                else
                                    wait_counter <= regs( to_integer( unsigned( instruction( 9 downto 6)))) & instruction( 5 downto 0);
                                end if;
                                
                                nextstate <= wait1;
                                
                when wait1 =>   wait_counter <= wait_counter - 1;               --- decrement count each cycle
                                if wait_counter = "0000000000000000000000" then
                                    nextstate <= fetch0;
                                end if;
                                
                when pop0  =>   if instruction( 10) = '1' or instruction( 5) = '1' then
                                    mem_addr <= SP + 1;
                                    nextstate <= pop1;
                                else
                                    SP <= SP + 1;       -- pop without saving to register
                                    nextstate <= fetch0;
                                end if;
                                
                                
                when pop1 =>    SP <= SP + 1;
                                if instruction( 10) = '1' then
                                    regs( to_integer( unsigned( instruction( 9 downto 6)))) <= mem_out; -- save to register 1
                                end if;
                                
                                if instruction( 5) = '1' then
                                    regs( to_integer( unsigned( instruction( 4 downto 1)))) <= mem_out; -- save to register 2
                                end if;
                                
                                        ----- TODO final bit?
                                        
                                nextstate <= fetch0;
                                
                when push0 =>   mem_addr <= SP;
                                mem_write <= '1';
                                SP <= SP - 1;
                                
                                if instruction( 10) = '0' then
                                    mem_in <= std_logic_vector( resize( signed( instruction( 9 downto 0)), 16)); -- TODO push multiple values?
                                else
                                    mem_in <= regs( to_integer( unsigned( instruction( 9 downto 6))));
                                end if;
                                
                                nextstate <= fetch0;
                                
                when gosub0 =>  mem_addr <= SP;
                                mem_write <= '1';
                                SP <= SP - 1;                                                                          
                                mem_in <= PC;
                                                                                                
                                nextstate <= dojump0;
                                
                when ret0   =>  mem_addr <= SP + 1;
                                nextstate <= ret1;
                
                when ret1   =>  SP <= SP + 1 + to_integer( unsigned( instruction( 10 downto 0)));
                                PC <= mem_out;
                                nextstate <= fetch0;
                                                                
                when others =>  nextstate <= fetch0;
       
            
            end case;
        end if;
    end process;

end Behavioral;
