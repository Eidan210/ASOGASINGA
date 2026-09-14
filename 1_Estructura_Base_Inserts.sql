-- ==========================================
-- ENTREGABLE 1: ESTRUCTURA BASE E INSERTS
-- BASE DE DATOS: ASOGASINGA
-- ==========================================

DROP DATABASE IF EXISTS ASOGASINGA;
CREATE DATABASE ASOGASINGA;
USE ASOGASINGA;

-- ==========================================
-- 1. TABLAS PRINCIPALES
-- ==========================================

CREATE TABLE socios (
    socio_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    cedula VARCHAR(20) UNIQUE,
    telefono VARCHAR(20),
    correo VARCHAR(100),
    direccion VARCHAR(150),
    fecha_ingreso DATE
);

CREATE TABLE municipios (
    municipio_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    departamento VARCHAR(100)
);

CREATE TABLE fincas (
    finca_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    ubicacion VARCHAR(150),
    hectareas DECIMAL(10,2),
    socio_id INT,
    municipio_id INT,
    FOREIGN KEY (socio_id) REFERENCES socios(socio_id),
    FOREIGN KEY (municipio_id) REFERENCES municipios(municipio_id)
);

CREATE TABLE tipos_ganado (
    tipo_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(50),
    descripcion VARCHAR(150)
);

CREATE TABLE ganado (
    ganado_id INT AUTO_INCREMENT PRIMARY KEY,
    codigo_arete VARCHAR(50) UNIQUE,
    nombre VARCHAR(50),
    raza VARCHAR(50),
    sexo VARCHAR(10),
    fecha_nacimiento DATE,
    peso DECIMAL(10,2),
    finca_id INT,
    tipo_id INT,
    FOREIGN KEY (finca_id) REFERENCES fincas(finca_id),
    FOREIGN KEY (tipo_id) REFERENCES tipos_ganado(tipo_id)
);

CREATE TABLE veterinarios (
    veterinario_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    telefono VARCHAR(20),
    especialidad VARCHAR(100)
);

CREATE TABLE vacunas (
    vacuna_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    descripcion VARCHAR(150),
    dosis VARCHAR(50)
);

CREATE TABLE vacunacion (
    vacunacion_id INT AUTO_INCREMENT PRIMARY KEY,
    ganado_id INT,
    vacuna_id INT,
    veterinario_id INT,
    fecha_aplicacion DATE,
    observaciones VARCHAR(200),
    FOREIGN KEY (ganado_id) REFERENCES ganado(ganado_id),
    FOREIGN KEY (vacuna_id) REFERENCES vacunas(vacuna_id),
    FOREIGN KEY (veterinario_id) REFERENCES veterinarios(veterinario_id)
);

CREATE TABLE produccion_leche (
    produccion_id INT AUTO_INCREMENT PRIMARY KEY,
    ganado_id INT,
    fecha DATE,
    litros DECIMAL(10,2),
    FOREIGN KEY (ganado_id) REFERENCES ganado(ganado_id)
);

CREATE TABLE empleados (
    empleado_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    cargo VARCHAR(100),
    telefono VARCHAR(20),
    salario DECIMAL(10,2),
    finca_id INT,
    FOREIGN KEY (finca_id) REFERENCES fincas(finca_id)
);

CREATE TABLE alimentos (
    alimento_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    tipo VARCHAR(50),
    costo DECIMAL(10,2)
);

CREATE TABLE alimentacion (
    alimentacion_id INT AUTO_INCREMENT PRIMARY KEY,
    ganado_id INT,
    alimento_id INT,
    fecha DATE,
    cantidad_kg DECIMAL(10,2),
    FOREIGN KEY (ganado_id) REFERENCES ganado(ganado_id),
    FOREIGN KEY (alimento_id) REFERENCES alimentos(alimento_id)
);

-- ==========================================
-- 2. DATOS DE PRUEBA (INSERTS)
-- ==========================================

INSERT INTO municipios(nombre, departamento) VALUES
('Yopal', 'Casanare'),
('Villavicencio', 'Meta');

INSERT INTO socios(nombre, apellido, cedula, telefono, correo, direccion, fecha_ingreso) VALUES
('Carlos', 'Perez', '12345678', '3001111111', 'carlos@gmail.com', 'Calle 1', '2025-01-10'),
('Ana', 'Gomez', '87654321', '3002222222', 'ana@gmail.com', 'Calle 2', '2025-02-15');

INSERT INTO fincas(nombre, ubicacion, hectareas, socio_id, municipio_id) VALUES
('La Esperanza', 'Vereda Norte', 120.5, 1, 1),
('El Descanso', 'Vereda Sur', 80.0, 2, 2);

INSERT INTO tipos_ganado(nombre_tipo, descripcion) VALUES
('Lechero', 'Ganado para producción de leche'),
('Carne', 'Ganado para producción cárnica');

INSERT INTO ganado(codigo_arete, nombre, raza, sexo, fecha_nacimiento, peso, finca_id, tipo_id) VALUES
('A001', 'Lola', 'Holstein', 'Hembra', '2023-01-10', 450, 1, 1),
('A002', 'ToroMax', 'Brahman', 'Macho', '2022-05-12', 600, 2, 2);

INSERT INTO veterinarios(nombre, telefono, especialidad) VALUES
('Dr. Ramirez', '3111111111', 'Bovinos'),
('Dra. Lopez', '3222222222', 'Vacunación');

INSERT INTO vacunas(nombre, descripcion, dosis) VALUES
('Brucelosis', 'Prevención brucelosis', '10ml'),
('Fiebre Aftosa', 'Prevención aftosa', '5ml');

INSERT INTO vacunacion(ganado_id, vacuna_id, veterinario_id, fecha_aplicacion, observaciones) VALUES
(1, 1, 1, '2026-01-10', 'Sin novedades'),
(2, 2, 2, '2026-01-15', 'Aplicación correcta');

INSERT INTO produccion_leche(ganado_id, fecha, litros) VALUES
(1, '2026-02-01', 18.5),
(1, '2026-02-02', 19.2);

INSERT INTO empleados(nombre, cargo, telefono, salario, finca_id) VALUES
('Pedro Ruiz', 'Administrador', '3333333333', 2500000, 1),
('Luis Mora', 'Ordeñador', '3444444444', 1800000, 2);

INSERT INTO alimentos(nombre, tipo, costo) VALUES
('Pasto Premium', 'Natural', 50000),
('Concentrado Bovino', 'Procesado', 120000);

INSERT INTO alimentacion(ganado_id, alimento_id, fecha, cantidad_kg) VALUES
(1, 1, '2026-02-01', 15),
(2, 2, '2026-02-01', 10);

-- ==========================================
-- VERIFICACIÓN
-- ==========================================
SELECT TABLE_NAME FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'ASOGASINGA' ORDER BY TABLE_NAME;   -- deben salir 12 tablas

SELECT
    (SELECT COUNT(*) FROM socios)          AS socios,
    (SELECT COUNT(*) FROM ganado)          AS ganado,
    (SELECT COUNT(*) FROM produccion_leche) AS produccion_leche,
    (SELECT COUNT(*) FROM empleados)       AS empleados;
