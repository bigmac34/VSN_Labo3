-------------------------------------------------------------------------------
-- HES-SO Master
-- Haute Ecole Specialisee de Suisse Occidentale
-------------------------------------------------------------------------------
-- Cours VSN
--------------------------------------------------------------------------------
--
-- File		: agent0_pkg.vhd
-- Authors	: Jérémie Macchi
--			  Vivien Kaltenrieder
-- Date     : 28.03.2018
--
-- Context  :
--
--------------------------------------------------------------------------------
-- Description : 1. Séquenceur générant des transactions.
--				 2. Driver capable de jouer les transactions.
--				 3. Moniteur d'entrée permettant de récupérer les transactions
--				 jouées pour les envoyer au scoreboard.
--
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        	Person     			Comments
-- 1.0	 28.03.2018		Jérémie Macchi		Mise en place
-- 1.1	 06.04.2018		Vivien Kaltenrieder	Réalisation séquenceur et moniteur
-- 1.2	 14.04.2018		Jérémie Macchi		Finalisation du projet
--------------------------------------------------------------------------------
----------------
-- Librairies --
----------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

library tlmvm;
context tlmvm.tlmvm_context;

use work.input_transaction_fifo_pkg.all;
use work.input_transaction_fifo1_pkg.all;
use work.output_transaction_fifo_pkg.all;
use work.transactions_pkg.all;
use work.spike_detection_pkg.all;
use work.constant_pkg.all;

---------------
--  Package  --
---------------
package agent0_pkg is

	-- Sequencer
    procedure sequencer(variable fifo : inout work.input_transaction_fifo1_pkg.tlm_fifo_type;
                        constant testcase : in integer);

	-- Driver
    procedure driver(variable fifo : inout work.input_transaction_fifo1_pkg.tlm_fifo_type;
        signal clk : in std_logic;
        signal rst : in std_logic;
        signal port_input  : out port0_input_t;
        signal port_output : in port0_output_t
    );

	-- Monitor
    procedure monitor(variable fifo : inout work.input_transaction_fifo_pkg.tlm_fifo_type;
        signal clk : in std_logic;
        signal rst : in std_logic;
        signal port_input  : in port0_input_t;
        signal port_output : in port0_output_t
    );

end package;

--------------------
--  Package body  --
--------------------
package body agent0_pkg is

	constant SAMPLING : time := 33 us;

	-----------------
	--  Sequencer  --
	-----------------
    procedure sequencer(variable fifo : inout work.input_transaction_fifo1_pkg.tlm_fifo_type;
                        constant testcase : in integer) is
        variable transaction : input_transaction_t;
        variable counter     : integer;

		variable input_line_v : line;
		variable value_v      : integer;
		file input_file_f     : text;

		variable val_mod	  : integer;

		constant INPUT_FILE_NAME : string  := "../src_tb/input_values.txt";

    begin

        raise_objection;

        counter := 0;

        case testcase is
			-- Test avec les données stockées dans un fichier --
            when 0 =>
				-- open source file
				file_open(input_file_f, INPUT_FILE_NAME, read_mode);

				transaction.time_next := SAMPLING;

	            for i in 0 to NB_SAMPLES-1 loop

					beat;

					-- Read line in file
					readline(input_file_f, input_line_v);

					-- Extract value
					read(input_line_v, value_v);
	            	transaction.sample := std_logic_vector(to_signed(value_v,16));

	                blocking_put(fifo, transaction);
	                --report "Sequencer : Sent transaction number " & integer'image(counter) severity note;
	                wait for SAMPLING;
	                counter := counter + 1;
	            end loop;

			-- Test avec des spikes tout les 200 echantillons --
            when 1 =>

				transaction.time_next := SAMPLING;

	            for i in 0 to NB_SAMPLES-1 loop

					beat;

					-- Valeur de base
					val_mod := (i mod 200);
					if val_mod /= 0 OR i < 200  then
						transaction.sample := std_logic_vector(to_signed(500,16));
					-- Spikes negatifs
					elsif (i mod 400) = 0 then
						transaction.sample := std_logic_vector(to_signed(-850,16));
					-- Spikes positifs
					else
						transaction.sample := std_logic_vector(to_signed(1850,16));
					end if;

					--report " Sequencer : Sent transaction number " & integer'image(counter) severity note;
	                blocking_put(fifo, transaction);
	                wait for SAMPLING;
	                counter := counter + 1;
	            end loop;

            when others =>
                --report "Sequencer : Unsupported testcase" severity error;

        end case;

        drop_objection;
        --report "Sequencer finished his job" severity note;
        wait;
    end sequencer;


	--------------
	--  Driver  --
	--------------
    procedure driver(variable fifo : inout work.input_transaction_fifo1_pkg.tlm_fifo_type;
        signal clk : in std_logic;
        signal rst : in std_logic;
        signal port_input  : out port0_input_t;
        signal port_output : in port0_output_t
    ) is
        variable transaction : input_transaction_t;
        variable counter : integer;
    begin

        raise_objection;

        counter := 0;

        for i in 0 to NB_SAMPLES-1 loop
			-- Toujours en vie
			beat;

            --report " --------------------------Driver waiting for transaction number " & integer'image(counter) severity note;
            blocking_get(fifo, transaction);
            --report " --------------------------Driver received transaction number " & integer'image(counter) severity note;
            wait until rising_edge(clk);
            -- TODO : Act on the DUV
			if  (port_output.ready = '1') then
              	port_input.sample <= transaction.sample;
              	port_input.sample_valid <= '1';
            	wait until rising_edge(clk);
            	port_input.sample_valid <= '0';
			end if;
			counter := counter + 1;

        end loop;

        drop_objection;

        wait;

    end driver;

	---------------
	--  Monitor  --
	---------------
    procedure monitor(variable fifo : inout work.input_transaction_fifo_pkg.tlm_fifo_type;
        signal clk : in std_logic;
        signal rst : in std_logic;
        signal port_input  : in port0_input_t;
        signal port_output : in port0_output_t
    ) is
        variable transaction : input_transaction_t;
        variable counter : integer;
    begin

        counter := 0;

		while (not no_objection) loop
            wait until rising_edge(clk);
            -- TODO : Retrieve data and create a transaction
            if (port_input.sample_valid = '1') AND (port_output.ready = '1') AND (rst = '0' ) then
				transaction.sample := port_input.sample;
				transaction.time_next := SAMPLING;
				--report " Monitor0 send transaction number " & integer'image(counter) severity note;
                blocking_put(fifo, transaction);
                counter := counter + 1;

            end if;
		end loop;

        wait;

    end monitor;

end package body;
