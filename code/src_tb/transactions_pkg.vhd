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

    constant SAMPLE_SIZE : integer := 16;
    constant TIME_TO_NEXT: time := 50 ns;
    constant WINDOW_SIZE : integer := 150;

    type input_transaction_t is record
      sample    : std_logic_vector(SAMPLE_SIZE-1 downto 0);
      time_next : time;
--        a : std_logic_vector(7 downto 0);
--        b : std_logic_vector(7 downto 0);
--        c : std_logic_vector(7 downto 0);
    end record;

    type window is array (WINDOW_SIZE-1 downto 0) of std_logic_vector(SAMPLE_SIZE-1 downto 0);

    type output_transaction_t is record
      samples_window : window;
--        r : std_logic_vector(7 downto 0);
    end record;

end package;
