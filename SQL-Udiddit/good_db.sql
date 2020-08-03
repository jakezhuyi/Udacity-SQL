-- https://github.com/zjy-T/SQL-Udacity
-- 2
DROP TABLE IF EXISTS 
  "users",
  "topics",
  "posts",
  "comments",
  "votes";

-- a. Allow new users to register:
CREATE TABLE "users"
(
  id SERIAL PRIMARY KEY,
  username VARCHAR(25) NOT NULL,
  last_login TIMESTAMP,
  CONSTRAINT "unique_usernames" UNIQUE ("username"),
  CONSTRAINT "non_empty_username" CHECK (LENGTH(TRIM("username")) > 0)
);

-- b. Allow registered users to create new topics:
CREATE TABLE "topics"
(
  id SERIAL PRIMARY KEY,
  name VARCHAR(30) NOT NULL,
  description VARCHAR(500),
  CONSTRAINT "unique_topics" UNIQUE ("name"),
  CONSTRAINT "non_empty_topic_name" CHECK (LENGTH(TRIM("name")) > 0)
);

-- c. Allow registered users to create new posts on existing topics:
CREATE TABLE "posts" 
(
  id SERIAL PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  created_on TIMESTAMP,
  url VARCHAR(400),
  text_content TEXT,
  topic_id INTEGER REFERENCES "topics" ON DELETE CASCADE,
  user_id INTEGER REFERENCES "users" ON DELETE SET NULL,
  CONSTRAINT "non_empty_title" CHECK (LENGTH(TRIM("title")) > 0),
  CONSTRAINT "url_or_text" CHECK (
    (LENGTH(TRIM("url")) > 0 AND LENGTH(TRIM("text_content")) = 0) OR
    (LENGTH(TRIM("url")) = 0 AND LENGTH(TRIM("text_content")) > 0)
  )
);
CREATE INDEX ON "posts" ("url" VARCHAR_PATTERN_OPS);

-- d. Allow registered users to comment on existing posts:
CREATE TABLE "comments"
(
  id SERIAL PRIMARY KEY,
  text_content TEXT NOT NULL,
  created_on TIMESTAMP,
  post_id INTEGER REFERENCES "posts" ON DELETE CASCADE,
  user_id INTEGER REFERENCES "users" ON DELETE SET NULL,
  parent_comment_id INTEGER REFERENCES "comments" ON DELETE CASCADE
  CONSTRAINT "non_empty_text_content" CHECK(LENGTH(TRIM("text_content")) > 0)
);

-- e. Make sure that a given user can only vote once on a given post:
CREATE TABLE "votes"
(
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES "users" ON DELETE SET NULL,
  post_id INTEGER,
  vote SMALLINT NOT NULL,
  CONSTRAINT "vote_plus_or_min" CHECK("vote" = 1 OR "vote" = -1),
  CONSTRAINT "one_vote_per_user" UNIQUE (user_id, post_id)
);

-- 3
INSERT INTO "users"("username")
  SELECT DISTINCT username
  FROM bad_posts
  UNION
  SELECT DISTINCT username
  FROM bad_comments
  UNION
  SELECT DISTINCT regexp_split_to_table(upvotes, ',')
  FROM bad_posts
  UNION
  SELECT DISTINCT regexp_split_to_table(downvotes, ',')
  FROM bad_posts;

INSERT INTO "topics"("name")
 SELECT DISTINCT topic FROM bad_posts;

INSERT INTO "posts"
(
  "user_id",
  "topic_id",
  "title",
  "url",
  "text_content"
)

SELECT
  users.id,
  topics.id,
  LEFT(bad_posts.title, 100),
bad_posts.url,
bad_posts.text_content
FROM bad_posts
JOIN users ON bad_posts.username = users.username
JOIN topics ON bad_posts.topic = topics.name;

INSERT INTO "comments"
(
  "post_id",
  "user_id",
  "text_content"
)

SELECT
  posts.id,
  users.id,
  bad_comments.text_content
FROM bad_comments
JOIN users ON bad_comments.username = users.username
JOIN posts ON posts.id = bad_comments.post_id;

-- https://knowledge.udacity.com/questions/293663
INSERT INTO "votes"
(
  "post_id",
  "user_id",
  "vote"
)

SELECT t1.id, users.id,
1 AS vote_up
FROM (SELECT id, REGEXP_SPLIT_TO_TABLE(upvotes,',') 
  AS upvote_users FROM bad_posts) t1
JOIN users ON users.username=t1.upvote_users;

INSERT INTO "votes"
(
  "post_id",
  "user_id",
  "vote"
)

SELECT t1.id, users.id,
-1 AS vote_down
FROM (SELECT id, REGEXP_SPLIT_TO_TABLE(downvotes,',') 
  AS downvote_users FROM bad_posts) t1
JOIN users ON users.username=t1.downvote_users;