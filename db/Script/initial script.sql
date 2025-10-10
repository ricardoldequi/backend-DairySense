-- Database: Dados

-- DROP DATABASE IF EXISTS "Dados";

/*CREATE DATABASE "Dados"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'pt_BR.UTF-8'
    LC_CTYPE = 'pt_BR.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

*/
-- Usuaios
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_digest TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Raças
CREATE TABLE breeds (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Animais
CREATE TABLE animals (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE, -- id do usuário
    name VARCHAR(50),
    breed_id BIGINT REFERENCES breeds(id) ON DELETE SET NULL, -- id da raça
    age INT, 
	earring INT, --brinco
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Colares
CREATE TABLE devices (
    id BIGSERIAL PRIMARY KEY,
    serial_number VARCHAR(10) UNIQUE NOT NULL,
	api_key VARCHAR(36) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Relação entre dispositivos e animais
CREATE TABLE device_animals (
    id BIGSERIAL PRIMARY KEY,
    device_id BIGINT REFERENCES devices(id) ON DELETE CASCADE,
    animal_id BIGINT REFERENCES animals(id) ON DELETE CASCADE,
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- evita duplicar o mesmo colar para a mesma vaca na mesma data
    CONSTRAINT unique_device_animal_period UNIQUE (device_id, animal_id, start_date)
);

-- Leituras das sensores
CREATE TABLE readings (
    id BIGSERIAL PRIMARY KEY,
    device_id BIGINT REFERENCES devices(id) ON DELETE CASCADE,
    animal_id BIGINT REFERENCES animals(id) ON DELETE CASCADE,
    temperature NUMERIC(5,2),
    sleep_time NUMERIC(5,2), 
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6),
	accel_x NUMERIC(7,4),                
    accel_y NUMERIC(7,2),                
    accel_z NUMERIC(7,2),        
    collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- baseline de atividade
CREATE TABLE activity_baselines (
  id BIGSERIAL PRIMARY KEY,
  animal_id BIGINT NOT NULL,
  hour_of_day INT NOT NULL,
  baseline_enmo FLOAT NOT NULL,
  mad_enmo NUMERIC(10,6) NOT NULL DEFAULT 0.0;
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (animal_id) REFERENCES animals(id)
);

-- tabela de Alertas 

CREATE TABLE alerts (
  id BIGSERIAL PRIMARY KEY,
  device_animal_id BIGINT NOT NULL REFERENCES device_animals(id) ON DELETE CASCADE,
  alert_type VARCHAR NOT NULL,
  detected_at TIMESTAMP NOT NULL,
  z_score DOUBLE PRECISION,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para otimizar consultas
CREATE INDEX index_activity_baselines_on_animal_id ON activity_baselines (animal_id);
CREATE UNIQUE INDEX idx_baseline_animal_hour_period ON activity_baselines (animal_id, hour_of_day, period_start, period_end);
CREATE INDEX index_alerts_on_device_animal_id ON public.alerts (device_animal_id);
CREATE INDEX index_alerts_on_detected_at ON public.alerts (detected_at);

-- Inclusão das Raças
INSERT INTO breeds (name) VALUES
('Holandesa'),
('Jersey'),
('Girolando'),
('Gir'),
('Nelore'),
('Pardo-Suíço'),
('Guzerá'),
('Guzolando'),
('Sindi'),
('Guernsey'),
('Ayrshire');

-- Inclusão de Animais
INSERT INTO animals (name, breed_id, age, earring) VALUES
('Mansinha',1, 3, 12 ),
('Xuxa',1, 7, 145 );

--Inclusão de Colares
INSERT INTO Devices (serial_number, api_key) VALUES
('DS0001', '58567df6-233b-4607-971f-d80b6ca927a2');

-- Inclusão de Usuário Admin
INSERT INTO users (name, email, password_digest)VALUES
 ('admin','ricardo.dequi02@gmail.com','$2a$12$7GyylJ.xYbfIAStF6tTnSumoTk6U4Pg0UsOpViO3JN58OWvlHpDIm');