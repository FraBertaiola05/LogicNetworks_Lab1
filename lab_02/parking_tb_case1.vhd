-- =================================================================================
-- UNIVERSITY OF TRENTO - DISI Department
-- Digital Electronics Laboratory Practice
-- 
-- Testbench in VHDL for the parking lot controller - Scenario 1
-- IMPORTANT:
-- -> Make sure to replace "MODULE_NAME" and "architecture_name" with the actual names
-- -> Make sure the DUT entity ports match the port map connections below
-- -> The payment terminal happens at the exit gates (Gout1, Gout2)
-- -> This testbench assumes a parking lot capacity of 7 cars
--
-- Description of the test cases:
-- 1) Three cars enter sequentially from input gate Gin1.
-- 2) One car leaves normally from exit gate Gout1.
-- 3) Two cars enter simultaneously from the two input gates Gin1 and Gin2.
-- 4) One car enters from Gin2 and then two cars leave sequentially from Gout2.
-- 5) A car approaches the exit, but payment is not done.
-- =================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity parking_tb_case1 is
end entity;

architecture sim of parking_tb_case1 is
    --------------------------------------------------------------------------------
    -- Timing constants
    --------------------------------------------------------------------------------
    constant CLOCK_FREQUENCY    : integer := 100e6; -- f= 100 MHz
    constant CLOCK_PERIOD       : time := 1000 ms / CLOCK_FREQUENCY; -- T = 10 ns

    --------------------------------------------------------------------------------
    -- DUT input signals
    --------------------------------------------------------------------------------
    -- General inputs
    signal Clk                  : std_logic := '0'; --! Clock signal
    signal nRst                 : std_logic := '1'; --! Active low reset signal

    -- Payment terminal inputs
    signal payment_done         : std_logic := '0'; --! Payment process completed

    -- Access gates
    signal sensor_front_Gin1    : std_logic := '0';  --! Access Gate 1. First sensor BEFORE boom barrier. Direction: coming from OUTSIDE
    signal sensor_back_Gin1     : std_logic := '0';  --! Access Gate 1. Second sensor AFTER boom barrier. Direction: coming from OUTSIDE
    signal sensor_front_Gin2    : std_logic := '0';  --! Access Gate 2. First sensor BEFORE boom barrier. Direction: coming from OUTSIDE
    signal sensor_back_Gin2     : std_logic := '0';  --! Access Gate 2. Second sensor AFTER boom barrier. Direction: coming from OUTSIDE

    --! Exit gates inputs
    signal sensor_front_Gout1   : std_logic := '0';  --! Exit Gate 1. First sensor BEFORE boom barrier. Direction: coming from INSIDE
    signal sensor_back_Gout1    : std_logic := '0';  --! Exit Gate 1. Second sensor AFTER boom barrier. Direction: coming from INSIDE
    signal sensor_front_Gout2   : std_logic := '0';  --! Exit Gate 2. First sensor BEFORE boom barrier. Direction: coming from INSIDE
    signal sensor_back_Gout2    : std_logic := '0';  --! Exit Gate 2. Second sensor AFTER boom barrier. Direction: coming from INSIDE

    --------------------------------------------------------------------------------
    -- DUT output signals
    --------------------------------------------------------------------------------
    -- Payment terminal output
    signal payment_request      : std_logic := '0'; --! Payment process requested
    signal payment_accepted     : std_logic; --! Payment process succesfully completed
  
    --! Access gates outputs
    signal barrier_Gin1         : std_logic; --! Access Gate 1 boom barrier control
    signal barrier_Gin2         : std_logic; --! Access Gate 2 boom barrier control
    
    --! Exit gates outputs
    signal barrier_Gout1        : std_logic; --! Exit Gate 1 boom barrier control
    signal barrier_Gout2        : std_logic; --! Exit Gate 2 boom barrier control
    
    --! Spots availability outputs
    signal Green_Light          : std_logic; --! Green light indicates available parking spots
    signal Red_Light            : std_logic; --! Red light indicates no available parking spots
    -- optional: 7-segment display output
    signal display              : std_logic_vector(6 downto 0); --! 7-segment display showing number of cars inside

