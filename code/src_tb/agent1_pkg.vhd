-------------------------------------------------------------------------------
-- HES-SO Master
-- Haute Ecole Specialisee de Suisse Occidentale
-------------------------------------------------------------------------------
-- Cours VSN
--------------------------------------------------------------------------------
--
-- File		: agent1_pkg.vhd
-- Authors	: Jérémie Macchi
--			  Vivien Kaltenrieder
-- Date     : 28.03.2018
--
--------------------------------------------------------------------------------
-- Description : Moniteure de sorti permettant de récupérer les transactions de
--				 sortie pour les envoyer au scoreboard
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

use work.output_transaction_fifo_pkg.all;
use work.transactions_pkg.all;
use work.spike_detection_pkg.all;

---------------
--  Package  --
---------------
package agent1_pkg is

	-- Monitor
    procedure monitor(variable fifo : inout work.output_transaction_fifo_pkg.tlm_fifo_type;
        signal clk : in std_logic;
        signal rst : in std_logic;
        signal port_output : in port1_output_t
    );

end package;

--------------------
--  Package body  --
--------------------
package body agent1_pkg is

	---------------
	--  Monitor  --
	---------------
    procedure monitor(variable fifo : inout work.output_transaction_fifo_pkg.tlm_fifo_type;
        signal clk : in std_logic;
        signal rst : in std_logic;
        signal port_output : in port1_output_t
    ) is
        variable transaction : output_transaction_t;
        variable counter : integer;
        variable index   : integer;
        variable ok : boolean;

        variable sample_window : window;

    begin

--      samples_spikes_o       => port1_output_obs.samples_spikes,
--      samples_spikes_valid_o => port1_output_obs.samples_spikes_valid,
--      spike_detected_o       => port1_output_obs.spike_detected

        counter := 0;
        while (not no_objection) loop
            ok := false;
            index := 0;
            while (not ok) loop
                wait until rising_edge(clk);
				--wait until rising_edge(port_output.samples_spikes_valid);

                if (port_output.samples_spikes_valid = '1') then
                    transaction.samples_window(index) := port_output.samples_spikes;

					report "------------- : Put index number " & integer'image(index) severity note;
					index := index + 1;
                end if;
                if (port_output.spike_detected = '1') then
					--transaction.samples_window(0) := port_output.samples_spikes;
					--report "-------------Monitor1 : Sent transaction number " & integer'image(0) severity note;

                    ok := true;
                end if;
            end loop;
			--report "-------------Monitor1 : Sent transaction number " & integer'image(index) severity note;
            blocking_put(fifo, transaction);
            counter := counter + 1;
        end loop;

        wait;

    end monitor;

end package body;
