library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.register_file_pkg.all;


entity LSU_decoder_testbench is
end LSU_decoder_testbench;

architecture LSU_decoder_testbench_arch of LSU_decoder_testbench is
--- tb begin
    component command_decoder_v2 is
        port(
             i_clk : in std_logic;
             i_rst : in std_logic;
             i_instr : in std_logic_vector(31 downto 0);

             o_rs1 : out std_logic_vector(4 downto 0);
             o_rs2 : out std_logic_vector(4 downto 0);
             o_imm : out std_logic_vector(11 downto 0);
             o_rd : out std_logic_vector(4 downto 0);
             o_write_to_LSU : out std_logic;
             o_LSU_code : out std_logic_vector(16 downto 0);
             o_LSU_code_post : out std_logic_vector(16 downto 0);
             o_LSU_reg_or_memory_flag : out std_logic;
             o_wb_result_src : out  STD_LOGIC_VECTOR(1 downto 0)
        );
   end component;

	component CSR is
		port(
			i_addr	: in std_logic_vector(11 downto 0);
			i_clk	: in std_logic;
			o_data	: out std_logic_vector(31 downto 0)
		);
	end component;
		
	component InstructionMemory is
	generic (
		file_path : string := "C:\data\program.hex"
	);

    port (
        i_clk       : in  std_logic;
	i_rst       : in  std_logic;
        i_read_addr : in  std_logic_vector(15 downto 0);
        o_read_data : out std_logic_vector(31 downto 0)
    );
   end component;

	component LSU_decoder_tester is
	port (
		
      	o_clk : out std_logic;
      	o_rst : out std_logic;
    
	-- instruction memory
	o_read_addr : out std_logic_vector(15 downto 0)

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
        i_spec_reg_or_memory_decoder : in std_logic;
        i_program_counter_csr : in std_logic_vector (15 downto 0);

        o_opcode_alu : out std_logic_vector (16 downto 0);
        o_rs_csr : out registers_array;
        o_rs1_alu, o_rs2_alu : out std_logic_vector (31 downto 0);
        o_write_enable_memory, o_write_enable_csr : out std_logic;
        o_addr_memory: out std_logic_vector (15 downto 0);
        o_write_data_memory: out std_logic_vector (31 downto 0);
        o_rd_csr : out std_logic_vector (4 downto 0);
        o_addr_spec_reg_csr : out std_logic_vector (11 downto 0);
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

-- i
	
    signal clk_s : std_logic := '0';
    signal rst_s : std_logic := '0';
    
	signal data_ss : std_logic_vector(31 downto 0);
	signal decoder_wb_src : std_logic_vector(1 downto 0);
    signal decoder_LSU_write_enable : std_logic;
    signal decoder_LSU_reg_or_memory_flag : std_logic;
    signal decoder_LSU_rs1 : std_logic_vector(4 downto 0);
    signal decoder_LSU_rs2 : std_logic_vector(4 downto 0);
    signal decoder_LSU_rd : std_logic_vector(4 downto 0);
    signal decoder_LSU_imm : std_logic_vector(11 downto 0);
    signal decoder_LSU_opcode : std_logic_vector (16 downto 0);
    signal decoder_LSU_opcode_write :std_logic_vector (16 downto 0);

    signal entry_rs_csr : registers_array;
    signal given_rs_csr : registers_array;

	 -- instruction memory
    signal read_addr_s : std_logic_vector(15 downto 0) := (others => '0');
    signal read_data_s : std_logic_vector(31 downto 0);
    
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

begin         

	tester: LSU_decoder_tester
	port map(
	o_clk => clk_s,
        o_rst => rst_s,
        o_read_addr => read_addr_s
	);

    decoder_t: command_decoder_v2
    port map (
        i_clk => clk_s,
        i_rst => rst_s,
        i_instr => read_data_s,
             
        o_rs1 => decoder_LSU_rs1,
        o_rs2 => decoder_LSU_rs2,
        o_imm => decoder_LSU_imm,
        o_rd => decoder_LSU_rd,
        o_write_to_LSU => decoder_LSU_write_enable,
        o_LSU_code => decoder_LSU_opcode,
        o_LSU_code_post	=> decoder_LSU_opcode_write,
        o_LSU_reg_or_memory_flag => decoder_LSU_reg_or_memory_flag,
        o_wb_result_src => decoder_wb_src
    );
	 
	instr_mem_t: InstructionMemory
	generic map (
		file_path => "C:\data\program.hex"
	)
   	port map (
		i_rst       => rst_s,
      		i_clk       => clk_s,
      		i_read_addr => read_addr_s,
      		o_read_data => read_data_s
        );
	

	LSU_t: LSU
	port map (
		i_clk => clk_s,
		i_rst => rst_s,
		i_rs_csr => entry_rs_csr,
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
        o_rs_csr => given_rs_csr,
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

	LSUMEM_t: LSUMEM
	port map (
	i_clk => clk_s,
	i_rst => rst_s,
	i_write_enable_LSU => LSU_LSUMEM_write_enable_memory,
        i_addr_LSU => LSU_LSUMEM_addr_memory,
        i_write_data_LSU => LSU_LSUMEM_write_data_memory
	);

	CSR_t: CSR
	port map (
		i_clk => clk_s,
		i_addr => LSU_tester_addr_spec_reg_csr,
		o_data => data_ss
	);

	
	
        --o_write_enable_memory => ,
        --o_addr_memory => ,
        --o_write_data_memory => 
	
	--
end LSU_decoder_testbench_arch;	
	
	