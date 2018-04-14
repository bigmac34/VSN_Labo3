--------------------------------------------------------------------------------
-- HEIG-VD
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
--------------------------------------------------------------------------------
-- REDS Institute
-- Reconfigurable Embedded Digital Systems
--------------------------------------------------------------------------------
--
-- File     : spike_detection_tb.vhd
-- Author   : TbGenerator
-- Date     : 16.03.2018
--
-- Context  :
--
--------------------------------------------------------------------------------
-- Description : This module is a simple VHDL testbench.
--               It instanciates the DUV and proposes a TESTCASE generic to
--               select which test to start.
--
--------------------------------------------------------------------------------
-- Dependencies : -
--
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        Person    	 	Comments
-- 0.1   16.03.2018  TbGen      	Initial version
-- 1.1	 14.04.2018	 Jérémie Macchi	Finalisation du projet
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library tlmvm;
context tlmvm.tlmvm_context;

use work.spike_detection_pkg.all;

use work.input_transaction_fifo_pkg.all;
use work.input_transaction_fifo1_pkg.all;
use work.output_transaction_fifo_pkg.all;
use work.agent0_pkg.all;
use work.scoreboard_pkg.all;
use work.constant_pkg.all;

library project_lib;
context project_lib.project_ctx;

entity spike_detection_tb is
    generic (
        TESTCASE : integer := 1;
        ERRNO    : integer := 0
    );

end spike_detection_tb;

architecture testbench of spike_detection_tb is

    signal clk_sti          : std_logic;
    signal rst_sti          : std_logic;
    signal port0_input_sti  : port0_input_t;
    signal port0_output_obs : port0_output_t;
    signal port1_output_obs : port1_output_t;

    component spike_detection is
        port (
            -- standard inputs
            clk_i                  : in  std_logic;
            rst_i                  : in  std_logic;
            -- Samples
            sample_i               : in  std_logic_vector(SAMPLE_SIZE-1 downto 0);
            sample_valid_i         : in  std_logic;
            ready_o                : out std_logic;
            -- Ouputs
            samples_spikes_o       : out std_logic_vector(SAMPLE_SIZE-1 downto 0);
            samples_spikes_valid_o : out std_logic;
            spike_detected_o       : out std_logic
            );
    end component;

    shared variable fifo_seq0_to_driver0 : work.input_transaction_fifo1_pkg.tlm_fifo_type;
    shared variable fifo_mon0_to_score : work.input_transaction_fifo_pkg.tlm_fifo_type;

    shared variable fifo_mon1_to_score : work.output_transaction_fifo_pkg.tlm_fifo_type;


  	procedure rep(finish_status: finish_status_t) is
  	begin
		logger.final_report;	-- Log final
		report "Simulation finished, see logger at /comp/" & FICHIER_LOG  & "_ERRNO_" &  integer'image(ERRNO) & ".txt";
  	end rep;

	-----------------------------
	-- Initialisation du logger -
	-----------------------------
	procedure start is
  	begin
	   logger.log_fichier_init(FICHIER_LOG & "_ERRNO_" & integer'image(ERRNO) & ".txt");
	   logger.set_verbosity(note);
	   logger.log_note("--------  ERRNO: " & integer'image(ERRNO) & " & " & "TESTCASE: " & integer'image(TESTCASE) & "  --------");
	   wait;
  	end start;

begin

	monitor: simulation_monitor
	generic map (drain_time => 150 ns,
                 beat_time => 1 ms,
                 final_reporting => rep,
				 should_finish => true); -- si on veut quitter après la simulation

	start_proc : start;

	clk_proc : clock_generator(clk_sti, CLK_PERIOD);

	rst_proc : simple_startup_reset(rst_sti, 2*CLK_PERIOD);

    agent0_sequencer : work.agent0_pkg.sequencer(fifo_seq0_to_driver0, TESTCASE);

    agent0_driver : work.agent0_pkg.driver(fifo_seq0_to_driver0,
                                           clk_sti,
                                           rst_sti,
                                           port0_input_sti,
                                           port0_output_obs );

    agent0_monitor : work.agent0_pkg.monitor(fifo_mon0_to_score,
                                             clk_sti,
                                             rst_sti,
                                             port0_input_sti,
                                             port0_output_obs );


    agent1_monitor : work.agent1_pkg.monitor(fifo_mon1_to_score,
                                             clk_sti,
                                             rst_sti,
                                             port1_output_obs );

    scoreboard : work.scoreboard_pkg.scoreboard(fifo_mon0_to_score,
                                                fifo_mon1_to_score);

    duv : spike_detection
        generic map (
            ERRNO => ERRNO
        )
        port map (
            clk_i                  => clk_sti,
            rst_i                  => rst_sti,

            sample_i               => port0_input_sti.sample,
            sample_valid_i         => port0_input_sti.sample_valid,
            ready_o                => port0_output_obs.ready,

            samples_spikes_o       => port1_output_obs.samples_spikes,
            samples_spikes_valid_o => port1_output_obs.samples_spikes_valid,
            spike_detected_o       => port1_output_obs.spike_detected
        );
end testbench;
