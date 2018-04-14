-------------------------------------------------------------------------------
-- HES-SO Master
-- Haute Ecole Specialisee de Suisse Occidentale
-------------------------------------------------------------------------------
-- Cours VSN
--------------------------------------------------------------------------------
--
-- File		: constant_pkg.vhd
-- Authors	: Jérémie Macchi
--			  Vivien Kaltenrieder
-- Date     : 28.03.2018
--
--------------------------------------------------------------------------------
-- Description : Constants pour le projet
--
--------------------------------------------------------------------------------
-- Modifications :
-- Ver   Date        	Person     			Comments
-- 1.0	 13.04.2018		Vivien Kaltenrieder	Mise en place
-- 1.1	 14.04.2018		Jérémie Macchi		Finalisation du projet
--------------------------------------------------------------------------------
----------------
-- Librairies --
----------------
library ieee;
use ieee.std_logic_1164.all;

---------------
--  Package  --
---------------
package constant_pkg is

    constant SAMPLE_SIZE 	: integer := 16;
    constant TIME_TO_NEXT	: time 	  := 50 ns;
    constant WINDOW_SIZE 	: integer := 150;
    constant NB_SAMPLES 	: integer := 1000;	--10000  si on veut tout les echantillons de input_value.txt
	constant N_AVERAGE      : integer := 128;
	constant POSITION		: integer := 50;
	constant BUFFER_SIZE	: integer := (WINDOW_SIZE + POSITION - 1);
	constant FICHIER_LOG	: string := "labo3_log";

	constant CLK_PERIOD 	: time := 10 ns;

end package;
