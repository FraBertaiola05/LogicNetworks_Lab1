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
    signal counter_wait : std_logic_vector(3 downto 0):= "0000";
    signal tmp: std_logic:='0';

    function is_pass_correct(pw1 : std_logic_vector(1 downto 0); pw2 : std_logic_vector(1 downto 0)) return boolean is
    begin
        if(pw1="01" and pw2="10") then
            return true;
        else
            return false;
        end if;
    end function;


begin
    process(clk, reset_n) is
    begin
        --default
            HEX_1 <= "1111111"; --off
            HEX_2 <= "1111111"; --off
            GREEN_LED <= '0';
            RED_LED <= '0';

        if(reset_n='0') then
            current_state <= IDLE;
            counter_wait <="0000";
        elsif(rising_edge(clk)) then
            case current_state is
                --idle state
                when IDLE =>
                    if front_sensor = '1' then
                        current_state <= WAIT_PASSWORD;
                    end if;

                --wait pass
                when WAIT_PASSWORD =>
                RED_LED <= '1';
                HEX_1 <= "0000110"; --E
                HEX_2 <= "0101011"; --n 

                if unsigned(counter_wait)>=9 then
                    counter_wait<="0000";
                    if (is_pass_correct(password_1, password_2)) then
                        current_state <= RIGHT_PASS;
                    else
                        current_state <= WRONG_PASS;
                    end if;
                else
                    counter_wait <= std_logic_vector(unsigned(counter_wait) + 1);
                        
                end if;
                
                --wrong pass
                when WRONG_PASS =>
                RED_LED <= tmp;
                tmp <= not tmp; --blinks
                HEX_1 <= "0000110"; --E
                HEX_2 <= "0000110"; --E 

                if unsigned(counter_wait)>=9 then
                    counter_wait<="0000";
                    if (is_pass_correct(password_1, password_2)) then
                        current_state <= RIGHT_PASS;
                    else
                        current_state <= WRONG_PASS;
                    end if;
                else
                    counter_wait <= std_logic_vector(unsigned(counter_wait) + 1);
                        
                end if;

                --right pass
                when RIGHT_PASS =>
                GREEN_LED <= tmp;
                tmp <= not tmp; --blinks
                HEX_1 <= "0000010"; --6
                HEX_2 <= "1000000"; --O 
                if back_sensor = '1' then
                    if front_sensor = '0' then
                        --in this case it means the car has passed by
                        current_state <= IDLE;
                    else
                        --case meaning queue
                        current_state <= STOP;
                    end if;
                else
                    if front_sensor = '0' then
                        --case no car detected
                        current_state <= IDLE;
                        --case car is still in the parking so we do nothing
                    end if;
                end if;

                --stop
                when STOP =>
                RED_LED <= tmp;
                tmp <= not tmp; --blinks
                HEX_1 <= "0100100"; --S
                HEX_2 <= "0001100"; --P
                if unsigned(counter_wait)>=9 then
                    --after 10 cycles go to IDLE and wait for new password
                    counter_wait<="0000";
                    current_state <= IDLE;
                else
                    --else increment counter and stay in STOP
                    counter_wait <= std_logic_vector(unsigned(counter_wait) + 1);
                        
                end if;


            end case;
        end if;
    end process;

end arch ; -- arch
