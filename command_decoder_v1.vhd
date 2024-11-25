library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity command_decoder_v1 is
 port(
  i_clk         	: in std_logic;
  i_rst         	: in std_logic;
  i_load        	: in std_logic;
  i_instr       	: in std_logic_vector(31 downto 0);
  o_instr_addr  	: out std_logic_vector(31 downto 0);
  o_r_type      	: out std_logic;
  o_s_type      	: out std_logic;
  o_i_type      	: out std_logic;
  o_opcode      	: out std_logic_vector(6 downto 0);
  o_rs1         	: out std_logic_vector(4 downto 0);
  o_rs2         	: out std_logic_vector(4 downto 0);
  o_imm		    	: out std_logic_vector(11 downto 0);
  o_rd          	: out std_logic_vector(4 downto 0);
  o_read_to_LSU 	: out std_logic;
  o_write_to_LSU 	: out std_logic;
  o_read_to_ALU 	: out std_logic;
  o_opcode_to_LSU 	: out std_logic_vector(6 downto 0);
  o_LSU_code		: out std_logic_vector(16 downto 0);
--debug
  o_DEBUG_LSU_0		: out std_logic_vector(5 downto 0)
 );
end entity;

architecture rtl of command_decoder_v1 is
  signal instr_addr : std_logic_vector(31 downto 0) := (others => '0');
  signal reg_stage1_ALU_0 : std_logic_vector(17 downto 0) := (others => '0');
  
  signal reg_stage2_LSU_0 : std_logic_vector(5 downto 0) := (others => '0');
  signal reg_stage2_LSU_1 : std_logic_vector(5 downto 0) := (others => '0');
