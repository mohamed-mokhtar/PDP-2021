library ieee;
use ieee.std_logic_1164.all;


entity SmallRegEnt is
    port
    (
        Clk,Input : in std_logic;
        Output : out std_logic
    );
end entity;


architecture SmallRegArc of SmallRegEnt is 
begin 
    process(Clk , Input)
    begin 
        if (falling_edge(Clk)) then
            Output <= Input;
        end if;
    end process;
end architecture;