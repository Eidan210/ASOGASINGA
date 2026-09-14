-- ==========================================
-- ARCHIVO 3: FUNCIONES (UDF)
-- Requiere haber ejecutado antes:
--   1_Estructura_Base_Inserts.sql
--   2_Procedimientos_Almacenados.sql
-- ==========================================

USE ASOGASINGA;

DELIMITER //

CREATE FUNCTION fn_CalcularEdadMeses(p_ganado_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_fecha DATE;
    SELECT fecha_nacimiento INTO v_fecha
    FROM ganado WHERE ganado_id = p_ganado_id;

    RETURN TIMESTAMPDIFF(MONTH, v_fecha, CURDATE());
END //

CREATE FUNCTION fn_TotalLitrosFinca(p_finca_id INT, p_fecha_inicio DATE, p_fecha_fin DATE)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(12,2);

    SELECT IFNULL(SUM(pl.litros), 0) INTO v_total
    FROM produccion_leche pl
    INNER JOIN ganado g ON pl.ganado_id = g.ganado_id
    WHERE g.finca_id = p_finca_id
      AND pl.fecha BETWEEN p_fecha_inicio AND p_fecha_fin;

    RETURN v_total;
END //

CREATE FUNCTION fn_PromedioPesoPorRaza(p_raza VARCHAR(50))
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_promedio DECIMAL(10,2);

    SELECT IFNULL(AVG(peso), 0) INTO v_promedio
    FROM ganado
    WHERE raza = p_raza;

    RETURN v_promedio;
END //

CREATE FUNCTION fn_ContarGanadoPorSocio(p_socio_id INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total INT;

    SELECT COUNT(*) INTO v_total
    FROM ganado g
    INNER JOIN fincas f ON g.finca_id = f.finca_id
    WHERE f.socio_id = p_socio_id;

    RETURN v_total;
END //

DELIMITER ;

-- ==========================================
-- PRUEBAS
-- ==========================================

SELECT fn_CalcularEdadMeses(1) AS edad_meses_lola;                          -- meses desde 2023-01-10
SELECT fn_TotalLitrosFinca(1, '2026-01-01', '2026-12-31') AS litros_finca_1; -- 58.20
SELECT fn_PromedioPesoPorRaza('Holstein') AS peso_promedio_holstein;        -- 450.00
SELECT fn_ContarGanadoPorSocio(1) AS animales_socio_1;                      -- 1

-- Caso de raza sin registros (no debe dar error, debe dar 0)
-- SELECT fn_PromedioPesoPorRaza('Angus') AS raza_sin_datos;
