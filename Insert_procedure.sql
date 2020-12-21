-- Процедура добавления пользователя

DROP PROCEDURE IF EXISTS add_user;
DELIMITER //
CREATE PROCEDURE add_user(nick_name VARCHAR(50),
							 email VARCHAR(100),
							 first_name VARCHAR(100),
							 last_name VARCHAR(100),
							 gender ENUM ('M', 'F', 'ud'),
							 date_of_birth DATE,
							 country VARCHAR(255),
							 OUT insert_status VARCHAR(200))
BEGIN
	DECLARE _rollback BOOL DEFAULT 0;
	DECLARE error_code VARCHAR(100);
	DECLARE error_message VARCHAR(100);
	DECLARE last_user_id INT;
	DECLARE user_country_id INT;

	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			SET _rollback = 1;
			GET STACKED DIAGNOSTICS CONDITION 1
				error_code = RETURNED_SQLSTATE, error_message = MESSAGE_TEXT;
			SET insert_status := concat('Unsuccessful. Error code: ', error_code, '. Text: ', error_message);
		END;

	START TRANSACTION;
	INSERT INTO users
		(id, nick_name, email)
	VALUES
		(null, nick_name, email);

	SELECT last_insert_id() INTO @last_user_id;
	SELECT c2.id FROM countries c2 WHERE c2.name = country INTO @user_country_id;

	INSERT INTO user_profiles
		(user_id, first_name, last_name, gender, date_of_birth, country_id)
	VALUES
		(@last_user_id, first_name, last_name, gender, date_of_birth, @user_country_id);

	IF _rollback THEN
		ROLLBACK;
	ELSE
		SET insert_status := 'Successful';
		COMMIT;
	END IF;

END //
DELIMITER ;

/*
CALL add_user('dragon_fly',
				 'd_fly@now.com',
				 'Dragon',
				 'Fly',
				 'M', 
				 '1900-01-01',
				 'Italy',
				 @insert_status);
SELECT @insert_status;
*/


-- Процедура добавления произведения

DROP PROCEDURE IF EXISTS add_title;
DELIMITER //
CREATE PROCEDURE add_title(title VARCHAR(100),
                    		autor VARCHAR(200),
  							t_genre VARCHAR(200),
  							t_type VARCHAR(200),
  							date_of_create DATE, 
							OUT insert_status VARCHAR(200))
BEGIN
	DECLARE _rollback BOOL DEFAULT 0;
	DECLARE error_code VARCHAR(100);
	DECLARE error_message VARCHAR(100);
	DECLARE title_autor INT;
    DECLARE title_genre INT;
    DECLARE title_type INT;

	DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
		BEGIN
			SET _rollback = 1;
			GET STACKED DIAGNOSTICS CONDITION 1
				error_code = RETURNED_SQLSTATE, error_message = MESSAGE_TEXT;
			SET insert_status := concat('Unsuccessful. Error code: ', error_code, '. Text: ', error_message);
		END;

	START TRANSACTION;
	
    SELECT id FROM autors a2 WHERE a2.last_name = autor INTO @title_autor;
    SELECT id FROM genres g2 WHERE g2.genre = t_genre INTO @title_genre;
   	SELECT id FROM lit_types lt WHERE lt.lit_type = t_type INTO @title_type;
   	
	INSERT INTO titles
		(id, title, autor_id, genre_id, lit_type_id, date_of_create)
	VALUES
		(null, title, @title_autor, @title_genre, @title_type, date_of_create);

	IF _rollback THEN
		ROLLBACK;
	ELSE
		SET insert_status := 'Successful';
		COMMIT;
	END IF;

END //
DELIMITER ;

/*
CALL add_title('My book!', 
                  'Okuneva',
                  'poem',
                  'ironic',
                  '1999-09-09',
                  @insert_status);
SELECT @insert_status;
