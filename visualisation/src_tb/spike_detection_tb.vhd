-------------------------------------------------------------------------------
-- Title      : Testbench for design "spike_detection"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : spike_detection_tb.vhd
-- Author     : mike  <mike@a13pc02>
-- Company    : 
-- Created    : 2018-03-21
-- Last update: 2018-03-21
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2018 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2018-03-21  1.0      mike    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

-------------------------------------------------------------------------------

entity spike_detection_tb is
    generic (
        ERRNO           : integer range 0 to 15 := 0;
        INPUT_FILE_NAME : string                := "../src_tb/input_values.txt"
        );
end entity spike_detection_tb;

-------------------------------------------------------------------------------

architecture test_bench of spike_detection_tb is

    ---------------
    -- Constants --
    ---------------
    constant CLOCK_PERIOD        : time    := 10 ns;  -- 100MHz
    constant SAMPLING_PERIOD     : time    := 33 us;  -- ~30kHz   
    constant SPIKES_EXPECTED     : integer := 4;
    constant MAX_SIMULATION_TIME : time    := 500 ms;

    -- component ports
    signal clk_sti                  : std_logic;
    signal rst_sti                  : std_logic;
    signal sample_sti               : std_logic_vector(15 downto 0);
    signal sample_valid_sti         : std_logic;
    signal ready_obs                : std_logic;
    signal samples_spikes_obs       : std_logic_vector(15 downto 0);
    signal samples_spikes_valid_obs : std_logic;
    signal spike_detected_obs       : std_logic;

    -- end of simulation flag
    signal end_sim : boolean := false;

    -- counter for spikes detected
    signal spike_counter_s : unsigned(7 downto 0);

    -- for end of simulation conditions
    signal capture_done_s : std_logic := '0';
    signal err_timeout_s  : std_logic := '0';

begin  -- architecture test_bench

    -- component instantiation
    DUT : entity work.spike_detection
        generic map (
            ERRNO => ERRNO)
        port map (
            clk_i                  => clk_sti,
            rst_i                  => rst_sti,
            sample_i               => sample_sti,
            sample_valid_i         => sample_valid_sti,
            ready_o                => ready_obs,
            samples_spikes_o       => samples_spikes_obs,
            samples_spikes_valid_o => samples_spikes_valid_obs,
            spike_detected_o       => spike_detected_obs
            );

    ----------------------
    -- Clock generation --
    ----------------------
    clk_gen : process
    begin
        clk_sti <= '1';
        wait for CLOCK_PERIOD/2;
        clk_sti <= '0';
        wait for CLOCK_PERIOD/2;
        if end_sim = true then
            wait;
        end if;
    end process;

    --------------------
    -- Reset sequence --
    --------------------
    rst_gen : process
    begin
        rst_sti <= '1';
        wait for 10*CLOCK_PERIOD;
        wait until rising_edge(clk_sti);
        rst_sti <= '0';
        wait;
    end process;

    ------------------------------
    -- Analog signal generation --
    ------------------------------
    sample_gen : process
        variable input_line_v : line;
        variable value_v      : integer;
        file input_file_f     : text;
    begin

        -- set default values
        sample_sti       <= (others => '0');
        sample_valid_sti <= '0';

        -- open source file
        file_open(input_file_f, INPUT_FILE_NAME, read_mode);

        -- we read file until we reach the end
        while (not endfile(input_file_f)) and end_sim = false loop

            -- Read line in file
            readline(input_file_f, input_line_v);

            -- Extract value
            read(input_line_v, value_v);

            -- put value as sample (synchronized with clk)            
            wait until rising_edge(clk_sti);
            sample_sti       <= std_logic_vector(to_signed(value_v, sample_sti'length));
            sample_valid_sti <= '1';
            wait until rising_edge(clk_sti);
            sample_valid_sti <= '0';
            -- wait to generate 30KHz signal
            wait for SAMPLING_PERIOD;

        end loop;

        -- close file
        file_close(input_file_f);

        -- we block here
        wait;
    end process;

    -------------------
    -- Spike counter --
    -------------------
    spike_cpt : process
    begin
        -- reset and wait end of reset sequence
        spike_counter_s <= (others => '0');
        capture_done_s  <= '0';
        wait until falling_edge(rst_sti);
        while ((spike_counter_s < SPIKES_EXPECTED-1) and end_sim = false) loop
            wait until rising_edge(spike_detected_obs);
            spike_counter_s <= spike_counter_s + 1;
        end loop;
        -- capture done
        capture_done_s <= '1';
        wait;
    end process;

    --------------------------
    -- Timeout verification --
    --------------------------
    timeout_proc : process
    begin
        err_timeout_s <= '0';
        wait for MAX_SIMULATION_TIME;
        if end_sim = false then
            -- we timeout
            err_timeout_s <= '1';
            report "\n\n--- TIMEOUT ---\n\n" severity error;
        end if;
        wait;
    end process;

    ------------------------
    -- End of simulation  --
    ------------------------
    end_sim_proc : process
    begin
        end_sim <= false;
        wait until (capture_done_s = '1' or err_timeout_s = '1');
        end_sim <= true;
        wait;
    end process;

end architecture test_bench;

-------------------------------------------------------------------------------

configuration spike_detection_tb_test_bench_cfg of spike_detection_tb is
    for test_bench
    end for;
end spike_detection_tb_test_bench_cfg;

-------------------------------------------------------------------------------
