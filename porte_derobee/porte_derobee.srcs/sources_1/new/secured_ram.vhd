library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity secured_ram is
    port (
        clk : in std_logic;
        we : in std_logic;
        unlock_w_in : in std_logic;
        unlock_rw_in : in std_logic;
        addr : in std_logic_vector(5 downto 0);
        di : in std_logic_vector(15 downto 0);
        do : out std_logic_vector(15 downto 0)
    );
end secured_ram;

architecture behavioral of secured_ram is

    -- RAM component integration
    component ram
        port (
            clk : in std_logic;
            we : in std_logic;
            en : in std_logic;
            addr : in std_logic_vector(5 downto 0);
            di : in std_logic_vector(15 downto 0);
            do : out std_logic_vector(15 downto 0)
        );
    end component;
    
    -- Constants definition
    constant addr_w_lock : integer := 0;
    constant addr_rw_lock : integer := 8;
    constant addr_ram : integer := 16;
    
    -- Signals definition
    signal en_tmp : std_logic := '0';

begin

    -- RAM component port mapping
    memory: ram port map (
            clk => clk,
            we => we,
            en => en_tmp,
            addr => addr,
            di => di,
            do => do
    );
    
    -- Access for free RAM part
    en_tmp <= '1' when (to_integer(unsigned(addr)) >= addr_ram)
    
    -- Access for read only RAM part
    else '1' when (to_integer(unsigned(addr)) >= addr_w_lock and to_integer(unsigned(addr)) < addr_rw_lock and unlock_w_in = '1' and we = '1')
    else '1' when (to_integer(unsigned(addr)) >= addr_w_lock and to_integer(unsigned(addr)) < addr_rw_lock and we = '0')
    
    -- Access for R/W forbidden RAM part
    else '1' when (to_integer(unsigned(addr)) >= addr_rw_lock and to_integer(unsigned(addr)) < addr_ram and unlock_rw_in = '1')
    else '0'; 

end behavioral;
