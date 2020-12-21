-- Рекомендация к прочтению для пользователя по его id. Количество 
-- рекомендованых книг задается параметром n_rows
-- в рекомендацию попадают книги авторов на которых подписан пользователь 
-- и книги из листа "favorites", пользователей, у которых целевой пользователь в подписчиках.
-- сортировка по рейтингу книг

DROP PROCEDURE IF EXISTS offer_titles;
DELIMITER //
CREATE PROCEDURE offer_titles(IN for_user_id INT, IN n_rows INT)
BEGIN
  SELECT DISTINCT t.title, 
    rat.avr
  FROM titles t
  LEFT JOIN
    (SELECT DISTINCT title_id AS t_id,
            AVG(rating) OVER(PARTITION BY title_id) AS avr
     FROM ratings) AS rat
    ON rat.t_id = t.id
  JOIN 
    (SELECT title_id AS tid 
     FROM users_lists 
     JOIN follow_users fu 
       ON follower_id = for_user_id 
       AND list_type_id = 1 ) AS fl 
    ON  fl.tid = t.id
  UNION
  SELECT  title, 
    rat.avr 
  FROM titles t
  LEFT JOIN
    (SELECT title_id AS t_id,
       AVG(rating) OVER(PARTITION BY title_id) AS avr
     FROM ratings) AS rat
    ON rat.t_id = t.id
  JOIN follow_autors fa 
    ON fa.autor_id = t.autor_id 
     WHERE fa.user_id =for_user_id
  ORDER BY avr DESC LIMIT n_rows;

END //
DELIMITER ;

CALL offer_titles(50, 10);
 




