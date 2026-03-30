USE staging_jardineria;
GO


-- 1. Verificar que no haya campos críticos nulos
-- Buscamos si hay clientes sin ciudad o sin país (datos vitales para ventas)
SELECT ID_cliente, nombre_cliente
FROM staging_cliente
WHERE ciudad IS NULL OR pais IS NULL;

-- 2. Verificar que no haya duplicados en Staging
-- Buscamos si algún producto se insertó dos veces por error
SELECT ID_producto, COUNT(*) as Total_Duplicados
FROM staging_producto
GROUP BY ID_producto
HAVING COUNT(*) > 1;

-- 3. Validar reglas de negocio
-- Los precios de venta nunca deberían ser cero o negativos.
SELECT ID_producto, nombre, precio_venta
FROM staging_producto
WHERE precio_venta <= 0;

-- 4. PRUEBA DE INTEGRIDAD REFERENCIAL (Integrity) en Staging
-- Como quitamos las Foreign Keys, debemos verificar que no haya pedidos "huérfanos"
-- (Pedidos asignados a un ID_cliente que no existe en la tabla clientes)
SELECT p.ID_pedido, p.ID_cliente
FROM staging_pedido p
         LEFT JOIN staging_cliente c ON p.ID_cliente = c.ID_cliente
WHERE c.ID_cliente IS NULL;