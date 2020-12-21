-- Представление для просмотра информации по странам(сколько пользователей, сколько авторов, сколько произведений)

CREATE OR REPLACE VIEW countries_info AS
  SELECT DISTINCT countries.id,
	countries.name AS country,
  ac.a_id AS total_autors,
  uc.u_id AS total_users,
  tt AS total_titles
  FROM countries 
  LEFT JOIN 
    (SELECT country_id, 
     count(id) OVER(PARTITION BY country_id) AS a_id
     FROM autors) AS ac 
    ON countries.id = ac.country_id 
  LEFT JOIN  
    (SELECT country_id,
     COUNT(user_id) OVER(PARTITION BY country_id) AS u_id 
     FROM user_profiles) AS uc
    ON countries.id=uc.country_id
  LEFT JOIN
  (SELECT DISTINCT cid AS u_cid, 
   COUNT(title) OVER(PARTITION BY cid) AS tt
   FROM titles 
    LEFT JOIN
    (SELECT autors.id AS a_id, countries.id AS cid FROM countries 
      LEFT JOIN autors 
       ON autors.country_id = countries.id) AS a_c 
      ON a_id = titles.autor_id) AS xx 
   ON countries.id = xx.u_cid;
  
-- Представление для просмотра сводной информации о пользователях

CREATE OR REPLACE VIEW user_info AS
	SELECT u.id AS u_id,
		   concat_ws(' ', up.first_name, up.last_name) AS full_name, -- полное имя
		   u.nick_name AS nickname, -- никнейм
		   u.email, -- емейл
		   c.name, -- страна
		   up.date_of_birth,
		   TIMESTAMPDIFF(YEAR, up.date_of_birth, NOW()) AS age,
		   CASE (up.gender)
			   WHEN 'M' THEN 'male'
			   WHEN 'F' THEN 'female'
			   WHEN 'ud' THEN 'undefined'
			   END AS gender,
		   fa_t.c AS autors, -- На скольких авторов подписан
		   fu_t.c AS followers, -- На скольких пользователей подписан
		   fu_f.c AS following, -- Сколько подписчиков
		   to_w.c AS to_wish, -- сколько книг в вишлисте
		   reed.c AS titles_reed,  -- сколько книг в прочитанном
		   fav.c AS to_favorit,  -- сколько книг в избранном
		   r.c AS reviews,  -- обзоров написано
		   r2.c AS rated_titles,  -- оценок поставлено
		   r2.avg_rating, -- средняя оценка
		   lk.c AS likes, -- лайков поставлено
		   up.about
	  FROM users u
			   LEFT JOIN user_profiles up ON u.id = up.user_id
			   LEFT JOIN countries c ON up.country_id = c.id
			   LEFT JOIN (SELECT count((id)) AS c, -- На скольких авторов подписан
								 user_id 
							FROM follow_autors
						   GROUP BY user_id
						 ) fa_t ON u.id = fa_t.user_id
			   LEFT JOIN (SELECT count((id)) AS c, -- На скольких пользователей подписан
								 follower_id 
							FROM follow_users
						   GROUP BY follower_id
						 ) fu_t ON u.id = fu_t.follower_id
			   LEFT JOIN (SELECT count((id)) AS c, -- Сколько подписчиков
								 user_id
							FROM follow_users
						   GROUP BY user_id
						 ) fu_f ON u.id = fu_f.user_id
			   LEFT JOIN (SELECT user_id,
								 count(title_id) AS c
							FROM users_lists ul2 
						   WHERE ul2.list_type_id = 3 -- сколько книг в вишлисте
						   GROUP BY user_id
						 ) to_w ON u.id = to_w.user_id
			   LEFT JOIN (SELECT user_id,
								 count(title_id) AS c
							FROM users_lists ul2
						   WHERE ul2.list_type_id = 2 -- сколько книг в прочитанном
						   GROUP BY user_id
						 ) reed ON u.id = reed.user_id
			   LEFT JOIN (SELECT user_id,
			                     count(title_id) AS c
							FROM users_lists ul2
						   WHERE ul2.list_type_id = 1  -- сколько книг в избранном
						   GROUP BY user_id
						 ) fav ON u.id = fav.user_id
			   LEFT JOIN (SELECT count(id) AS c,
								 user_id
							FROM reviews
						   GROUP BY user_id
						 ) r ON u.id = r.user_id -- обзоров написано
			   LEFT JOIN (SELECT count(id) AS c,
								 round(avg(rating)) AS avg_rating,
								 user_id
							FROM ratings
						   GROUP BY user_id
						 ) r2 ON u.id = r2.user_id -- оценок поставлено
			   LEFT JOIN (SELECT count(id) AS c,
								 user_id
							FROM likes
						   GROUP BY user_id
						 ) lk ON u.id = lk.user_id -- лайков поставлено
	 ORDER BY
		 u.id;


 
-- Представление для просмотра информации по рецензиям на книги

CREATE OR REPLACE VIEW reviews_info AS
	SELECT r.title_id AS t_id,
		   t.title,
		   r.id AS rev_id,
		   r.body,
		   CASE (r.is_positive)
			   WHEN 1 THEN 'positive'
			   WHEN 0 THEN 'negative'
			   END AS mood,   
		   u.nick_name 
	  FROM reviews r
			   JOIN titles t ON r.title_id = t.id
			   JOIN users u ON r.user_id = u.id
	 ORDER BY
		 r.id;
		 
SELECT * FROM countries_info where country='Algeria';
SELECT * FROM reviews_info WHERE nick_name='sed';
SELECT * FROM user_info;