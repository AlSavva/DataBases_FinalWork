DROP DATABASE IF EXISTS libroteka;
CREATE DATABASE libroteka;

USE libroteka;

-- ---------------directories---------------

DROP TABLE IF EXISTS lit_types;
CREATE TABLE lit_types (
  id SERIAL PRIMARY KEY,
  lit_type VARCHAR(200) UNIQUE NOT NULL
);

DROP TABLE IF EXISTS genres;
CREATE TABLE genres (
  id SERIAL PRIMARY KEY,
  genre VARCHAR(200) UNIQUE NOT NULL
);

DROP TABLE IF EXISTS countries;
CREATE TABLE countries (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL
);

DROP TABLE IF EXISTS target_types;
CREATE TABLE target_types (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS list_types;
CREATE TABLE list_types (
  id SERIAL PRIMARY KEY,
  list_type VARCHAR(255) UNIQUE NOT NULL
);

-- ---------------users---------------

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  nick_name VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS user_profiles;
CREATE TABLE user_profiles (
  user_id SERIAL PRIMERY KEY,
  first_name VARCHAR(100) DEFAULT ' ',
  last_name VARCHAR(100) DEFAULT ' ',
  gender ENUM ('M', 'F', 'ud') DEFAULT 'ud',
  date_of_birth DATE,
  country_id BIGINT UNSIGNED,
  about VARCHAR(350) DEFAULT ' ',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX profiles_full_user_name_idx (first_name, last_name),
  INDEX profiles_date_of_birth_idx (date_of_birth),
  

  FOREIGN KEY (country_id) REFERENCES countries (id)
		ON DELETE SET NULL
		ON UPDATE CASCADE
  
  );

-- -----------------autors----------------------

DROP TABLE IF EXISTS autors;
CREATE TABLE autors (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL, 
  date_of_birth DATE,
  gender ENUM ('M', 'F', 'other', 'ud') DEFAULT 'ud',
  country_id BIGINT UNSIGNED,
  
  INDEX autors_full_autor_name_idx (first_name, last_name),
  INDEX autors_date_of_birth_idx (date_of_birth),
  
  
  FOREIGN KEY (country_id) REFERENCES countries (id)
		ON DELETE SET NULL
		ON UPDATE CASCADE
		
);

-- -----------------titles----------------------

DROP TABLE IF EXISTS titles;
CREATE TABLE titles(
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  autor_id BIGINT UNSIGNED NOT NULL,
  genre_id BIGINT UNSIGNED NOT NULL,
  lit_type_id BIGINT UNSIGNED NOT NULL,
  date_of_create DATE,
  summary VARCHAR(500),
  
  INDEX titles_title_idx (title),
  INDEX titles_date_of_create_idx (date_of_create),
  
  FOREIGN KEY (autor_id) REFERENCES autors (id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  FOREIGN KEY (genre_id) REFERENCES genres (id)
    ON DELETE RESTRICT
	ON UPDATE CASCADE,
  FOREIGN KEY (lit_type_id) REFERENCES lit_types (id)
	ON DELETE RESTRICT
	ON UPDATE CASCADE
);

-- ----------------reviews-----------------------

DROP TABLE IF EXISTS reviews;
CREATE TABLE reviews (
  id SERIAL PRIMARY KEY,
  title_id BIGINT UNSIGNED,
  user_id BIGINT UNSIGNED,
  body VARCHAR(500) NOT NULL,
  is_positive BIT DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (title_id) REFERENCES titles (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
);

-- ---------------likes, ratings----------------

DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
  id SERIAL PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  target_id BIGINT UNSIGNED NOT NULL,
  target_type_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  INDEX likes_target_idx (target_id),
  
  FOREIGN KEY (user_id) REFERENCES users (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
  FOREIGN KEY (target_type_id) REFERENCES target_types (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
);

DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings (
  id SERIAL PRIMARY KEY,
  title_id BIGINT UNSIGNED,
  user_id BIGINT UNSIGNED,
  rating INT UNSIGNED NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (title_id) REFERENCES titles (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
);

-- ----------------users lists----------------------

DROP TABLE IF EXISTS users_lists;
CREATE TABLE users_lists (
  id SERIAL PRIMARY KEY,
  user_id BIGINT UNSIGNED,
  title_id BIGINT UNSIGNED,
  list_type_id BIGINT UNSIGNED,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (title_id) REFERENCES titles (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
  FOREIGN KEY (list_type_id) REFERENCES list_types (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE

);

-- ----------------followers------------------------

DROP TABLE IF EXISTS follow_users;
CREATE TABLE follow_users (
  id SERIAL PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  follower_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
  
  FOREIGN KEY (user_id) REFERENCES users (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
  FOREIGN KEY (follower_id) REFERENCES users (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
		
);

DROP TABLE IF EXISTS follow_autors;
CREATE TABLE follow_autors (
  id SERIAL PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  autor_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE,
  FOREIGN KEY (autor_id) REFERENCES autors (id)
		ON DELETE RESTRICT
		ON UPDATE CASCADE
		
);





	