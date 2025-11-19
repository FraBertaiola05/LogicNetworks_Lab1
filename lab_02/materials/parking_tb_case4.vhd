-- =================================================================================
-- UNIVERSITY OF TRENTO - DISI Department
-- Digital Electronics Laboratory Practice
-- 
-- Testbench in VHDL for the parking lot controller - Scenario 4
-- IMPORTANT:
-- -> Make sure to replace "MODULE_NAME" and "architecture_name" with the actual names
-- -> Make sure the DUT entity ports match the port map connections below
-- -> The payment terminal happens at the exit gates (Gout1, Gout2)
-- -> This testbench assumes a parking lot capacity of 7 cars
--
-- Description of the test cases:
-- 1) Three cars enter: one from Gin1 and two from Gin2.
-- 2) A car tries to enter from exit gate Gout2 (wrong direction).
-- 3) Four cars enter: alternating between gates with varying delays.
-- 4) Two cars exit normally with payment done (first from Gout1, then from Gout2).
-- 5) Two cars enter consecutively from Gin1 and a third one tries to enter when the parking lot is full.
-- =================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity parking_tb_case4 is
end entity;

architecture sim of parking_tb_case4 is
    --------------------------------------------------------------------------------
    -- Timing constants
    --------------------------------------------------------------------------------
    constant CLOCK_FREQUENCY    : integer := 100e6; -- f= 100 MHz
    constant CLOCK_PERIOD       : time := 1000 ms / CLOCK_FREQUENCY; -- T = 10 ns

    --------------------------------------------------------------------------------
    -- DUT input signals
    --------------------------------------------------------------------------------
    -- General inputs
    signal Clk                  : std_logic := '0';
    signal nRst                 : std_logic := '1';

    -- Payment terminal inputs
    signal payment_done         : std_logic := '0'; -- Payment process completed

    -- Access gates
    signal sensor_front_Gin1    : std_logic := '0';  -- Access Gate 1. First sensor BEFORE boom barrier. Direction: coming from OUTSIDE
    signal sensor_back_Gin1     : std_logic := '0';  -- Access Gate 1. Second sensor AFTER boom barrier. Direction: coming from OUTSIDE
    signal sensor_front_Gin2    : std_logic := '0';  -- Access Gate 2. First sensor BEFORE boom barrier. Direction: coming from OUTSIDE
    signal sensor_back_Gin2     : std_logic := '0';  -- Access Gate 2. Second sensor AFTER boom barrier. Direction: coming from OUTSIDE

    -- Exit gates inputs
    signal sensor_front_Gout1   : std_logic := '0';  -- Exit Gate 1. First sensor BEFORE boom barrier. Direction: coming from INSIDE
    signal sensor_back_Gout1    : std_logic := '0';  -- Exit Gate 1. Second sensor AFTER boom barrier. Direction: coming from INSIDE
    signal sensor_front_Gout2   : std_logic := '0';  -- Exit Gate 2. First sensor BEFORE boom barrier. Direction: coming from INSIDE
    signal sensor_back_Gout2    : std_logic := '0';  -- Exit Gate 2. Second sensor AFTER boom barrier. Direction: coming from INSIDE

    --------------------------------------------------------------------------------
    -- DUT output signals
    --------------------------------------------------------------------------------
    -- Payment terminal output
    signal payment_request      : std_logic := '0'; -- Payment process requested
    signal payment_accepted     : std_logic; -- Payment process succesfully completed
  
    -- Access gates outputs
    signal barrier_Gin1         : std_logic; -- Access Gate 1 boom barrier control
    signal barrier_Gin2         : std_logic; -- Access Gate 2 boom barrier control
    
    -- Exit gates outputs
    signal barrier_Gout1        : std_logic; -- Exit Gate 1 boom barrier control
    signal barrier_Gout2        : std_logic; -- Exit Gate 2 boom barrier control
    
    -- Spots availability outputs
    signal Green_Light          : std_logic; -- Green light indicates available parking spots
    signal Red_Light            : std_logic; -- Red light indicates no available parking spots
    -- optional: 7-segment display output
    signal display              : std_logic_vector(6 downto 0);

