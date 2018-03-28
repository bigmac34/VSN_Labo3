-------------------------------------------------------------------------------
-- HES-SO Master
-- Haute Ecole Specialisee de Suisse Occidentale
-------------------------------------------------------------------------------
-- Cours VSN
--------------------------------------------------------------------------------
--
-- File		: transactions_fifo.vhd
-- Authors	: Jérémie Macchi
--			  Vivien Kaltenrieder
-- Date     : 28.03.2018
--
--------------------------------------------------------------------------------
-- Description : Transaction FIFO
--
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        	Person     		Comments
-- 1.0	 28.03.2018		Jérémie Macchi	Mise en place
--------------------------------------------------------------------------------

use work.transactions_pkg.all;

library tlmvm;
use tlmvm.tlm_unbounded_fifo_pkg;

-- Create a specialized package that will offer unbounded FIFOs with the
-- specific user type of data in it
package input_transaction_fifo_pkg is new tlm_unbounded_fifo_pkg
    generic map (element_type => input_transaction_t);


use work.transactions_pkg.all;

library tlmvm;
use tlmvm.tlm_unbounded_fifo_pkg;

-- Create a specialized package that will offer unbounded FIFOs with the
-- specific user type of data in it
package input_transaction_fifo1_pkg is new tlm_unbounded_fifo_pkg
    generic map (element_type => input_transaction_t,
                 nb_max_data => 1);


use work.transactions_pkg.all;

library tlmvm;
use tlmvm.tlm_unbounded_fifo_pkg;

package output_transaction_fifo_pkg is new tlm_unbounded_fifo_pkg
    generic map (element_type => output_transaction_t);
