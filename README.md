# 📚 Librería — Base de Datos Relacional

Este proyecto consiste en el diseño e implementación de una **base de datos relacional para una librería**, junto con procedimientos, funciones, vistas y triggers que automatizan y facilitan la gestión de inventario, ventas y clientes.  

Incluye el script SQL para crear y poblar la base de datos, y una memoria técnica en PDF con la explicación detallada del sistema.

---

## 🎯 Objetivo

Diseñar una base de datos para una librería que permita:
- Gestionar de manera eficiente los libros, autores, clientes y ventas.
- Mantener registros claros y actualizados sobre el inventario disponible.
- Automatizar cálculos, validaciones y actualizaciones mediante procedimientos almacenados, funciones y triggers.
- Facilitar la generación de reportes y análisis de datos para mejorar la toma de decisiones.

---

## 🗃️ Contenido del repositorio

- `codigo_libreria.sql`: script SQL con la creación de tablas, vistas, funciones, procedimientos y triggers.
- `Libreria.pdf`: memoria técnica explicando el diseño y la implementación.
- `modelo_er.png`: modelo entidad-relación diseñado en MySQL Workbench.
- `README.md`: este archivo de documentación.

---

## 📝 Descripción técnica

### 📦 Tablas principales
- `Autor`: registra los autores y su nacionalidad.
- `Libro`: información de los libros, precios, stock y su autor.
- `Cliente`: datos básicos de los clientes.
- `Venta`: cabecera de cada venta realizada.
- `DetalleVenta`: detalle de los libros vendidos por cada venta.

### 🔷 Vistas
- **VistaLibrosDisponibles**: muestra libros disponibles con autor y precio.
- **VistaVentasClientes**: muestra historial de ventas con datos del cliente.

### 🧮 Funciones
- `CalcularTotalVenta(id_venta)`: calcula el total de una venta.
- `StockDisponible(id_libro)`: devuelve el stock disponible de un libro.

### ⚙️ Procedimientos almacenados
- `RegistrarVenta(id_cliente, OUT nuevo_id)`: crea una venta y devuelve su ID.
- `AgregarDetalleVenta(id_venta, id_libro, cantidad)`: agrega un detalle de venta verificando stock.

### 🔗 Triggers
- Calculan automáticamente el total de un detalle de venta.
- Verifican disponibilidad de stock antes de registrar una venta.
- Actualizan stock correctamente al eliminar un detalle de venta.

---

## 🖼️ Modelo entidad-relación

El modelo refleja las relaciones entre las entidades:  
- `Autor (1:N Libro)`  
- `Cliente (1:N Venta)`  
- `Venta (1:N DetalleVenta)`  
- `Libro (1:N DetalleVenta)`  

El diagrama completo está en el archivo `Libreria.pdf`.

---

## 🚀 Cómo usarlo

1. Abrí MySQL Workbench o tu gestor de base de datos.
2. Ejecutá el script `Libreria + Proyecto_Final_D'Ercole.sql` para crear la base de datos y todas sus funcionalidades.
3. Podés consultar las vistas, llamar las funciones y procedimientos, y verificar el funcionamiento de los triggers según la documentación.

---

## 📄 Documentación

Para más detalles sobre el diseño, objetivos y funcionalidades, consultá el archivo `Libreria.pdf` incluido en este repositorio.

---

## 📬 Contacto

Si tenés dudas o sugerencias, podés contactarme a través de [LinkedIn](https://www.linkedin.com/in/maria-victoria-dercole/).

---

