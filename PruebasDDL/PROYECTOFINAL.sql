/*
Universidad Nacional Autónoma de México
Facultad de Ingeniería 

División de Ingeniería Eléctrica 
Bases de Datos 
Grupo: 1. 

Ing. Fernando Arreola. 

PROYECTO FINAL

Beltran Garcia Fernando Ivan.
Gómez Enríquez Agustín.
Madera Fuente Jose Angel.
Walls Chávez Luis Fernando.
*/

-- Este es un proyecto realizado para la materia de BD con fines academicos. 

-- Empleados: Información de los empleados del restaurante
CREATE TABLE empleados (
    id SERIAL PRIMARY KEY,
    rfc VARCHAR(13) NOT NULL,
    num_empleado INTEGER NOT NULL,
    nombre VARCHAR(100) NOT NULL,
	apellido_paterno VARCHAR(100) NOT NULL,
	apellido_materno VARCHAR(100) NULL,
    fecha_nacimiento DATE NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    edad INTEGER NOT NULL,
    domicilio VARCHAR(200) NOT NULL,
    sueldo DECIMAL(10, 2) NOT NULL,
    foto BYTEA,
    puesto VARCHAR(50) NOT NULL
);

-- Dependientes: Información de los dependientes de los empleados
CREATE TABLE dependientes (
    id SERIAL PRIMARY KEY,
    curp VARCHAR(18) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    parentesco VARCHAR(50) NOT NULL,
    empleado_id INTEGER NOT NULL,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id)
);

-- Platillos: Información de los platillos que ofrece el restaurante
CREATE TABLE platillos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200) NOT NULL,
    receta TEXT NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    disponible BOOLEAN NOT NULL,
    categoria VARCHAR(50) NOT NULL
);

-- Bebidas: Información de las bebidas que ofrece el restaurante
CREATE TABLE bebidas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200) NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    disponible BOOLEAN NOT NULL,
    categoria VARCHAR(50) NOT NULL
);

-- Ordenes: Información de las ordenes realizadas en el restaurante
CREATE TABLE ordenes (
    id SERIAL PRIMARY KEY,
    folio VARCHAR(50) NOT NULL,
    fecha_hora TIMESTAMP NOT NULL,
    cantidad_total DECIMAL(10, 2) NOT NULL,
    mesero_id INTEGER NOT NULL,
    FOREIGN KEY (mesero_id) REFERENCES empleados(id)
);

-- Relación Platillos-Ordenes: Tabla intermedia para relacionar platillos y ordenes
CREATE TABLE platillos_ordenes (
    id SERIAL PRIMARY KEY,
    platillo_id INTEGER NOT NULL,
    orden_id INTEGER NOT NULL,
    cantidad INTEGER NOT NULL,
    precio_total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (platillo_id) REFERENCES platillos(id),
    FOREIGN KEY (orden_id) REFERENCES ordenes(id)
);

-- Relación Bebidas-Ordenes: Tabla intermedia para relacionar bebidas y ordenes
CREATE TABLE bebidas_ordenes (
    id SERIAL PRIMARY KEY,
    bebida_id INTEGER NOT NULL,
    orden_id INTEGER NOT NULL,
    cantidad INTEGER NOT NULL,
    precio_total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (bebida_id) REFERENCES bebidas(id),
    FOREIGN KEY (orden_id) REFERENCES ordenes(id)
);

-- Clientes: Información de los clientes que solicitan factura
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    rfc VARCHAR(13) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    domicilio VARCHAR(200) NOT NULL,
    razon_social VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL
);

-- Puestos: Información de los distintos puestos que pueden tener los empleados
CREATE TABLE puestos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200) NOT NULL
);

-- Horarios: Información de los horarios de trabajo de los meseros
CREATE TABLE horarios (
    id SERIAL PRIMARY KEY,
    mesero_id INTEGER NOT NULL,
    hora_entrada TIME NOT NULL,
    hora_salida TIME NOT NULL,
    FOREIGN KEY (mesero_id) REFERENCES empleados(id)
);

-- Especialidad: Información sobre la especialidad de los cocineros
CREATE TABLE especialidades (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200) NOT NULL
);

