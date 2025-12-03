-- ==========================================================
-- PROYECTO BÓREAS - SCRIPT BASE DE DATOS FINAL (CORREGIDO)
-- ==========================================================

DROP DATABASE IF EXISTS gestor_incidencias_db;
CREATE DATABASE gestor_incidencias_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE gestor_incidencias_db;

-- ----------------------------------------------------------
-- 1. GESTIÓN DE ROLES Y PERMISOS (Para el Super Admin)
-- ----------------------------------------------------------
CREATE TABLE roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) UNIQUE NOT NULL, -- Ej: 'SUPER_ADMIN', 'GESTOR', 'CLIENTE_WEB'
    descripcion VARCHAR(100)
);

-- Insertamos los roles base mencionados en 
INSERT INTO roles (nombre_rol, descripcion) VALUES 
('SUPER_ADMIN', 'Acceso total y gestión de usuarios'),
('ADMINISTRADOR', 'Gestión operativa, no crea admins'),
('GESTOR_INCIDENCIAS', 'Resuelve incidencias'),
('ATENCION_CLIENTE', 'Solo visualiza incidencias');

-- ----------------------------------------------------------
-- 2. USUARIOS INTERNOS (Staff de la Lavandería)
-- Referencia: 
-- ----------------------------------------------------------
CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    codigo_usuario VARCHAR(20) UNIQUE NOT NULL, -- El código visible 
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(100),
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,             -- Contraseña encriptada
    foto_perfil VARCHAR(255),
    
    rol_id INT NOT NULL,
    activo BOOLEAN DEFAULT TRUE,                -- 
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (rol_id) REFERENCES roles(id_rol)
);

-- ----------------------------------------------------------
-- 3. CLIENTES (Establecimientos)
-- Referencia: 
-- ----------------------------------------------------------
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    codigo_cliente VARCHAR(20) UNIQUE NOT NULL, -- 
    
    -- Datos Empresa
    nombre_establecimiento VARCHAR(100) NOT NULL,
    cadena_hotelera VARCHAR(100),               -- 
    sociedad VARCHAR(100),                      -- 
    cif_nif VARCHAR(20) NOT NULL,               -- 
    
    -- Dirección 
    direccion VARCHAR(255), 
    poblacion VARCHAR(50),
    codigo_postal VARCHAR(10),

    -- Acceso Web 
    nombre_usuario VARCHAR(50) UNIQUE NOT NULL, 
    password VARCHAR(255) NOT NULL,
    email_contacto VARCHAR(100) NOT NULL,
    foto_perfil VARCHAR(255),                   -- 
    
    -- Gestión
    notas TEXT,                                 -- 
    activo BOOLEAN DEFAULT TRUE,                -- 
    visible BOOLEAN DEFAULT TRUE,               -- Visibilidad Super Admin
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------
-- 4. MAESTROS (Tipos de Incidencia)
-- Referencia: 
-- ----------------------------------------------------------
CREATE TABLE tipos_incidencia (
    id_tipo INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    es_personalizado BOOLEAN DEFAULT FALSE -- Para permitir "Añadir otro"
);

INSERT INTO tipos_incidencia (nombre) VALUES ('Rotura'), ('Mancha'), ('Pérdida'), ('Re-lavado');

-- ----------------------------------------------------------
-- 5. INCIDENCIAS (Tabla Principal)
-- Referencia: y 
-- ----------------------------------------------------------
CREATE TABLE incidencias (
    id_incidencia INT AUTO_INCREMENT PRIMARY KEY,
    
    -- Código visual formato "2025-0001" 
    -- NOTA: Este código se genera por software, aquí lo guardamos como texto único.
    codigo_visual VARCHAR(20) UNIQUE NOT NULL, 

    -- Relaciones
    cliente_id INT NOT NULL,
    tipo_id INT NOT NULL,
    usuario_asignado_id INT,                    -- Gestor asignado por el Super Admin 

    -- Datos del Formulario
    nombre_creador VARCHAR(100) NOT NULL,       -- 
    telefono_contacto VARCHAR(20),              -- 
    titulo VARCHAR(20) NOT NULL,                -- Limitado a 20 caracteres 
    descripcion TEXT NOT NULL,                  -- 
    fecha_ocurrencia DATE NOT NULL,             -- 
    
    -- Datos Numéricos requeridos en INT 
    numero_albaran INT,                         -- Cambiado a INT según requisito

    -- Estado y Tiempos
    estado ENUM('ABIERTA', 'ASIGNADA', 'CERRADA') DEFAULT 'ABIERTA', -- 
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_ultima_modificacion DATETIME ON UPDATE CURRENT_TIMESTAMP, -- 
    fecha_cierre DATETIME,

    FOREIGN KEY (cliente_id) REFERENCES clientes(id_cliente),
    FOREIGN KEY (tipo_id) REFERENCES tipos_incidencia(id_tipo),
    FOREIGN KEY (usuario_asignado_id) REFERENCES usuarios(id_usuario)
);

-- ----------------------------------------------------------
-- 6. ETIQUETAS DE INCIDENCIA (1 a N)
-- Referencia: "Puede haber más de una"
-- ----------------------------------------------------------
CREATE TABLE incidencia_etiquetas (
    id_etiqueta INT AUTO_INCREMENT PRIMARY KEY,
    incidencia_id INT NOT NULL,
    numero_etiqueta INT NOT NULL,               -- Cambiado a INT según requisito

    FOREIGN KEY (incidencia_id) REFERENCES incidencias(id_incidencia) ON DELETE CASCADE
);

-- ----------------------------------------------------------
-- 7. ADJUNTOS (FOTOS/VIDEOS) (1 a N)
-- Referencia: 
-- CORRECCIÓN IMPORTANTE: Tabla separada para permitir múltiples archivos
-- ----------------------------------------------------------
CREATE TABLE incidencia_adjuntos (
    id_adjunto INT AUTO_INCREMENT PRIMARY KEY,
    incidencia_id INT NOT NULL,
    url_archivo VARCHAR(255) NOT NULL,
    tipo_archivo ENUM('IMAGEN', 'VIDEO', 'DOCUMENTO'),
    fecha_subida DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (incidencia_id) REFERENCES incidencias(id_incidencia) ON DELETE CASCADE
);

-- ----------------------------------------------------------
-- 8. MENSAJES / CHAT (Historial)
-- Referencia: 
-- ----------------------------------------------------------
CREATE TABLE incidencia_mensajes (
    id_mensaje INT AUTO_INCREMENT PRIMARY KEY,
    incidencia_id INT NOT NULL,
    
    -- Autor del mensaje (Puede ser Cliente o Lavandería)
    origen ENUM('CLIENTE', 'LAVANDERIA') NOT NULL, -- 
    id_autor INT, -- Guardamos el ID del usuario o cliente que escribió
    nombre_autor_visual VARCHAR(100), -- Para mostrar rápido "Juan (Lavandería)"
    
    mensaje TEXT NOT NULL,
    fecha_mensaje DATETIME DEFAULT CURRENT_TIMESTAMP, -- 

    FOREIGN KEY (incidencia_id) REFERENCES incidencias(id_incidencia) ON DELETE CASCADE
);