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
	constant NB_SAMPLES : integer := 1000;

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

        -- open source file
        file_open(input_file_f, INPUT_FILE_NAME, read_mode);

        case testcase is
            when 0 =>
            for i in 0 to NB_SAMPLES-1 loop
                -- TODO : Prepare a transaction

				-- Lecture de données stockées dans un fichier texte
				-- -- Read line in file
				-- readline(input_file_f, input_line_v);
				--
				-- -- Extract value
				-- read(input_line_v, value_v);
            	-- transaction.sample := std_logic_vector(to_signed(value_v,16));

				-- Creation d'un spikes tout les 200 echantillons
				val_mod := (i mod 200);
				if val_mod /= 0 OR i < 200  then
					transaction.sample := std_logic_vector(to_signed(500,16));
				else
				--	transaction.sample := std_logic_vector(to_signed((2000-val_mod*30),16));
					transaction.sample := std_logic_vector(to_signed(1850,16));

				end if;

				--Ajout de bruit sur les echantillons
				-- val_mod := (i mod 250);
				-- if val_mod = 0 AND i >= 250  then
				-- 	transaction.sample := std_logic_vector(to_signed(700,16));
				-- elsif (i mod 2 = 0) then
				-- 	transaction.sample := std_logic_vector(to_signed(505,16));
				-- else
				-- 	transaction.sample := std_logic_vector(to_signed(495,16));
				-- end if;

                transaction.time_next := SAMPLING;
                blocking_put(fifo, transaction);
                wait for SAMPLING;
                --report "Sequencer : Sent transaction number " & integer'image(counter) severity note;
                counter := counter + 1;
            end loop;

            when 1 =>
            for i in 0 to 9 loop
                -- TODO : Prepare a transaction

                blocking_put(fifo, transaction);
                --report "Sequencer : Sent transaction number " & integer'image(counter) severity note;
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
            --report "Driver waiting for transaction number " & integer'image(counter) severity note;
            blocking_get(fifo, transaction);
            --report "Driver received transaction number " & integer'image(counter) severity note;
            wait until rising_edge(clk);
            -- TODO : Act on the DUV
            if (rst = '0') AND (port_output.ready = '1') then
              port_input.sample <= transaction.sample;
              port_input.sample_valid <= '1';
		  	end if;
            wait until rising_edge(clk);
            port_input.sample_valid <= '0';
            wait for transaction.time_next;
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
        variable ok : boolean;
    begin

        counter := 0;
        --for i in 0 to 100000-1 loop
            --report "Monitor waiting for transaction number " & integer'image(counter) severity note;
		while (not no_objection) loop
            ok := false;
            while (not ok) loop
                wait until rising_edge(clk);
                -- TODO : Retrieve data and create a transaction
                if (port_input.sample_valid = '1') AND (port_output.ready = '1') then
					transaction.sample := port_input.sample;
					transaction.time_next := SAMPLING;
                    blocking_put(fifo, transaction);
                    --report "Monitor received transaction number " & integer'image(counter) severity note;
					--report "Monitor send transaction number " & integer'image(counter) severity note;
                    counter := counter + 1;
                    ok := true;

                end if;
            end loop;
		end loop;
        --end loop;

        wait;

    end monitor;

end package body;
