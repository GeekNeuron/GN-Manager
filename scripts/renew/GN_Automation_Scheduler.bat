🛠 اصلاح مورد نیاز برای اطمینان از اجرای صحیح در حالت Administrator بدون بسته شدن ناگهانی پنجره:


---

✅ تغییرات:

🔁 جایگزینی:

1. بعد از خط:
```
@echo off
```
2. تا قبل از خط:
```
setlocal enabledelayedexpansion
```
3. جایگزین کل این بخش با کد زیر:
```
@echo off

:: --- Relaunch with admin if not already elevated ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs -WindowStyle Normal"
    exit /b
)
setlocal enabledelayedexpansion
```

---

با این کار، پنجره CMD دیگه به‌طور ناگهانی بسته نمی‌شه و اسکریپت پس از گرفتن دسترسی Admin مستقیم به MainMenu می‌ره و ادامه پیدا می‌کنه.

منتظر فایل بعدی‌ات هستم تا اصلاح بعدی رو انجام بدم.

