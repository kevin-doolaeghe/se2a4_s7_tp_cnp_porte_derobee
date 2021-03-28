library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity frequency_divider is
    generic (
        MAX_CNT : integer := 8
    );
    port (
        iClk : in std_logic;
        oClk : out std_logic
    );
end frequency_divider;

architecture behavioral of frequency_divider is

signal cnt : integer range 0 to (MAX_CNT / 2) - 1 := 0;
signal clk : std_logic := '0';

begin

    process(iClk)
    begin
        if rising_edge(iClk) then
            if cnt < ((MAX_CNT / 2) - 1) then
                cnt <= cnt + 1;
            else
                cnt <= 0;
                clk <= not clk;
            end if;
        end if;
    end process;

    oClk <= clk;

end behavioral;
