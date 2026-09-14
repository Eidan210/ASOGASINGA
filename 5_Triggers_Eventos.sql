-- ==========================================
-- ARCHIVO 5: AUTOMATIZACIÓN - TRIGGERS Y EVENTOS
-- Requiere haber ejecutado antes:
--   1_Estructura_Base_Inserts.sql
--   2_Procedimientos_Almacenados.sql
--   3_Funciones.sql
--   4_Usuarios_Privilegios.sql
-- ==========================================

USE ASOGASINGA;

-- ==========================================
-- TABLAS DE APOYO
-- No forman parte del esquema original; las exige la lógica
-- de los triggers y eventos de este archivo.
-- ==========================================

CREATE TABLE auditoria_salarios (
    auditoria_id INT AUTO_INCREMENT PRIMARY KEY,
    empleado_id INT NOT NULL,
    salario_anterior DECIMAL(10,2) NOT NULL,
    salario_nuevo DECIMAL(10,2) NOT NULL,
    diferencia DECIMAL(10,2) NOT NULL,
    fecha_modificacion DATETIME NOT NULL,
    FOREIGN KEY (empleado_id) REFERENCES empleados(empleado_id)
);

CREATE TABLE resumen_semanal_fincas (
    resumen_id INT AUTO_INCREMENT PRIMARY KEY,
    finca_id INT NOT NULL,
    litros_totales DECIMAL(12,2) NOT NULL,
    semana_anio VARCHAR(10) NOT NULL,
    fecha_cierre DATETIME NOT NULL,
    FOREIGN KEY (finca_id) REFERENCES fincas(finca_id)
);

CREATE TABLE bitacora_depuracion (
    bitacora_id INT AUTO_INCREMENT PRIMARY KEY,
    filas_purgadas INT NOT NULL,
    fecha_ejecucion DATETIME NOT NULL
);

-- ==========================================
-- TRIGGERS
-- ==========================================

DELIMITER //

CREATE TRIGGER trg_ValidarPesoGanadoInsert
BEFORE INSERT ON ganado
FOR EACH ROW
BEGIN
    IF NEW.peso <= 0 OR NEW.peso > 1500 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El peso debe estar entre 1 y 1500 kg';
    END IF;
END //

CREATE TRIGGER trg_ValidarPesoGanadoUpdate
BEFORE UPDATE ON ganado
FOR EACH ROW
BEGIN
    IF NEW.peso <= 0 OR NEW.peso > 1500 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: El peso debe estar entre 1 y 1500 kg';
    END IF;
END //

CREATE TRIGGER trg_AuditarAumentoSalario
AFTER UPDATE ON empleados
FOR EACH ROW
BEGIN
    IF NEW.salario <> OLD.salario THEN
        INSERT INTO auditoria_salarios (empleado_id, salario_anterior, salario_nuevo, diferencia, fecha_modificacion)
        VALUES (NEW.empleado_id, OLD.salario, NEW.salario, NEW.salario - OLD.salario, NOW());
    END IF;
END //

CREATE TRIGGER trg_ValidarIntervaloVacunacion
BEFORE INSERT ON vacunacion
FOR EACH ROW
BEGIN
    DECLARE v_conteo INT;

    SELECT COUNT(*) INTO v_conteo
    FROM vacunacion
    WHERE ganado_id = NEW.ganado_id
      AND vacuna_id = NEW.vacuna_id
      AND fecha_aplicacion >= DATE_SUB(NEW.fecha_aplicacion, INTERVAL 30 DAY);

    IF v_conteo > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Esta vacuna ya fue aplicada a este animal hace menos de 30 dias';
    END IF;
END //

DELIMITER ;

-- ==========================================
-- EVENTOS
-- ==========================================

SET GLOBAL event_scheduler = ON;

DELIMITER //

CREATE EVENT evt_DepuracionAuditoriaMensual
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DECLARE v_filas INT;

    SELECT COUNT(*) INTO v_filas
    FROM auditoria_salarios
    WHERE fecha_modificacion < NOW() - INTERVAL 6 MONTH;

    DELETE FROM auditoria_salarios
    WHERE fecha_modificacion < NOW() - INTERVAL 6 MONTH;

    INSERT INTO bitacora_depuracion (filas_purgadas, fecha_ejecucion)
    VALUES (v_filas, NOW());
END //

CREATE EVENT evt_CierreSemanalProduccionLeche
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO resumen_semanal_fincas (finca_id, litros_totales, semana_anio, fecha_cierre)
    SELECT g.finca_id, SUM(pl.litros), YEARWEEK(NOW()), NOW()
    FROM produccion_leche pl
    INNER JOIN ganado g ON pl.ganado_id = g.ganado_id
    WHERE pl.fecha >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
    GROUP BY g.finca_id;
END //

DELIMITER ;

-- ==========================================
-- PRUEBAS
-- ==========================================

SELECT EVENT_NAME, STATUS FROM information_schema.EVENTS
WHERE EVENT_SCHEMA = 'ASOGASINGA';                                   -- 2 eventos, ambos ENABLED

-- Trigger de peso (INSERT)
-- INSERT INTO ganado(codigo_arete, nombre, raza, sexo, fecha_nacimiento, peso, finca_id, tipo_id)
-- VALUES ('A099', 'Test', 'Holstein', 'Hembra', '2024-01-01', 2000, 1, 1);   -- debe fallar (>1500)

-- Trigger de peso (UPDATE)
-- UPDATE ganado SET peso = 0 WHERE ganado_id = 1;                            -- debe fallar (<=0)

-- Trigger de auditoría de salario
UPDATE empleados SET salario = 2800000.00 WHERE empleado_id = 1;
SELECT * FROM auditoria_salarios WHERE empleado_id = 1;                      -- 1 fila: 2750000 -> 2800000

-- Trigger de intervalo de vacunación (repetir la misma vacuna aplicada en 2_Procedimientos_Almacenados.sql)
-- CALL sp_RegistrarVacunacion('A001', 'Fiebre Aftosa', 1, 'Repetido');      -- debe fallar (< 30 dias)
