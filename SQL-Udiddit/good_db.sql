DROP TABLE IF EXISTS 
  "users",
  "topics",
  "comments",
  "votes";

CREATE TABLE "users"
(
"id" SERIAL PRIMARY KEY,
"username" VARCHAR(25) 
  UNIQUE CHECK(LENGTH(TRIM("username")) > 0)
  NOT NULL,
"last_login" TIMESTAMP
);

CREATE TABLE "topics"
(
"id" SERIAL PRIMARY KEY,
"topic_name" VARCHAR(30) 
  UNIQUE CHECK(LENGTH(TRIM("topic_name")) > 0)
  NOT NULL,
"description" VARCHAR(500)
);

CREATE TABLE "posts"
(
"id" SERIAL PRIMARY KEY,
"user_id" INTEGER REFERENCES "users" ON 
  DELETE SET NULL,
"topic_id" INTEGER REFERENCES "topics" ON 
  DELETE CASCADE,
"title" VARCHAR(100) NOT NULL
  CHECK(LENGTH(TRIM("title")) > 0),
"url" VARCHAR(400) NOT NULL,
"text_content" TEXT NOT NULL,
  CONSTRAINT "not_both_url_and_textcontent"
  CHECK
  (
    (LENGTH(TRIM("url")) > 0 AND 
      LENGTH(TRIM("text_content")) = 0
    ) 
    OR
    (LENGTH(TRIM("url")) = 0 AND
      LENGTH(TRIM("text_content")) > 0
    );
  );
);

CREATE TABLE "comments" 
(
"id" SERIAL PRIMARY KEY,
"user_id" INTEGER REFERENCES "users" ON 
  DELETE SET NULL,
"post_id" INTEGER REFERENCES "posts" ON
  DELETE CASCADE,
"text_content" TEXT NOT NULL
  CHECK(LENGTH(TRIM("text_content")) > 0),
"parent_comment_id" INTEGER,
CONSTRAINT "parent_child_thread" 
  FOREIGN KEY (parent_comment_id) 
  REFERENCES comments (id) ON 
  DELETE CASCADE
);

CREATE TABLE "votes"
(
"id" SERIAL PRIMARY KEY,
"user_id" INTEGER
  REFERENCES "users" ON 
  DELETE SET NULL,
"post_id" INTEGER,
"vote" SMALLINT
  CHECK(vote = 1 OR vote = -1)
);