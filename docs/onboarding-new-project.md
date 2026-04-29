# 新規プロジェクト立ち上げ Runbook

作成: 2026-04-30 / cmd_364 Phase 2

新しい事業を multi-agent-shogun で管理対象にするときのチェックリスト。
上から順に実施すること。

---

## Step 1: projects.yaml 登録

`config/projects.yaml` に以下を追記:

```yaml
- id: <project_id>          # 英小文字+アンダースコア（例: matsmoneylabo）
  name: "<表示名>"
  path: "<リポジトリ絶対パス>"
  priority: high | medium | low
  status: planning | active | paused | completed
  notes: "<一言説明>"
```

- `id` はシステム内で一意にすること
- 立ち上げ直後は `status: planning`、実装開始後に `active` に変更
- 参照例: cmd_364（matsmoneylabo / coconmusicschoolsystem 登録）

---

## Step 2: context/{project_id}.md 作成

`context/{project_id}.md` を新規作成:

```markdown
# {Project Name}

最終更新: YYYY-MM-DD

## 概要
（1-2 段落で事業内容）

## リポジトリ
- main repo: <絶対パス or TBD>
- 関連リポ: <list or TBD>

## 主担当・履歴
- 担当 ash: TBD
- 過去 cmd: なし（立ち上げ時）

## .knowledge/
- 場所: TBD（リポ確定後に作成）

## 主要 stack
TBD

## 補足
- ステータス: 立ち上げ準備中
```

- 不明な項目は TBD で記録し、確定次第更新
- Secret 値は絶対に記載しない

---

## Step 3: dashboard.md に project セクション追加

`dashboard.md` の `## 📋 バックログ` の前に:

```markdown
## 📋 {Project Name} バックログ

| ID | 内容 | cmd | ステータス |
|---|---|---|---|
| （初期エントリなし） | — | — | 待機 |
```

- dashboard.md は家老が管理。足軽は書かない。

---

## Step 4: リポジトリパス確定

リポジトリを作成・clone したら:

1. `config/projects.yaml` の `path` を実パスに更新
2. `context/{project_id}.md` の `## リポジトリ` を更新

---

## Step 5: .knowledge/ 雛形作成

リポジトリ確定後、以下のファイルを作成:

```
{repo}/.knowledge/
  debug-patterns.md        ← DP-NNN 形式でデバッグパターンを記録
  architecture-decisions.md ← AD-NNN 形式で設計判断を記録
  handoff.md               ← Claude.ai が作成・管理（エージェントは読むだけ）
```

最小雛形:
```markdown
# {Project} Debug Patterns
<!-- DP-001: タイトル (YYYY-MM-DD) -->
```

```markdown
# {Project} Architecture Decisions
<!-- AD-001: タイトル (YYYY-MM-DD) -->
```

---

## Step 6: 主担当 ash 指名

初期 cmd 起票時に `tasks/ashigaru{N}.yaml` の `project:` フィールドを設定:

```yaml
project: <project_id>
```

命名規則に変更はなし（ashigaru1〜7 を輪番使用）。

---

## Step 7: 初期 cmd 起票テンプレ

`queue/shogun_to_karo.yaml` に追記:

```yaml
- cmd_id: cmd_XXX
  project: <project_id>
  title: "<Project Name> 初期セットアップ"
  description: |
    ■ 目的
    <事業内容の初期実装>

    ■ スコープ
    - repo 初期化
    - README.md
    - 基本 stack セットアップ

  priority: high
  status: pending
  bloom_level: L2
  estimated_ash: 1
  gunshi_review: required | not_required
```

---

## Step 8: Memory MCP namespace 設定

> **TBD: cmd_364 Phase 3 完了後に追記予定**

Memory MCP の跨ぎ汚染を防ぐための namespace 設定方法はここに追記される。
Phase 3 軍師レビュー結果を反映後、家老が更新する。

---

## 注意事項

- **Secret 値は一切記載・コミットしない**（値取得・交換は殿専権）
- **repo path は必ず絶対パスで記録**（`/mnt/c/Users/ammac/...`）
- **TBD のまま push して構わない**。確定後にその都度 Edit で更新。
- `1 commit = 1 subtask` 原則（AD-007 教訓: commit と diff 実態の乖離防止）
- 各 step 完了時に context/{project_id}.md の `最終更新` 日付を更新
