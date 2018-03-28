-------------------------------------------------------------------------------
-- HES-SO Master
-- Haute Ecole Specialisee de Suisse Occidentale
-------------------------------------------------------------------------------
-- Cours VSN
--------------------------------------------------------------------------------
--
-- File		: transactions_pkg.vhd
-- Authors	: Jérémie Macchi
--			  Vivien Kaltenrieder
-- Date     : 28.03.2018
--
--------------------------------------------------------------------------------
-- Description : Définition des transactions d'entrée/sortie
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

---------------
--  Package  --
---------------
package transactions_pkg is

    type input_transaction_t is record
        a : std_logic_vector(7 downto 0);
        b : std_logic_vector(7 downto 0);
        c : std_logic_vector(7 downto 0);
    end record;


    type output_transaction_t is record
        r : std_logic_vector(7 downto 0);
    end record;

end package;
