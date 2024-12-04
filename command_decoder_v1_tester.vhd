library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_decoder_tester is
    port (
		i_clk         	: out std_logic;
		i_rst         	: out std_logic;
		i_instr       	: out std_logic_vector(31 downto 0);
		o_r_type      	: in std_logic;
		o_s_type      	: in std_logic;
		o_i_type      	: in std_logic;
		o_opcode      	: in std_logic_vector(6 downto 0);
		o_rs1         	: in std_logic_vector(4 downto 0);
		o_rs2         	: in std_logic_vector(4 downto 0);
		o_imm		    	: in std_logic_vector(11 downto 0);
		o_rd          	: in std_logic_vector(4 downto 0);
		o_read_to_LSU 	: in std_logic;
		o_write_to_LSU 	: in std_logic;
		o_LSU_code		: in std_logic_vector(16 downto 0)

    );
end entity instruction_decoder_tester;

architecture tester of instruction_decoder_tester is
    signal clk : std_logic := '0';
    constant clk_period : time := 10 ns;
begin
    clk_process : process 
	 
    begin
        i_clk <= '0';
        wait for clk_period / 2;
        i_clk <= '1';
        wait for clk_period / 2;
    end process;
	 
    test_process : process
	 
    begin
			wait for 11ns;
	 
			i_rst <= '1';
			wait for 3ns;

			i_rst <= '0';
			i_instr <= "11111111111100101100011100010011";
			
			wait for clk_period;
			
			i_instr <= "00000000101010101010010100110011";
			
			wait for clk_period;
			
			i_instr <= "11111111111101010001110100000011";
			
			wait for clk_period;
			
			i_instr <= "11111110101000101000101010100011";

        wait;
    end process;
end architecture tester;