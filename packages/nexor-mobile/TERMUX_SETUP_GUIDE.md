# دليل تشغيل OpenCode على الهاتف

## 🚀 تشغيل OpenCode محلياً على هاتفك Android

هذا الدليل يشرح كيفية تشغيل OpenCode بالكامل على هاتفك بدون الحاجة لسيرفر خارجي.

---

## المتطلبات

- هاتف Android
- تطبيق Termux (مجاني)
- اتصال بالإنترنت (للتثبيت فقط)

---

## الخطوة 1: تثبيت Termux

### الطريقة 1: من F-Droid (موصى بها)
1. حمل F-Droid من: https://f-droid.org
2. ابحث عن "Termux"
3. ثبت التطبيق

### الطريقة 2: من GitHub
1. اذهب إلى: https://github.com/termux/termux-app/releases
2. حمل أحدث APK
3. ثبت التطبيق

⚠️ **ملاحظة:** لا تستخدم Termux من Google Play (نسخة قديمة)

---

## الخطوة 2: إعداد Termux

افتح Termux واكتب الأوامر التالية:

```bash
# تحديث الحزم
pkg update && pkg upgrade -y

# تثبيت الأدوات الأساسية
pkg install -y nodejs git
```

---

## الخطوة 3: تثبيت OpenCode

```bash
# تثبيت OpenCode عالمياً
npm install -g opencode-ai

# أو استخدام Bun (أسرع)
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc
bun install -g opencode-ai
```

---

## الخطوة 4: تشغيل OpenCode

```bash
# تشغيل OpenCode على المنفذ 4096
opencode --port 4096

# أو مع تحديد مجلد معين
cd ~/projects/my-project
opencode --port 4096
```

**ستظهر رسالة:**
```
✓ OpenCode server started on http://localhost:4096
```

---

## الخطوة 5: الاتصال من Nexor Mobile

1. افتح تطبيق Nexor Mobile
2. اضغط "Add Server"
3. أدخل المعلومات:
   - **Name:** Local OpenCode
   - **Host:** 127.0.0.1
   - **Port:** 4096
   - **Username:** (اتركه فارغاً)
   - **Password:** (اتركه فارغاً)
4. اضغط "Test Connection"
5. اضغط "Save"

---

## 💡 نصائح مهمة

### إبقاء OpenCode يعمل في الخلفية

```bash
# استخدام tmux للحفاظ على الجلسة
pkg install tmux
tmux new -s opencode
opencode --port 4096

# للخروج من tmux بدون إيقاف OpenCode:
# اضغط Ctrl+B ثم D

# للعودة للجلسة:
tmux attach -t opencode
```

### تشغيل تلقائي عند فتح Termux

أضف هذا السطر إلى `~/.bashrc`:

```bash
echo "alias start-opencode='tmux new -s opencode -d \"opencode --port 4096\"'" >> ~/.bashrc
```

الآن يمكنك كتابة `start-opencode` لتشغيل OpenCode في الخلفية.

---

## 🔧 حل المشاكل

### المشكلة: "command not found: opencode"

**الحل:**
```bash
# تأكد من تثبيت OpenCode
npm list -g opencode-ai

# إذا لم يكن مثبتاً، ثبته:
npm install -g opencode-ai
```

### المشكلة: "Port 4096 already in use"

**الحل:**
```bash
# ابحث عن العملية التي تستخدم المنفذ
lsof -i :4096

# أوقف العملية
kill -9 <PID>

# أو استخدم منفذ آخر
opencode --port 4097
```

### المشكلة: Nexor Mobile لا يتصل

**الحل:**
1. تأكد أن OpenCode يعمل في Termux
2. تأكد من استخدام `127.0.0.1` وليس `localhost`
3. تأكد من رقم المنفذ صحيح
4. جرب إعادة تشغيل OpenCode

---

## 📱 للمستخدمين المتقدمين

### تشغيل OpenCode كخدمة

```bash
# إنشاء سكريبت تشغيل
cat > ~/start-opencode.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd ~
opencode --port 4096
EOF

chmod +x ~/start-opencode.sh

# تشغيل عند بدء Termux
echo "~/start-opencode.sh &" >> ~/.bashrc
```

### استخدام Termux:Boot

1. ثبت Termux:Boot من F-Droid
2. أنشئ ملف: `~/.termux/boot/start-opencode`
3. أضف:
```bash
#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock
opencode --port 4096
```
4. اجعله قابل للتنفيذ: `chmod +x ~/.termux/boot/start-opencode`

---

## 🎯 المميزات

✅ **لا يحتاج إنترنت** (بعد التثبيت)
✅ **خصوصية كاملة** (كل شيء على هاتفك)
✅ **سريع جداً** (لا latency)
✅ **مجاني تماماً**
✅ **يعمل offline**

---

## ⚠️ القيود

- يحتاج Termux مفتوح في الخلفية
- يستهلك بطارية (استخدم tmux)
- لا يعمل على iOS بنفس الطريقة (استخدم iSH)

---

## 📚 موارد إضافية

- [Termux Wiki](https://wiki.termux.com)
- [OpenCode Documentation](https://opencode.ai/docs)
- [Nexor Mobile GitHub](https://github.com/your-repo)

---

## 🆘 الدعم

إذا واجهت أي مشاكل:
1. تحقق من [حل المشاكل](#-حل-المشاكل) أعلاه
2. افتح issue على GitHub
3. انضم إلى Discord server

---

**تم التحديث:** مارس 2026
