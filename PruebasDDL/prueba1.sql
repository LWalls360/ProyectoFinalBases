-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler version: 1.1.0-alpha1
-- PostgreSQL version: 16.0
-- Project Site: pgmodeler.io
-- Model Author: ---

-- Database creation must be performed outside a multi lined SQL file. 
-- These commands were put in this file only as a convenience.
-- 
-- object: new_database | type: DATABASE --
-- DROP DATABASE IF EXISTS new_database;
CREATE DATABASE new_database;
-- ddl-end --


-- object: public."EMPLEADO" | type: TABLE --
-- DROP TABLE IF EXISTS public."EMPLEADO" CASCADE;
CREATE TABLE public."EMPLEADO" (
	"RFC" varchar(13) NOT NULL,
	num_empleado smallint NOT NULL,
	nombre varchar(60) NOT NULL,
	fecha_nacimiento date NOT NULL,
	telefonos int4 NOT NULL,
	edad smallint NOT NULL,
	domicilio varchar(120) NOT NULL,
	sueldo smallint NOT NULL,
	foto smallint NOT NULL,
-- 	especialidad varchar NOT NULL,
-- 	horarios varchar NOT NULL,
-- 	rol varchar NOT NULL,
	CONSTRAINT "EMPLEADO_pk" PRIMARY KEY ("RFC")
)
 INHERITS(public."COCINEROS",public."MESEROS",public."ADMINISTRATIVOS");
-- ddl-end --
ALTER TABLE public."EMPLEADO" OWNER TO postgres;
-- ddl-end --

-- object: public."COCINEROS" | type: TABLE --
-- DROP TABLE IF EXISTS public."COCINEROS" CASCADE;
CREATE TABLE public."COCINEROS" (
	especialidad varchar NOT NULL,
	CONSTRAINT "COCINEROS_pk" PRIMARY KEY (especialidad)
);
-- ddl-end --
ALTER TABLE public."COCINEROS" OWNER TO postgres;
-- ddl-end --

-- object: public."MESEROS" | type: TABLE --
-- DROP TABLE IF EXISTS public."MESEROS" CASCADE;
CREATE TABLE public."MESEROS" (
	horarios varchar NOT NULL,
	CONSTRAINT "MESEROS_pk" PRIMARY KEY (horarios)
);
-- ddl-end --
ALTER TABLE public."MESEROS" OWNER TO postgres;
-- ddl-end --

-- object: public."ADMINISTRATIVOS" | type: TABLE --
-- DROP TABLE IF EXISTS public."ADMINISTRATIVOS" CASCADE;
CREATE TABLE public."ADMINISTRATIVOS" (
	rol varchar NOT NULL,
	CONSTRAINT "ADMINISTRATIVOS_pk" PRIMARY KEY (rol)
);
-- ddl-end --
ALTER TABLE public."ADMINISTRATIVOS" OWNER TO postgres;
-- ddl-end --

-- object: public."DEPENDIENTES" | type: TABLE --
-- DROP TABLE IF EXISTS public."DEPENDIENTES" CASCADE;
CREATE TABLE public."DEPENDIENTES" (
	"CURP" varchar(18) NOT NULL,
	nombre varchar NOT NULL,
	parentesco varchar NOT NULL,
	"RFC_EMPLEADO" varchar(13)

);
-- ddl-end --
ALTER TABLE public."DEPENDIENTES" OWNER TO postgres;
-- ddl-end --

-- object: public."PLATILLOS" | type: TABLE --
-- DROP TABLE IF EXISTS public."PLATILLOS" CASCADE;
CREATE TABLE public."PLATILLOS" (
	descripcion varchar(200) NOT NULL,
	nombre_platillo varchar(60) NOT NULL,
	receta varchar(200) NOT NULL,
	preco smallint NOT NULL,
	disponibilidad boolean NOT NULL,
	descripcion_categoria varchar(200) NOT NULL,
	"folio_ORDEN" varchar(20),
	CONSTRAINT "PLATILLOS_pk" PRIMARY KEY (descripcion)
);
-- ddl-end --
ALTER TABLE public."PLATILLOS" OWNER TO postgres;
-- ddl-end --

