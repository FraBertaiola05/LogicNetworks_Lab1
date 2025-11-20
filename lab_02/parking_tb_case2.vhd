-- ===========================================================================================================
-- UNIVERSITY OF TRENTO - DISI Department
-- Digital Electronics Laboratory Practice
-- 
-- Testbench in VHDL for the parking lot controller - Scenario 2
-- IMPORTANT:
-- -> Make sure to replace "MODULE_NAME" and "architecture_name" with the actual names
-- -> Make sure the DUT entity ports match the port map connections below
-- -> The payment terminal happens at the exit gates (Gout1, Gout2)
-- -> This testbench assumes a parking lot capacity of 7 cars
--
-- Description of the test cases:
-- 1) A car arrives at input gate Gin2, but back sensor never activates.
-- 2) Two cars enter from different gates (Gin1 and Gin2) sequentially.
-- 3) One car tries to leave from an input gate, then it exits properly.
-- 4) Three cars enter sequentially: two from Gin1 and one from Gin2.
-- 5) Three cars enter consecutively from Gin1 and a fourth one tries to enter when the parking lot is full.
-- ===========================================================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity parking_tb_case2 is
end entity;

architecture sim of parking_tb_case2 is
    --------------------------------------------------------------------------------
    -- Timing constants
    --------------------------------------------------------------------------------
    constant CLOCK_FREQUENCY    : integer := 100e6; -- f= 100 MHz
    constant CLOCK_PERIOD       : time := 1000 ms / CLOCK_FREQUENCY; -- T = 10 ns

    --------------------------------------------------------------------------------
    -- DUT input signals
    --------------------------------------------------------------------------------
    -- General inputs
    signal Clk                  : std_logic := '0'; --! System clock
    signal nRst                 : std_logic := '1'; --! Active low reset

    -- Payment terminal inputs
    
    signal payment_done         : std_logic := '0'; --! Payment process completed

    -- Access gates
    signal sensor_front_Gin1    : std_logic := '0';  --! Access Gate 1. First sensor BEFORE boom barrier. Direction: coming from OUTSIDE
    signal sensor_back_Gin1     : std_logic := '0';  --! Access Gate 1. Second sensor AFTER boom barrier. Direction: coming from OUTSIDE
    signal sensor_front_Gin2    : std_logic := '0';  --! Access Gate 2. First sensor BEFORE boom barrier. Direction: coming from OUTSIDE
    signal sensor_back_Gin2     : std_logic := '0';  --! Access Gate 2. Second sensor AFTER boom barrier. Direction: coming from OUTSIDE

    -- Exit gates inputs
    signal sensor_front_Gout1   : std_logic := '0';  --! Exit Gate 1. First sensor BEFORE boom barrier. Direction: coming from INSIDE
    signal sensor_back_Gout1    : std_logic := '0';  --! Exit Gate 1. Second sensor AFTER boom barrier. Direction: coming from INSIDE
    signal sensor_front_Gout2   : std_logic := '0';  --! Exit Gate 2. First sensor BEFORE boom barrier. Direction: coming from INSIDE
    signal sensor_back_Gout2    : std_logic := '0';  --! Exit Gate 2. Second sensor AFTER boom barrier. Direction: coming from INSIDE

    --------------------------------------------------------------------------------
    -- DUT output signals
    --------------------------------------------------------------------------------
    -- Payment terminal output
    signal payment_accepted     : std_logic; --! Payment process succesfully completed
    signal payment_request      : std_logic := '0'; --! Payment process requested
  
    -- Access gates outputs
    signal barrier_Gin1         : std_logic; --! Access Gate 1 boom barrier control
    signal barrier_Gin2         : std_logic; --! Access Gate 2 boom barrier control
    
    -- Exit gates outputs
    signal barrier_Gout1        : std_logic; --! Exit Gate 1 boom barrier control
    signal barrier_Gout2        : std_logic; --! Exit Gate 2 boom barrier control
    
    -- Spots availability outputs
    signal Green_Light          : std_logic; --! Green light indicates available parking spots
    signal Red_Light            : std_logic; --! Red light indicates no available parking spots
    -- optional: 7-segment display output
    signal display              : std_logic_vector(6 downto 0);

