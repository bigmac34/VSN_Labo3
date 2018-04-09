--------------------------------------------------------------------------------
-- HES-SO Master
-- Haute Ecole Specialisee de Suisse Occidentale
--------------------------------------------------------------------------------
-- Cours VSN
--------------------------------------------------------------------------------
--
-- File		: scoreboard_pkg.vhd
-- Authors	: Jérémie Macchi
--			  Vivien Kaltenrieder
-- Date     : 28.03.2018
--
--------------------------------------------------------------------------------
-- Description : Scoreboard pour la vérification des transactions de sortie
--
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        	Person     		Comments
-- 1.0	 28.03.2018		Jérémie Macchi	Mise en place
--------------------------------------------------------------------------------
----------------
-- Librairies --
----------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library tlmvm;
context tlmvm.tlmvm_context;

use work.input_transaction_fifo_pkg.all;
use work.output_transaction_fifo_pkg.all;
use work.transactions_pkg.all;
use work.spike_detection_pkg.all;

---------------
--  Package  --
---------------
package scoreboard_pkg is

	-- Scoreboard
	procedure scoreboard(variable fifo_input  : inout work.input_transaction_fifo_pkg.tlm_fifo_type;
	variable fifo_output : inout work.output_transaction_fifo_pkg.tlm_fifo_type
	);

	type window_comp is array (199-1 downto 0) of std_logic_vector(16-1 downto 0);

end package;

