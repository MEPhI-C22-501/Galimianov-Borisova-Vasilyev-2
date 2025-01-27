library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.register_file_pkg.all;


entity LSU_decoder_tests is
end LSU_decoder_tests;

architecture LSU_decoder_tests_arch of LSU_decoder_tests is

    component command_decoder_v1 is
        port(
             i_clk         	: in std_logic;
             i_rst         	: in std_logic;
             i_instr       	: in std_logic_vector(31 downto 0);

             o_rs1         	: out std_logic_vector(4 downto 0);
             o_rs2         	: out std_logic_vector(4 downto 0);
             o_imm		    	: out std_logic_vector(11 downto 0);
             o_rd          	: out std_logic_vector(4 downto 0);
             o_write_to_LSU 	: out std_logic;
             o_LSU_code		: out std_logic_vector(16 downto 0);
             o_LSU_code_post	: out std_logic_vector(16 downto 0);
             o_LSU_reg_or_memory_flag : out std_logic;
             o_wb_result_src     : out  STD_LOGIC_VECTOR(1 downto 0)
        );
   end component;

	component LSU is
	Port (
        i_clk, i_rst, i_write_enable_decoder : in std_logic;
        i_opcode_decoder, i_opcode_write_decoder : in std_logic_vector (16 downto 0);
        i_rs1_decoder, i_rs2_decoder, i_rd_decoder : in std_logic_vector (4 downto 0);
        i_rd_ans : in std_logic_vector (31 downto 0);
        i_imm_decoder : in std_logic_vector (11 downto 0);
        i_rs_csr : in registers_array;
        i_spec_reg_or_memory_decoder : in std_logic; --Если 1, то чтение из спец регистров, если 0 то из памяти (сделал)
        i_program_counter_csr : in std_logic_vector (15 downto 0); --Просто получаю (сделал)

        o_opcode_alu : out std_logic_vector (16 downto 0);
        o_rs_csr : out registers_array;
        o_rs1_alu, o_rs2_alu : out std_logic_vector (31 downto 0);
        o_write_enable_memory, o_write_enable_csr : out std_logic;
        o_addr_memory: out std_logic_vector (15 downto 0);
        o_write_data_memory: out std_logic_vector (31 downto 0);
        o_rd_csr : out std_logic_vector (4 downto 0);
        o_addr_spec_reg_csr : out std_logic_vector (11 downto 0);  --Адрес берем из регестра (сделал)
		o_program_counter : out std_logic_vector(15 downto 0);
		o_program_counter_write_enable : out std_logic
	);
	end component;

	component LSUMEM is
		Port (
        		i_clk, i_rst, i_write_enable_LSU : in std_logic;
        		i_addr_LSU : in std_logic_vector (15 downto 0);
        		i_write_data_LSU : in std_logic_vector (31 downto 0);

        		o_write_enable_memory: out std_logic;
        		o_addr_memory: out std_logic_vector (15 downto 0);
        		o_write_data_memory: out std_logic_vector (31 downto 0)
		);
	end component;


    signal clk_s : std_logic := '0';
   	signal rst_s : std_logic := '0';
	
    signal tester_decoder_instr : std_logic_vector(31 downto 0);
    
    signal decoder_LSU_write_enable : std_logic;
    signal decoder_LSU_reg_or_memory_flag : std_logic;
    signal decoder_LSU_rs1 : std_logic_vector(4 downto 0);
    signal decoder_LSU_rs2 : std_logic_vector(4 downto 0);
    signal decoder_LSU_rd : std_logic_vector(4 downto 0);
    signal decoder_LSU_imm : std_logic_vector(11 downto 0);
    signal decoder_LSU_opcode : std_logic_vector (16 downto 0);
    signal decoder_LSU_opcode_write :std_logic_vector (16 downto 0);

    signal rs_csr : registers_array;

    signal LSU_LSUMEM_write_enable_memory : std_logic;
    signal LSU_LSUMEM_addr_memory : std_logic_vector (15 downto 0);
    signal LSU_LSUMEM_write_data_memory : std_logic_vector (31 downto 0);

    signal LSU_tester_opcode_alu : std_logic_vector (16 downto 0);
    signal LSU_tester_rs1_alu : std_logic_vector (31 downto 0);
    signal LSU_tester_rs2_alu : std_logic_vector (31 downto 0);
    signal LSU_tester_write_enable_csr  : std_logic;
    signal LSU_tester_rd_csr : std_logic_vector(4 downto 0);
    signal LSU_tester_addr_spec_reg_csr : std_logic_vector (11 downto 0);

    --signal LSUMEM_tester_ : ;
    
    signal tester_LSU_rd_ans : std_logic_vector(31 downto 0);
    signal tester_LSU_program_counter_csr : std_logic_vector (15 downto 0);

    constant clk_period : time := 10 ns;


    	procedure wait_clk(constant j: in integer) is 
        	variable ii: integer := 0;
        	begin
        	while ii < j loop
           		if (rising_edge(clk_s)) then
                		ii := ii + 1;
            		end if;
            		wait for 10 ps;
        	end loop;
    	end;