-- object: public."ORDEN" | type: TABLE --
-- DROP TABLE IF EXISTS public."ORDEN" CASCADE;
CREATE TABLE public."ORDEN" (
	folio varchar(20) NOT NULL,
	fecha date NOT NULL,
	hora time NOT NULL,
	total float4 NOT NULL,
	registro_mesero smallint,
	sub_total float4 NOT NULL,
	"RFC_EMPLEADO" varchar(13),
	"RFC_CLIENTE" varchar(13),
	CONSTRAINT "ORDEN_pk" PRIMARY KEY (folio)
);
-- ddl-end --
ALTER TABLE public."ORDEN" OWNER TO postgres;
-- ddl-end --

-- object: public."CLIENTE" | type: TABLE --
-- DROP TABLE IF EXISTS public."CLIENTE" CASCADE;
CREATE TABLE public."CLIENTE" (
	"RFC" varchar(13) NOT NULL,
	nombre_cliente char,
	domicilo_cliente varchar(150) NOT NULL,
	razon_social char(20) NOT NULL,
	email varchar(70) NOT NULL,
	fecha_nacimiento_cliente date NOT NULL,
	CONSTRAINT "CLIENTE_pk" PRIMARY KEY ("RFC")
);
-- ddl-end --
ALTER TABLE public."CLIENTE" OWNER TO postgres;
-- ddl-end --

-- object: "EMPLEADO_fk" | type: CONSTRAINT --
-- ALTER TABLE public."DEPENDIENTES" DROP CONSTRAINT IF EXISTS "EMPLEADO_fk" CASCADE;
ALTER TABLE public."DEPENDIENTES" ADD CONSTRAINT "EMPLEADO_fk" FOREIGN KEY ("RFC_EMPLEADO")
REFERENCES public."EMPLEADO" ("RFC") MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: "EMPLEADO_fk" | type: CONSTRAINT --
-- ALTER TABLE public."ORDEN" DROP CONSTRAINT IF EXISTS "EMPLEADO_fk" CASCADE;
ALTER TABLE public."ORDEN" ADD CONSTRAINT "EMPLEADO_fk" FOREIGN KEY ("RFC_EMPLEADO")
REFERENCES public."EMPLEADO" ("RFC") MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: "ORDEN_uq" | type: CONSTRAINT --
-- ALTER TABLE public."ORDEN" DROP CONSTRAINT IF EXISTS "ORDEN_uq" CASCADE;
ALTER TABLE public."ORDEN" ADD CONSTRAINT "ORDEN_uq" UNIQUE ("RFC_EMPLEADO");
-- ddl-end --

-- object: "CLIENTE_fk" | type: CONSTRAINT --
-- ALTER TABLE public."ORDEN" DROP CONSTRAINT IF EXISTS "CLIENTE_fk" CASCADE;
ALTER TABLE public."ORDEN" ADD CONSTRAINT "CLIENTE_fk" FOREIGN KEY ("RFC_CLIENTE")
REFERENCES public."CLIENTE" ("RFC") MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: "ORDEN_uq1" | type: CONSTRAINT --
-- ALTER TABLE public."ORDEN" DROP CONSTRAINT IF EXISTS "ORDEN_uq1" CASCADE;
ALTER TABLE public."ORDEN" ADD CONSTRAINT "ORDEN_uq1" UNIQUE ("RFC_CLIENTE");
-- ddl-end --

-- object: "ORDEN_fk" | type: CONSTRAINT --
-- ALTER TABLE public."PLATILLOS" DROP CONSTRAINT IF EXISTS "ORDEN_fk" CASCADE;
ALTER TABLE public."PLATILLOS" ADD CONSTRAINT "ORDEN_fk" FOREIGN KEY ("folio_ORDEN")
REFERENCES public."ORDEN" (folio) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --


