--función sin parametro de entrada para devolver el precio máximo

CREATE FUNCTION obtener_precio_max()
RETURNS numeric
as $$ 
DECLARE 
precio_max numeric;
BEGIN 
	SELECT MAX(unit_price)
	INTO precio_max
	FROM products;
	return precio_max;
END $$ 
language 'plpgsql';

SELECT obtener_precio_max()

--parametro de entrada,Obtener el numero de ordenes por empleado

CREATE FUNCTION orden_emple(employee numeric)
RETURNS numeric
as $$ 
DECLARE 
numero_ordenes numeric;
BEGIN 
	SELECT employee_id, order_id COUNT(order_id)
	INTO numero_ordenes
	FROM orders
	where employee_id=employee;
	return numero_ordenes;
END $$ 
language 'plpgsql';

SELECT orden_emple(3);

--Obtener la venta de un empleado con un determinado producto


CREATE FUNCTION venta(empleado numeric, producto numeric)
RETURNS numeric
as $$ 
DECLARE 
venta numeric;
BEGIN 
	SELECT sum(quantity)
	INTO venta
	FROM order_details od
	JOIN orders o  ON 
	od.order_id=o.order_id
	and employee_id= empleado
	and product_id= producto;
	return venta;
END $$ 
language 'plpgsql';

SELECT venta(4,1);

--Crear una funcion para devolver una tabla con producto_id,
--nombre, precio y unidades en strock, debe obtener los productos terminados en n
SELECT * FROM products;
CREATE FUNCTION tabla()
RETURNS TABLE (
    _id smallint,
	_name character varying,
	_price real,
	_stock smallint
) AS $$
BEGIN
RETURN QUERY
    SELECT product_id,product_name,unit_price,units_in_stock 
	FROM products 
	WHERE product_name 
	LIKE '%n';
END;
$$ LANGUAGE plpgsql;

SELECT * FROM tabla();


---- Creamos la función contador_ordenes_anio()
--QUE CUENTE LAS ORDENES POR AÑO devuelve una tabla con año y contador


SELECT * FROM orders;
CREATE FUNCTION contador_ordenes_anio()
RETURNS TABLE (
    _anio numeric,
	_contador bigint
) AS $$
BEGIN
RETURN QUERY
    SELECT extract(year from order_date) as anio, 
	count(order_id) as contador
	FROM orders 
	GROUP BY anio;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM contador_ordenes_anio();

--Lo mismo que el ejemplo anterior pero con un parametro de entrada que sea el año

CREATE FUNCTION contador_ordenes_anio1(anioo numeric)
RETURNS TABLE (
    _anio numeric,
	_contador bigint
) AS $$
BEGIN
RETURN QUERY
    SELECT extract(year from order_date) as anio, 
	count(order_id) as contador 
	FROM orders 
	where extract(year from order_date)=anioo
	GROUP BY anio ;
END;
$$ LANGUAGE plpgsql;

SELECT contador_ordenes_anio1(1992);

--PROCEDIMIENTO ALMACENADO PARA OBTENER PRECIO PROMEDIO Y SUMA DE 
--UNIDADES EN STOCK POR CATEGORIA

SELECT * FROM products; 

CREATE FUNCTION almacenado()
RETURNS TABLE (
	categoria smallint,
    precio_promedio double precision,
	suma_unidades bigint
) AS $$
BEGIN
RETURN QUERY
    SELECT  category_id, 
	AVG(unit_price) as promedio, 
	SUM(units_in_stock) as suma 
	FROM products 
	GROUP BY category_id ;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM almacenado();
--PROCEDIMIENTO ALMACENADO PARA OBTENER PRECIO PROMEDIO Y SUMA DE 
--UNIDADES EN STOCK POR CATEGORIA

SELECT * FROM products; 

CREATE FUNCTION almacenadoo( categoriaid integer)
RETURNS TABLE (
	categoria smallint,
    precio_promedio numeric,
	suma_unidades bigint
) AS $$
BEGIN
RETURN QUERY
    SELECT  category_id, 
	AVG(unit_price)::numeric as promedio, 
	SUM(units_in_stock) as suma 
	FROM products 
 	WHERE category_id=categoriaid
	GROUP BY category_id ;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM almacenadoo(1);


--Con el nombre de categoria.

CREATE FUNCTION almacenado1()
RETURNS TABLE (
	categoria VARCHAR(15),
    precio_promedio double precision,
	suma_unidades bigint
) AS $$
BEGIN
RETURN QUERY
    SELECT category_name,  
	AVG(p.unit_price), SUM(p.units_in_stock) 
	FROM categories c 
	INNER JOIN products p
	ON c.category_id= p.category_id
	GROUP BY category_name;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM almacenado1();

	