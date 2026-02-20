-- Supabase postsテーブル作成SQL
-- SupabaseのSQL Editorで実行してください

-- postsテーブル（投稿データ）
CREATE TABLE IF NOT EXISTS posts (
  id BIGSERIAL PRIMARY KEY,
  category VARCHAR(20) NOT NULL CHECK (category IN ('lecture', 'circle', 'campus', 'qa')),
  faculty VARCHAR(20),
  author VARCHAR(100) NOT NULL DEFAULT 'waseda_taro',
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  likes INTEGER DEFAULT 0,
  comments INTEGER DEFAULT 0,
  stars INTEGER CHECK (stars >= 1 AND stars <= 5),
  solved BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- answersテーブル（Q&A回答データ）
CREATE TABLE IF NOT EXISTS answers (
  id BIGSERIAL PRIMARY KEY,
  post_id BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  author VARCHAR(100) NOT NULL DEFAULT 'waseda_taro',
  text TEXT NOT NULL,
  best BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- インデックス作成（検索パフォーマンス向上）
CREATE INDEX IF NOT EXISTS idx_posts_category ON posts(category);
CREATE INDEX IF NOT EXISTS idx_posts_faculty ON posts(faculty);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_answers_post_id ON answers(post_id);
CREATE INDEX IF NOT EXISTS idx_answers_best ON answers(best);

-- updated_atを自動更新する関数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- updated_atトリガー
CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_answers_updated_at BEFORE UPDATE ON answers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) を有効化（全員が読み書き可能に設定）
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE answers ENABLE ROW LEVEL SECURITY;

-- 全員が読み書き可能なポリシー
CREATE POLICY "Allow all operations on posts" ON posts
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on answers" ON answers
  FOR ALL USING (true) WITH CHECK (true);