-- Crear la tabla intermedia Empleados_Puestos
CREATE TABLE empleados_puestos (
    id SERIAL PRIMARY KEY,
    empleado_id INTEGER NOT NULL,
    puesto_id INTEGER NOT NULL,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id),
    FOREIGN KEY (puesto_id) REFERENCES puestos(id)
);

-- Crear el índice en la tabla Dependientes
CREATE INDEX idx_dependientes_empleado_id ON dependientes(empleado_id);

-- Crear los índices en la tabla Ordenes
CREATE INDEX idx_ordenes_mesero_id ON ordenes(mesero_id);

-- Crear los índices en la tabla Horarios
CREATE INDEX idx_horarios_mesero_id ON horarios(mesero_id);

-- Actualizar Totales Function: Actualiza los totales de las ordenes y productos al insertar nuevos registros
CREATE OR REPLACE FUNCTION actualizar_totales() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.platillo_id IS NOT NULL THEN
        -- Actualizar el precio total de los platillos en platillos_ordenes
        UPDATE platillos_ordenes SET precio_total = NEW.cantidad * platillos.precio
        FROM platillos WHERE platillos.id = NEW.platillo_id AND platillos.disponible = TRUE;
    ELSE
        -- Actualizar el precio total de las bebidas en bebidas_ordenes
        UPDATE bebidas_ordenes SET precio_total = NEW.cantidad * bebidas.precio
        FROM bebidas WHERE bebidas.id = NEW.bebida_id AND bebidas.disponible = TRUE;
    END IF;

    -- Actualizar la cantidad total en la orden
    UPDATE ordenes SET cantidad_total = COALESCE(
        (SELECT SUM(precio_total) FROM platillos_ordenes WHERE orden_id = NEW.orden_id),
        0)
        +
        COALESCE(
        (SELECT SUM(precio_total) FROM bebidas_ordenes WHERE orden_id = NEW.orden_id),
        0)
    WHERE id = NEW.orden_id;

    -- Verificar si algún producto no está disponible
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Producto no disponible';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers
CREATE TRIGGER actualizar_totales_platillos
AFTER INSERT ON platillos_ordenes
FOR EACH ROW
EXECUTE FUNCTION actualizar_totales();

CREATE TRIGGER actualizar_totales_bebidas
AFTER INSERT ON bebidas_ordenes
FOR EACH ROW
EXECUTE FUNCTION actualizar_totales();

-- Vista de Factura: Contiene información relevante para simular una factura
CREATE VIEW vista_factura AS
SELECT
    o.folio,
    o.fecha_hora,
    o.cantidad_total,
    o.mesero_id,
    e.nombre AS nombre_mesero,
    COALESCE(p.nombre, b.nombre) AS nombre_producto,
    COALESCE(po.cantidad, bo.cantidad) AS cantidad_producto,
    COALESCE(po.precio_total, bo.precio_total) AS precio_total_producto
FROM ordenes o
JOIN empleados e ON o.mesero_id = e.id
LEFT JOIN platillos_ordenes po ON o.id = po.orden_id
LEFT JOIN platillos p ON po.platillo_id = p.id
LEFT JOIN bebidas_ordenes bo ON o.id = bo.orden_id
LEFT JOIN bebidas b ON bo.bebida_id = b.id;

-- Añadir columna cliente_id a Ordenes
ALTER TABLE ordenes ADD COLUMN cliente_id INTEGER;

-- Vista de Factura: Proporciona información necesaria para asemejarse a una factura y una orden
-- Vista de Factura: Proporciona información necesaria para asemejarse a una factura y una orden
CREATE VIEW factura AS
SELECT
    CONCAT('ORD-', LPAD(CAST(ordenes.id AS VARCHAR), 3, '0')) AS folio,
    ordenes.fecha_hora,
    ordenes.cantidad_total,
    CONCAT(empleados.nombre, ' ', empleados.apellido_paterno, ' ', empleados.apellido_materno) AS mesero
FROM
    ordenes
    JOIN empleados ON ordenes.mesero_id = empleados.id;