--------------------
--  Package body  --
--------------------
package body scoreboard_pkg is

	constant NB_SAMPLES : integer := 10000;

	------------------
	--  Scoreboard  --
	------------------
	procedure scoreboard(variable fifo_input  : inout work.input_transaction_fifo_pkg.tlm_fifo_type;
						 variable fifo_output : inout work.output_transaction_fifo_pkg.tlm_fifo_type
	) is
		constant SIZE             : integer := 16;
		constant LOG2_WINDOW_SIZE : integer := 7;
		constant DIV_128					: integer := 7;

		variable trans_input  : input_transaction_t;
		variable trans_output : output_transaction_t;
		variable counter      : integer := 0;

		variable expected     : std_logic_vector(7 downto 0);
		variable ok			      : boolean;

		-- For the spike detection
		variable window_compare   : window_comp;
		variable index_put        : integer;
		variable end_window_150   : integer;

		--    variable spike_detected   : boolean;
		variable spike_expected   : boolean;
		variable same_window      : boolean;

		constant WINDOW_SIZE  : integer := 150;
		constant POSITION     : integer := 50;
		constant N_AFTER      : integer := (WINDOW_SIZE - POSITION);
		constant AVERAGE      : integer := 128;

		constant FACTOR_DETECTION : signed(15 downto 0) := to_signed(15, 16);

		-- Moyenne glissante
		variable moving_average 								: signed(SIZE-1 downto 0);
		variable sample_squared 								: signed(SIZE*2-1 downto 0);
		variable sum_squared    								: signed(SIZE*2+LOG2_WINDOW_SIZE-1 downto 0);
		variable moving_average_squared  						: signed(SIZE*2-1 downto 0);
		variable standard_deviation_squared						: signed(SIZE*2-1 downto 0);
		variable product_std_dev_factor_squared 				: signed(standard_deviation_squared'length + FACTOR_DETECTION'length - 1 downto 0);
		variable deviation           							: signed(SIZE downto 0);  -- one extra bit
		variable dev_squared         							: signed(deviation'length*2-1 downto 0);


		begin

			raise_objection;

			index_put := 0;
			spike_expected := false;
			same_window    := true;
			moving_average := (others => '0');
			sum_squared    := (others => '0');
			sample_squared  := (others => '0');

			for i in 0 to NB_SAMPLES-1 loop
				-- Recieve the transactions
				blocking_get(fifo_input, trans_input);
				-- ok à true s'il y avait un truc dans la fifo
				blocking_timeout_get(fifo_output, trans_output, trans_input.time_next/10, ok);

				--------------------------- detection ----------------------
				spike_expected := false;
				same_window		:= true;
				window_compare(index_put) := trans_input.sample;

				--- Squared deviation
				sample_squared     				:= signed(trans_input.sample) * signed(trans_input.sample);

				-- On en calcul pas avant d'avoir 128 échantillons
				if i >= AVERAGE-1 then
					-- --- Moyenne glissante
					 moving_average 					:= moving_average + signed(trans_input.sample(SIZE-1 downto DIV_128)) - moving_average(SIZE-1 downto DIV_128);
					--
					-- --- Squared deviation
					-- sample_squared     				:= signed(trans_input.sample) * signed(trans_input.sample);
					 sum_squared  					:= sample_squared - sum_squared(SIZE*2+LOG2_WINDOW_SIZE-1 downto DIV_128) + sum_squared;
					-- moving_average_squared  		:= moving_average * moving_average;
					-- standard_deviation_squared 		:= sum_squared(SIZE*2+LOG2_WINDOW_SIZE-1 downto DIV_128) - moving_average_squared;
					--
					-- --- Calcul for the comparaison
					-- product_std_dev_factor_squared 	:= standard_deviation_squared * FACTOR_DETECTION;
					-- deviation                      	:= resize(signed(trans_input.sample), deviation'length) - resize(moving_average, deviation'length);
					-- dev_squared                    	:= deviation * deviation;
				else
					sum_squared  					:= sample_squared + sum_squared;
					moving_average 					:= moving_average + signed(trans_input.sample(SIZE-1 downto DIV_128));

				end if;

				--- Moyenne glissante
				--moving_average 					:= moving_average + signed(trans_input.sample(SIZE-1 downto DIV_128)) - moving_average(SIZE-1 downto DIV_128);

			--sum_squared  					:= sample_squared - sum_squared(SIZE*2+LOG2_WINDOW_SIZE-1 downto DIV_128) + sum_squared;
				moving_average_squared  		:= moving_average * moving_average;
				standard_deviation_squared 		:= sum_squared(SIZE*2+LOG2_WINDOW_SIZE-1 downto DIV_128) - moving_average_squared;

				--- Calcul for the comparaison
				product_std_dev_factor_squared 	:= standard_deviation_squared * FACTOR_DETECTION;
				deviation                      	:= resize(signed(trans_input.sample), deviation'length) - resize(moving_average, deviation'length);
				dev_squared                    	:= deviation * deviation;



				if dev_squared > product_std_dev_factor_squared then
					end_window_150 := (index_put + WINDOW_SIZE - 1) mod 199;
					--report "###### Scoreboard comparaison for spike " &  integer'image(to_integer(dev_squared)) & " > " & integer'image(to_integer(product_std_dev_factor_squared)) & "             SCOREBOARD at time " & time'image(now);
				end if;

				if index_put = end_window_150 then
					spike_expected := true;
				end if;

				----------------- Check case ------------------------------------------
				if ok and spike_expected then
					report "On a recu un spike au bon moment              --------- In scoreboard" severity note;
					for j in index_put to index_put + WINDOW_SIZE - 1 loop
						--report "J:" & integer'image(j) & "    " & integer'image(to_integer(unsigned(window_compare((j+201) mod 200)))) & "/=" & integer'image(to_integer(unsigned(trans_output.samples_window(j-index_put))));
						if window_compare((j+200) mod 199) /= trans_output.samples_window(j-index_put) then
							same_window := false;
							report "----------------------- Faux a: J=" & integer'image(j-index_put) & "    " & integer'image(to_integer(unsigned(window_compare((j+200) mod 199)))) & "/=" & integer'image(to_integer(unsigned(trans_output.samples_window(j-index_put))));
						end if;
					end loop;
					if not same_window then
						report "La fenetre ne possede pas les bons echantillions --- In scoreboard" severity error;
					end if;
				elsif ok and not spike_expected then
					report "On a recu un spike alors qu'il n'y en a pas   --------- In scoreboard ---------" severity error;
				elsif not ok and spike_expected then
					report "On devait avoir un spike mais il n'y en a pas eu------- In scoreboard ---------" severity error;
				else
					--do nothing : pas de spike attendu, pas de spike reçu
				end if;

				----------
				counter := counter + 1;
				index_put := index_put + 1;

				if index_put > (199 - 1) then
					index_put := 0;
				end if;

			end loop;

			drop_objection;

			wait;

		end scoreboard;

	end package body;
