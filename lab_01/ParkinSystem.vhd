library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Car_Parking_System_VHDL is 
generic(ClockFrequencyHz : integer);
port( clk : in std_logic;
        reset_n : in std_logic; -- Active low
        front_sensor: in std_logic;
        back_sensor : in std_logic;
        password_1 : in std_logic_vector(1 downto 0);
        password_2 : in std_logic_vector(1 downto 0);
        GREEN_LED : out std_logic;
        RED_LED : out std_logic;
        HEX_1 : out std_logic_vector(6 downto 0); 
        HEX_2 : out std_logic_vector(6 downto 0)
        );
end Car_Parking_System_VHDL;

architecture arch of Car_Parking_System_VHDL is
    --State declarations
    type FSM_States is (IDLE, WAIT_PASSWORD, WRONG_PASS, RIGHT_PASS, STOP);
    signal current_state : FSM_States;
    --Counter
    signal counter_wait : std_logic_vector(3 downto 0);


begin
    process(clk, rst) is
    begin
        if(reset_n='0') then
            current_state <= IDLE;
        elsif(rising_edge(clk)) then
            --idle state
            when IDLE =>
            green_tmp <= '0';
            red_tmp <= '0';
            HEX_1 <= "1111111"; 
            HEX_2 <= "1111111"; 

            --wait pass
            when WAIT_PASSWORD =>
            green_tmp <= '0';
            red_tmp <= '1';
            HEX_1 <= "0000110"; --E
            HEX_2 <= "0101011"; --n 
            
            --wrong pass
            when WRONG_PASS =>
            green_tmp <= '0';
            red_tmp <= '0'; --blonks
            HEX_1 <= "0000110"; --E
            HEX_2 <= "0000110"; --E 

            --right pass
            when RIGHT_PASS =>
            green_tmp <= '0'; --blinks
            red_tmp <= '0';
            HEX_1 <= "0000010"; --6
            HEX_2 <= "1000000"; --O 

            --stop
            when RIGHT_PASS =>
            green_tmp <= '0';
            red_tmp <= '0'; --blinks
            HEX_1 <= "0100100"; --S
            HEX_2 <= "0001100"; --P
        end if;
    end process;

end arch ; -- arch
