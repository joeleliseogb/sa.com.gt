SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO gtcop.departamento (nombre) VALUES ('Chimaltenango') ON DUPLICATE KEY UPDATE nombre = 'Chimaltenango';
INSERT INTO gtcop.departamento (nombre) VALUES ('Chiquimula') ON DUPLICATE KEY UPDATE nombre = 'Chiquimula';
INSERT INTO gtcop.departamento (nombre) VALUES ('Escuintla') ON DUPLICATE KEY UPDATE nombre = 'Escuintla';
INSERT INTO gtcop.departamento (nombre) VALUES ('Izabal') ON DUPLICATE KEY UPDATE nombre = 'Izabal';
INSERT INTO gtcop.departamento (nombre) VALUES ('Sacatepéquez') ON DUPLICATE KEY UPDATE nombre = 'Sacatepéquez';
INSERT INTO gtcop.departamento (nombre) VALUES ('Sololá') ON DUPLICATE KEY UPDATE nombre = 'Sololá';
INSERT INTO gtcop.departamento (nombre) VALUES ('Retalhuleu') ON DUPLICATE KEY UPDATE nombre = 'Retalhuleu';
INSERT INTO gtcop.departamento (nombre) VALUES ('Baja Verapaz') ON DUPLICATE KEY UPDATE nombre = 'Baja Verapaz';
INSERT INTO gtcop.departamento (nombre) VALUES ('Jalapa') ON DUPLICATE KEY UPDATE nombre = 'Jalapa';
INSERT INTO gtcop.departamento (nombre) VALUES ('Jutiapa') ON DUPLICATE KEY UPDATE nombre = 'Jutiapa';
INSERT INTO gtcop.departamento (nombre) VALUES ('Quiché') ON DUPLICATE KEY UPDATE nombre = 'Quiché';
INSERT INTO gtcop.departamento (nombre) VALUES ('Huehuetenango') ON DUPLICATE KEY UPDATE nombre = 'Huehuetenango';
INSERT INTO gtcop.departamento (nombre) VALUES ('Zacapa') ON DUPLICATE KEY UPDATE nombre = 'Zacapa';
INSERT INTO gtcop.departamento (nombre) VALUES ('Santa Rosa') ON DUPLICATE KEY UPDATE nombre = 'Santa Rosa';
INSERT INTO gtcop.departamento (nombre) VALUES ('Quetzaltenango') ON DUPLICATE KEY UPDATE nombre = 'Quetzaltenango';
INSERT INTO gtcop.departamento (nombre) VALUES ('Totonicapán') ON DUPLICATE KEY UPDATE nombre = 'Totonicapán';
INSERT INTO gtcop.departamento (nombre) VALUES ('Guatemala') ON DUPLICATE KEY UPDATE nombre = 'Guatemala';
INSERT INTO gtcop.departamento (nombre) VALUES ('El Progreso') ON DUPLICATE KEY UPDATE nombre = 'El Progreso';
INSERT INTO gtcop.departamento (nombre) VALUES ('Alta Verapaz') ON DUPLICATE KEY UPDATE nombre = 'Alta Verapaz';
INSERT INTO gtcop.departamento (nombre) VALUES ('Suchitepéquez') ON DUPLICATE KEY UPDATE nombre = 'Suchitepéquez';
INSERT INTO gtcop.departamento (nombre) VALUES ('Petén') ON DUPLICATE KEY UPDATE nombre = 'Petén';
INSERT INTO gtcop.departamento (nombre) VALUES ('San Marcos') ON DUPLICATE KEY UPDATE nombre = 'San Marcos';
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Chimaltenango', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chimaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Chimaltenango') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San José Poaquil', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chimaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San José Poaquil') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Martín Jilotepeque', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chimaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Martín Jilotepeque') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Juan Comalapa', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chimaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Juan Comalapa') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Apolonia', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chimaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Apolonia') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Tecpán Guatemala', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chimaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Tecpán Guatemala') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Patzún', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chimaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Patzún') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Pochuta', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chimaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Pochuta') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Patzicía', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chimaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Patzicía') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Cruz Balanyá', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chimaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Cruz Balanyá') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Acatenango', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chimaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Acatenango') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Yepocapa', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chimaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Yepocapa') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Andrés Itzapa', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chimaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Andrés Itzapa') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Parramos', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chimaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Parramos') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Zaragoza', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chimaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Zaragoza') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'El Tejar', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chimaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('El Tejar') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Chiquimula', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chiquimula'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Chiquimula') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San José La Arada', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chiquimula'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San José La Arada') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Juan Ermita', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chiquimula'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Juan Ermita') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Jocotán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chiquimula'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Jocotán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Camotán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chiquimula'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Camotán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Olopa', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chiquimula'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Olopa') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Esquipulas', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chiquimula'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Esquipulas') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Concepción Las Minas', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chiquimula'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Concepción Las Minas') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Quetzaltepeque', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chiquimula'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Quetzaltepeque') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Jacinto', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chiquimula'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Jacinto') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Ipala', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Chiquimula'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Ipala') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Escuintla', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Escuintla'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Escuintla') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Lucía Cotzumalguapa', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Escuintla'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Lucía Cotzumalguapa') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'La Democracia', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Escuintla'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('La Democracia') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Siquinalá', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Escuintla'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Siquinalá') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Masagua', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Escuintla'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Masagua') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Tiquisate', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Escuintla'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Tiquisate') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'La Gomera', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Escuintla'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('La Gomera') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Guanagazapa', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Escuintla'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Guanagazapa') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San José', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Escuintla'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San José') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Iztapa', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Escuintla'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Iztapa') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Palín', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Escuintla'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Palín') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Vicente Pacaya', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Escuintla'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Vicente Pacaya') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Nueva Concepción', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Escuintla'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Nueva Concepción') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Sipacate', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Escuintla'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Sipacate') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Puerto Barrios', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Izabal'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Puerto Barrios') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Livingston', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Izabal'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Livingston') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'El Estor', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Izabal'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('El Estor') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Morales', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Izabal'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Morales') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Los Amates', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Izabal'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Los Amates') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Antigua Guatemala', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sacatepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Antigua Guatemala') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Jocotenango', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sacatepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Jocotenango') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Pastores', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sacatepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Pastores') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Sumpango', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sacatepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Sumpango') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santo Domingo Xenacoj', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sacatepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santo Domingo Xenacoj') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santiago Sacatepéquez', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sacatepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santiago Sacatepéquez') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Bartolomé Milpas Altas', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sacatepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Bartolomé Milpas Altas') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Lucas Sacatepéquez', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sacatepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Lucas Sacatepéquez') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Lucía Milpas Altas', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sacatepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Lucía Milpas Altas') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Magdalena Milpas Altas', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sacatepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Magdalena Milpas Altas') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa María de Jesús', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sacatepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa María de Jesús') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Ciudad Vieja', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sacatepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Ciudad Vieja') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Miguel Dueñas', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sacatepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Miguel Dueñas') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Alotenango', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sacatepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Alotenango') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Antonio Aguas Calientes', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sacatepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Antonio Aguas Calientes') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Catarina Barahona', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sacatepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Catarina Barahona') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Sololá', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sololá'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Sololá') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San José Chacayá', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sololá'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San José Chacayá') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa María Visitación', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sololá'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa María Visitación') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Lucía Utatlán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sololá'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Lucía Utatlán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Nahualá', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sololá'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Nahualá') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Catarina Ixtahuacán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sololá'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Catarina Ixtahuacán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Clara La Laguna', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sololá'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Clara La Laguna') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Concepción', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sololá'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Concepción') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Andrés Semetabaj', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sololá'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Andrés Semetabaj') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Panajachel', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sololá'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Panajachel') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Catarina Palopó', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sololá'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Catarina Palopó') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Antonio Palopó', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sololá'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Antonio Palopó') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Lucas Tolimán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sololá'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Lucas Tolimán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Cruz La Laguna', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sololá'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Cruz La Laguna') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Pablo La Laguna', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sololá'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Pablo La Laguna') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Marcos La Laguna', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sololá'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Marcos La Laguna') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Juan La Laguna', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sololá'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Juan La Laguna') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Pedro La Laguna', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sololá'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Pedro La Laguna') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santiago Atitlán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Sololá'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santiago Atitlán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Retalhuleu', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Retalhuleu'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Retalhuleu') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Sebastián', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Retalhuleu'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Sebastián') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Cruz Muluá', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Retalhuleu'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Cruz Muluá') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Martín Zapotitlán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Retalhuleu'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Martín Zapotitlán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Felipe', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Retalhuleu'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Felipe') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Andrés Villa Seca', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Retalhuleu'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Andrés Villa Seca') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Champerico', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Retalhuleu'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Champerico') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Nuevo San Carlos', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Retalhuleu'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Nuevo San Carlos') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'El Asintal', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Retalhuleu'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('El Asintal') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Salamá', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Baja Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Salamá') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Miguel Chicaj', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Baja Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Miguel Chicaj') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Rabinal', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Baja Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Rabinal') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Cubulco', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Baja Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Cubulco') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Granados', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Baja Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Granados') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Cruz El Chol', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Baja Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Cruz El Chol') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Jerónimo', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Baja Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Jerónimo') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Purulhá', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Baja Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Purulhá') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Jalapa', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jalapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Jalapa') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Pedro Pinula', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jalapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Pedro Pinula') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Luis Jilotepeque', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jalapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Luis Jilotepeque') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Manuel Chaparrón', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jalapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Manuel Chaparrón') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Carlos Alzatate', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jalapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Carlos Alzatate') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Monjas', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jalapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Monjas') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Mataquescuintla', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jalapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Mataquescuintla') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Jutiapa', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jutiapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Jutiapa') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'El Progreso', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jutiapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('El Progreso') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Catarina Mita', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jutiapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Catarina Mita') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Agua Blanca', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jutiapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Agua Blanca') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Asunción Mita', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jutiapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Asunción Mita') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Yupiltepeque', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jutiapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Yupiltepeque') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Atescatempa', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jutiapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Atescatempa') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Jerez', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jutiapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Jerez') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'El Adelanto', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jutiapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('El Adelanto') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Zapotitlán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jutiapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Zapotitlán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Comapa', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jutiapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Comapa') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Jalpatagua', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jutiapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Jalpatagua') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Conguaco', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jutiapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Conguaco') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Moyuta', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jutiapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Moyuta') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Pasaco', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jutiapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Pasaco') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San José Acatempa', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jutiapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San José Acatempa') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Quesada', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Jutiapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Quesada') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Cruz del Quiché', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Cruz del Quiché') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Chiché', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Chiché') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Chinique', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Chinique') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Zacualpa', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Zacualpa') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Chajul', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Chajul') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santo Tomás Chichicastenango', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santo Tomás Chichicastenango') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Patzité', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Patzité') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Antonio Ilotenango', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Antonio Ilotenango') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Pedro Jocopilas', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Pedro Jocopilas') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Cunén', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Cunén') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Juan Cotzal', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Juan Cotzal') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Joyabaj', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Joyabaj') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa María Nebaj', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa María Nebaj') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Andrés Sajcabajá', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Andrés Sajcabajá') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Miguel Uspantán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Miguel Uspantán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Sacapulas', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Sacapulas') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Bartolomé Jocotenango', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Bartolomé Jocotenango') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Canillá', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Canillá') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Chicamán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Chicamán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Ixcán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Ixcán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Pachalum', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quiché'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Pachalum') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Huehuetenango', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Huehuetenango') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Chiantla', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Chiantla') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Malacatancito', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Malacatancito') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Cuilco', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Cuilco') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Nentón', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Nentón') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Pedro Necta', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Pedro Necta') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Jacaltenango', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Jacaltenango') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Pedro Soloma', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Pedro Soloma') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Ildefonso Ixtahuacán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Ildefonso Ixtahuacán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Bárbara', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Bárbara') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'La Libertad', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('La Libertad') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'La Democracia', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('La Democracia') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Miguel Acatán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Miguel Acatán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Rafael La Independencia', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Rafael La Independencia') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Todos Santos Cuchumatán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Todos Santos Cuchumatán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Juan Atitán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Juan Atitán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Eulalia', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Eulalia') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Mateo Ixtatán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Mateo Ixtatán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Colotenango', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Colotenango') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Sebastián Huehuetenango', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Sebastián Huehuetenango') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Tectitán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Tectitán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Concepción Huista', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Concepción Huista') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Juan Ixcoy', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Juan Ixcoy') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Antonio Huista', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Antonio Huista') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Sebastián Coatán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Sebastián Coatán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Cruz Barillas', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Cruz Barillas') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Aguacatán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Aguacatán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Rafael Petzal', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Rafael Petzal') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Gaspar Ixchil', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Gaspar Ixchil') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santiago Chimaltenango', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santiago Chimaltenango') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Ana Huista', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Ana Huista') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Unión Cantinil', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Unión Cantinil') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Petatán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Huehuetenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Petatán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Zacapa', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Zacapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Zacapa') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Estanzuela', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Zacapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Estanzuela') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Río Hondo', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Zacapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Río Hondo') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Gualán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Zacapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Gualán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Teculután', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Zacapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Teculután') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Usumatlán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Zacapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Usumatlán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Cabañas', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Zacapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Cabañas') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Diego', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Zacapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Diego') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'La Unión', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Zacapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('La Unión') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Huité', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Zacapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Huité') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Jorge', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Zacapa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Jorge') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Cuilapa', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Santa Rosa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Cuilapa') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Barberena', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Santa Rosa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Barberena') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Rosa de Lima', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Santa Rosa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Rosa de Lima') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Casillas', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Santa Rosa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Casillas') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Rafael Las Flores', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Santa Rosa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Rafael Las Flores') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Oratorio', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Santa Rosa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Oratorio') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Juan Tecuaco', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Santa Rosa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Juan Tecuaco') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Chiquimulilla', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Santa Rosa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Chiquimulilla') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Taxisco', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Santa Rosa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Taxisco') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa María Ixhuatán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Santa Rosa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa María Ixhuatán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Guazacapán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Santa Rosa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Guazacapán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Cruz Naranjo', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Santa Rosa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Cruz Naranjo') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Pueblo Nuevo Viñas', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Santa Rosa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Pueblo Nuevo Viñas') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Nueva Santa Rosa', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Santa Rosa'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Nueva Santa Rosa') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Quetzaltenango', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Quetzaltenango') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Salcajá', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Salcajá') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Olintepeque', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Olintepeque') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Carlos Sija', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Carlos Sija') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Sibilia', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Sibilia') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Cabricán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Cabricán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Huitán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Huitán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Miguel Sigüilá', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Miguel Sigüilá') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Juan Ostuncalco', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Juan Ostuncalco') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Mateo', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Mateo') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Concepción Chiquirichapa', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Concepción Chiquirichapa') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Martín Sacatepéquez', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Martín Sacatepéquez') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Almolonga', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Almolonga') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Cantel', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Cantel') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Zunil', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Zunil') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Colomba Costa Cuca', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Colomba Costa Cuca') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Francisco La Unión', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Francisco La Unión') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'El Palmar', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('El Palmar') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Coatepeque', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Coatepeque') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Génova', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Génova') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Flores Costa Cuca', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Flores Costa Cuca') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'La Esperanza', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('La Esperanza') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Palestina de Los Altos', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Quetzaltenango'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Palestina de Los Altos') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Totonicapán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Totonicapán'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Totonicapán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Cristóbal Totonicapán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Totonicapán'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Cristóbal Totonicapán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Francisco El Alto', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Totonicapán'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Francisco El Alto') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Andrés Xecul', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Totonicapán'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Andrés Xecul') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Momostenango', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Totonicapán'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Momostenango') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa María Chiquimula', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Totonicapán'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa María Chiquimula') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Lucía La Reforma', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Totonicapán'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Lucía La Reforma') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Bartolo Aguas Calientes', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Totonicapán'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Bartolo Aguas Calientes') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Guatemala', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Guatemala'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Guatemala') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Catarina Pinula', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Guatemala'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Catarina Pinula') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San José Pinula', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Guatemala'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San José Pinula') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San José del Golfo', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Guatemala'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San José del Golfo') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Palencia', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Guatemala'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Palencia') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Chinautla', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Guatemala'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Chinautla') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Pedro Ayampuc', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Guatemala'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Pedro Ayampuc') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Mixco', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Guatemala'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Mixco') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Pedro Sacatepéquez', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Guatemala'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Pedro Sacatepéquez') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Juan Sacatepéquez', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Guatemala'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Juan Sacatepéquez') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Raymundo', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Guatemala'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Raymundo') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Chuarrancho', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Guatemala'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Chuarrancho') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Fraijanes', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Guatemala'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Fraijanes') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Amatitlán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Guatemala'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Amatitlán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Villa Nueva', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Guatemala'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Villa Nueva') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Villa Canales', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Guatemala'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Villa Canales') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Miguel Petapa', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Guatemala'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Miguel Petapa') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Guastatoya', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'El Progreso'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Guastatoya') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Morazán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'El Progreso'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Morazán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Agustín Acasaguastlán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'El Progreso'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Agustín Acasaguastlán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Cristóbal Acasaguastlán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'El Progreso'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Cristóbal Acasaguastlán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'El Jícaro', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'El Progreso'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('El Jícaro') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Sansare', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'El Progreso'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Sansare') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Sanarate', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'El Progreso'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Sanarate') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Antonio La Paz', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'El Progreso'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Antonio La Paz') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Cobán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Alta Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Cobán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Cruz Verapaz', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Alta Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Cruz Verapaz') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Cristóbal Verapaz', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Alta Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Cristóbal Verapaz') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Tactic', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Alta Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Tactic') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Tamahú', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Alta Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Tamahú') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Miguel Tucurú', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Alta Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Miguel Tucurú') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Panzós', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Alta Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Panzós') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Senahú', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Alta Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Senahú') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Pedro Carchá', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Alta Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Pedro Carchá') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Juan Chamelco', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Alta Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Juan Chamelco') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Lanquín', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Alta Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Lanquín') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa María Cahabón', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Alta Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa María Cahabón') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Chisec', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Alta Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Chisec') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Chahal', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Alta Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Chahal') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Fray Bartolomé de las Casas', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Alta Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Fray Bartolomé de las Casas') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Catarina La Tinta', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Alta Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Catarina La Tinta') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Raxruhá', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Alta Verapaz'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Raxruhá') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Mazatenango', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Mazatenango') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Cuyotenango', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Cuyotenango') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Francisco Zapotitlán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Francisco Zapotitlán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Bernardino', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Bernardino') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San José El Idolo', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San José El Idolo') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santo Domingo Suchitepéquez', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santo Domingo Suchitepéquez') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Lorenzo', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Lorenzo') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Samayac', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Samayac') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Pablo Jocopilas', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Pablo Jocopilas') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Antonio Suchitepéquez', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Antonio Suchitepéquez') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Miguel Panán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Miguel Panán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Gabriel', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Gabriel') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Chicacao', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Chicacao') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Patulul', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Patulul') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Bárbara', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Bárbara') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Juan Bautista', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Juan Bautista') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santo Tomás La Unión', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santo Tomás La Unión') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Zunilito', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Zunilito') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Pueblo Nuevo', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Pueblo Nuevo') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Río Bravo', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Río Bravo') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San José La Máquina', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Suchitepéquez'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San José La Máquina') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Flores', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Petén'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Flores') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San José', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Petén'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San José') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Benito', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Petén'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Benito') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Andrés', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Petén'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Andrés') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'La Libertad', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Petén'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('La Libertad') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Francisco', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Petén'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Francisco') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Santa Ana', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Petén'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Santa Ana') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Dolores', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Petén'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Dolores') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Luis', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Petén'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Luis') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Sayaxché', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Petén'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Sayaxché') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Melchor de Mencos', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Petén'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Melchor de Mencos') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Poptún', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Petén'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Poptún') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Las Cruces', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Petén'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Las Cruces') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'El Chal', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'Petén'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('El Chal') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Marcos', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Marcos') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Pedro Sacatepéquez', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Pedro Sacatepéquez') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Antonio Sacatepéquez', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Antonio Sacatepéquez') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Comitancillo', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Comitancillo') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Miguel Ixtahuacán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Miguel Ixtahuacán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Concepción Tutuapa', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Concepción Tutuapa') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Tacaná', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Tacaná') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Sibinal', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Sibinal') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Tajumulco', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Tajumulco') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Tejutla', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Tejutla') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Rafael Pie de la Cuesta', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Rafael Pie de la Cuesta') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Nuevo Progreso', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Nuevo Progreso') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'El Tumbador', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('El Tumbador') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'El Rodeo', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('El Rodeo') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Malacatán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Malacatán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Catarina', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Catarina') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Ayutla', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Ayutla') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Ocós', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Ocós') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Pablo', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Pablo') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'El Quetzal', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('El Quetzal') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'La Reforma', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('La Reforma') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Pajapita', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Pajapita') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Ixchiguán', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Ixchiguán') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San José Ojetenam', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San José Ojetenam') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Cristóbal Cucho', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Cristóbal Cucho') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Sipacapa', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Sipacapa') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Esquipulas Palo Gordo', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Esquipulas Palo Gordo') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'Río Blanco', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('Río Blanco') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'San Lorenzo', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('San Lorenzo') AND m.departamento_id = d.id
  )
LIMIT 1;
INSERT INTO gtcop.municipio (nombre, departamento_id)
SELECT 'La Blanca', d.id
FROM gtcop.departamento d
WHERE d.nombre = 'San Marcos'
  AND NOT EXISTS (
      SELECT 1 FROM gtcop.municipio m 
      WHERE LOWER(m.nombre) = LOWER('La Blanca') AND m.departamento_id = d.id
  )
LIMIT 1;
SET FOREIGN_KEY_CHECKS = 1;