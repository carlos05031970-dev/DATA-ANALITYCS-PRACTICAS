-- 1 DROP (de mas dependiente a menos dependiente)
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;
-- 2 CREACION DE TABLAS BASE (DDL)
CREATE TABLE categorias (
id_categoria INT PRIMARY KEY,
nombre_categoria VARCHAR(50) NOT NULL,
descripción VARCHAR(200)
);
CREATE TABLE clientes (
id_cliente INT PRIMARY KEY,
nombre VARCHAR(100) NOT NULL,
email VARCHAR(100) UNIQUE,
ciudad VARCHAR(50),
fecha_registro DATE NOT NULL
);
CREATE TABLE productos (
id_producto INT PRIMARY KEY,
nombre_producto VARCHAR(100) NOT NULL,
id_categoria INT NOT NULL,
precio DECIMAL(10,2) NOT NULL,
stock INT DEFAULT 0,
activo BIT DEFAULT 1,
FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);
CREATE TABLE ventas (
id_venta INT PRIMARY KEY,
id_cliente INT NOT NULL,
id_producto INT NOT NULL,
cantidad INT NOT NULL,
precio_unitario DECIMAL(10,2) NOT NULL,
fecha_venta DATE NOT NULL,
FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);
-- 3 INSERT DATA (DML)
INSERT INTO categorias (id_categoria, nombre_categoria, descripción) VALUES
(1, 'Computación', 'Laptops, PCs y monitores'),
(2, 'Accesorios', 'Perifericos y complementos'),
(3, 'Audio', 'Auriculares y parlantes'),
(4, 'Almacenamiento', 'Discos y memorias');
INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
(1, 'Maria López', 'maria@mail.com', 'Buenos Aires', '2024-01-05'),
(2, 'Carlos Ruíz', 'carlos@mail.com', 'Córdoba', '2024-01-10'),
(3, 'Ana Gómez', 'ana@mail.com', 'Rosario', '2024-02-01'),
(4, 'Pedro Sanz', 'pedro@mail.com', 'Mendoza', '2024-02-15'),
(5, 'Laura Torres', 'laura@mail.com', 'Tucumán', '2024-03-01');
INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
 (1, 'Laptop Pro 15',      1, 1200.00, 15, 1),
 (2, 'Mouse Inalámbrico',  2,   28.00, 80, 1),
 (3, 'Monitor 4K 27',      1,  450.00, 12, 1),
 (4, 'Auriculares BT Pro', 3,  120.00, 35, 1),
 (5, 'SSD Externo 1TB',    4,  130.00, 18, 1),
 (6, 'Teclado Mecánico',   2,   95.00, 40, 1);
 INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
 ( 1, 1, 1, 2, 1200.00, '2024-03-05'),
 ( 2, 2, 2, 5,   28.00, '2024-03-06'),
 ( 3, 3, 3, 1,  450.00, '2024-03-07'),
 ( 4, 1, 4, 2,  120.00, '2024-03-08'),
 ( 5, 4, 5, 3,  130.00, '2024-03-10'),
 ( 6, 2, 6, 4,   95.00, '2024-03-11'),
 ( 7, 5, 1, 1, 1200.00, '2024-03-12'),
 ( 8, 3, 2, 8,   28.00, '2024-03-13'),
 ( 9, 4, 4, 1,  120.00, '2024-03-14'),
 (10, 5, 3, 2,  450.00, '2024-03-15');
 -- 4 VALIDACION DE DATOS
 SELECT * FROM categorias;
 SELECT * FROM clientes; 
 SELECT * FROM productos;
 SELECT * FROM ventas;  
 -- FIN DEL SCRIPT


 -- PRE ENTREGA 5 

 -- 1. Agregamos id_sucursal a ventas
ALTER TABLE ventas ADD id_sucursal INT;
GO
-- 2. Asignamos sucursales a los registros de ventas
UPDATE ventas SET id_sucursal = 1 WHERE id_venta IN (1, 2);
UPDATE ventas SET id_sucursal = 2 WHERE id_venta = 3;
UPDATE ventas SET id_sucursal = 3 WHERE id_venta > 3;
GO

-- Consulta 1: Vista base del proyecto (INNER JOIN)
SELECT 
    v.id_venta,
    v.fecha_venta,
    c.nombre AS nombre_cliente,
    p.nombre_producto,
    cat.nombre_categoria,
    s.nombre_sucursal,
    s.ciudad,
    s.region,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta
FROM ventas AS v
INNER JOIN clientes AS c 
    ON v.id_cliente = c.id_cliente
INNER JOIN productos AS p 
    ON v.id_producto = p.id_producto
INNER JOIN categorias AS cat 
    ON p.id_categoria = cat.id_categoria
INNER JOIN sucursales AS s 
    ON v.id_sucursal = s.id_sucursal;

    -- Hallazgo: Se observa que Córdoba tiene el mayor volumen físico de transacciones impulsada por el producto de mayor rotación (Mouse Inalámbrico, con 8 unidades), mientras que CABA concentra las ventas de mayor ticket unitario (Laptop Pro 15, con 2 unidades).

-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: detectar clientes dados de alta en el sistema que no registran transacciones para activar acciones de marketing o reactivación.
SELECT 
    c.id_cliente,
    c.nombre AS nombre_cliente,
    v.id_venta
FROM clientes AS c
LEFT JOIN ventas AS v 
    ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
-- Hallazgo: La consulta no devuelve un resultado, lo cual evidencia que todos los integrantes de la cartera de clientes registrada cuenta con al menos una transacción en el histórico de ventas. A nivel de negocio, indica una base de usuarios plenamente convertida en el período analizado, sin clientes inactivos.

-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Propósito: identificar artículos del catálogo sin movimiento comercial para optimizar inventario o definir promociones de liquidación.
SELECT 
    p.id_producto,
    p.nombre_producto,
    cat.nombre_categoria,
    p.precio
FROM productos AS p
INNER JOIN categorias AS cat 
    ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas AS v 
    ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;
-- Hallazgo: La consulta no devuelve registros, lo que confirma que el 100% del catálogo activo registra rotación comercial en el período evaluado. No se identifican productos

-- Consulta 4: Consolidado por canal (UNION ALL)
-- Propósito: unificar ventas de diferentes orígenes/canales conservando todas las transacciones para comparar la facturación global de cada canal.
SELECT 
    canal, 
    COUNT(*) AS cantidad_operaciones,
    SUM(total) AS total_facturado
FROM (
    SELECT 
        id_venta,
        fecha_venta, 
        (cantidad * precio_unitario) AS total, 
        'Presencial' AS canal
    FROM ventas 
    WHERE id_sucursal IN (1, 2)
    UNION ALL
    SELECT 
        id_venta,
        fecha_venta, 
        (cantidad * precio_unitario) AS total, 
        'Online' AS canal
    FROM ventas 
    WHERE id_sucursal = 3
) AS consolidado
GROUP BY canal;
-- Hallazgo: El canal Online concentra el mayor volumen de transacciones (7 operaciones frente a 3 de Presencial), posicionándose como la principal vía de captación de órdenes para el negocio, mientras que la venta presencial complementa con operaciones puntuales.
 -- FIN DEL SCRIPT