begin

	o_instr_addr <= instr_addr;
  
  process(i_clk, i_rst)
  begin
    if i_rst = '1' then
      instr_addr <= (others => '0');
		reg_stage1_ALU_0 <= (others => '0');
		reg_stage2_LSU_0 <= (others => '0');
		reg_stage2_LSU_1 <= (others => '0');
		o_opcode <= (others => '0');
		o_rs1 <= (others => '0');
		o_rs2 <= (others => '0');
		o_imm <= (others => '0');
		o_rd <= (others => '0');
      o_r_type <= '0';
      o_s_type <= '0';
      o_i_type <= '0';
		o_read_to_LSU <= '0';
		o_read_to_ALU <= '0';
		o_LSU_code <= (others => '0');
		
    elsif rising_edge(i_clk) then
		
		o_write_to_LSU <= reg_stage2_LSU_1(5);

		o_DEBUG_LSU_0 <= reg_stage2_LSU_0;
		reg_stage2_LSU_1 <= reg_stage2_LSU_0;
		o_rd <= reg_stage2_LSU_1(4 downto 0);
	 
		if i_load = '1' then
			instr_addr <= i_instr;
		else
			instr_addr <= instr_addr + x"1";
		end if;
		
		-- R-type
		if (i_instr(6 downto 0) = "0110011") then 
			 o_r_type <= '1';
			 o_s_type <= '0';
			 o_i_type <= '0';
		end if;
		
		if (i_instr(6 downto 0) = "0110011") then
			 o_read_to_LSU <= '1';
		end if;
		
		if (i_instr(6 downto 0) = "0110011") then
			 reg_stage2_LSU_0(4 downto 0) <= i_instr(11 downto 7);
		end if;
		
		if (i_instr(6 downto 0) = "0110011") then
			 reg_stage2_LSU_0(5) <= '1';
		end if;
		
		if (i_instr(6 downto 0) = "0110011") then
			 o_rs1 <= i_instr(19 downto 15);
		end if;

		if (i_instr(6 downto 0) = "0110011") then
			 o_rs2 <= i_instr(24 downto 20);
		end if;

		if (i_instr(6 downto 0) = "0110011") then
			 o_LSU_code(2 downto 0) <= i_instr(14 downto 12);
		end if;

		if (i_instr(6 downto 0) = "0110011") then
			 o_LSU_code(9 downto 3) <= i_instr(31 downto 25);
		end if;
		
		if (i_instr(6 downto 0) = "0110011") then
			 o_LSU_code(16 downto 10) <= i_instr(6 downto 0);
		end if;
		-- end R-type
		
		-- I-type
		if (i_instr(6 downto 0) = "0000011" or i_instr(6 downto 0) = "0010011") then 
			 o_r_type <= '0';
			 o_s_type <= '0';
			 o_i_type <= '1';
		end if;
		
		if (i_instr(6 downto 0) = "0000011" or i_instr(6 downto 0) = "0010011") then
			 reg_stage2_LSU_0(4 downto 0) <= i_instr(11 downto 7);
			--o_DEBUG_LSU_0(4 downto 0) <=  i_instr(11 downto 7);
		end if;
		
		if (i_instr(6 downto 0) = "0000011" or i_instr(6 downto 0) = "0010011") then
			 reg_stage2_LSU_0(5) <= '1';
		end if;

		if (i_instr(6 downto 0) = "0000011" or i_instr(6 downto 0) = "0010011") then
			 o_read_to_LSU <= '1';
		end if;
		
		if (i_instr(6 downto 0) = "0000011" or i_instr(6 downto 0) = "0010011") then
			 o_rs1 <= i_instr(19 downto 15);
		end if;

		if (i_instr(6 downto 0) = "0000011" or i_instr(6 downto 0) = "0010011") then
			 o_imm <= i_instr(31 downto 20);
		end if;
		
		if (i_instr(6 downto 0) = "0000011" or i_instr(6 downto 0) = "0010011") then
			 o_LSU_code(2 downto 0) <= i_instr(14 downto 12);
		end if;
		
		if (i_instr(6 downto 0) = "0000011" or i_instr(6 downto 0) = "0010011") then
			 o_LSU_code(9 downto 3) <= (others => '0');
		end if;
		
		if (i_instr(6 downto 0) = "0000011" or i_instr(6 downto 0) = "0010011") then
			 o_LSU_code(16 downto 10) <= i_instr(6 downto 0);
		end if;
		-- end I-type
		
		-- S-type
		
		if (i_instr(6 downto 0) = "0100011") then 
			 o_r_type <= '0';
			 o_s_type <= '1';
			 o_i_type <= '0';
		end if;
		
		if (i_instr(6 downto 0) = "0110011") then
			 o_read_to_LSU <= '1';
		end if;

		if (i_instr(6 downto 0) = "0110011") then
			 reg_stage2_LSU_0(5) <= '0';
		end if;
		
		if (i_instr(6 downto 0) = "0100011") then
			 o_rs1 <= i_instr(19 downto 15);
		end if;

		if (i_instr(6 downto 0) = "0100011") then
			 o_rs2 <= i_instr(24 downto 20);
		end if;

		if (i_instr(6 downto 0) = "0100011") then
			 o_imm(4 downto 0) <= i_instr(11 downto 7);
			 o_imm(5 downto 11) <= i_instr(31 downto 25);
		end if;
		
		if (i_instr(6 downto 0) = "0000011" or i_instr(6 downto 0) = "0010011") then
			 o_LSU_code(2 downto 0) <= i_instr(14 downto 12);
		end if;
		
		if (i_instr(6 downto 0) = "0000011" or i_instr(6 downto 0) = "0010011") then
			 o_LSU_code(9 downto 3) <= (others => '0');
		end if;
		
		if (i_instr(6 downto 0) = "0000011" or i_instr(6 downto 0) = "0010011") then
			 o_LSU_code(16 downto 10) <= i_instr(6 downto 0);
		end if;

		
		

		if not (
			 i_instr(6 downto 0) = "0110011" or
			 i_instr(6 downto 0) = "0000011" or
			 i_instr(6 downto 0) = "0010011" or
			 i_instr(6 downto 0) = "0100011"
		) then
			 o_r_type <= '0';
			 o_s_type <= '0';
			 o_i_type <= '0';
			 reg_stage1_ALU_0(17) <= '0';
			 o_read_to_LSU <= '0';
			 reg_stage2_LSU_0(5) <= '0';
		end if;
				
	end if;
  end process;
end rtl;