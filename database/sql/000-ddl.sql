-- Project Name : blog-engine
-- Date/Time    : 2022/04/15 1:55:06
-- Author       : arlechann
-- RDBMS Type   : PostgreSQL
-- Application  : A5:SQL Mk-2

-- 管理者パスワード
DROP TABLE if exists administrator_secrets CASCADE;

CREATE TABLE administrator_secrets (
  id serial NOT NULL
  , administrator_id integer NOT NULL
  , password char(60) NOT NULL
  , CONSTRAINT administrator_secrets_PKC PRIMARY KEY (id)
) ;

CREATE INDEX administrator_secrets_IX1
  ON administrator_secrets(administrator_id);

CREATE INDEX administrator_secrets_IX2
  ON administrator_secrets(password);

-- コメント
DROP TABLE if exists comments CASCADE;

CREATE TABLE comments (
  post_id integer NOT NULL
  , name varchar(255) NOT NULL
  , content text NOT NULL
  , created_at timestamp with time zone NOT NULL
) ;

CREATE INDEX comments_IX1
  ON comments(post_id);

CREATE INDEX comments_IX2
  ON comments(created_at);

-- スラッグ
DROP TABLE if exists slugs CASCADE;

CREATE TABLE slugs (
  post_id integer NOT NULL
  , slug text NOT NULL
) ;

CREATE UNIQUE INDEX slugs_IX1
  ON slugs(slug);

-- 投稿
DROP TABLE if exists posts CASCADE;

CREATE TABLE posts (
  id serial NOT NULL
  , title varchar(255) NOT NULL
  , content text NOT NULL
  , publish_status_id integer NOT NULL
  , administrator_id integer NOT NULL
  , created_at timestamp with time zone NOT NULL
  , last_updated_at timestamp with time zone NOT NULL
  , CONSTRAINT posts_PKC PRIMARY KEY (id)
) ;

-- 公開状態
DROP TABLE if exists publish_statuses CASCADE;

CREATE TABLE publish_statuses (
  id serial NOT NULL
  , code varchar(32) NOT NULL
  , label varchar(255) NOT NULL
  , CONSTRAINT publish_statuses_PKC PRIMARY KEY (id)
) ;

CREATE UNIQUE INDEX publish_statuses_IX1
  ON publish_statuses(code);

-- 管理者
DROP TABLE if exists administrators CASCADE;

CREATE TABLE administrators (
  id serial NOT NULL
  , email varchar(255) NOT NULL
  , CONSTRAINT administrators_PKC PRIMARY KEY (id)
) ;

CREATE UNIQUE INDEX administrators_IX1
  ON administrators(email);

ALTER TABLE administrator_secrets
  ADD CONSTRAINT administrator_secrets_FK1 FOREIGN KEY (administrator_id) REFERENCES administrators(id);

ALTER TABLE comments
  ADD CONSTRAINT comments_FK1 FOREIGN KEY (post_id) REFERENCES posts(id);

ALTER TABLE posts
  ADD CONSTRAINT posts_FK1 FOREIGN KEY (publish_status_id) REFERENCES publish_statuses(id);

ALTER TABLE posts
  ADD CONSTRAINT posts_FK2 FOREIGN KEY (administrator_id) REFERENCES administrators(id);

ALTER TABLE slugs
  ADD CONSTRAINT slugs_FK1 FOREIGN KEY (post_id) REFERENCES posts(id);

COMMENT ON TABLE administrator_secrets IS '管理者パスワード';
COMMENT ON COLUMN administrator_secrets.id IS 'ID';
COMMENT ON COLUMN administrator_secrets.administrator_id IS '管理者ID';
COMMENT ON COLUMN administrator_secrets.password IS 'パスワードハッシュ';

COMMENT ON TABLE comments IS 'コメント';
COMMENT ON COLUMN comments.post_id IS '投稿ID';
COMMENT ON COLUMN comments.name IS '投稿者名';
COMMENT ON COLUMN comments.content IS '本文';
COMMENT ON COLUMN comments.created_at IS '作成日時';

COMMENT ON TABLE slugs IS 'スラッグ';
COMMENT ON COLUMN slugs.post_id IS '投稿ID';
COMMENT ON COLUMN slugs.slug IS 'スラッグ';

COMMENT ON TABLE posts IS '投稿';
COMMENT ON COLUMN posts.id IS 'ID';
COMMENT ON COLUMN posts.title IS 'タイトル';
COMMENT ON COLUMN posts.content IS '本文';
COMMENT ON COLUMN posts.publish_status_id IS '公開状態ID';
COMMENT ON COLUMN posts.administrator_id IS '管理者ID';
COMMENT ON COLUMN posts.created_at IS '作成日時';
COMMENT ON COLUMN posts.last_updated_at IS '最終更新日時';

COMMENT ON TABLE publish_statuses IS '公開状態';
COMMENT ON COLUMN publish_statuses.id IS 'ID';
COMMENT ON COLUMN publish_statuses.code IS 'コード';
COMMENT ON COLUMN publish_statuses.label IS '表示名';

COMMENT ON TABLE administrators IS '管理者';
COMMENT ON COLUMN administrators.id IS 'ID';
COMMENT ON COLUMN administrators.email IS 'メールアドレス';

