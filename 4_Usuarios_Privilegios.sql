-- ==========================================
-- ARCHIVO 4: SEGURIDAD - USUARIOS Y PRIVILEGIOS
-- Requiere haber ejecutado antes:
--   1_Estructura_Base_Inserts.sql
--   2_Procedimientos_Almacenados.sql
--   3_Funciones.sql
-- (los GRANT sobre procedimientos y funciones necesitan que
--  ya existan)
-- ==========================================

USE ASOGASINGA;

DROP USER IF EXISTS 'usuario_admin'@'localhost';
CREATE USER 'usuario_admin'@'localhost' IDENTIFIED BY 'Admin_2026*';
GRANT ALL PRIVILEGES ON ASOGASINGA.* TO 'usuario_admin'@'localhost';

DROP USER IF EXISTS 'usuario_veterinario'@'localhost';
CREATE USER 'usuario_veterinario'@'localhost' IDENTIFIED BY 'Vet_2026*';
GRANT SELECT ON ASOGASINGA.ganado TO 'usuario_veterinario'@'localhost';
GRANT SELECT ON ASOGASINGA.fincas TO 'usuario_veterinario'@'localhost';
GRANT INSERT ON ASOGASINGA.vacunas TO 'usuario_veterinario'@'localhost';
GRANT INSERT ON ASOGASINGA.vacunacion TO 'usuario_veterinario'@'localhost';
GRANT EXECUTE ON PROCEDURE ASOGASINGA.sp_RegistrarVacunacion TO 'usuario_veterinario'@'localhost';

DROP USER IF EXISTS 'usuario_operador'@'localhost';
CREATE USER 'usuario_operador'@'localhost' IDENTIFIED BY 'Oper_2026*';
GRANT SELECT, INSERT, UPDATE ON ASOGASINGA.produccion_leche TO 'usuario_operador'@'localhost';
GRANT SELECT, INSERT, UPDATE ON ASOGASINGA.alimentacion TO 'usuario_operador'@'localhost';
GRANT SELECT, INSERT, UPDATE ON ASOGASINGA.ganado TO 'usuario_operador'@'localhost';
GRANT EXECUTE ON PROCEDURE ASOGASINGA.sp_RegistrarProduccionLeche TO 'usuario_operador'@'localhost';
GRANT EXECUTE ON FUNCTION ASOGASINGA.fn_CalcularEdadMeses TO 'usuario_operador'@'localhost';

DROP USER IF EXISTS 'usuario_rrhh'@'localhost';
CREATE USER 'usuario_rrhh'@'localhost' IDENTIFIED BY 'Rrhh_2026*';
GRANT SELECT, INSERT, UPDATE, DELETE ON ASOGASINGA.empleados TO 'usuario_rrhh'@'localhost';
GRANT EXECUTE ON PROCEDURE ASOGASINGA.sp_ActualizarSalarioEmpleado TO 'usuario_rrhh'@'localhost';

FLUSH PRIVILEGES;

-- ==========================================
-- VERIFICACIÓN
-- ==========================================
SELECT User FROM mysql.user WHERE User LIKE 'usuario_%';    -- deben salir los 4

-- ==========================================
-- PRUEBAS DE PERMISOS
-- Estas no se corren dentro de este script (aquí estás
-- conectado como root/admin). Ábrelas en una terminal nueva
-- conectándote con cada usuario y prueba:
-- ==========================================

-- mysql -u usuario_operador -p ASOGASINGA
-- SELECT * FROM empleados;
-- -> debe dar "SELECT command denied" (el operador no ve empleados)

-- mysql -u usuario_rrhh -p ASOGASINGA
-- SELECT * FROM ganado;
-- -> debe dar "SELECT command denied" (rrhh solo ve empleados)

-- mysql -u usuario_veterinario -p ASOGASINGA
-- DELETE FROM ganado WHERE ganado_id = 1;
-- -> debe dar "DELETE command denied" (veterinario solo tiene SELECT en ganado)
