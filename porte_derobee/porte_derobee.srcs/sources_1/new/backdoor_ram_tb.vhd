library ieee;
use ieee.std_logic_1164.all;

entity test_backdoor_ram is
end test_backdoor_ram;

architecture behavioral of test_backdoor_ram is

    component backdoor_ram
    port (
        clk : in std_logic;
        we : in std_logic;
        unlock_w_in : in std_logic;
        unlock_rw_in : in std_logic;
        addr : in std_logic_vector (5 downto 0);
        di : in std_logic_vector (15 downto 0);
        do : out std_logic_vector (15 downto 0);
        ook : out std_logic
    );
    end component;
    
    component frequency_divider
    generic (
        MAX_CNT : integer := 10 -- Frequency divided by 10
    );
    port (
        iClk : in std_logic;
        oClk : out std_logic
    );
    
    end component;
    signal clk : std_logic;
    signal we : std_logic;
    signal unlock_w_in : std_logic;
    signal unlock_rw_in : std_logic;
    signal addr : std_logic_vector (5 downto 0);
    signal di : std_logic_vector (15 downto 0);
    signal do : std_logic_vector (15 downto 0);
    signal ook : std_logic;
    
    signal clk_bf : std_logic;
    
    constant clk_period : time := 10ns;

begin

    uut: backdoor_ram port map (
        clk => clk,
        we => we,
        unlock_w_in => unlock_w_in,
        unlock_rw_in => unlock_rw_in,
        addr => addr,
        di => di,
        do => do,
        ook => ook
    );
    
    freq_div : frequency_divider port map (
        iClk => clk,
        oClk => clk_bf
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
        unlock_w_in <= '0';
        unlock_rw_in <= '0';
        we <= '0';
        addr <= (others => '0');
        di <= (others => '0');
        
        -- Write 5555h at address 0
        wait for 1 us;
        unlock_w_in <= '1';
        unlock_rw_in <= '0';
        we <= '1';
        addr <= (others => '0');
        di <= "0101010101010101";
        
        -- Write AAAAh at address 8 with WE rising edge
        wait for 1 us;
        we <= '0';
        wait for 10 ns;
        unlock_w_in <= '0';
        unlock_rw_in <= '1';
        we <= '1';
        addr <= "001000";
        di <= "1010101010101010";
        
        -- Write CCCCh at address 16
        wait for 1 us;
        unlock_w_in <= '0';
        unlock_rw_in <= '0';
        we <= '1';
        addr <= "010000";
        di <= "1100110011001100";
        
        -- Read data at address 0
        wait for 1 us;
        unlock_w_in <= '0';
        unlock_rw_in <= '0';
        we <= '0';
        addr <= (others => '0');
        di <= (others => '0');
        
        -- Read data at address 8
        wait for 1 us;
        unlock_w_in <= '0';
        unlock_rw_in <= '1';
        we <= '0';
        addr <= "001000";
        di <= (others => '0');
        
        -- Read data at address 16
        wait for 1 us;
        unlock_w_in <= '0';
        unlock_rw_in <= '0';
        we <= '0';
        addr <= "010000";
        di <= (others => '0');
        
        -- Write 3333h at address 0 without permission
        wait for 1 us;
        unlock_w_in <= '0';
        unlock_rw_in <= '0';
        we <= '1';
        addr <= (others => '0');
        di <= "0011001100110011";
        
        -- Read data at address 0
        wait for 1 us;
        unlock_w_in <= '0';
        unlock_rw_in <= '0';
        we <= '0';
        addr <= (others => '0');
        di <= "0011001100110011";
        
        -- Write 3333h at address 0 with permission
        wait for 1 us;
        unlock_w_in <= '1';
        unlock_rw_in <= '0';
        we <= '1';
        addr <= (others => '0');
        di <= "0011001100110011";
        
        -- Read data at address 0
        wait for 1 us;
        unlock_w_in <= '0';
        unlock_rw_in <= '0';
        we <= '0';
        addr <= (others => '0');
        di <= "1111111111111111";
        
        -- Write 1286h at adrress 8 without permission
        wait for 1 us;
        unlock_w_in <= '0';
        unlock_rw_in <= '0';
        we <= '1';
        addr <= "001000";
        di <= "0001001010000110";
        
        -- Read data at address 8 without permission
        wait for 1 us;
        unlock_w_in <= '0';
        unlock_rw_in <= '0';
        we <= '0';
        addr <= "001000";
        di <= "0001001010000110";
        
        -- Read data at address 8 with permission
        wait for 1 us;
        unlock_w_in <= '0';
        unlock_rw_in <= '1';
        we <= '0';
        addr <= "001000";
        di <= "0001001010000110";
        
        -- Write 1286h at adrress 8 with permission
        wait for 1 us;
        unlock_w_in <= '0';
        unlock_rw_in <= '1';
        we <= '1';
        addr <= "001000";
        di <= "0001001010000110";
        
        -- Read data at address 8 with permission
        wait for 1 us;
        unlock_w_in <= '0';
        unlock_rw_in <= '1';
        we <= '0';
        addr <= "001000";
        di <= "0001001010000110";
        
        -- Reset
        wait for 1 us;
        unlock_w_in <= '0';
        unlock_rw_in <= '0';
        we <= '0';
        addr <= (others => '0');
        di <= (others => '0');
        
        wait;
    end process;

end behavioral;
