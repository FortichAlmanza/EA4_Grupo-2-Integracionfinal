--  CREACIÓN DE LA BASE DE DATOS
DROP DATABASE IF EXISTS staging_jardineria;
CREATE DATABASE staging_jardineria;
GO
USE staging_jardineria;
GO

-- 2. CREACIÓN DE TABLAS OPTIMIZADAS (Solo columnas analíticas con nombres actualizados)
CREATE TABLE staging_oficina (
                                 ID_oficina INT,
                                 Descripcion_Codigo VARCHAR(10),
                                 ciudad VARCHAR(30),
                                 pais VARCHAR(50),
                                 region VARCHAR(50),
                                 fecha_carga DATETIME DEFAULT GETDATE()
);

CREATE TABLE staging_empleado (
                                  ID_empleado INT,
                                  nombre VARCHAR(50),
                                  apellido1 VARCHAR(50),
                                  apellido2 VARCHAR(50),
                                  ID_oficina INT,
                                  ID_jefe INT,
                                  puesto VARCHAR(50),
                                  fecha_carga DATETIME DEFAULT GETDATE()
);

CREATE TABLE staging_Categoria_producto (
                                            Id_Categoria INT,
                                            Nombre_Categoria VARCHAR(50),
                                            fecha_carga DATETIME DEFAULT GETDATE()
);

CREATE TABLE staging_cliente (
                                 ID_cliente INT,
                                 nombre_cliente VARCHAR(50),
                                 ciudad VARCHAR(50),
                                 region VARCHAR(50),
                                 pais VARCHAR(50),
                                 ID_empleado_rep_ventas INT,
                                 limite_credito NUMERIC(15,2),
                                 fecha_carga DATETIME DEFAULT GETDATE()
);

CREATE TABLE staging_producto (
                                  ID_producto VARCHAR(15),
                                  nombre VARCHAR(70),
                                  Id_Categoria INT,
                                  proveedor VARCHAR(50),
                                  cantidad_en_stock SMALLINT,
                                  precio_venta NUMERIC(15,2),
                                  precio_proveedor NUMERIC(15,2),
                                  fecha_carga DATETIME DEFAULT GETDATE()
);

-- Las tablas de hechos se mantienen intactas
CREATE TABLE staging_pedido (
                                ID_pedido INT, fecha_pedido DATE, fecha_esperada DATE, fecha_entrega DATE,
                                estado VARCHAR(15), comentarios TEXT, ID_cliente INT, fecha_carga DATETIME DEFAULT GETDATE()
);

CREATE TABLE staging_detalle_pedido (
                                        ID_pedido INT, ID_producto VARCHAR(15), cantidad INT, precio_unidad NUMERIC(15,2),
                                        numero_linea SMALLINT, fecha_carga DATETIME DEFAULT GETDATE()
);

CREATE TABLE staging_pago (
                              ID_cliente INT, forma_pago VARCHAR(40), id_transaccion VARCHAR(50), fecha_pago DATE,
                              total NUMERIC(15,2), fecha_carga DATETIME DEFAULT GETDATE()
);
GO

-- CARGA DE DATOS
INSERT INTO staging_oficina (ID_oficina, Descripcion_Codigo, ciudad, pais, region)
SELECT ID_oficina, Descripcion_Codigo, ciudad, pais, region FROM jardineria.dbo.oficina;

INSERT INTO staging_Categoria_producto (Id_Categoria, Nombre_Categoria)
SELECT Id_Categoria, Nombre_Categoria FROM jardineria.dbo.Categoria_producto;

INSERT INTO staging_empleado (ID_empleado, nombre, apellido1, apellido2, ID_oficina, ID_jefe, puesto)
SELECT ID_empleado, nombre, apellido1, apellido2, ID_oficina, ID_jefe, puesto FROM jardineria.dbo.empleado;

INSERT INTO staging_cliente (ID_cliente, nombre_cliente, ciudad, region, pais, ID_empleado_rep_ventas, limite_credito)
SELECT ID_cliente, nombre_cliente, ciudad, region, pais, ID_empleado_rep_ventas, limite_credito FROM jardineria.dbo.cliente;

INSERT INTO staging_producto (ID_producto, nombre, Id_Categoria, proveedor, cantidad_en_stock, precio_venta, precio_proveedor)
SELECT ID_producto, nombre, Id_Categoria, proveedor, cantidad_en_stock, precio_venta, precio_proveedor FROM jardineria.dbo.producto;

INSERT INTO staging_pedido (ID_pedido, fecha_pedido, fecha_esperada, fecha_entrega, estado, comentarios, ID_cliente)
SELECT ID_pedido, fecha_pedido, fecha_esperada, fecha_entrega, estado, comentarios, ID_cliente FROM jardineria.dbo.pedido;

INSERT INTO staging_detalle_pedido (ID_pedido, ID_producto, cantidad, precio_unidad, numero_linea)
SELECT ID_pedido, ID_producto, cantidad, precio_unidad, numero_linea FROM jardineria.dbo.detalle_pedido;

INSERT INTO staging_pago (ID_cliente, forma_pago, id_transaccion, fecha_pago, total)
SELECT ID_cliente, forma_pago, id_transaccion, fecha_pago, total FROM jardineria.dbo.pago;
GO

--  CONSULTAS DE VALIDACIÓN
SELECT
    'oficina' AS Tabla,
    (SELECT COUNT(*) FROM jardineria.dbo.oficina) AS Registros_Origen,
    (SELECT COUNT(*) FROM staging_jardineria.dbo.staging_oficina) AS Registros_Staging
UNION ALL
SELECT
    'Categoria_producto',
    (SELECT COUNT(*) FROM jardineria.dbo.Categoria_producto),
    (SELECT COUNT(*) FROM staging_jardineria.dbo.staging_Categoria_producto)
UNION ALL
SELECT
    'producto',
    (SELECT COUNT(*) FROM jardineria.dbo.producto),
    (SELECT COUNT(*) FROM staging_jardineria.dbo.staging_producto)
UNION ALL
SELECT
    'pedido',
    (SELECT COUNT(*) FROM jardineria.dbo.pedido),
    (SELECT COUNT(*) FROM staging_jardineria.dbo.staging_pedido);

SELECT TOP 5 ID_pedido, estado, fecha_carga
FROM staging_jardineria.dbo.staging_pedido
ORDER BY fecha_carga DESC;
GO

-- CREACIÓN DEL BACKUP
BACKUP DATABASE staging_jardineria
TO DISK = 'M:\actividad2\staging_jardineria_BK.bak'
WITH FORMAT, MEDIANAME = 'JardineriaBackups', NAME = 'Full Backup of staging_jardineria depurada';
GO