-- 1.- La base de datos ventas_online fue creada a través de la interfaz de pgAdmin,(evidencia en archivo PDF entregado a profesor aparte).

-- 2.-Creo mis tablas.

-- =========================
-- 2.1 Tabla Cliente
-- =========================
CREATE TABLE public.Cliente (
    id_cliente  SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    email       VARCHAR(100) UNIQUE NOT NULL,
    ciudad      VARCHAR(50)
);

-- =========================
-- 2.2 Tabla Producto
-- =========================
CREATE TABLE public.Producto (
    id_producto SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    categoria   VARCHAR(50),
    precio      NUMERIC(10, 2) NOT NULL CHECK (precio > 0)
);

-- =========================
-- 2.3 Tabla Pedido
-- =========================
CREATE TABLE public.Pedido (
    id_pedido    SERIAL PRIMARY KEY,
    fecha_pedido DATE NOT NULL,
    id_cliente   INT NOT NULL,
    
    CONSTRAINT fk_pedido_cliente 
        FOREIGN KEY (id_cliente) 
        REFERENCES public.Cliente(id_cliente) 
        ON DELETE CASCADE
);

-- =========================
-- 2.4 Tabla Detalle_Pedido
-- =========================
CREATE TABLE public.Detalle_Pedido (
    id_detalle  SERIAL PRIMARY KEY,
    id_pedido   INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad    INT NOT NULL CHECK (cantidad > 0),
    
    CONSTRAINT fk_detalle_pedido 
        FOREIGN KEY (id_pedido) 
        REFERENCES public.Pedido(id_pedido) 
        ON DELETE CASCADE,
    
    CONSTRAINT fk_detalle_producto 
        FOREIGN KEY (id_producto) 
        REFERENCES public.Producto(id_producto) 
        ON DELETE RESTRICT,
        
    CONSTRAINT unique_pedido_producto 
        UNIQUE (id_pedido, id_producto)
);

-- 3.- Inserto datos.

-- =========================
-- 3.1- INSERTO CLIENTES.
-- =========================
-- Inserto 5 clientes distintos.

INSERT INTO public.Cliente (nombre, email, ciudad) VALUES
('Carlos Mendoza', 'carlos.mendoza@email.com', 'Lima'),
('Ana Torres', 'ana.torres@email.com', 'Bogotá'),
('Luis Ramírez', 'luis.ramirez@email.com', 'Madrid'),
('María López', 'maria.lopez@email.com', 'Buenos Aires'),
('Jorge Castillo', 'jorge.castillo@email.com', 'Santiago');

-- =========================
-- 3.2- INSERTO PRODUCTOS.
-- =========================
-- Inserto 6 productos.
-- Pertenecen a 3 categorías diferentes: Tecnología, Muebles e Iluminación.

INSERT INTO public.Producto (nombre, categoria, precio) VALUES
('Laptop HP 15', 'Tecnología', 750.00),
('Mouse Inalámbrico Logitech', 'Tecnología', 25.50),
('Silla de Oficina Ergonómica', 'Muebles', 180.00),
('Escritorio de Madera', 'Muebles', 320.00),
('Impresora Epson L3250', 'Tecnología', 210.00),
('Lámpara LED de Escritorio', 'Iluminación', 45.00);

-- =========================
-- 3.3- INSERTO PEDIDOS.
-- =========================
-- Inserto 5 pedidos.
-- Cada pedido pertenece a un cliente distinto.

INSERT INTO public.Pedido (fecha_pedido, id_cliente) VALUES
('2026-02-01', 1),  -- Pedido del Cliente 1
('2026-02-05', 2),  -- Pedido del Cliente 2
('2026-02-10', 3),  -- Pedido del Cliente 3
('2026-02-15', 4),  -- Pedido del Cliente 4
('2026-02-20', 5);  -- Pedido del Cliente 5

-- =========================
-- 3.4- INSERTO DETALLE_PEDIDO.
-- =========================
-- Cada pedido contiene al menos 2 productos.

-- -------------------------
-- Detalles del Pedido 1.
-- -------------------------
INSERT INTO public.Detalle_Pedido (id_pedido, id_producto, cantidad) VALUES
(1, 1, 1),  -- Laptop HP 15
(1, 2, 2);  -- Mouse Inalámbrico

-- -------------------------
-- Detalles del Pedido 2.
-- -------------------------
INSERT INTO public.Detalle_Pedido (id_pedido, id_producto, cantidad) VALUES
(2, 3, 1),  -- Silla de Oficina
(2, 4, 1);  -- Escritorio de Madera

-- -------------------------
-- Detalles del Pedido 3.
-- -------------------------
INSERT INTO public.Detalle_Pedido (id_pedido, id_producto, cantidad) VALUES
(3, 1, 1),  -- Laptop HP 15
(3, 3, 2);  -- Silla de Oficina

-- -------------------------
-- Detalles del Pedido 4.
-- -------------------------
INSERT INTO public.Detalle_Pedido (id_pedido, id_producto, cantidad) VALUES
(4, 5, 1),  -- Impresora Epson
(4, 6, 2);  -- Lámpara LED

-- -------------------------
-- Detalles del Pedido 5.
-- -------------------------
INSERT INTO public.Detalle_Pedido (id_pedido, id_producto, cantidad) VALUES
(5, 2, 3),  -- Mouse Inalámbrico
(5, 6, 1);  -- Lámpara LED

