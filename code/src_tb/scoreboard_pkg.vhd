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

end package;

--------------------
--  Package body  --
--------------------
package body scoreboard_pkg is

	------------------
	--  Scoreboard  --
	------------------
    procedure scoreboard(variable fifo_input  : inout work.input_transaction_fifo_pkg.tlm_fifo_type;
                         variable fifo_output : inout work.output_transaction_fifo_pkg.tlm_fifo_type
    ) is
        variable trans_input  : input_transaction_t;
        variable trans_output : output_transaction_t;
        variable counter0     : integer;
		variable counter1     : integer;
		variable spike     	  : integer;

        variable expected     : std_logic_vector(7 downto 0);
		variable ok			  : boolean;

    begin

        raise_objection;

		spike := 0;
        counter0 := 0;
		counter1:= 0;

        for i in 0 to 50000-1 loop
            --report "Scoreboard waiting for transaction number " & integer'image(counter0) severity note;
			blocking_get(fifo_input, trans_input);

			blocking_timeout_get(fifo_output, trans_output, trans_input.time_next/10, ok);
			if ok then
				report "On a recu un spike";
				spike := spike + 1;
			end if;



            --report "Scoreboard received transaction number " & integer'image(counter0) severity note;

            counter0 := counter0 + 1;
			counter1 := counter1 + 1;

        end loop;

        drop_objection;

		wait;

    end scoreboard;

end package body;