begin

    --------------------------------------------------------------------------------
    -- Generate clock
    --------------------------------------------------------------------------------
    Clk <= not Clk after CLOCK_PERIOD / 2;

    --------------------------------------------------------------------------------
    -- Instantiate the DUT
    --------------------------------------------------------------------------------
    dut : entity work.Parking_Controller(Behavioral)
        port map (
            --! Inputs  
            clk               => Clk,
            nrst              => nRst,
            payment_done      => payment_done,
            sensor_A_Gin1     => sensor_front_Gin1,
            sensor_B_Gin1     => sensor_back_Gin1,
            sensor_A_Gin2     => sensor_front_Gin2,
            sensor_B_Gin2     => sensor_back_Gin2,
            sensor_A_Gout1    => sensor_front_Gout1,
            sensor_B_Gout1    => sensor_back_Gout1,
            sensor_A_Gout2    => sensor_front_Gout2,
            sensor_B_Gout2    => sensor_back_Gout2,
            --! Outputs
            payment_request   => payment_request,
            payment_accepted   => payment_accepted,
            barrier_Gin1       => barrier_Gin1,
            barrier_Gin2       => barrier_Gin2,
            barrier_Gout1      => barrier_Gout1,
            barrier_Gout2      => barrier_Gout2,
            Green_Light        => Green_Light,
            Red_Light          => Red_Light,
            display            => display  -- optional output
  );

    --------------------------------------------------------------------------------
    -- Testbench process: scenario 1
    --------------------------------------------------------------------------------
    stim_proc : process
        --! local variables to simulate timing and counts inside testbench (not DUT)
        variable i : integer;
    begin
        --! initial reset
        report ">>>>> SCENARIO 1: reset <<<<<";
        nRst <= '0';
        wait for 200 ns;
        nRst <= '1';
        wait for 200 ns;

        --------------------------------------------------------------------------------
        -- 1) Three cars enter sequentially from input gate Gin1.
        --------------------------------------------------------------------------------
        report ">>>>> SCENARIO 1: Part 1 <<<<<";
        
        for i in 1 to 3 loop
            -- A car arrives at input gate Gin1
            sensor_front_Gin1 <= '1';
            wait for 5 us;
            assert barrier_Gin1 = '1' report "Part 1: Barrier not opened for car entering from Gin1" severity error;
            -- The car accesses the parking lot
            sensor_back_Gin1 <= '1';
            wait for 1 us;
            sensor_front_Gin1 <= '0';
            wait for 1 us;
            sensor_back_Gin1 <= '0';
            -- Next car arrives after some time
            if i = 1 then
                wait for 18 us;
            elsif i = 2 then
                wait for 15 us;
            elsif i = 3 then
                wait for 26 us;
            end if;
        end loop;

        --------------------------------------------------------------------------------
        -- 2) One car leaves normally from exit gate Gout1.
        --------------------------------------------------------------------------------
        report ">>>>> SCENARIO 1: Part 2 <<<<<";
        
        -- A car arrives at exit gate Gout1
        sensor_front_Gout1 <= '1';
        wait for 2 us;
        -- Payment system simulation
        wait for 0.1 us;
        payment_done <= '1';
        wait for 0.1 us;
        payment_done <= '0';
        wait for 5 us;
        assert barrier_Gout1 = '1' report "Part 2: Barrier not opened for car exiting from Gout1" severity error;
        assert payment_accepted = '1' report "Part 2: Payment not accepted for car exiting from Gout1" severity warning;
        -- The car exits the parking lot
        sensor_back_Gout1 <= '1';
        wait for 1 us;
        sensor_front_Gout1 <= '0';
        wait for 1 us;
        sensor_back_Gout1 <= '0';

        wait for 10 us;

        --------------------------------------------------------------------------------
        -- 3) Two cars enter simultaneously from the two input gates Gin1 and Gin2.
        -- Note: DUT must correctly count both.
        --------------------------------------------------------------------------------
        report ">>>>> SCENARIO 1: Part 3 <<<<<";

        -- Both cars arrive at their respective gates at the same time
        sensor_front_Gin1 <= '1';
        sensor_front_Gin2 <= '1';
        wait for 5 us;
        assert barrier_Gin1 = '1' report "Part 3: Barrier not opened for car entering from Gin1" severity error;
        assert barrier_Gin2 = '1' report "Part 3: Barrier not opened for car entering from Gin2" severity error;
        -- Both cars access the parking lot simultaneously
        sensor_back_Gin1 <= '1';
        sensor_back_Gin2 <= '1';
        wait for 1 us;
        sensor_front_Gin1 <= '0';
        sensor_front_Gin2 <= '0';
        wait for 1 us;
        sensor_back_Gin1 <= '0';
        sensor_back_Gin2 <= '0';

        wait for 20 us;

        --------------------------------------------------------------------------------
        -- 4) One car enters from Gin2 and then two cars leave sequentially from Gout2.
        --------------------------------------------------------------------------------
        report ">>>>> SCENARIO 1: Part 4 <<<<<";

        -- One car enters from gate Gin2
        sensor_front_Gin2 <= '1';
        wait for 5 us;
        assert barrier_Gin2 = '1' report "Part 4: Barrier not opened for car entering from Gin2" severity error;
        sensor_back_Gin2 <= '1';
        wait for 1 us;
        sensor_front_Gin2 <= '0';
        wait for 1 us;
        sensor_back_Gin2 <= '0';
        wait for 20 us;

        -- Two cars leaving from gate Gout2 sequentially
        for i in 1 to 2 loop
            -- Car arrives at exit gate Gout2
            sensor_front_Gout2 <= '1';
            wait for 5 us;
            -- Payment system simulation
            assert payment_request='1'  report "Part 4: Payment request not high before payment done at Gout2" severity warning;
            payment_done <= '1';
            wait for 0.1 us;
            payment_done <= '0';
            wait for 5 us;
            assert barrier_Gout2 = '1' report "Part 4: Barrier not opened for car exiting from Gout2" severity error;
            assert payment_accepted = '1' report "Part 4: Payment not accepted for car exiting from Gout2" severity warning;
            -- The car exits the parking lot
            sensor_back_Gout2 <= '1';
            wait for 1 us;
            sensor_front_Gout2 <= '0';
            wait for 1 us;
            sensor_back_Gout2 <= '0';
            -- Next car arrives after some time
            if i = 1 then
                wait for 7 us;
            else
                wait for 12 us;
            end if;
        end loop;

        --------------------------------------------------------------------------------
        -- 5) A car approaches the exit, but payment is not done.
        --------------------------------------------------------------------------------
        report ">>>>> SCENARIO 1: Part 5 <<<<<";
        
        -- Car arrives at exit gate Gout1
        sensor_front_Gout1 <= '1';
        wait for 2 us;
        -- Payment system simulation (no payment done)
        wait for 10 us;
        assert barrier_Gout1 = '0' report "Part 5: Barrier opened without payment at Gout1" severity warning;
        assert payment_accepted = '0' report "Part 5: Payment accepted without payment at Gout1" severity warning;
        -- Car leaves without paying (glitch on back sensor)
        sensor_back_Gout1 <= '1';  -- glitch: something triggers back sensor before payment is done
        wait for 0.5 us;
        sensor_back_Gout1 <= '0';
        assert barrier_Gout1 = '0' report "Part 5: Barrier opened without payment at Gout1" severity warning;
        assert payment_accepted = '0' report "Part 5: Payment accepted without payment at Gout1" severity warning;

        wait for 30 us;

        --------------------------------------------------------------------------------
        -- Final checks
        --------------------------------------------------------------------------------
        report ">>>>> SCENARIO 1: Final checks <<<<<";
        assert Green_Light = '1' report "Green light should be ON (spots available)" severity warning;
        assert Red_Light = '0' report "Red light should be OFF (spots available)" severity warning; 
        -- assert unsigned(display) = 3 report "Display should show 3 cars inside" severity warning;
        assert barrier_Gin1 = '0' report "Barrier Gin1 should be closed" severity warning;
        assert barrier_Gin2 = '0' report "Barrier Gin2 should be closed" severity warning;
        assert barrier_Gout1 = '0' report "Barrier Gout1 should be closed" severity warning;
        assert barrier_Gout2 = '0' report "Barrier Gout2 should be closed" severity warning;
    
    end process;

end architecture;