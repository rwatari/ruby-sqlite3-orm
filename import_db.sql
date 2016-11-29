DROP TABLE if EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE if EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author_id INTEGER,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE if EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE if EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)
);

DROP TABLE if EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('John', 'Smith'),
  ('Bob', 'Johnson'),
  ('Frank', 'Williams');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('Is the Earth round?', 'Is it?', 1),
  ('How does SQL work?', 'I still don''t understand it', 2),
  ('iPhone 7 Jack', 'Is it really better?', 1);

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  (3, 1),
  (3, 2),
  (2, 2),
  (3, 3);

INSERT INTO
  replies (question_id, parent_id, user_id, body)
VALUES
  (1, NULL, 2, 'No, it''s flat.'),
  (1, 1, 3, 'Bob, you''re an idiot.'),
  (2, NULL, 3, 'Try googling it'),
  (3, NULL, 1, 'Apple is so courageous');

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  (1, 1),
  (2, 1),
  (2, 3),
  (3, 2);
