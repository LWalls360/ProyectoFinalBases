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
CREATE TABLE empleado (
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
    rol_administrativo VARCHAR(100),    
    especialidad_cocinero VARCHAR(100),
    foto BYTEA
);

-- Dependientes: Información de los dependientes de los empleados
CREATE TABLE dependiente (
    id SERIAL PRIMARY KEY,
    curp VARCHAR(18) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    parentesco VARCHAR(50) NOT NULL,
    empleado_id INTEGER NOT NULL,
    FOREIGN KEY (empleado_id) REFERENCES empleado(id)
);

CREATE TABLE categoria (
    id SERIAL PRIMARY KEY,    
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200) NOT NULL,
);

-- Platillos: Información de los platillos que ofrece el restaurante
CREATE TABLE producto (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200) NOT NULL,
    receta TEXT NOT NULL,
    precio DECIMAL(10, 2) NOT NULL,
    disponible BOOLEAN NOT NULL,
    categoria_id INTEGER NOT NULL,    
    FOREIGN KEY (categoria_id) REFERENCES categoria(id)
);

-- Ordenes: Información de las ordenes realizadas en el restaurante
CREATE TABLE orden (
    id SERIAL PRIMARY KEY,
    folio VARCHAR(50) NOT NULL,
    fecha_hora TIMESTAMP NOT NULL,
    cantidad_total DECIMAL(10, 2) NOT NULL,
    mesero_id INTEGER NOT NULL,
    cliente_id INTEGER NOT NULL,
    FOREIGN KEY (mesero_id) REFERENCES empleado(id),
    FOREIGN KEY (cliente_id) REFERENCES cliente(id);
);

-- Relación Platillos-Ordenes: Tabla intermedia para relacionar platillos y ordenes
CREATE TABLE producto_orden (
    id SERIAL PRIMARY KEY,
    producto_id INTEGER NOT NULL,
    orden_id INTEGER NOT NULL,
    cantidad INTEGER NOT NULL,
    precio_total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (producto_id) REFERENCES producto(id),
    FOREIGN KEY (orden_id) REFERENCES orden(id)
);

-- Clientes: Información de los cliente que solicitan factura
CREATE TABLE cliente (
    id SERIAL PRIMARY KEY,
    rfc VARCHAR(13) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    domicilio VARCHAR(200) NOT NULL,
    razon_social VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL
);

-- Puestos: Información de los distintos puestos que pueden tener los empleados
CREATE TABLE puesto (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200) NOT NULL
);

-- Horarios: Información de los horarios de trabajo de los meseros
CREATE TABLE horario (
    id SERIAL PRIMARY KEY,
    mesero_id INTEGER NOT NULL,
    hora_entrada TIME NOT NULL,
    hora_salida TIME NOT NULL,
    FOREIGN KEY (mesero_id) REFERENCES empleado(id)
);

-- Crear la tabla intermedia Empleados_Puestos
CREATE TABLE empleado_puesto (
    id SERIAL PRIMARY KEY,
    empleado_id INTEGER NOT NULL,
    puesto_id INTEGER NOT NULL,
    FOREIGN KEY (empleado_id) REFERENCES empleado(id),
    FOREIGN KEY (puesto_id) REFERENCES puesto(id)
);

-- Crear el índice en la tabla Dependientes
CREATE INDEX idx_dependiente_empleado_id ON dependiente(empleado_id);

-- Crear los índices en la tabla Ordenes
CREATE INDEX idx_orden_mesero_id ON orden(mesero_id);

-- Crear los índices en la tabla Horarios
CREATE INDEX idx_horario_mesero_id ON horario(mesero_id);

-- Actualizar Totales Function: Actualiza los totales de las ordenes y productos al insertar nuevos registros
CREATE OR REPLACE FUNCTION actualizar_totales() RETURNS TRIGGER AS $$
DECLARE
    esta_disponible BOOLEAN; 
BEGIN

    IF NEW.producto_id IS NOT NULL THEN
        -- Verificar si algún producto no está disponible
        SELECT
            disponible
        INTO 
            esta_disponible
        FROM
            NEW nuevo_producto_orden
            JOIN platillo
                ON nuevo_producto_orden.producto_id = producto.id;

        IF NOT esta_disponible THEN
            RAISE EXCEPTION 'Producto no disponible';
        END IF;
        
        -- Actualizar el precio total de los productos en producto_orden
        UPDATE producto_orden SET precio_total = NEW.cantidad * producto.precio
        FROM producto WHERE producto.id = NEW.producto_id AND producto.disponible = TRUE;
    END IF;

    -- Actualizar la cantidad total en la orden
    UPDATE orden 
    SET cantidad_total = COALESCE((SELECT SUM(precio_total) FROM producto_orden WHERE orden_id = NEW.orden_id), 0)
    WHERE id = NEW.orden_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers
CREATE TRIGGER actualizar_totales_platillos
AFTER INSERT ON platillo_orden
FOR EACH ROW
EXECUTE FUNCTION actualizar_totales();

CREATE TRIGGER actualizar_totales_bebidas
AFTER INSERT ON bebida_orden
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
FROM orden o
JOIN empleado e ON o.mesero_id = e.id
LEFT JOIN platillo_orden po ON o.id = po.orden_id
LEFT JOIN platillo p ON po.platillo_id = p.id
LEFT JOIN bebida_orden bo ON o.id = bo.orden_id
LEFT JOIN bebida b ON bo.bebida_id = b.id;

-- Vista de Factura: Proporciona información necesaria para asemejarse a una factura y una orden
CREATE VIEW factura AS
SELECT
    CONCAT('ORD-', LPAD(CAST(orden.id AS VARCHAR), 3, '0')) AS folio,
    orden.fecha_hora,
    orden.cantidad_total,
    CONCAT(empleado.nombre, ' ', empleado.apellido_paterno, ' ', empleado.apellido_materno) AS mesero
FROM
    orden
    JOIN empleado ON orden.mesero_id = empleado.id;