begin

    --------------------------------------------------------------------------------
    -- Generate clock
    --------------------------------------------------------------------------------
    Clk <= not Clk after CLOCK_PERIOD / 2;

    --------------------------------------------------------------------------------
    --! Instantiate the DUT
    --------------------------------------------------------------------------------
    dut : entity work.Parking_Controller(Behavioral) --! Replace with actual module and architecture names
        port map (
            -- Inputs  
            clk               => Clk,
            nrst              => nRst,
            payment_request   => payment_request,
            payment_done      => payment_done,
            sensor_A_Gin1     => sensor_front_Gin1,
            sensor_B_Gin1     => sensor_back_Gin1,
            sensor_A_Gin2     => sensor_front_Gin2,
            sensor_B_Gin2     => sensor_back_Gin2,
            sensor_A_Gout1    => sensor_front_Gout1,
            sensor_B_Gout1    => sensor_back_Gout1,
            sensor_A_Gout2    => sensor_front_Gout2,
            sensor_B_Gout2    => sensor_back_Gout2,
            -- Outputs
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
    -- Testbench process: scenario 2
    --------------------------------------------------------------------------------
    stim_proc : process --! no sensitivity list, uses wait statements
        --! local variables to simulate timing and counts inside testbench (not DUT)
        variable i : integer;
    begin
        -- initial reset
        report ">>>>> SCENARIO 2: reset <<<<<";
        nRst <= '0';
        wait for 200 ns;
        nRst <= '1';
        wait for 200 ns;

        --------------------------------------------------------------------------------------------------------------
        -- 1) A car arrives at input gate Gin2, but back sensor never activates.
        -- Note: DUT should not detect this as a valid entry nor increment car count.
        --------------------------------------------------------------------------------------------------------------
        report ">>>>> SCENARIO 2: Part 1 <<<<<";

        -- Car arrives at Gin2
        sensor_front_Gin2 <= '1';
        wait for 10 us;
        -- The car decides not to enter and leaves
        sensor_front_Gin2 <= '0';
        wait for 3 us;
        assert barrier_Gin2 = '0' report "Part 1: Barrier from Gin2 should remain closed as car did not enter" severity warning;
        -- assert unsigned(display) = 0 report "Display should show 0 cars inside" severity warning;

        wait for 17 us; -- wait some time before next case      

        --------------------------------------------------------------------------------------------------------------
        -- 2) Two cars enter from different gates (Gin1 and Gin2) sequentially.
        --------------------------------------------------------------------------------------------------------------
        report ">>>>> SCENARIO 2: Part 2 <<<<<";
    
        -- A car arrives at Gin2
        sensor_front_Gin2 <= '1';
        wait for 5 us;
        assert barrier_Gin2 = '1' report "Part 2: Barrier not opened for car entering from Gin2" severity error;
        -- The car accesses the parking lot
        sensor_back_Gin2 <= '1';
        wait for 1 us;
        sensor_front_Gin2 <= '0';
        wait for 1 us;
        sensor_back_Gin2 <= '0';

        wait for 7 us;

        -- A second car arrives at Gin1
        sensor_front_Gin1 <= '1';
        wait for 5 us;
        assert barrier_Gin1 = '1' report "Part 2: Barrier not opened for car entering from Gin1" severity error;
        -- The car accesses the parking lot
        sensor_back_Gin1 <= '1';
        wait for 1 us;
        sensor_front_Gin1 <= '0';
        wait for 1 us;
        sensor_back_Gin1 <= '0';

        wait for 35 us;

        --------------------------------------------------------------------------------------------------------------
        -- 3) One car tries to leave from an input gate, then it exits properly.
        -- Note: DUT should not count the exit until the correct exit gate is used.
        --------------------------------------------------------------------------------------------------------------
        report ">>>>> SCENARIO 2: Part 3 <<<<<";
        
        -- A car tries to exit from Gin1
        sensor_back_Gin1 <= '1';
        wait for 5 us;
        assert barrier_Gin1 = '0' report "Part 3: Barrier of Gin1 should remain closed as this is an input gate" severity warning;
        
        -- Now the car exits properly from Gout2
        sensor_front_Gout2 <= '1';
        wait for 2 us;
        -- Payment system simulation
        assert payment_request = '1' report "Part 3: Payment request not activated for car exiting from Gout2" severity error;
        payment_done <= '1';
        wait for 0.1 us;
        payment_done <= '0';
        wait for 5 us;
        assert barrier_Gout2 = '1' report "Part 3: Barrier not opened for car exiting from Gout2" severity error;
        assert payment_accepted = '1' report "Part 3: Payment not accepted for car exiting from Gout2" severity warning;
        -- The car exits the parking lot
        sensor_back_Gout2 <= '1';
        wait for 1 us;
        sensor_front_Gout2 <= '0';
        wait for 1 us;
        sensor_back_Gout2 <= '0';

        wait for 13 us;

        --------------------------------------------------------------------------------------------------------------
        -- 4) Three cars enter sequentially: two from Gin1 and one from Gin2.
        --------------------------------------------------------------------------------------------------------------
        report ">>>>> SCENARIO 2: Part 4 <<<<<";
        
        -- First car enters from Gin1
        sensor_front_Gin1 <= '1';
        wait for 5 us;
        assert barrier_Gin1 = '1' report "Part 4: Barrier not opened for car entering from Gin1" severity error;
        -- The car accesses the parking lot
        sensor_back_Gin1 <= '1';
        wait for 1 us;
        sensor_front_Gin1 <= '0';
        wait for 1 us;
        sensor_back_Gin1 <= '0';
        
        wait for 16 us;

        -- Second car enters from Gin2
        sensor_front_Gin2 <= '1';
        wait for 5 us;
        assert barrier_Gin2 = '1' report "Part 4: Barrier not opened for car entering from Gin2" severity error;
        -- The car accesses the parking lot
        sensor_back_Gin2 <= '1';
        wait for 1 us;
        sensor_front_Gin2 <= '0';
        wait for 1 us;
        sensor_back_Gin2 <= '0';
        
        wait for 17 us;

        -- Third car enters from Gin1
        sensor_front_Gin1 <= '1';
        wait for 5 us;
        assert barrier_Gin1 = '1' report "Part 4: Barrier not opened for car entering from Gin1" severity error;
        -- The car accesses the parking lot
        sensor_back_Gin1 <= '1';
        wait for 1 us;
        sensor_front_Gin1 <= '0';
        wait for 1 us;
        sensor_back_Gin1 <= '0';
        
        wait for 18 us;

        --------------------------------------------------------------------------------------------------------------
        -- 5) Three cars enter consecutively from Gin1 and a fourth one tries to enter when the parking lot is full.
        -- Note: DUT should reject the fourth car (Red_Light active).
        --------------------------------------------------------------------------------------------------------------
        report ">>>>> SCENARIO 2: Part 5 <<<<<";

        for i in 1 to 3 loop
            -- A car arrives at Gin2
            sensor_front_Gin2 <= '1';
            wait for 5 us;
            assert barrier_Gin2 = '1' report "Part 5: Barrier not opened for car entering from Gin2" severity error;
            -- The car accesses the parking lot
            sensor_back_Gin2 <= '1';
            wait for 1 us;
            sensor_front_Gin2 <= '0';
            wait for 1 us;
            sensor_back_Gin2 <= '0';
            -- Next car arrives after some time
            if i = 1 then
                wait for 34 us;
            elsif i = 2 then
                wait for 12 us;
            elsif i = 3 then
                wait for 22 us;
            end if;
        end loop;

        -- The fourth car tries to enter when parking is full
        sensor_front_Gin1 <= '1';
        wait for 10 us;
        assert barrier_Gin1 = '0' report "Part 5: Barrier should remain closed for car entering from Gin1 when full" severity warning;
        assert Green_Light = '0' report "Part 5: Green_Light should be OFF when parking is full" severity warning;
        assert Red_Light = '1' report "Part 5: Red_Light should be ON when parking is full" severity warning;
        sensor_back_Gin1 <= '1'; -- A glitch makes the back sensor activate, but car never entered
        wait for 0.1 us;
        sensor_back_Gin1 <= '0';

        wait for 20 us;

        ---------------------------------------------------------------------
        -- Final checks
        ---------------------------------------------------------------------
        report ">>>>> SCENARIO 2: Final checks <<<<<";
        assert Green_Light = '0' report "Green light should be OFF (spots available)" severity warning;
        assert Red_Light = '1' report "Red light should be ON (spots available)" severity warning; 
        --assert unsigned(display) = 7 report "Display should show 7 cars inside" severity warning;
        assert barrier_Gin1 = '0' report "Barrier Gin1 should be closed" severity warning;
        assert barrier_Gin2 = '0' report "Barrier Gin2 should be closed" severity warning;
        assert barrier_Gout1 = '0' report "Barrier Gout1 should be closed" severity warning;
        assert barrier_Gout2 = '0' report "Barrier Gout2 should be closed" severity warning;
    
    end process;

end architecture;
