-- Borrar la base de datos si existe y crear una nueva
DROP DATABASE IF EXISTS twitter_db;
CREATE DATABASE twitter_db;

-- Mostrar todas las bases de datos y usar la nueva
SHOW DATABASES;
USE twitter_db;

-- Borrar la tabla users si existe
DROP TABLE IF EXISTS users;

-- Crear la tabla users
CREATE TABLE users (
    user_id INT NOT NULL AUTO_INCREMENT,
    user_handle VARCHAR(50) NOT NULL UNIQUE,
    email_address VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_number CHAR(11) UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id)
);

-- Insertar datos en la tabla users
INSERT INTO users (user_handle, email_address, first_name, last_name, phone_number)
VALUES
('midudev', 'midudev@gmail.com', 'Miguel', 'Angel', '1126572233'),
('colitadecuadril', 'colita22@gmail.com', 'Angela', 'Torres', '1134567233'),
('LosDelAgua', 'nafy302@gmail.com', 'Ignacio', 'Lopez Díaz', '1127186033'),
('AfCPasion', 'arsenalfc@gmail.com', 'Arsenal', 'FC', '1144527781'),
('astrak3', 'astralluegobaby@msn.com', 'Ivan', 'Jesus', '1166229031'),
('penita_02', 'penitaap10@msn.com', 'Agustin', 'Pena', '1142229039');

-- Borrar la tabla followers si existe
DROP TABLE IF EXISTS followers;

-- Crear la tabla followers
CREATE TABLE followers (
    follower_id INT NOT NULL,
    following_id INT NOT NULL,
    PRIMARY KEY (follower_id, following_id),
    FOREIGN KEY (follower_id) REFERENCES users (user_id),
    FOREIGN KEY (following_id) REFERENCES users (user_id)
);

-- Añadir la restricción para que el usuario no se pueda seguir a sí mismo
ALTER TABLE followers 
ADD CONSTRAINT check_follower_id
CHECK (follower_id <> following_id); 

-- Insertar datos en la tabla followers
INSERT INTO followers (follower_id, following_id)
VALUES 
(1, 2),
(2, 1),
(3, 1),
(4, 1),
(5, 6),
(6, 5),
(2, 5),
(3, 5);

-- Seleccionar y mostrar los datos de la tabla followers
SELECT follower_id, following_id FROM followers;

-- Recuperar los followers de un usuario
SELECT follower_id FROM followers WHERE following_id = 1;

-- Contar números de usuarios que están siguiendo a otro usuario
SELECT COUNT(follower_id) AS followers FROM followers WHERE following_id = 1;

-- Top 3 usuarios con mayor número de seguidores
SELECT following_id, COUNT(follower_id) AS followers 
FROM followers 
GROUP BY following_id
ORDER BY followers DESC -- Sirve para hacer el top de manera ordenada y decreciente 
LIMIT 3;

-- JOIN te permite traer información de una tabla hacia la otra, gracias a las Foreing Keys
-- Top 3 usuarios con mayor número de seguidores gracias al JOIN
SELECT users.user_id, users.user_handle, users.first_name, following_id, COUNT(follower_id) AS followers 
FROM followers 
JOIN users ON users.user_id = followers.following_id
GROUP BY following_id, users.user_id, users.user_handle, users.first_name
ORDER BY followers DESC -- Sirve para hacer el top de manera ordenada y decreciente 
LIMIT 3;

-- Borrar la tabla tweets si existe
DROP TABLE IF EXISTS tweets;

-- Crear la tabla tweets
CREATE TABLE tweets (
    tweet_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    tweet_text VARCHAR(280) NOT NULL,
    num_likes INT DEFAULT 0,
    num_retweets INT DEFAULT 0,
    num_comments INT DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (tweet_id),
    FOREIGN KEY (user_id) REFERENCES users (user_id)
);

-- Insertar datos en la tabla tweets
INSERT INTO tweets (user_id, tweet_text)
VALUES 
(1, '¡Hola, soy Midudev! ¿Qué tal? 🚀'),
(2, '¡Entrando en twitter, qué genial!'),
(3, 'HTML es un lenguaje de programación'),
(1, 'Sígueme en https://www.twitch.tv/nacffy'),
(2, 'Hoy es un día soleado'),
(3, '¡Me encanta la música!'),
(1, 'Programando un nuevo proyecto. ¡Emocionado!'),
(1, 'Me cae mal Elon Musk'),
(1, 'Explorando nuevas tecnologías');

-- Seleccionar y mostrar los datos de la tabla tweets
SELECT * FROM tweets;

-- ¿Cuántos tweets ha hecho un usuario?
SELECT user_id, COUNT(*) AS tweet_count 
FROM tweets
GROUP BY user_id;

-- Subconsulta
-- Obtener los tweets de los usuarios que tienen más de 2 seguidores
SELECT tweet_id, tweet_text, user_id
FROM tweets
WHERE user_id IN (
	SELECT following_id
	FROM followers
	GROUP BY following_id -- Cuando agrupamos el WHERE del GROUP es HAVING
	HAVING COUNT(*) > 2
);

/* -- DELETE
DELETE FROM tweets WHERE tweet_id = 3;  -- Por Tweet
DELETE FROM tweets WHERE user_id = 1; -- Por usuario 
DELETE FROM tweets WHERE tweet_text LIKE '%Elon Musk%'; -- Por texto o palabras claves
*/

-- UPDATE
UPDATE tweets SET num_coments = num_coments + 1 WHERE tweet_id = 1;

/*-- Reemplazar Texto
UPDATE tweets SET tweet_text = REPLACE (tweet_text, 'twitter', 'Threads')
WHERE tweet_text LIKE '%twitter%';*/

-- Borrar la tabla likes si existe
DROP TABLE IF EXISTS tweets_likes;

-- Crear la tabla de likes
CREATE TABLE tweet_likes (
user_id INT NOT NULL,
tweet_id INT NOT NULL,
FOREIGN KEY (user_id) REFERENCES users (user_id),
FOREIGN KEY (tweet_id) REFERENCES tweets (tweet_id),
PRIMARY KEY (user_id, tweet_id)
);

INSERT INTO tweet_likes (user_id, tweet_id)
VALUES (1, 3), (1, 6), (3, 7), (4, 7), (1, 7), (3, 6), (2, 7), (5, 7);

-- Obtener el número de likes por tweet
SELECT tweet_id, COUNT(*) AS like_count
FROM tweet_likes
GROUP BY tweet_id;

-- Borrar el TRIGGER incremental de seguidores si existe
DROP TRIGGER IF EXISTS increase_follower_count;

-- Triggers
DELIMITER $$

CREATE TRIGGER increase_follower_count
 AFTER INSERT ON followers -- <-------
 FOR EACH ROW 
  BEGIN 
UPDATE users SET follower_count = follower_count + 1
WHERE user_id = NEW.following_id;
  END $$
  
DELIMITER ;

-- Borrar el TRIGGER de decrecimento de seguidores si existe
DROP TRIGGER IF EXISTS decrease_follower_count;

-- Trigger para cuando un follower deja de seguirte
DELIMITER $$

CREATE TRIGGER decrease_follower_count
 AFTER DELETE ON followers -- <-------
 FOR EACH ROW 
  BEGIN 
UPDATE users SET follower_count = follower_count - 1
WHERE user_id = NEW.following_id;
  END $$
  
DELIMITER ;
  
  