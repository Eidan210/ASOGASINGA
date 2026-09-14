-- ==========================================
-- ENTREGABLE 2: PROCEDIMIENTOS ALMACENADOS
-- Requiere haber ejecutado antes: 1_Estructura_Base_Inserts.sql
-- ==========================================

USE ASOGASINGA;

DELIMITER //

CREATE PROCEDURE sp_RegistrarProduccionLeche(
    IN p_codigo_arete VARCHAR(50),
    IN p_fecha DATE,
    IN p_litros DECIMAL(10,2)
)
BEGIN
    DECLARE v_ganado_id INT;
    DECLARE v_sexo VARCHAR(10);
    DECLARE v_tipo VARCHAR(50);
    DECLARE v_existe INT DEFAULT 0;

    SELECT COUNT(*) INTO v_existe FROM ganado WHERE codigo_arete = p_codigo_arete;

    IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: No existe ganado con ese arete';
    END IF;

    SELECT g.ganado_id, g.sexo, t.nombre_tipo
    INTO v_ganado_id, v_sexo, v_tipo
    FROM ganado g
    INNER JOIN tipos_ganado t ON g.tipo_id = t.tipo_id
    WHERE g.codigo_arete = p_codigo_arete;

    IF v_tipo = 'Lechero' AND v_sexo = 'Hembra' THEN
        INSERT INTO produccion_leche (ganado_id, fecha, litros)
        VALUES (v_ganado_id, p_fecha, p_litros);
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El animal debe ser Hembra y de tipo Lechero';
    END IF;
END //

CREATE PROCEDURE sp_ActualizarSalarioEmpleado(
    IN p_empleado_id INT,
    IN p_porcentaje DECIMAL(10,2)
)
BEGIN
    DECLARE v_existe INT DEFAULT 0;

    SELECT COUNT(*) INTO v_existe FROM empleados WHERE empleado_id = p_empleado_id;

    IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El empleado no existe';
    ELSE
        UPDATE empleados
        SET salario = salario + (salario * (p_porcentaje / 100))
        WHERE empleado_id = p_empleado_id;
    END IF;
END //

CREATE PROCEDURE sp_TrasladarGanadoFinca(
    IN p_ganado_id INT,
    IN p_finca_id INT
)
BEGIN
    DECLARE v_existe_ganado INT DEFAULT 0;
    DECLARE v_existe_finca INT DEFAULT 0;

    SELECT COUNT(*) INTO v_existe_ganado FROM ganado WHERE ganado_id = p_ganado_id;
    SELECT COUNT(*) INTO v_existe_finca FROM fincas WHERE finca_id = p_finca_id;

    IF v_existe_ganado = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El animal no existe';
    ELSEIF v_existe_finca = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: La finca destino no existe';
    ELSE
        UPDATE ganado
        SET finca_id = p_finca_id
        WHERE ganado_id = p_ganado_id;
    END IF;
END //

CREATE PROCEDURE sp_RegistrarVacunacion(
    IN p_codigo_arete VARCHAR(50),
    IN p_nombre_vacuna VARCHAR(100),
    IN p_veterinario_id INT,
    IN p_observaciones VARCHAR(200)
)
BEGIN
    DECLARE v_ganado_id INT DEFAULT NULL;
    DECLARE v_vacuna_id INT DEFAULT NULL;

    SELECT MAX(ganado_id) INTO v_ganado_id
    FROM ganado WHERE codigo_arete = p_codigo_arete;

    IF v_ganado_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: No existe ganado con ese codigo de arete';
    END IF;

    SELECT MAX(vacuna_id) INTO v_vacuna_id
    FROM vacunas WHERE nombre = p_nombre_vacuna;

    IF v_vacuna_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: No existe una vacuna con ese nombre';
    END IF;

    INSERT INTO vacunacion (ganado_id, vacuna_id, veterinario_id, fecha_aplicacion, observaciones)
    VALUES (v_ganado_id, v_vacuna_id, p_veterinario_id, CURDATE(), p_observaciones);
END //

DELIMITER ;

-- ==========================================
-- PRUEBAS
-- ==========================================

-- sp_RegistrarProduccionLeche
CALL sp_RegistrarProduccionLeche('A001', '2026-03-01', 20.50);
SELECT * FROM produccion_leche WHERE ganado_id = 1;                 -- 3 filas, total 58.20

-- sp_ActualizarSalarioEmpleado
CALL sp_ActualizarSalarioEmpleado(1, 10);
SELECT empleado_id, salario FROM empleados WHERE empleado_id = 1;   -- 2500000 -> 2750000

-- sp_TrasladarGanadoFinca
CALL sp_TrasladarGanadoFinca(1, 2);
SELECT ganado_id, nombre, finca_id FROM ganado WHERE ganado_id = 1; -- finca_id = 2
CALL sp_TrasladarGanadoFinca(1, 1);                                 -- se restaura a finca 1
SELECT ganado_id, nombre, finca_id FROM ganado WHERE ganado_id = 1; -- finca_id = 1

-- sp_RegistrarVacunacion
CALL sp_RegistrarVacunacion('A001', 'Fiebre Aftosa', 1, 'Dosis de refuerzo');
SELECT * FROM vacunacion WHERE ganado_id = 1;                       -- 2 filas

-- Casos de error (descomentar uno a la vez para probarlos)
-- CALL sp_RegistrarProduccionLeche('A002', '2026-03-01', 10.00);      -- no es Hembra/Lechero
-- CALL sp_RegistrarProduccionLeche('Z999', '2026-03-01', 15.00);      -- arete inexistente
-- CALL sp_ActualizarSalarioEmpleado(99, 10);                          -- empleado inexistente
-- CALL sp_TrasladarGanadoFinca(1, 99);                                -- finca inexistente
