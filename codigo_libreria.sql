-- Proyecto: DATABASE LIBRERIA --

-- Creo la base de datos
CREATE DATABASE libreriaDB;

-- Me posiciono sobre la base de datos
USE libreriaDB;

-- Tabla Autor
CREATE TABLE Autor(
    idAutor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    apellido VARCHAR(30) NOT NULL,
    nacionalidad VARCHAR(50)
);

-- Tabla Libro
CREATE TABLE Libro(
    idLibro INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(50) NOT NULL,
    editorial VARCHAR(40),
    idAutor INT,
    precio DECIMAL(10,2) NOT NULL CHECK(precio >= 0),
    stock INT NOT NULL CHECK(stock >= 0),
    FOREIGN KEY (idAutor) REFERENCES Autor(idAutor) ON DELETE SET NULL
);

-- Tabla Cliente
CREATE TABLE Cliente(
    idCliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL,
    apellido VARCHAR(30) NOT NULL,
    correo VARCHAR(50) UNIQUE
);

-- Tabla Venta
CREATE TABLE Venta(
    idVenta INT AUTO_INCREMENT PRIMARY KEY,
    idCliente INT NOT NULL,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(idCliente) REFERENCES Cliente(idCliente) ON DELETE CASCADE
);

-- Tabla intermedia: DetalleVenta (relación muchos a muchos entre Venta y Libro)
CREATE TABLE DetalleVenta(
    idDetalle INT AUTO_INCREMENT PRIMARY KEY,
    idVenta INT NOT NULL,
    idLibro INT NOT NULL,
    cantidad INT NOT NULL CHECK(cantidad > 0),
    total DECIMAL(10,2) NOT NULL, -- Se calculará mediante un trigger
    FOREIGN KEY(idVenta) REFERENCES Venta(idVenta) ON DELETE CASCADE,
    FOREIGN KEY(idLibro) REFERENCES Libro(idLibro) ON DELETE CASCADE
);

-- Trigger para calcular automáticamente el total en DetalleVenta
DELIMITER $$
CREATE TRIGGER before_insert_detalleventa
BEFORE INSERT ON DetalleVenta
FOR EACH ROW
BEGIN
    DECLARE precio_libro DECIMAL(10,2);
    -- Obtener el precio del libro
    SELECT precio INTO precio_libro FROM Libro WHERE idLibro = NEW.idLibro;
    -- Calcular el total
    SET NEW.total = precio_libro * NEW.cantidad;
END$$
DELIMITER ;


-- Trigger para evitar ventas si el stock es insuficiente
DELIMITER $$
CREATE TRIGGER before_insert_detalleventa_check_stock
BEFORE INSERT ON DetalleVenta
FOR EACH ROW
BEGIN
    DECLARE stock_actual INT;
    
    -- Obtener el stock actual del libro
    SELECT stock INTO stock_actual FROM Libro WHERE idLibro = NEW.idLibro;
    
    -- Verificar si hay suficiente stock
    IF stock_actual < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente para completar la venta';
    END IF;
END$$
DELIMITER ;

-- Trigger para actualizar el stock al eliminar un detalle de venta
DELIMITER $$
CREATE TRIGGER after_delete_detalleventa_update_stock
AFTER DELETE ON DetalleVenta
FOR EACH ROW
BEGIN
    -- Reponer el stock del libro cuando se elimina un detalle de venta
    UPDATE Libro 
    SET stock = stock + OLD.cantidad 
    WHERE idLibro = OLD.idLibro;
END$$
DELIMITER ;



#VISTAS
CREATE VIEW VistaLibrosDisponibles AS
SELECT 
    l.idLibro, l.titulo, l.editorial, 
    CONCAT(a.nombre, ' ', a.apellido) AS autor, 
    l.precio, l.stock
FROM Libro l
LEFT JOIN Autor a ON l.idAutor = a.idAutor
WHERE l.stock > 0;





CREATE VIEW VistaVentasClientes AS
SELECT 
    v.idVenta, 
    CONCAT(c.nombre, ' ', c.apellido) AS cliente, 
    v.fecha
FROM Venta v
JOIN Cliente c ON v.idCliente = c.idCliente;




#FUNCIONES 



