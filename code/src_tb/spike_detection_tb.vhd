-------------------------------------------------------------------------------
-- HES-SO Master
-- Haute Ecole Specialisee de Suisse Occidentale
-------------------------------------------------------------------------------
-- Cours VSN
--------------------------------------------------------------------------------
--
-- File		: spike_detected_tb.vhd
-- Authors	: Jérémie Macchi
--			  Vivien Kaltenrieder
-- Date     : 28.03.2018
--
-- Context  :
--
--------------------------------------------------------------------------------
-- Description : Testbench pour le labo 3 de VSN spikeonchip
--
--------------------------------------------------------------------------------
-- Dependencies : agent0_pkg.vhd
--			      agent1_pkg.vhd
--				  scoreboard_pkg.vhd
--				  transaction_fifo_pkg.vhd
--				  transaction_pkg.vhd
--
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        	Person     		Comments
-- 1.0	 28.03.2018		Jérémie Macchi	Mise en place
--------------------------------------------------------------------------------
------------------
--  Librairies  --
------------------
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

-------------------------------
--  Déclaration de l'entité  --
-------------------------------
entity spike_detection_tb is
    generic (
        TESTCASE : integer := 0
    );

end spike_detection_tb;

--------------------
--	Architecture  --
--------------------
architecture testbench of spike_detection_tb is

	------------------
	--  Constantes  --
	------------------
    constant CLK_PERIOD : time := 10 ns;

	---------------
	--  Signaux  --
	---------------
    signal clk_sti          : std_logic;
    signal rst_sti          : std_logic;
    signal port0_input_sti  : port0_input_t;
    signal port0_output_obs : port0_output_t;
    signal port1_output_obs : port1_output_t;

	-----------------
	--  Composant  --
	-----------------
    component spike_detection is
        port (
            -- standard inputs
            clk_i                  : in  std_logic;
            rst_i                  : in  std_logic;
            -- Samples
            sample_i               : in  std_logic_vector(15 downto 0);
            sample_valid_i         : in  std_logic;
            ready_o                : out std_logic;
            -- Ouputs
            samples_spikes_o       : out std_logic_vector(15 downto 0);
            samples_spikes_valid_o : out std_logic;
            spike_detected_o       : out std_logic
            );
    end component;

	------------------------
	--  shared variables  --
	------------------------
    shared variable fifo_seq0_to_driver0 : work.input_transaction_fifo1_pkg.tlm_fifo_type;
    shared variable fifo_mon0_to_score : work.input_transaction_fifo_pkg.tlm_fifo_type;

    shared variable fifo_mon1_to_score : work.output_transaction_fifo_pkg.tlm_fifo_type;


	-----------
	--  Rep  --
	-----------
  	procedure rep(finish_status: finish_status_t) is
  	begin
  		report "I finished, yippee";
  	end rep;

-------------
--  Begin  --
-------------
begin

	-----------------------------------
	--  Monitor: simulation_monitor  --
	-----------------------------------
	monitor: simulation_monitor
	generic map (drain_time => 150 ns,			-- Temps pour arret automatique
                 beat_time => 500 ms,			-- Temps pour arret automatique
                 final_reporting => rep);

  ---- Les éléments de vérification sont lancés sous forme de procédures ----
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

  ----- Instanciation du composant à tester -------
	----------------------------
	--  DUV: spike_detection  --
	----------------------------
    duv : spike_detection
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
