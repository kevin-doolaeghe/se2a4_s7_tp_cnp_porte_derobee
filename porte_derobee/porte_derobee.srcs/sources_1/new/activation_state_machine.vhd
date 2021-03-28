library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity activation_state_machine is
    port (
        iClk : in std_logic;
        iEn : in std_logic;
        iAck : in std_logic;
        iAddr : in std_logic_vector (5 downto 0);
        oStart : out std_logic
    );
end activation_state_machine;

architecture behavioral of activation_state_machine is

    -- Signals definition
    -- State machine states signal
    signal state : std_logic_vector (1 downto 0) := (others => '0');
    -- Other signals
    signal start : std_logic := '0';
    signal en_old : std_logic := '0';

begin

    process (iClk)
    begin
        -- If there is a rising edge of the clock
        if rising_edge(iClk) then
            -- Detect current state
            case state is
                -- Idle state
                when "00" =>
                    start <= '0';

                    -- If writing in private storage
                    if iEn = '1' and en_old = '0' and iAddr >= 0 and iAddr < 16 then
                        state <= "01"; -- First access state
                    else
                        state <= "00"; -- Idle state
                    end if;

                -- First access state
                when "01" =>
                    start <= '0';
                    -- If writing in private storage
                    if iEn = '1' and en_old = '0' and iAddr >= 0 and iAddr < 16 then
                        state <= "10"; -- Second access state
                    else
                        state <= "01"; -- First access
                    end if;

                -- Second access state
                when "10" =>
                    start <= '1'; -- Enabling private data send
                    
                    -- If data sent is acknowledged
                    if iAck = '1' then
                        state <= "00"; -- Idle state
                    else
                        state <= "10"; -- Second access
                    end if;

                -- Other states
                when others =>
                    state <= "00"; -- Idle state

            end case;
            en_old <= iEn; -- Saving old EN pin state
        end if;
    end process;

    oStart <= start;

end behavioral;