begin

    --------------------------------------------------------------------------------
    -- Generate clock
    --------------------------------------------------------------------------------
    Clk <= not Clk after CLOCK_PERIOD / 2;

    --------------------------------------------------------------------------------
    -- Instantiate the DUT
    --------------------------------------------------------------------------------
    dut : entity work.MODULE_NAME(architecture_name)
        port map (
            -- Inputs  
            YOUR_MODULE_clk               => Clk,
            YOUR_MODULE_nrst              => nRst,
            YOUR_MODULE_payment_request   => payment_request,
            YOUR_MODULE_payment_done      => payment_done,
            YOUR_MODULE_sensor_A_Gin1     => sensor_front_Gin1,
            YOUR_MODULE_sensor_B_Gin1     => sensor_back_Gin1,
            YOUR_MODULE_sensor_A_Gin2     => sensor_front_Gin2,
            YOUR_MODULE_sensor_B_Gin2     => sensor_back_Gin2,
            YOUR_MODULE_sensor_A_Gout1    => sensor_front_Gout1,
            YOUR_MODULE_sensor_B_Gout1    => sensor_back_Gout1,
            YOUR_MODULE_sensor_A_Gout2    => sensor_front_Gout2,
            YOUR_MODULE_sensor_B_Gout2    => sensor_back_Gout2,
            -- Outputs
            YOUR_MODULE_payment_accepted   => payment_accepted,
            YOUR_MODULE_barrier_Gin1       => barrier_Gin1,
            YOUR_MODULE_barrier_Gin2       => barrier_Gin2,
            YOUR_MODULE_barrier_Gout1      => barrier_Gout1,
            YOUR_MODULE_barrier_Gout2      => barrier_Gout2,
            YOUR_MODULE_Green_Light        => Green_Light,
            YOUR_MODULE_Red_Light          => Red_Light,
            YOUR_MODULE_display            => display  -- optional output
  );

    --------------------------------------------------------------------------------
    -- Testbench process: scenario 4
    --------------------------------------------------------------------------------
    stim_proc : process
        -- local variables to simulate timing and counts inside testbench (not DUT)
        variable i : integer;
    begin
        -- initial reset
        report ">>>>> SCENARIO 4: reset <<<<<";
        nRst <= '0';
        wait for 200 ns;
        nRst <= '1';
        wait for 200 ns;

        --------------------------------------------------------------------------------
        -- 1) Three cars enter: one from Gin1 and two from Gin2.
        ---------------------------------------------------------------------
        report ">>>>> SCENARIO 4: Part 1 <<<<<";
        
        -- The first car enters through Gin2
        sensor_front_Gin2 <= '1';
        wait for 5 us;
        assert barrier_Gin2 = '1' report "Part 1: Barrier not opened for car entering from Gin2" severity error;
        sensor_back_Gin2 <= '1';
        wait for 1 us;
        sensor_front_Gin2 <= '0';
        wait for 1 us;
        sensor_back_Gin2 <= '0';

        wait for 17 us;

        -- The second car enters through Gin1
        sensor_front_Gin1 <= '1';
        wait for 5 us;
        assert barrier_Gin1 = '1' report "Part 1: Barrier not opened for car entering from Gin1" severity error;
        sensor_back_Gin1 <= '1';
        wait for 1 us;
        sensor_front_Gin1 <= '0';
        wait for 1 us;
        sensor_back_Gin1 <= '0';
        
        wait for 23 us;

        -- The third car enters through Gin2
        sensor_front_Gin2 <= '1';
        wait for 5 us;
        assert barrier_Gin2 = '1' report "Part 1: Barrier not opened for car entering from Gin2" severity error;
        sensor_back_Gin2 <= '1';
        wait for 1 us;
        sensor_front_Gin2 <= '0';
        wait for 1 us;
        sensor_back_Gin2 <= '0';

        wait for 25 us;

        ---------------------------------------------------------------------
        -- 2) A car tries to enter from exit gate Gout2 (wrong direction).
        -- Note: DUT should not allow it to enter
        ---------------------------------------------------------------------
        report ">>>>> SCENARIO 4: Part 2 <<<<<";

        -- A car tries to enter from the exit gate Gout2 
        wait for 11 us;
        sensor_front_Gout2 <= '1'; -- glitch: something triggers front sensor too
        wait for 0.5 us;
        sensor_front_Gout2 <= '0';
        wait for 0.5 us;
        assert barrier_Gout2 = '0' report "Part 2: Barrier at Gout2 should NOT open for wrong direction entry without payment" severity warning;
        assert payment_accepted = '0' report "Part 2: Payment at Gout2 should not be accepted" severity warning;
        -- The car realizes mistake and leaves
        sensor_back_Gout2 <= '0';

        wait for 20 us;

        ---------------------------------------------------------------------
        -- 3) Four cars enter: alternating between gates with varying delays.
        ---------------------------------------------------------------------
        report ">>>>> SCENARIO 4: Part 3 <<<<<";
        
        -- Car 1: enters friom Gin2
        sensor_front_Gin2 <= '1';
        wait for 5 us;
        assert barrier_Gin2 = '1' report "Part 3: Barrier not opened for car entering from Gin2" severity error;
        sensor_back_Gin2 <= '1';
        wait for 1 us;
        sensor_front_Gin2 <= '0';
        wait for 1 us;
        sensor_back_Gin2 <= '0';

        wait for 15 us;

        -- Car 2: enters through Gin1 (shorter delay)
        sensor_front_Gin1 <= '1';
        wait for 5 us;
        assert barrier_Gin1 = '1' report "Part 3: Barrier not opened for car entering from Gin1" severity error;
        sensor_back_Gin1 <= '1';
        wait for 1 us;
        sensor_front_Gin1 <= '0';
        wait for 1 us;
        sensor_back_Gin1 <= '0';

        wait for 25 us;

        -- Car 3: enters through Gin1 again
        sensor_front_Gin1 <= '1';
        wait for 5 us;
        assert barrier_Gin1 = '1' report "Part 3: Barrier not opened for car entering from Gin1" severity error;
        sensor_back_Gin1 <= '1';
        wait for 1 us;
        sensor_front_Gin1 <= '0';
        wait for 1 us;
        sensor_back_Gin1 <= '0';

        wait for 12 us;

        -- Car 4: enters through Gin2 (short delay)
        sensor_front_Gin2 <= '1';
        wait for 5 us;
        assert barrier_Gin2 = '1' report "Part 3: Barrier not opened for car entering from Gin2" severity error;
        sensor_back_Gin2 <= '1';
        wait for 1 us;
        sensor_front_Gin2 <= '0';
        wait for 1 us;
        sensor_back_Gin2 <= '0';

        wait for 30 us;

        ---------------------------------------------------------------------
        -- 4) Two cars exit normally with payment done (first from Gout1, then from Gout2).
        ---------------------------------------------------------------------
        report ">>>>> SCENARIO 4: Part 4 <<<<<";
        
        -- First car exits from Gate 1
        sensor_front_Gout1 <= '1';
        wait for 5 us;
        -- Payment system simulation
        assert payment_request = '0' report "Part 4: Payment request not signaled for car exiting Gate 1" severity warning;
        payment_done <= '1';
        wait for 0.1 us;
        payment_done <= '0';
        wait for 5 us;
        assert barrier_Gout1 = '1' report "Part 4: Barrier not opened for car exiting Gate 1" severity error;
        assert payment_accepted = '1' report "Part 4: Payment not accepted for car exiting Gate 1" severity warning;
        -- The car exits the parking lot
        sensor_back_Gout1 <= '1';
        wait for 1 us;
        sensor_front_Gout1 <= '0';
        wait for 1 us;
        sensor_back_Gout1 <= '0';

        wait for 9 us;

        -- Second car exits from Gate 2
        sensor_front_Gout2 <= '1';
        wait for 5 us;
        -- Payment system simulation
        assert payment_request = '0' report "Part 4: Payment request not signaled for car exiting Gate 2" severity warning;
        payment_done <= '1';
        wait for 0.1 us;
        payment_done <= '0';
        wait for 5 us;
        assert barrier_Gout2 = '1' report "Part 4: Barrier not opened for car exiting Gate 2" severity error;
        assert payment_accepted = '1' report "Part 4: Payment not accepted for car exiting Gate 2" severity warning;
        -- The car exits the parking lot
        sensor_back_Gout2 <= '1';
        wait for 1 us;
        sensor_front_Gout2 <= '0';
        wait for 1 us;
        sensor_back_Gout2 <= '0';

        wait for 19 us;

        ---------------------------------------------------------------------
        -- 5) Two cars enter consecutively from Gin1 and a third one tries to enter when the parking lot is full.
        -- Note: DUT should reject the fourth car (Red_Light active).
        ---------------------------------------------------------------------
        report ">>>>> SCENARIO 4: Part 5 <<<<<";
        
        -- First car: should enter successfully (6th car)
        sensor_front_Gin1 <= '1';
        wait for 5 us;
        assert barrier_Gin1 = '1' report "Part 5: Barrier should open for 6th car entering from Gin1" severity error;
        sensor_back_Gin1 <= '1';
        wait for 1 us;
        sensor_front_Gin1 <= '0';
        wait for 1 us;
        sensor_back_Gin1 <= '0';

        wait for 20 us;

        -- Second car: should enter successfully (7th car - FULL)
        sensor_front_Gin2 <= '1';
        wait for 5 us;
        assert barrier_Gin2 = '1' report "Part 5: Barrier should open for 7th car entering from Gin2 (last spot)" severity error;
        sensor_back_Gin2 <= '1';
        wait for 1 us;
        sensor_front_Gin2 <= '0';
        wait for 1 us;
        sensor_back_Gin2 <= '0';

        wait for 10 us;

        -- Another car attempts to enter from Gin1: should be REJECTED (parking full)
        sensor_front_Gin2 <= '1';
        assert Red_Light = '1' report "Part 5: Red light should be ON when parking is full" severity warning;
        assert Green_Light = '0' report "Part 5: Green light should be OFF when parking is full" severity warning;
        wait for 10 us;
        assert barrier_Gin2 = '0' report "Part 5: Barrier at Gin2 should NOT open when parking is full" severity warning;
        sensor_back_Gin2 <= '1'; -- A glitch makes the back sensor activate, but car never entered
        wait for 0.1 us;
        sensor_back_Gin2 <= '0';
        assert Red_Light = '1' report "Part 5: Red light should remain ON" severity warning;

        wait for 30 us;

        ---------------------------------------------------------------------
        -- Final checks
        ---------------------------------------------------------------------
        report ">>>>> SCENARIO 4: Final checks <<<<<";
        assert Green_Light = '0' report "Green light should be OFF (parking full)" severity warning;
        assert Red_Light = '1' report "Red light should be ON (parking full)" severity warning; 
        --assert unsigned(display) = 7 report "Display should show 7 cars inside" severity warning;
        assert barrier_Gin1 = '0' report "Barrier Gin1 should be closed" severity warning;
        assert barrier_Gin2 = '0' report "Barrier Gin2 should be closed" severity warning;
        assert barrier_Gout1 = '0' report "Barrier Gout1 should be closed" severity warning;
        assert barrier_Gout2 = '0' report "Barrier Gout2 should be closed" severity warning;
    
    end process;

end architecture;