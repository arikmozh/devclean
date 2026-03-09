# SubKill — Launch Checklist

> מסמך מעקב להשקת האפליקציה ב-App Store

---

## שלב א׳: חובה להשקה

### 1. אתר Privacy Policy
- [ ] ליצור ריפו `subkill-site` ב-GitHub (או להשתמש ב-GitHub Pages של ריפו קיים)
- [ ] להעלות את `docs/privacy-policy.html` כ-`index.html` בתיקיית `/privacy`
- [ ] להפעיל GitHub Pages (Settings → Pages → Deploy from branch)
- [ ] לוודא שהכתובת עובדת: `https://arikmozh.github.io/subkill-site/privacy`
- [ ] חלופה: Netlify — drag & drop של התיקייה

### 2. כתובת מייל תמיכה
- [ ] ליצור `subkill@klause.dev` (אם יש דומיין)
- [ ] חלופה: להשתמש במייל קיים
- [ ] לעדכן את המייל ב-`privacy-policy.html` ו-`app-store-listing.md`

### 3. App Store Screenshots (6 סקרינשוטים)
צריך עבור 2 גדלים:
- **6.7"** — iPhone 15 Pro Max / iPhone 16 Pro Max (1290 × 2796)
- **6.1"** — iPhone 15 Pro / iPhone 16 Pro (1179 × 2556)

סקרינשוטים נדרשים:

| # | מסך | כיתוב (ASO) | איך לצלם |
|---|------|-------------|----------|
| 1 | Dashboard עם DrainTank | "Watch your subscriptions drain your wallet in real-time" | להוסיף 4-5 מנויים, לצלם Dashboard |
| 2 | Smart Insights | "Smart insights tell you exactly where to cut spending" | לגלול למטה ל-Insights |
| 3 | Add Subscription (Quick Pick) | "40+ services ready to add in one tap" | לפתוח Add sheet |
| 4 | Statistics | "Beautiful statistics show where every dollar goes" | לעבור ל-Statistics tab |
| 5 | Cancel Animation | "Cancel with satisfaction — haptics, confetti, savings" | לבטל מנוי ולצלם ברגע הנכון |
| 6 | Widget (3 גדלים) | "Home screen widgets keep your spending in check" | להוסיף widgets למסך הבית |

**איך לצלם:**
```bash
# צילום מסך מהסימולטור
xcrun simctl io booted screenshot screenshot1.png
```

### 4. IAP ב-App Store Connect
ליצור 3 מוצרים מסוג **Consumable**:

| Product ID | שם | מחיר |
|-----------|-----|------|
| `com.klause.subkill.tip.small` | Coffee Tip | $1.99 |
| `com.klause.subkill.tip.medium` | Pizza Tip | $4.99 |
| `com.klause.subkill.tip.large` | Amazing Tip | $9.99 |

**שלבים ב-App Store Connect:**
1. My Apps → SubKill → Features → In-App Purchases
2. לחץ "+" → Consumable
3. למלא: Reference Name, Product ID, Price, Display Name, Description
4. להוסיף Screenshot של ה-Tip Jar screen (לצורך Review)
5. לחזור על זה ל-3 המוצרים

### 5. TestFlight
- [ ] ב-Xcode: Product → Archive
- [ ] ב-Organizer: Distribute App → App Store Connect
- [ ] להמתין ל-processing (10-30 דקות)
- [ ] ב-App Store Connect: TestFlight → להוסיף בודקים פנימיים
- [ ] לבדוק: onboarding, הוספת מנוי, ביטול, widget, notifications
- [ ] לתקן באגים שנמצאו

### 6. הגשה ל-App Store
- [ ] App Store Connect → App Information:
  - Name: `SubKill - Subscription Tracker`
  - Subtitle: `Stop the Money Drain. No Sub.`
  - Category: Finance (Primary), Utilities (Secondary)
  - Privacy Policy URL
  - Support URL
- [ ] Pricing: $4.99
- [ ] Age Rating: 4+
- [ ] App Review Information: demo notes + contact
- [ ] להעלות screenshots
- [ ] להדביק Description + Promotional Text + Keywords
- [ ] Spanish (Mexico) locale: להוסיף כיתוב + keywords נוספים
- [ ] Submit for Review
- [ ] להמתין 24-48 שעות (לפעמים עד שבוע)

---

## שלב ב׳: שיפורים לפני השקה (מומלץ)

### 7. בדיקה בסימולטור
- [ ] Onboarding flow — 4 עמודים + skip
- [ ] הוספת מנוי ידנית
- [ ] הוספת מנוי מ-Quick Pick
- [ ] עריכת מנוי
- [ ] ביטול מנוי — אנימציה + haptics
- [ ] Dashboard: DrainTank, QuickStats, Insights, Search, Sort
- [ ] Statistics: donut chart, top 5, fun facts
- [ ] Settings: currency, reminders, share, export CSV, rate, tip jar
- [ ] Widget: Small, Medium, Large
- [ ] Empty state (בלי מנויים)
- [ ] Notifications (renewal reminder)

### 8. Launch Screen
- [ ] ליצור LaunchScreen.storyboard או SwiftUI launch screen
- [ ] לוגו SubKill על רקע navy (#0A1628)

---

## שלב ג׳: אחרי השקה (v1.1+)

### 9. Live Activity / Dynamic Island
- הצגת חידוש הבא 48 שעות לפני
- ActivityKit integration
- Compact + Expanded + Lock Screen views

### 10. StandBy Mode Widget
- תצוגת שעון עם burn rate יומי
- עיצוב מינימליסטי לStandBy

### 11. Yearly Wrapped
- סיכום שנתי בסגנון Spotify Wrapped
- כמה שילמת, כמה חסכת, הקטגוריה הכי יקרה
- כרטיסים שניתן לשתף (ShareCardView)

### 12. iCloud Sync
- CloudKit container
- סנכרון בין מכשירים
- Merge conflicts handling

### 13. לוקליזציה
- עברית (RTL support)
- גרמנית, צרפתית, ספרדית
- Keywords מקומיים לכל שפה

### 14. שיווק
- [ ] Apple Search Ads — $50-100 תקציב התחלתי
- [ ] ProductHunt launch — להכין assets + description
- [ ] Reddit: r/iOSapps, r/personalfinance, r/subscriptions
- [ ] Twitter/X: השקה + demo video
- [ ] Dev.to / Medium: מאמר על הבנייה
