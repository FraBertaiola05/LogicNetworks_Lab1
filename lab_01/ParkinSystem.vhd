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
        HEX_2 : out std_logic_vector(6 downto 0);
        car_count: out integer:=0
        );
end Car_Parking_System_VHDL;

architecture arch of Car_Parking_System_VHDL is

    component led_block is
        port (
            clock : in std_logic;
            en : in std_logic;
            led_out : out std_logic
        );
    end component;

    component prescaler is
    generic(
        divider : integer := 10 
    );
    port(
        clk_in  : in  std_logic;
        reset   : in  std_logic;
        clk_out : out std_logic
    );
end component;
    --State declarations

    type FSM_States is (IDLE, WAIT_PASSWORD, WRONG_PASS, RIGHT_PASS, STOP, TIMEOUT);
    signal current_state : FSM_States;
    --Counter
    signal counter_wait : std_logic_vector(3 downto 0):= "0000";
    signal prescaled_clock: std_logic:='0';
    signal en_green_led : std_logic:='0';
    signal en_red_led : std_logic:='0';
    signal count : integer := 0;


    function is_pass_correct(pw1 : std_logic_vector(1 downto 0); pw2 : std_logic_vector(1 downto 0)) return boolean is
    begin
        if(pw1="01" and pw2="10") then
            return true;
        else
            return false;
        end if;
    end function;


begin
    --Prescaler instance
    DUT_Prescaler: prescaler
        generic map(
            divider => 2 -- Set to 2 for testing purposes, halves the clock frequency
        )
        port map(
            clk_in => clk,
            reset => reset_n,
            clk_out => prescaled_clock
        );

    --LED blocks
     DUT: led_block
        port map (
            clock => prescaled_clock,
            en => en_green_led,
            led_out => GREEN_LED
        );

    DUT2: led_block
        port map (
            clock => prescaled_clock,
            en => en_red_led,
            led_out => RED_LED
        );


    process(clk, reset_n) is
    begin
        
        if(reset_n='0') then
            current_state <= IDLE;
            counter_wait <="0000";
            HEX_1 <= "1111111"; --off
            HEX_2 <= "1111111"; --off
            GREEN_LED <= '0';
            RED_LED <= '0';
            en_green_led <= '0';
            en_red_led <= '0';
        elsif(rising_edge(clk)) then
        --default
            HEX_1 <= "1111111"; --off
            HEX_2 <= "1111111"; --off
            GREEN_LED <= '0';
            RED_LED <= '0';
            en_green_led <= '0';
            en_red_led <= '0';
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
                    if (password_1 = "00" and password_2 = "00") then
                        --no password entered go to IDLE
                        current_state <= TIMEOUT;
                    else
                        if (is_pass_correct(password_1, password_2)) then
                            current_state <= RIGHT_PASS;
                        else
                            current_state <= WRONG_PASS;
                        end if;
                    end if;
                else
                    counter_wait <= std_logic_vector(unsigned(counter_wait) + 1);
                        
                end if;
                
                --wrong pass
                when WRONG_PASS =>
                en_red_led <= '1';
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
                en_green_led <= '1';
                HEX_1 <= "0000010"; --6
                HEX_2 <= "1000000"; --O 
                if back_sensor = '1' then
                    count <= count + 1;
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
                en_red_led <= '1';
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

                --timeout
                when TIMEOUT =>
                RED_LED <= '1';
                GREEN_LED <= '1';
                if unsigned(counter_wait)>=9 then
                    counter_wait<="0000";
                    current_state <= IDLE;

                else
                    counter_wait <= std_logic_vector(unsigned(counter_wait) + 1);
                        
                end if;

                when others =>
                    current_state <= IDLE;


            end case;
        end if;
        car_count <= count;
    end process;

end arch ; -- arch