-- 4.- Consultas SQL Requeridas. Realizar las siguientes consultas:

-- 4.1- Para obtener todos los clientes y sus pedidos, (aunque no tengan pedidos).

SELECT 
    c.id_cliente,
    c.nombre,
    c.email,
    c.ciudad,
    COALESCE(p.id_pedido::TEXT, 'Sin pedido') AS id_pedido,
    p.fecha_pedido
FROM public.Cliente c
LEFT JOIN public.Pedido p 
    ON c.id_cliente = p.id_cliente
ORDER BY c.id_cliente, p.fecha_pedido;

-- 4.2 - Listar los productos vendidos con su cantidad total vendida.

SELECT 
    p.id_producto,
    p.nombre,
    p.categoria,
    p.precio,
    SUM(dp.cantidad) AS total_vendido
FROM public.Producto p
INNER JOIN public.Detalle_Pedido dp
    ON p.id_producto = dp.id_producto
GROUP BY 
    p.id_producto,
    p.nombre,
    p.categoria,
    p.precio
ORDER BY total_vendido DESC;

-- 4.3 - Calcular el monto total de cada pedido.

SELECT
    pe.id_pedido,
    pe.fecha_pedido,
    c.nombre AS cliente,
    SUM(dp.cantidad * pr.precio) AS monto_total
FROM public.Pedido pe
JOIN public.Detalle_Pedido dp
    ON pe.id_pedido = dp.id_pedido
JOIN public.Producto pr
    ON dp.id_producto = pr.id_producto
JOIN public.Cliente c
    ON pe.id_cliente = c.id_cliente
GROUP BY
    pe.id_pedido,
    pe.fecha_pedido,
    c.nombre
ORDER BY
    pe.id_pedido;

-- 4.4.- Obtener el cliente que ha gastado más dinero.

SELECT
    c.id_cliente,
    c.nombre AS cliente,
    c.email,
    c.ciudad,
    SUM(dp.cantidad * pr.precio) AS total_gastado
FROM public.Cliente c
JOIN public.Pedido pe
    ON c.id_cliente = pe.id_cliente
JOIN public.Detalle_Pedido dp
    ON pe.id_pedido = dp.id_pedido
JOIN public.Producto pr
    ON dp.id_producto = pr.id_producto
GROUP BY
    c.id_cliente,
    c.nombre,
    c.email,
    c.ciudad
ORDER BY
    total_gastado DESC
LIMIT 1;

-- 4.5- Contar la cantidad de pedidos realizados por cada cliente.

SELECT
    c.id_cliente,
    c.nombre,
    c.email,
    c.ciudad,
    COUNT(pe.id_pedido) AS cantidad_pedidos
FROM public.Cliente c
LEFT JOIN public.Pedido pe
    ON c.id_cliente = pe.id_cliente
GROUP BY
    c.id_cliente,
    c.nombre,
    c.email,
    c.ciudad
ORDER BY
    cantidad_pedidos DESC;

-- 4.6.- Obtener los productos cuyo precio sea mayor al precio promedio (subquery).

SELECT
    id_producto,
    nombre,
    categoria,
    precio
FROM public.Producto
WHERE precio > (
    SELECT AVG(precio)
    FROM public.Producto
)
ORDER BY precio DESC;

-- 4.7- Listar pedidos realizados en una fecha específica.

SELECT
    pe.id_pedido,
    pe.fecha_pedido,
    c.nombre AS cliente,
    c.email,
    c.ciudad
FROM public.Pedido pe
JOIN public.Cliente c
    ON pe.id_cliente = c.id_cliente
WHERE pe.fecha_pedido = '2026-02-10'
ORDER BY pe.id_pedido;

-- 5.- Manipulación de datos.

-- 5.1- Actualizar el precio de un producto específico.

-- Primero corroboro el precio original del producto con id_producto = 1 que efectivamente sea de 750 dólares.

SELECT id_producto, nombre, precio
FROM public.Producto
WHERE id_producto = 1;

-- Luego actualizo el valor del producto con id_producto = 1 a 800 dólares.

UPDATE public.Producto
SET precio = 800.00
WHERE id_producto = 1
RETURNING *;

-- 5.2- Eliminar un pedido (y sus detalles asociados, respetando integridad referencial).

DELETE FROM public.Pedido
WHERE id_pedido = 5
RETURNING *;

-- 6.- Función definida por el Usuario. Crear una función SQL que reciba un id_cliente y retorne el monto total gastado por ese cliente.

CREATE OR REPLACE FUNCTION obtener_total_gastado(p_id_cliente INT)
RETURNS NUMERIC AS $$
DECLARE
    total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(dp.cantidad * pr.precio), 0)
    INTO total
    FROM public.Pedido pe
    JOIN public.Detalle_Pedido dp
        ON pe.id_pedido = dp.id_pedido
    JOIN public.Producto pr
        ON dp.id_producto = pr.id_producto
    WHERE pe.id_cliente = p_id_cliente;

    RETURN total;
END;
$$ LANGUAGE plpgsql;

-- 6.1- Ejemplo para corroborar el correcto funcionamiento de la función.

SELECT obtener_total_gastado(1);