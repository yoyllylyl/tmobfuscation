# tmobfuscation

Обход DPI в Туркменистане через HTTP-обфускацию.  
Xray с кастомным `config.json`, имитирующим браузерный трафик.

---

## 🧪 Состояние

**Alpha 0.1** — работает только базовая обфускация через заголовок `Host`.  
Проект на ранней стадии, безопасности нет, всё вручную.

---

## 📦 Что внутри

- `server/config.json` — конфиг для Xray с протоколом XHTTP
- `client/example-v2box.json` — конфиг для клиента V2Box
- `notes/alpha-notes.md` — мои технические заметки

---

## 🚀 Быстрый запуск (сервер)

```bash
xray -config server/config.json
