library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity command_decoder_v2 is
	 port(
		  i_clk         					: in std_logic;
		  i_rst         					: in std_logic;
		  i_instr       					: in std_logic_vector(31 downto 0);
		  o_rs1         					: out std_logic_vector(4 downto 0);
		  o_rs2         					: out std_logic_vector(4 downto 0);
		  o_imm		    					: out std_logic_vector(11 downto 0);
		  o_rd          					: out std_logic_vector(4 downto 0);
		  o_read_to_LSU 					: out std_logic;
		  o_write_to_LSU 					: out std_logic;
		  o_LSU_code						: out std_logic_vector(16 downto 0);
		  o_LSU_code_post					: out std_logic_vector(16 downto 0);
		  o_LSU_reg_or_memory_flag 	: out std_logic;
		  o_wb_result_src     			: out std_logic_vector(1 downto 0)
	 );
end entity;

architecture rtl of command_decoder_v2 is  
  signal reg_stage_LSU_1 : std_logic_vector(22 downto 0);
  signal reg_stage_LSU_2 : std_logic_vector(22 downto 0);
  signal reg_stage_LSU_3 : std_logic_vector(22 downto 0);
  signal reg_stage_LSU_4 : std_logic_vector(22 downto 0);
  
  signal wb_result_src_1 : std_logic_vector(1 downto 0);
  signal wb_result_src_2 : std_logic_vector(1 downto 0);
  
  signal rs1_r					: std_logic_vector(4 downto 0);
  signal rs2_r					: std_logic_vector(4 downto 0);
  signal imm_r					: std_logic_vector(11 downto 0);
  
  signal read_to_LSU_r					: 	std_logic;
  signal LSU_reg_or_memory_flag_r	:	std_logic;
begin
	o_LSU_code 			<= reg_stage_LSU_1(16 downto 0);
	o_rs1 				<= rs1_r;
	o_rs2 				<= rs2_r;
	o_imm					<= imm_r;
	
	o_wb_result_src	<= wb_result_src_2;
	o_write_to_LSU 	<= reg_stage_LSU_3(22);
	o_LSU_code_post 	<= reg_stage_LSU_3(16 downto 0);
	o_rd 					<= reg_stage_LSU_3(21 downto 17);
	
	o_read_to_LSU 		<= read_to_LSU_r;
	o_LSU_reg_or_memory_flag 		<= LSU_reg_or_memory_flag_r;
	
	process(i_clk, i_rst)
