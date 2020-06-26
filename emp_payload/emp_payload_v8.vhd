-- payload to utilize LRHLS IP-Core component, version 8

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

use work.ipbus.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.emp_device_decl.all;
use work.emp_ttc_decl.all;

entity emp_payload is
port(
	clk: in std_logic; -- ipbus signals
	rst: in std_logic;
	ipb_in: in ipb_wbus;
	ipb_out: out ipb_rbus;
	clk_payload: in std_logic_vector(2 downto 0);
	rst_payload: in std_logic_vector(2 downto 0);
	clk_p: in std_logic; -- data clock
	rst_loc: in std_logic_vector(N_REGION - 1 downto 0);
	clken_loc: in std_logic_vector(N_REGION - 1 downto 0);
	ctrs: in ttc_stuff_array;
	bc0: out std_logic;
	d: in ldata(4 * N_REGION - 1 downto 0); -- data in
	q: out ldata(4 * N_REGION - 1 downto 0); -- data out
	gpio: out std_logic_vector(29 downto 0); -- IO to mezzanine connector
	gpio_en: out std_logic_vector(29 downto 0) -- IO to mezzanine connector (three-state enables)
);

end emp_payload;

architecture rtl of emp_payload is

type dr_t is array(PAYLOAD_LATENCY downto 0) of ldata(3 downto 0);

component LRHLS_IP is
port (
	stubIn_ce0 : OUT STD_LOGIC;
	stubOut_ce0 : OUT STD_LOGIC;
	stubOut_we0 : OUT STD_LOGIC;
	ap_clk : IN STD_LOGIC;
	ap_rst : IN STD_LOGIC;
	ap_start : IN STD_LOGIC;
	ap_done : OUT STD_LOGIC;
	ap_idle : OUT STD_LOGIC;
	ap_ready : OUT STD_LOGIC;
	stubIn_address0 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
	stubIn_q0 : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
	stubOut_address0 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
	stubOut_d0 : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
);
end component LRHLS_IP;


begin

ipb_out <= IPB_RBUS_NULL;

gen: for i in N_REGION - 1 downto 0 generate

	constant ich: integer := i * 4 + 3;
	constant icl: integer := i * 4;
	signal dr: dr_t;

	attribute SHREG_EXTRACT: string;
	attribute SHREG_EXTRACT of dr: signal is "no"; -- Don't absorb FFs into shreg

	begin

	gen: for j in 3 downto 0 generate

		LRHLS_IP_0 : LRHLS_IP
		PORT MAP (
			ap_clk => clk_p,
			ap_rst => rst, 
			ap_start => '1',
			ap_done => open,
			ap_idle => open,
			ap_ready => open,
			stubIn_ce0 => open,
			stubIn_address0 => open, 
			stubIn_q0 => d(icl+j).data,
			stubOut_ce0 => open, 
			stubOut_we0 => open,  
			stubOut_address0 => open, 
			stubOut_d0 => dr(0)(j).data
		);

		dr(0)(j).valid <= d(icl).valid;
		dr(0)(j).start <= d(icl).start;
		dr(0)(j).strobe <= d(icl).strobe;

	end generate;

	process(clk_p) -- Mother of all shift registers
	begin
	if rising_edge(clk_p) then
		dr(PAYLOAD_LATENCY downto 1) <= dr(PAYLOAD_LATENCY - 1 downto 0);
	end if;
	end process;

	q(ich downto icl) <= dr(PAYLOAD_LATENCY) ;

end generate;

bc0 <= '0';

gpio <= (others => '0');
gpio_en <= (others => '0');

end rtl;
