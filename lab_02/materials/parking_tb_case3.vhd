-- =================================================================================
-- UNIVERSITY OF TRENTO - DISI Department
-- Digital Electronics Laboratory Practice
-- 
-- Testbench in VHDL for the parking lot controller - Scenario 3
-- IMPORTANT:
-- -> Make sure to replace "MODULE_NAME" and "architecture_name" with the actual names
-- -> Make sure the DUT entity ports match the port map connections below
-- -> The payment terminal happens at the exit gates (Gout1, Gout2)
-- -> This testbench assumes a parking lot capacity of 7 cars
--
-- Description of the test cases:
-- 1) Two cars enter simultaneously from the two input gates Gin1 and Gin2.
-- 2) A car tries to enter from Gin1 but stops at the back sensor, then reverses out.
-- 3) Two cars exit sequentially, each from different gate (Gout1 and Gout2).
-- 4) Five cars enter: 3 from Gin1 and 2 from Gin2.
-- 5) Two cars enter sequentially from Gin2.
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
    signal payment_request      : std_logic := '0'; --! Payment process requested
    signal payment_accepted     : std_logic; --! Payment process succesfully completed
  
    -- Access gates outputs
    signal barrier_Gin1         : std_logic; --! Access Gate 1 boom barrier control
    signal barrier_Gin2         : std_logic; --! Access Gate 2 boom barrier control
    
    --! Exit gates outputs
    signal barrier_Gout1        : std_logic; --! Exit Gate 1 boom barrier control
    signal barrier_Gout2        : std_logic; --! Exit Gate 2 boom barrier control
    
    --! Spots availability outputs
    signal Green_Light          : std_logic; --! Green light indicates available parking spots
    signal Red_Light            : std_logic; --! Red light indicates no available parking spots
    --! optional: 7-segment display output
    signal display              : std_logic_vector(6 downto 0); --! 7-segment display showing number of cars inside

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
    -- Testbench process: scenario 3
    --------------------------------------------------------------------------------
    stim_proc : process
        -- local variables to simulate timing and counts inside testbench (not DUT)
        variable i : integer;
    begin
        -- initial reset
        report ">>>>> SCENARIO 3: reset <<<<<";
        nRst <= '0';
        wait for 200 ns;
        nRst <= '1';
        wait for 200 ns;

        --------------------------------------------------------------------------------
        -- 1) Two cars enter simultaneously from the two input gates Gin1 and Gin2.
        -- Note: DUT must correctly count both.
        ---------------------------------------------------------------------
        report ">>>>> SCENARIO 3: Part 1 <<<<<";
        
        -- Both cars arrive at their respective gates at the same time
        sensor_front_Gin1 <= '1';
        sensor_front_Gin2 <= '1';
        wait for 5 us;
        assert barrier_Gin1 = '1' report "Part 1: Barrier not opened for car entering from Gin1" severity error;
        assert barrier_Gin2 = '1' report "Part 1: Barrier not opened for car entering from Gin2" severity error;
        -- Both cars access the parking lot simultaneously
        sensor_back_Gin1 <= '1';
        sensor_back_Gin2 <= '1';
        wait for 1 us;
        sensor_front_Gin1 <= '0';
        sensor_front_Gin2 <= '0';
        wait for 1 us;
        sensor_back_Gin1 <= '0';
        sensor_back_Gin2 <= '0';

        wait for 23 us;

        ---------------------------------------------------------------------
        -- 2) A car tries to enter from Gin1 but stops at the back sensor, then reverses out.
        -- Note: The DUT must not increment the car count in this case.
        ---------------------------------------------------------------------
        report ">>>>> SCENARIO 3: Part 2 <<<<<";
        
        -- Car approaches Gin1
        sensor_front_Gin1 <= '1';
        wait for 5 us;
        assert barrier_Gin1 = '1' report "Part 2: Barrier at Gin1 should open for the approaching car" severity warning;
        -- Car moves forward, back sensor activates (car between sensors)
        sensor_back_Gin1 <= '1';
        wait for 10 us;
        assert barrier_Gin1 = '1' report "Part 2: Barrier at Gin1 should remain open while car between sensors" severity warning;
        -- Car decides to reverse
        sensor_back_Gin1 <= '0';
        wait for 1 us;
        sensor_front_Gin1 <= '0';
        wait for 5 us;
        assert barrier_Gin1 = '0' report "Part 2: Barrier at Gin1 should close after car reverses out" severity warning;
        assert 

        wait for 16 us;

        ---------------------------------------------------------------------
        -- 3) Two cars exit sequentially, each from different gate (Gout1 and Gout2).
        ---------------------------------------------------------------------
        report ">>>>> SCENARIO 3: Part 3 <<<<<";
        
        -- First car exits from Gout1
        sensor_front_Gout1 <= '1';
        wait for 5 us;
        -- Payment system simulation (driver pays at output)
        assert payment_request = '0' report "Part 3: Payment request should be high before payment" severity warning;
        payment_done <= '1';
        wait for 0.1 us;
        payment_done <= '0';
        wait for 5 us;
        assert barrier_Gout1 = '1' report "Part 3: Barrier not opened for car exiting from Gout1" severity error;
        assert payment_accepted = '1' report "Part 3: Payment not accepted for car exiting from Gout1" severity warning;
        -- The car exits the parking lot
        sensor_back_Gout1 <= '1';
        wait for 1 us;
        sensor_front_Gout1 <= '0';
        wait for 1 us;
        sensor_back_Gout1 <= '0';
        wait for 12 us;

        
        -- Second car exits from Gout2
        sensor_front_Gout2 <= '1';
        wait for 2 us;
        -- Payment system simulation
        assert payment_request = '0' report "Part 3: Payment request should be high before payment" severity warning;
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

        wait for 12 us;

        ---------------------------------------------------------------------
        -- 4) Five cars enter: 3 from Gin1 and 2 from Gin2.
        ---------------------------------------------------------------------
        report ">>>>> SCENARIO 3: Part 4 <<<<<";
        
        -- First 3 cars enter through Gate 1
        for i in 1 to 3 loop
            sensor_front_Gin1 <= '1';
            wait for 5 us;
            assert barrier_Gin1 = '1' report "Barrier not opened for car entering from Gin1" severity error;
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

        -- Next 2 cars enter through Gate 2
        for i in 1 to 2 loop
            sensor_front_Gin2 <= '1';
            wait for 5 us;
            assert barrier_Gin2 = '1' report "Barrier not opened for car entering from Gin2" severity error;
            sensor_back_Gin2 <= '1';
            wait for 1 us;
            sensor_front_Gin2 <= '0';
            wait for 1 us;
            sensor_back_Gin2 <= '0';
            -- Next car arrives after some time
            if i = 1 then
                wait for 7 us;
            else
                wait for 14 us;
            end if;
        end loop;

        ---------------------------------------------------------------------
        -- 5) Two cars enter sequentially from Gin2.
        ---------------------------------------------------------------------
        report ">>>>> SCENARIO 3: Part 5 <<<<<";
        
        for i in 1 to 2 loop
            sensor_front_Gin2 <= '1';
            wait for 5 us;
            assert barrier_Gin2 = '1' report "Barrier not opened for car entering from Gin2" severity error;
            sensor_back_Gin2 <= '1';
            wait for 1 us;
            sensor_front_Gin2 <= '0';
            wait for 1 us;
            sensor_back_Gin2 <= '0';
            if i = 1 then
                wait for 33 us;
            else
                wait for 12 us;
            end if;
        end loop;

        ---------------------------------------------------------------------
        -- Final checks
        ---------------------------------------------------------------------
        report ">>>>> SCENARIO 3: Final checks <<<<<";
        assert Green_Light = '0' report "Green light should be OFF (spots not available)" severity warning;
        assert Red_Light = '1' report "Red light should be ON (spots not available)" severity warning; 
        --assert unsigned(display) = 7 report "Display should show 7 cars inside" severity warning;
        assert barrier_Gin1 = '0' report "Barrier Gin1 should be closed" severity warning;
        assert barrier_Gin2 = '0' report "Barrier Gin2 should be closed" severity warning;
        assert barrier_Gout1 = '0' report "Barrier Gout1 should be closed" severity warning;
        assert barrier_Gout2 = '0' report "Barrier Gout2 should be closed" severity warning;
    
    end process;

end architecture;