begin
    if i_rst = '1' then
        reg_stage_LSU_1 <= (others => '0');
        reg_stage_LSU_2 <= (others => '0');
        reg_stage_LSU_3 <= (others => '0');
        reg_stage_LSU_4 <= (others => '0');
        
        wb_result_src_1 <= (others => '0');
        wb_result_src_2 <= (others => '0');
        
        rs1_r <= (others => '0');
        rs2_r <= (others => '0');
        imm_r <= (others => '0');
        
        read_to_LSU_r <= '0';
        LSU_reg_or_memory_flag_r <= '0';
        
    elsif rising_edge(i_clk) then
        
        -- Сдвиг информации для LSU
        reg_stage_LSU_4 <= reg_stage_LSU_3;
        reg_stage_LSU_3 <= reg_stage_LSU_2;
        reg_stage_LSU_2 <= reg_stage_LSU_1;
        
        -- Сдвиг информации для WriteBack
        wb_result_src_2 <= wb_result_src_1;
        
        
            
            -- Обработка корректных инструкций
            
        -- o_read_to_LSU
            if (i_instr(6 downto 0) = "0110011" or 
                i_instr(6 downto 0) = "0000011" or 
                i_instr(6 downto 0) = "0010011" or
                i_instr(6 downto 0) = "0100011") then
                read_to_LSU_r <= '1';
            else 
                read_to_LSU_r <= '0'; --NOP
            end if;
            
            -- reg_stage_LSU_1(22)
            if (i_instr(6 downto 0) = "0110011" or
                i_instr(6 downto 0) = "0000011" or 
                i_instr(6 downto 0) = "0010011") then
                reg_stage_LSU_1(22) <= '1';
            elsif (i_instr(6 downto 0) = "0100011") then
                reg_stage_LSU_1(22) <= '0';
				else
				    reg_stage_LSU_1(22) <= '0'; --NOP
            end if;
            
            -- reg_stage_LSU_1(21 downto 17)
            if (i_instr(6 downto 0) = "0110011" or
                i_instr(6 downto 0) = "0000011" or 
                i_instr(6 downto 0) = "0010011") then
                reg_stage_LSU_1(21 downto 17) <= i_instr(11 downto 7);
				else
					 reg_stage_LSU_1(21 downto 17) <= (others => '0'); --NOP
            end if;
            
            -- reg_stage_LSU_1(16 downto 10)
            if (i_instr(6 downto 0) = "0110011" or
                (i_instr(6 downto 0) = "0010011" and i_instr(14 downto 12) = "101")) then
                reg_stage_LSU_1(16 downto 10) <= i_instr(31 downto 25);
            elsif(i_instr(6 downto 0) = "0000011" or 
                  (i_instr(6 downto 0) = "0010011" and i_instr(14 downto 12) /= "101") or
                  i_instr(6 downto 0) = "0100011") then
                reg_stage_LSU_1(16 downto 10) <= (others => '0');
				else
					 reg_stage_LSU_1(16 downto 10) <= (others => '0'); --NOP
            end if;
            
            -- reg_stage_LSU_1(9 downto 7)
            if (i_instr(6 downto 0) = "0110011" or
                i_instr(6 downto 0) = "0100011" or
                i_instr(6 downto 0) = "0000011" or
                i_instr(6 downto 0) = "0010011") then
                reg_stage_LSU_1(9 downto 7) <= i_instr(14 downto 12);
				else
				    reg_stage_LSU_1(9 downto 7) <= (others => '0'); --NOP
            end if;
            
            -- reg_stage_LSU_1(6 downto 0)
            if (i_instr(6 downto 0) = "0110011" or
                i_instr(6 downto 0) = "0000011" or
                i_instr(6 downto 0) = "0010011" or
                i_instr(6 downto 0) = "0100011") then
                reg_stage_LSU_1(6 downto 0) <= i_instr(6 downto 0);
				else
				    reg_stage_LSU_1(6 downto 0) <= (others => '0'); --NOP
            end if;
            
            -- o_rs1
            if (i_instr(6 downto 0) = "0110011" or
                i_instr(6 downto 0) = "0000011" or
                i_instr(6 downto 0) = "0010011" or
                i_instr(6 downto 0) = "0100011") then
                rs1_r <= i_instr(19 downto 15);
				else
					 rs1_r <= (others => '0'); --NOP
            end if;
            
            -- o_rs2
            if (i_instr(6 downto 0) = "0110011" or
                i_instr(6 downto 0) = "0100011") then
                rs2_r <= i_instr(24 downto 20);
				else
					 rs2_r <= (others => '0');
            end if;
            
            -- o_imm
            if (i_instr(6 downto 0) = "0000011" or
                i_instr(6 downto 0) = "0010011") then
                imm_r <= i_instr(31 downto 20);
            elsif (i_instr(6 downto 0) = "0100011") then
                imm_r(4 downto 0) <= i_instr(11 downto 7);
                imm_r(11 downto 5) <= i_instr(31 downto 25);
				else
				    imm_r <= (others => '0'); --NOP
            end if;
            
            -- o_LSU_reg_or_memory_flag
            if (i_instr(6 downto 0) = "0000011" and i_instr(14 downto 12) = "010" and i_instr(31 downto 16) = "0000000000000000") then
                LSU_reg_or_memory_flag_r <= '1';
            else
                LSU_reg_or_memory_flag_r <= '0'; --NOP
            end if;
            
            -- o_wb_result_src_1
            if(i_instr(6 downto 0) = "0000011") then
                wb_result_src_1 <= "01";
            elsif(i_instr(6 downto 0) = "0010011" or i_instr(6 downto 0) = "0110011") then
                wb_result_src_1 <= "00";
            else
                wb_result_src_1 <= "11"; --NOP
            end if;
                       
        end if;

end process;
end rtl;