DELIMITER $$
CREATE FUNCTION CalcularTotalVenta(id_venta INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(total) INTO total FROM DetalleVenta WHERE idVenta = id_venta;
    RETURN IFNULL(total, 0);
END$$
DELIMITER ;






DELIMITER $$
CREATE FUNCTION StockDisponible(id_libro INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE stock_actual INT;
    SELECT stock INTO stock_actual FROM Libro WHERE idLibro = id_libro;
    RETURN IFNULL(stock_actual, 0);
END$$
DELIMITER ;




#STORED PROCEDURES

DELIMITER $$
CREATE PROCEDURE RegistrarVenta(IN id_cliente INT, OUT nuevo_id INT)
BEGIN
    INSERT INTO Venta (idCliente) VALUES (id_cliente);
    SELECT LAST_INSERT_ID() INTO nuevo_id;
END$$
DELIMITER ;





DELIMITER $$
CREATE PROCEDURE AgregarDetalleVenta(
    IN id_venta INT, 
    IN id_libro INT, 
    IN cantidad INT
)
BEGIN
    DECLARE precio_libro DECIMAL(10,2);
    DECLARE stock_actual INT;

    -- Obtener el stock y el precio del libro
    SELECT precio, stock INTO precio_libro, stock_actual FROM Libro WHERE idLibro = id_libro;

    -- Verificar que haya stock suficiente
    IF stock_actual >= cantidad THEN
        INSERT INTO DetalleVenta (idVenta, idLibro, cantidad, total) 
        VALUES (id_venta, id_libro, cantidad, precio_libro * cantidad);

        -- Actualizar stock
        UPDATE Libro SET stock = stock - cantidad WHERE idLibro = id_libro;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente';
    END IF;
END$$
DELIMITER ;



#INSERCION DE DATOS

-- Insertar Autores
INSERT INTO Autor (nombre, apellido, nacionalidad) VALUES 
('Gabriel', 'García Márquez', 'Colombiana'),
('J.K.', 'Rowling', 'Británica'),
('George', 'Orwell', 'Británica'),
('Isabel', 'Allende', 'Chilena'),
('Julio', 'Cortázar', 'Argentina'),
('Haruki', 'Murakami', 'Japonesa'),
('Stephen', 'King', 'Estadounidense'),
('J.R.R.', 'Tolkien', 'Británica'),
('Jane', 'Austen', 'Británica'),
('Miguel', 'de Cervantes', 'Española'),
('Mark', 'Twain', 'Estadounidense'),
('Fiódor', 'Dostoyevski', 'Rusa'),
('Ernest', 'Hemingway', 'Estadounidense'),
('Mary', 'Shelley', 'Británica'),
('Franz', 'Kafka', 'Alemana'),
('Victor', 'Hugo', 'Francesa'),
('Emily', 'Bronte', 'Británica'),
('Leo', 'Tolstói', 'Rusa'),
('Umberto', 'Eco', 'Italiana'),
('Oscar', 'Wilde', 'Irlandesa'),
('Carlos', 'Fuentes', 'Mexicana'),
('Mario', 'Vargas Llosa', 'Peruana'),
('Bram', 'Stoker', 'Irlandesa'),
('Arthur', 'Conan Doyle', 'Británica'),
('Aldous', 'Huxley', 'Británica'),
('J.D.', 'Salinger', 'Estadounidense'),
('H.G.', 'Wells', 'Británica'),
('Edgar', 'Allan Poe', 'Estadounidense'),
('Virginia', 'Woolf', 'Británica'),
('Philip', 'K. Dick', 'Estadounidense');

-- Insertar Libros
INSERT INTO Libro (titulo, editorial, idAutor, precio, stock) VALUES 
('Cien años de soledad', 'Sudamericana', 1, 1500.00, 20),
('Harry Potter y la piedra filosofal', 'Bloomsbury', 2, 1200.00, 15),
('1984', 'Secker & Warburg', 3, 1100.00, 30),
('La casa de los espíritus', 'Plaza & Janés', 4, 1400.00, 25),
('Rayuela', 'Sudamericana', 5, 1350.00, 10),
('Kafka en la orilla', 'Tusquets', 6, 1250.00, 18),
('It', 'Viking', 7, 1600.00, 12),
('El señor de los anillos', 'Allen & Unwin', 8, 1700.00, 22),
('Orgullo y prejuicio', 'T. Egerton', 9, 1000.00, 27),
('Don Quijote de la Mancha', 'Francisco de Robles', 10, 1800.00, 9),
('Las aventuras de Tom Sawyer', 'American Publishing Company', 11, 900.00, 19),
('Crimen y castigo', 'Rusia', 12, 1450.00, 17),
('El viejo y el mar', 'Charles Scribner’s Sons', 13, 950.00, 14),
('Frankenstein', 'Lackington, Hughes, Harding, Mavor & Jones', 14, 1150.00, 20),
('La metamorfosis', 'Kurt Wolff Verlag', 15, 1300.00, 8),
('Los miserables', 'A. Lacroix, Verboeckhoven & Cie', 16, 1600.00, 12),
('Cumbres Borrascosas', 'Thomas Cautley Newby', 17, 1000.00, 15),
('Guerra y Paz', 'Rusia', 18, 1750.00, 10),
('El nombre de la rosa', 'Bompiani', 19, 1400.00, 18),
('El retrato de Dorian Gray', 'Ward, Lock & Co.', 20, 1250.00, 13),
('La región más transparente', 'Fondo de Cultura Económica', 21, 1350.00, 9),
('La ciudad y los perros', 'Seix Barral', 22, 1250.00, 11),
('Drácula', 'Archibald Constable and Company', 23, 1550.00, 14),
('Sherlock Holmes: Estudio en escarlata', 'Ward, Lock & Co.', 24, 1450.00, 16),
('Un mundo feliz', 'Chatto & Windus', 25, 1200.00, 20),
('El guardián entre el centeno', 'Little, Brown and Company', 26, 1300.00, 18),
('La guerra de los mundos', 'Heinemann', 27, 1100.00, 12),
('Narraciones extraordinarias', 'Graham’s Magazine', 28, 1350.00, 15),
('Al faro', 'Hogarth Press', 29, 1250.00, 17),
('Sueñan los androides con ovejas eléctricas?', 'Doubleday', 30, 1400.00, 11);


-- Insertar Clientes
INSERT INTO Cliente (nombre, apellido, correo) VALUES 
('Juan', 'Pérez', 'juanperez@gmail.com'),
('María', 'Gómez', 'mariagomez@gmail.com'),
('Carlos', 'López', 'carloslopez@hotmail.com'),
('Ana', 'Martínez', 'anamartinez@yahoo.com'),
('Diego', 'Rodríguez', 'diegorodriguez@gmail.com'),
('Laura', 'Fernández', 'laurafernandez@gmail.com'),
('Pedro', 'Sánchez', 'pedrosanchez@gmail.com'),
('Sofía', 'Torres', 'sofiatorres@gmail.com'),
('Fernando', 'García', 'fernandogarcia@gmail.com'),
('Valentina', 'Ramírez', 'valentinaramirez@gmail.com'),
('Luis', 'Ortiz', 'luisortiz@hotmail.com'),
('Camila', 'Vega', 'camilavega@gmail.com'),
('Roberto', 'Herrera', 'robertoherrera@yahoo.com'),
('Marta', 'Castro', 'martacastro@gmail.com'),
('Javier', 'Mendoza', 'javiermendoza@hotmail.com'),
('Paula', 'Silva', 'paulasilva@gmail.com'),
('Héctor', 'Jiménez', 'hectorjimenez@gmail.com'),
('Verónica', 'Díaz', 'veronicadiaz@yahoo.com'),
('Andrés', 'Morales', 'andresmorales@gmail.com'),
('Natalia', 'Ríos', 'nataliarios@hotmail.com'),
('Ricardo', 'Paredes', 'ricardoparedes@gmail.com'),
('Esteban', 'Suárez', 'estebansuarez@yahoo.com'),
('Clara', 'Reyes', 'clarareyes@gmail.com'),
('Francisco', 'Navarro', 'francisconavarro@hotmail.com'),
('Elena', 'Ruiz', 'elenaruiz@gmail.com'),
('Sebastián', 'Lara', 'sebastianlara@yahoo.com'),
('Alejandro', 'Vargas', 'alejandrovargas@gmail.com'),
('Gabriela', 'Acosta', 'gabrielaacosta@hotmail.com'),
('Tomás', 'Núñez', 'tomasnunez@gmail.com'),
('Daniela', 'Cabrera', 'danielacabrera@yahoo.com');

-- Insertar Ventas
INSERT INTO Venta (idCliente) VALUES 
(1), (2), (3), (4), (5), (6), (7), (8), (9), (10),
(11), (12), (13), (14), (15), (16), (17), (18), (19), (20),
(21), (22), (23), (24), (25), (26), (27), (28), (29), (30);

-- Insertar Detalles de Venta
CALL AgregarDetalleVenta(1, 1, 2);  -- Cliente 1 compra 2 libros de 'Cien años de soledad'
CALL AgregarDetalleVenta(2, 2, 1);  -- Cliente 2 compra 1 libro de 'Harry Potter'
CALL AgregarDetalleVenta(3, 3, 3);  -- Cliente 3 compra 3 libros de '1984'
CALL AgregarDetalleVenta(4, 4, 1);  -- Cliente 4 compra 1 libro de 'La casa de los espíritus'
CALL AgregarDetalleVenta(5, 5, 2);  -- Cliente 5 compra 2 libros de 'Rayuela'
CALL AgregarDetalleVenta(6, 6, 1);  -- Cliente 6 compra 1 libro de 'Kafka en la orilla'
CALL AgregarDetalleVenta(7, 7, 1);  -- Cliente 7 compra 1 libro de 'It'
CALL AgregarDetalleVenta(8, 8, 2);  -- Cliente 8 compra 2 libros de 'El señor de los anillos'
CALL AgregarDetalleVenta(9, 9, 1);  -- Cliente 9 compra 1 libro de 'Orgullo y prejuicio'
CALL AgregarDetalleVenta(10, 10, 1); -- Cliente 10 compra 1 libro de 'Don Quijote de la Mancha'
CALL AgregarDetalleVenta(11, 11, 2);  -- Cliente 11 compra 2 libros de 'Las aventuras de Tom Sawyer'
CALL AgregarDetalleVenta(12, 12, 1);  -- Cliente 12 compra 1 libro de 'Crimen y castigo'
CALL AgregarDetalleVenta(13, 13, 1);  -- Cliente 13 compra 1 libro de 'El viejo y el mar'
CALL AgregarDetalleVenta(14, 14, 3);  -- Cliente 14 compra 3 libros de 'Frankenstein'
CALL AgregarDetalleVenta(15, 15, 1);  -- Cliente 15 compra 1 libro de 'La metamorfosis'
CALL AgregarDetalleVenta(16, 16, 2);  -- Cliente 16 compra 2 libros de 'Los miserables'
CALL AgregarDetalleVenta(17, 17, 1);  -- Cliente 17 compra 1 libro de 'Cumbres Borrascosas'
CALL AgregarDetalleVenta(18, 18, 1);  -- Cliente 18 compra 1 libro de 'Guerra y Paz'
CALL AgregarDetalleVenta(19, 19, 2);  -- Cliente 19 compra 2 libros de 'El nombre de la rosa'
CALL AgregarDetalleVenta(20, 20, 1);  -- Cliente 20 compra 1 libro de 'El retrato de Dorian Gray'
CALL AgregarDetalleVenta(21, 21, 1);  -- Cliente 21 compra 1 libro de 'La región más transparente'
CALL AgregarDetalleVenta(22, 22, 1);  -- Cliente 22 compra 1 libro de 'La ciudad y los perros'
CALL AgregarDetalleVenta(23, 23, 1);  -- Cliente 23 compra 1 libro de 'Drácula'
CALL AgregarDetalleVenta(24, 24, 3);  -- Cliente 24 compra 3 libros de 'Sherlock Holmes: Estudio en escarlata'
CALL AgregarDetalleVenta(25, 25, 2);  -- Cliente 25 compra 2 libros de 'Un mundo feliz'
CALL AgregarDetalleVenta(26, 26, 2);  -- Cliente 26 compra 2 libros de 'El guardián entre el centeno'
CALL AgregarDetalleVenta(27, 27, 1);  -- Cliente 27 compra 1 libro de 'La guerra de los mundos'
CALL AgregarDetalleVenta(28, 28, 2);  -- Cliente 28 compra 2 libros de 'Narraciones extraordinarias'
CALL AgregarDetalleVenta(29, 29, 1);  -- Cliente 29 compra 1 libro de 'Al faro'
CALL AgregarDetalleVenta(30, 30, 1);  -- Cliente 30 compra 1 libro de 'Sueñan los androides con ovejas eléctricas?'


