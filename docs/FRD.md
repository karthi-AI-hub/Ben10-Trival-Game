This is an internal **Functional Requirements Document (FRD)** designed for you, the developer. It skips the corporate fluff and focuses on the logic, architecture, and exact requirements needed to build "Alien 10: Hero Time Game" in Flutter.

---

# **Functional Requirements Document (FRD)**

**Project Name:** Alien 10: Hero Time Game
**Platform:** Android & iOS (via Flutter)
**Target Audience:** Ben 10 fans (Classic to Omniverse focus)
**Version:** 2.0 (Latest Version)

---

## **1. Project Overview**

A single-player 2D trivia game where users guess the Alien based on an image and a trivia question. The game features 500 levels, a life management system, and an aggressive but fair ad monetization strategy.

---

## **2. Tech Stack**

* **Framework:** Flutter (Dart)
* **State Management:** `Provider` (Recommended for simplicity) or `Riverpod`.
* **Local Storage:** `shared_preferences` (To save User Level and Current Lives).
* **Ad Network:** Google AdMob (`google_mobile_ads`).
* **Image Handling:** `cached_network_image` (To cache URLs for offline feel).
* **Data Source:** Local JSON file (`assets/data/classic.json`, etc.).

---

## **3. Game Logic & Algorithms**

### **A. The Data Structure**

The app reads from a local JSON file containing 500 objects.

```dart
class AlienLevel {
  final String imageUrl;
  final String question;
  final String answer; // The Correct Answer
}

```

### **B. The "Distractor" Algorithm (Dynamic Choices)**

Instead of hardcoding wrong answers, the app generates them at runtime:

1. Fetch current level object (Correct Answer).
2. Randomly select 3 *other* names from the full list of 500.
3. **Validation:** Ensure none of the 3 random names match the Correct Answer or each other.
4. **Shuffle:** Combine the 1 Correct + 3 Wrong answers and shuffle the list for display.

### **C. The Progression Logic**

* **Total Levels:** 500.
* **Winning:** If user selects Correct -> Increment `currentLevel` -> Save to Preferences -> Load Next.
* **Losing:** If user selects Wrong -> Decrement `lives` -> Save to Preferences -> Show Error Animation.

---

## **4. Functional Modules (UI Screens)**

### **I. Splash Screen**

* **Display:** App Logo + "Loading..."
* **Action:**
* Initialize AdMob SDK.
* Parse JSON data into memory.
* Check `SharedPreferences` for saved Level/Lives.
* Navigate to Home Screen.



### **II. Home Screen**

* **Display:**
* App Title ("Alien 10").
* "Play" Button (showing current level, e.g., "Level 42").
* Lives Counter (Heart Icon: x/5).
* Settings Icon (Sound Toggle, Privacy Policy/Disclaimer).



### **III. Gameplay Screen (The Core)**

* **Top Bar:**
* Current Level Indicator (e.g., "Level 15").
* Lives Indicator (Updates instantly on wrong guess).


* **Content Area:**
* **Image:** 200x200 (or larger) image of the Alien (Cached).
* **Question:** Text widget displaying the trivia hint.


* **Interaction Area:**
* **Grid/List:** 4 Buttons containing the shuffled names.
* **Feedback:**
* *Correct Tap:* Button turns Green -> Short delay -> Transition.
* *Wrong Tap:* Button turns Red -> Phone vibrates -> Life lost.





### **IV. Game Over Modal**

* **Trigger:** When `lives == 0`.
* **UI:** "Out of Lives!"
* **Primary Action (CTA):** "Watch Video to Revive (+1 Life)".
* **Secondary Action:** "Wait" (Timer) or "Quit".

---

## **5. Ad Strategy & Monetization**

### **A. Interstitial Ads (Forced Breaks)**

* **Trigger:** Modulo Logic.
```dart
if (currentLevel % 5 == 0) {
   // Show Ad
}

```


* **Placement:** displayed **after** the user answers correctly on a divisible level, but **before** the next level loads.
* **Frequency:** Every 5 levels. (Total 100 ads if user beats game).

### **B. Rewarded Video Ads (User Choice)**

* **Trigger:** Game Over Screen (Lives = 0).
* **Value:** Watch 30s video -> Reward: Restore 1 Life (Immediate Resume).
* **Fallback:** If ad fails to load, show a "Try Again Later" toast.

---

## **6. Data Persistence (Offline Capability)**

The game must remember progress even if the app is killed.

| Key | Type | Description |
| --- | --- | --- |
| `user_level` | Int | Default: 1. Max: 500. |
| `user_lives` | Int | Default: 5. Max: 5. |
| `last_life_loss_time` | Timestamp | (Optional) For regenerating lives over time. |

---

## **7. Asset Requirements**

* **JSON File:** The combined 1-500 JSON list.
* **Images:** No local asset images for Aliens (saves APK size). Use Placeholder image while loading network image.
* **Sounds:**
* `correct.mp3` (Ding)
* `wrong.mp3` (Buzz)
* `win_level.mp3` (Short cheerful sound)


* **Fonts:** A clean, bold font (e.g., "Press Start 2P" or "Roboto/Open Sans").

---

## **8. Constraints & Disclaimer Logic**

To prevent Play Store bans:

1. **About Screen:** Must contain text: *"This is a fan-made app. All characters and images are property of their respective owners."*
2. **Screenshots:** When taking screenshots for the Play Store, ensure you use the "Generic" UI or silhouettes if possible to avoid copyright bots, or use the generated questions but blur the artwork slightly if needed (though usually fan trivia is allowed if marked as such).

---

## **9. Development Roadmap (Checklist)**

1. **Setup:** `flutter create alien10`, add dependencies.
2. **Data Layer:** Create `Alien` model and `JsonParser`.
3. **State Layer:** Create `GameProvider` with `lives` and `level` variables.
4. **UI - Gameplay:** Build the layout with hardcoded data first.
5. **Logic Integration:** Connect Provider to UI (Dynamic 4 choices).
6. **Persistence:** Add `SharedPreferences` to save/load state.
7. **Ads:** Integrate AdMob (Interstitials & Rewarded).
8. **Polish:** Add animations (Green/Red button colors), sounds, and App Icon.
9. **Build:** Generate Android App Bundle (.aab).