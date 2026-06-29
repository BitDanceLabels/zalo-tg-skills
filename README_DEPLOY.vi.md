# Zalo Telegram Bridge - Deploy & Operate

Tai lieu nay mo ta cach chay `zalo-tg-skills` tren may local/macOS hien tai, cach backup cac file quan trong, va checklist truoc khi dong goi Docker.

## 1. Mo hinh dang chay

```text
Zalo account
  <-> zalo-tg bridge Node.js
  <-> Telegram bot
  <-> Telegram supergroup co bat Topics
```

Moi chat Zalo ca nhan hoac nhom se duoc map thanh mot Telegram topic rieng. Nhan tin trong topic Telegram se gui nguoc ve Zalo.

## 2. File quan trong

```text
.env
  Chua TG_TOKEN va TG_GROUP_ID. Khong commit.

credentials.json
  Session dang nhap Zalo. Bao ve nhu mat khau. Khong commit.

data/topics.json
  Mapping Zalo chat ID <-> Telegram topic ID. Nen backup.

~/Library/LaunchAgents/ai.thewan.zalo-tg-bridge.plist
  macOS LaunchAgent de tu chay khi user login.

~/Library/Logs/thewan/zalo-tg-bridge.log
  Log stdout.

~/Library/Logs/thewan/zalo-tg-bridge.err.log
  Log stderr.
```

## 3. Cau hinh `.env`

Tao file `.env` trong root repo:

```env
TG_TOKEN=telegram_bot_token
TG_GROUP_ID=-100xxxxxxxxxx
ZALO_CREDENTIALS_PATH=./credentials.json
DATA_DIR=./data
```

Yeu cau Telegram:

```text
1. Tao bot bang BotFather.
2. Tao Telegram supergroup rieng.
3. Bat Topics/Forum.
4. Add bot vao group.
5. Cap admin cho bot:
   - Manage topics
   - Delete messages
   - Pin messages
   - Manage group
```

Kiem tra group ID dung phai la supergroup, thuong co dang `-100...`.

## 4. Cai dat local

```bash
cd /Users/nhutpham/Downloads/thewan-workspace/zalo-tg-skills
npm ci
npm run build
```

Chay thu foreground:

```bash
npm start
```

Neu chua co `credentials.json`, gui `/login` trong Telegram group de bot gui QR, sau do quet bang app Zalo.

## 5. Chay cung macOS bang LaunchAgent

Service hien dang duoc cai tai:

```bash
~/Library/LaunchAgents/ai.thewan.zalo-tg-bridge.plist
```

Kiem tra service:

```bash
launchctl list | rg 'ai.thewan.zalo-tg-bridge'
ps aux | rg '[z]alo-tg|dist/index.js'
tail -n 80 ~/Library/Logs/thewan/zalo-tg-bridge.log
```

Restart service:

```bash
launchctl kickstart -k gui/$(id -u)/ai.thewan.zalo-tg-bridge
```

Dung service:

```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/ai.thewan.zalo-tg-bridge.plist
```

Bat lai service:

```bash
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/ai.thewan.zalo-tg-bridge.plist
launchctl enable gui/$(id -u)/ai.thewan.zalo-tg-bridge
```

## 6. Test sau khi deploy

Checklist:

```text
1. Service co PID trong launchctl.
2. Log co dong "Telegram bot started".
3. Log co dong "Zalo dang nhap thanh cong".
4. Nhan Zalo tu tai khoan khac vao account nay.
5. Telegram group tu tao topic moi.
6. Reply trong topic Telegram.
7. Tin nhan xuat hien nguoc ve Zalo.
```

Lenh bot huu ich:

```text
/login
/search ten_ban_be
/topic list
/topic info
/topic delete
/recall
```

## 7. Backup va restore

Backup toi thieu:

```bash
cd /Users/nhutpham/Downloads/thewan-workspace/zalo-tg-skills
mkdir -p ~/Backups/thewan-zalo-tg
cp .env credentials.json ~/Backups/thewan-zalo-tg/
cp -R data ~/Backups/thewan-zalo-tg/
```

Restore:

```bash
cd /Users/nhutpham/Downloads/thewan-workspace/zalo-tg-skills
cp ~/Backups/thewan-zalo-tg/.env .
cp ~/Backups/thewan-zalo-tg/credentials.json .
cp -R ~/Backups/thewan-zalo-tg/data .
chmod 600 .env credentials.json
npm ci
npm run build
launchctl kickstart -k gui/$(id -u)/ai.thewan.zalo-tg-bridge
```

## 8. Bao mat

Khong commit cac file sau:

```text
.env
credentials.json
data/*.json
*.log
```

`credentials.json` tuong duong session dang nhap Zalo. Neu lo file nay, can logout session Zalo tren thiet bi va login lai.

Telegram group nen de private va chi moi nguoi tin cay, vi ai co quyen nhan trong topic deu co the gui tin qua Zalo.

## 9. Khi nao nen Docker

Chua can Docker neu service dang chay on tren Mac. Docker nen lam khi:

```text
- Muon deploy len VPS/Google Cloud.
- Muon chay nhieu bridge doc lap.
- Muon backup/migrate de hon.
- Muon dong goi thanh service chuan cho team.
```

Khi Docker hoa, bat buoc mount volume:

```text
/app/.env
/app/credentials.json
/app/data
/app/logs
```

Khong bake `.env` hoac `credentials.json` vao image.

