# AIぴた (AutonomousBusiness)

最終更新: 2026-04-30

## 概要

AIぴたは Mats Labo（代表: 森 淳史）が運営する AI サービスプラットフォーム。aipita.jp ポータルを通じてユーザーが AI サービスを契約・利用できる SaaS 基盤を提供。第一弾サービスとして OshiWatch（推し活ニュース配信）を展開。Stripe による月額課金、Supabase による認証・DB・Edge Functions を基盤とする。

事業者名: Mats Labo / 代表: 森 淳史 / 連絡先: contact@matslabo.jp / 所在地: 東京都（仮）

## リポジトリ

- main repo (portal + pipeline): `/mnt/c/Users/ammac/AutonomousBusiness`
- frontend (aipita.jp): `/mnt/c/Users/ammac/aipita/Ai-pita-Frontend`
- 関連リポ: なし（2 リポ構成）

## 主担当・履歴

- 担当 ash: ashigaru1〜7（タスク内容により割当）
- 過去 cmd: cmd_295〜367（以下に主要履歴）

| cmd 範囲 | 内容 |
|----------|------|
| cmd_295〜319 | 初期構築・Supabase EF 初回 deploy・ポータル基本機能 |
| cmd_320〜334 | Vercel シークレット入替（漏洩対応 cmd_334）・stg alias 整備 |
| cmd_348〜349 | stg alias 保護（OshiWatch=B-2+E, aipita-portal=D）|
| cmd_350〜353 | OshiWatch stg DB 登録不発火ゼロベース再調査→真因確定（`verify_jwt=true` で 11 日間 EF 未実行）→ `--no-verify-jwt` 再 deploy で解消 |
| cmd_354 | Ai-pita-Frontend `.knowledge/` 新規作成・学習更新 |
| cmd_355 | shutsujin_departure.sh Learning Update 自動呼び出し削除 |
| cmd_356 | Learning Update 後追い（DP-001 訂正・新教訓 L1〜L5 永続化）|
| cmd_357 | dashboard 整理・バックログセクション新設 |
| cmd_358 | B-1 課金無限発生リスク対策（Stripe idempotency / 既契約チェック / subscriptionGuard.ts / website 表記更新）Phase 1+2+3+5 完了、統合 E2E 残 4 シナリオ Stripe CLI 後 |
| cmd_359 | B-2 OshiWatch サブスクメール配信時刻ズレ修正（UTC→JST cron 修正）|
| cmd_360 | B-3 ポータル「定額プラン準備中」セクション削除 |
| cmd_361 | M-1 ローンチ承認前の却下機能実装 + StudyPulse 却下 |
| cmd_362 | マルチプロジェクト対応構造調査（殿確定: MatsMoneyLabo + CoconMusicSchoolSystem 独立事業）|
| cmd_363 | TEST_EMAIL hardcode 除去（全購読者集中送信バグ緊急修正）|
| cmd_364 | 案A+ 実装（本 cmd）|
| cmd_367 | cmd_358 Phase 5 LU（DP-003/004 / AD-006/007 / new-service-checklist.md）|

## .knowledge/

- 場所（AutonomousBusiness）: `/mnt/c/Users/ammac/AutonomousBusiness/.knowledge/`
- 場所（Ai-pita-Frontend）: `/mnt/c/Users/ammac/aipita/Ai-pita-Frontend/.knowledge/`
- 内容: debug-patterns.md / architecture-decisions.md / new-service-checklist.md / handoff.md（Claude.ai 管理）

## 主要 stack

- **Frontend**: Next.js (App Router) / TypeScript / Tailwind CSS → Vercel deploy
- **Backend**: Supabase (PostgreSQL + Auth + Edge Functions) / Deno (EF runtime)
- **決済**: Stripe（月額課金 / webhook 署名検証 / idempotency）
- **インフラ**: Vercel（stg + production alias 分離）/ Supabase（stg project-ref: yaypbooktcbrkeskdkox）
- **Cron**: vercel.json cron（OshiWatch ダイジェスト: JST 毎週月曜 08:00 = UTC 日曜 23:00）

## 補足

- Stripe webhook: `supabase functions deploy stripe-webhook --no-verify-jwt` が必須（JWT なしで Stripe から直接呼ばれるため）
- stg alias 保護方針: OshiWatch=B-2+E alias / aipita-portal=D alias（cmd_349 確定）
- Secret 取扱い: 値の取得・交換は殿専権。エージェントは値非依存経路で作業（2026-04-26 厳命）
- 月曜 cron 監視: 次回 2026-05-04 08:00 JST に家老朝一確認予定（cmd_359/363 効果検証）
- 殿対応事項残: (b) OshiWatch stg ブラウザ再 E2E / (c) Stripe CLI 環境手配
