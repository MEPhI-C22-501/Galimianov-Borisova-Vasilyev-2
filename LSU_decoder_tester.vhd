library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.inst_mem_pkg.all;
use work.register_file_pkg.all;

entity LSU_decoder_tester is
	port (
		
      o_clk : out std_logic;
      o_rst : out std_logic;
    
	-- instruction memory
	o_read_addr : out std_logic_vector(15 downto 0)

	);
end LSU_decoder_tester;


architecture LSU_decoder_tt of LSU_decoder_tester is
    signal clk_s       : std_logic := '0';
    signal rst_s : std_logic := '0'; -- Объявление rst_s
	constant clk_period : time := 10 ns;
procedure wait_clk(constant j: in integer) is 
        variable ii: integer := 0;
        begin
        while ii < j loop
		if(rising_edge(clk_s)) then
	    	 ii := ii + 1;
		end if;
            wait for 10 ps;
        end loop;
    end;
begin
		clk_s <= not clk_s after clk_period / 2;
      		o_clk <= clk_s;
		o_rst <= rst_s;
	process
		
	begin
		
        	wait_clk(2);
	 
                 rst_s <= '1';
		  
		  wait_clk(2);

        rst_s <= '0';

	for addr in 0 to 34 loop
		o_read_addr <= std_logic_vector(to_unsigned(addr, 16));
		wait_clk(1);
	end loop;
	wait;
	end process;
end LSU_decoder_tt;

