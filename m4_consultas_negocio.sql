--CONSULTA 1 Resumen ejecutivo mensual
SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta);
--CONSULTA 2 Ranking de productos
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;
--CONSULTA 3 Clientes recurrentes
SELECT 
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY cantidad_pedidos DESC;
-- CONSULTA 4 Productos por encima/por debajo del promedio
WITH FacturacionPorProducto AS (
    SELECT 
        id_producto,
        SUM(cantidad * precio_unitario) AS total_producto
    FROM ventas
    GROUP BY id_producto
)
SELECT 
    id_producto,
    total_producto,
    CASE 
        WHEN total_producto >= (SELECT AVG(total_producto) FROM FacturacionPorProducto) THEN 'Por encima'
        ELSE 'Por debajo'
    END AS rendimiento
FROM FacturacionPorProducto
ORDER BY total_producto DESC;
-- Los productos Por debajo del promedio concentran el 66% de la facturacion
-- El producto 1 concentra el 16% de la facturacion
-- Los clientes recurrentes hicieron 2 pedidos 

-- FIN DE LAS CONSULTAS.