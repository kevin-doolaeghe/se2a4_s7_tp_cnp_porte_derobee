library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ram is
    port (
        clk : in std_logic;
        we : in std_logic;
        en : in std_logic;
        addr : in std_logic_vector(5 downto 0);
        di : in std_logic_vector(15 downto 0);
        do : out std_logic_vector(15 downto 0)
    );
end ram;

architecture behavioral of ram is

type ram_type is array (63 downto 0) of std_logic_vector (15 downto 0);
signal RAM : ram_type;

begin

process (clk)
begin
    if clk'event and clk = '1' then
        if en = '1' then
            if we = '1' then
                RAM(conv_integer(addr)) <= di;
                do <= di;
            else
                do <= RAM(conv_integer(addr));
            end if;
        else
            do <= (others => '0');
        end if;
    end if;
end process;

end behavioral;