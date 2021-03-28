library ieee;
use ieee.std_logic_1164.all;

entity test_ram is
end test_ram;

architecture behavioral of test_ram is

    component ram
    port (
        clk : in std_logic;
        we : in std_logic;
        en : in std_logic;
        addr : in std_logic_vector (5 downto 0);
        di : in std_logic_vector (15 downto 0);
        do : out std_logic_vector (15 downto 0)
    );
    end component;
    
    signal clk : std_logic;
    signal we : std_logic;
    signal en : std_logic;
    signal addr : std_logic_vector (5 downto 0);
    signal di : std_logic_vector (15 downto 0);
    signal do : std_logic_vector (15 downto 0);
    
    constant clk_period : time := 10 ns;

begin

    uut: ram port map (
        clk => clk,
        we => we,
        en => en,
        addr => addr,
        di => di,
        do => do
    );
    
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;
    
    stim_proc: process
    begin
        -- Init
        wait for 10 ns;
        en <= '1';
        we <= '0';
        addr <= (others => '0');
        di <= (others => '0');
        
        -- Write 5555h at address 0
        wait for 1 us;
        we <= '1';
        addr <= (others => '0');
        di <= "0101010101010101";
        
        -- Write AAAAh at address 8 with WE rising edge
        wait for 1 us;
        we <= '0';
        wait for 10 ns;
        we <= '1';
        addr <= "001000";
        di <= "1010101010101010";
        
        -- Write CCCCh at address 16
        wait for 1 us;
        we <= '1';
        addr <= "010000";
        di <= "1100110011001100";
        
        -- Read data at address 0
        wait for 1 us;
        we <= '0';
        addr <= (others => '0');
        di <= (others => '0');
        
        -- Read data at address 8
        wait for 1 us;
        we <= '0';
        addr <= "001000";
        di <= (others => '0');
        
        -- Read data at address 16
        wait for 1 us;
        we <= '0';
        addr <= "010000";
        di <= (others => '0');
        
        -- Write 3333h at address 0 without permission
        wait for 1 us;
        we <= '1';
        addr <= (others => '0');
        di <= "0011001100110011";
        
        -- Read data at address 0
        wait for 1 us;
        we <= '0';
        addr <= (others => '0');
        di <= "0011001100110011";
        
        -- Write 3333h at address 0 with permission
        wait for 1 us;
        we <= '1';
        addr <= (others => '0');
        di <= "0011001100110011";
        
        -- Read data at address 0
        wait for 1 us;
        we <= '0';
        addr <= (others => '0');
        di <= "1111111111111111";
        
        -- Write 1286h at adrress 8 without permission
        wait for 1 us;
        we <= '1';
        addr <= "001000";
        di <= "0001001010000110";
        
        -- Read data at address 8 without permission
        wait for 1 us;
        we <= '0';
        addr <= "001000";
        di <= "0001001010000110";
        
        -- Read data at address 8 with permission
        wait for 1 us;
        we <= '0';
        addr <= "001000";
        di <= "0001001010000110";
        
        -- Write 1286h at adrress 8 with permission
        wait for 1 us;
        we <= '1';
        addr <= "001000";
        di <= "0001001010000110";
        
        -- Read data at address 8 with permission
        wait for 1 us;
        we <= '0';
        addr <= "001000";
        di <= "0001001010000110";
        
        -- Reset
        wait for 1 us;
        we <= '0';
        addr <= (others => '0');
        di <= (others => '0');
        
        wait;
    end process;

end behavioral;