begin         
	
	clk_s <= not clk_s after clk_period / 2;

    t1: command_decoder_v1
    port map (
        i_clk => clk_s,
        i_rst => rst_s,
        i_instr => tester_decoder_instr,
             
        o_rs1 => decoder_LSU_rs1,
        o_rs2 => decoder_LSU_rs2,
        o_imm => decoder_LSU_imm,
        o_rd => decoder_LSU_rd,
        o_write_to_LSU => decoder_LSU_write_enable,
        o_LSU_code => decoder_LSU_opcode,
        o_LSU_code_post	=> decoder_LSU_opcode_write,
        o_LSU_reg_or_memory_flag => decoder_LSU_reg_or_memory_flag
        --o_wb_result_src => 
    );

	t2: LSU
	port map (
		i_clk => clk_s,
		i_rst => rst_s,
		i_rs_csr => rs_csr,
		i_write_enable_decoder => decoder_LSU_write_enable,
		i_opcode_decoder => decoder_LSU_opcode,
		i_opcode_write_decoder => decoder_LSU_opcode_write,
		i_rs1_decoder => decoder_LSU_rs1,
		i_rs2_decoder => decoder_LSU_rs2,
		i_rd_decoder  => decoder_LSU_rd,
		i_rd_ans => tester_LSU_rd_ans,
		i_imm_decoder => decoder_LSU_imm,
		i_spec_reg_or_memory_decoder => decoder_LSU_reg_or_memory_flag,
		i_program_counter_csr => tester_LSU_program_counter_csr,

		o_opcode_alu => LSU_tester_opcode_alu,
        o_rs_csr => rs_csr,
        o_rs1_alu => LSU_tester_rs1_alu, 
        o_rs2_alu => LSU_tester_rs2_alu, 
        o_write_enable_memory => LSU_LSUMEM_write_enable_memory, 
        o_write_enable_csr => LSU_tester_write_enable_csr,
        o_addr_memory => LSU_LSUMEM_addr_memory,
        o_write_data_memory => LSU_LSUMEM_write_data_memory,
        o_rd_csr => LSU_tester_rd_csr,
        o_addr_spec_reg_csr => LSU_tester_addr_spec_reg_csr
		--o_program_counter 
		--o_program_counter_write_enable 
	);

	t3: LSUMEM
	port map (
		i_clk => clk_s,
		i_rst => rst_s,
		i_write_enable_LSU => LSU_LSUMEM_write_enable_memory,
        i_addr_LSU => LSU_LSUMEM_addr_memory,
        i_write_data_LSU => LSU_LSUMEM_write_data_memory

        --o_write_enable_memory => ,
        --o_addr_memory => ,
        --o_write_data_memory => 
	);

	process
	begin
		
        wait for 11 ns;
	 
        --rst_s <= '1';
        --wait for 3 ns;

        --rst_s <= '0';
        tester_decoder_instr <= "11111111111100101100011100010011";
        
        wait for clk_period;
        
        tester_decoder_instr <= "00000000101010101010010100110011";
        
        wait for clk_period;
        
        tester_decoder_instr <= "11111111111101010001110100000011";
        
        wait for clk_period;
        
        tester_decoder_instr <= "11111110101000101000101010100011";

		wait;
	end process;
end LSU_decoder_tests_arch;
