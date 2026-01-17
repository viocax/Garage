# Product Definition

## 1. Vision
**Garage** is the ultimate driving companion and vehicle management utility for car enthusiasts, daily commuters, and multi-vehicle owners. It unifies real-time driving safety (speed camera alerts, HUD) with comprehensive vehicle lifecycle management (maintenance, expenses, cloud sync) into a single, premium application with a modern "Glassmorphism" aesthetic.

## 2. Target Audience
*   **Car Enthusiasts:** Users who meticulously track maintenance, modifications, and fuel stats, and appreciate high-quality visuals like 3D car models.
*   **Daily Commuters:** Drivers requiring reliable, real-time alerts for fixed speed cameras to ensure safety and avoid fines.
*   **Multi-Vehicle Owners:** Individuals or families managing records and maintenance schedules for multiple cars or motorcycles.

## 3. Core Features

### Speed Camera Alerts (Driving Safety)
*   **Real-time Monitoring:** GPS-based speed detection with a visual speedometer and HUD-style interface.
*   **Intelligent Alerts:**
    *   **Fixed Camera Warning:** Alerts based on distance (configurable: 500m - 2000m) and speed limit.
    *   **Voice Announcements:** TTS (Text-to-Speech) for approaching cameras and speed limits.
    *   **Visual Warning:** Color-coded speed display (White: Normal, Orange: Near Limit, Red: Speeding).
*   **3D Visuals:** Interactive 3D vehicle model that animates based on driving speed.
*   **Map Integration:** OpenStreetMap via `flutter_map` with Standard and Satellite modes, using QuadTree for efficient camera lookups.
*   **Background Operation:** Supports background location tracking for alerts even when the screen is off (Future/WIP).

### Vehicle Management (Record Keeping)
*   **Garage Profile:** Manage multiple vehicles with custom profiles and order.
*   **Comprehensive Logging:**
    *   **Fuel:** Track date, cost, mileage, fuel type (92/95/98/Diesel), and liters.
    *   **Maintenance:** Track items, costs, and set "Next Maintenance Mileage" for health calculations.
    *   **Other Expenses:** General expense logging with notes.
*   **Health Tracker:** Visual "Health Percentage" bar based on remaining mileage until next maintenance.
*   **Statistics:** Interactive charts for monthly spending, fuel efficiency, and cost breakdowns.
*   **Cloud Sync:** Robust backup and restore to iCloud (iOS) and Google Drive (Android/iOS) using JSON export/import.

### Monetization & Rewards
*   **Hybrid Ad Model:** Integrated with Google AdMob.
    *   **Banner:** Non-intrusive bottom banners in list views.
    *   **Interstitial:** Full-screen ads after completing actions (e.g., adding a record), with a cooldown period.
    *   **Native:** Seamlessly integrated ads within the record list (every ~8 items).
    *   **App Open:** Ads displayed when returning to the app.
*   **Rewarded Actions:**
    *   **Ad Tickets:** Watch rewarded ads to earn tickets that bypass interstitial ads.
    *   **Temporary Ad Removal:** Watch ads to remove banner ads for a set duration (e.g., 12 hours).

### User Experience
*   **Design Language:** Apple-style "Glassmorphism" UI with Dark Theme support.
*   **Localization:** Complete support for Traditional Chinese and English.
*   **Privacy First:** Local-first architecture using Isar database; Cloud Sync is user-initiated.

## 4. Roadmap

### Phase 1 (Current)
*   Fixed speed camera alerts.
*   Complete CRUD for vehicle records.
*   Local storage and Cloud Sync (iCloud/Google Drive).
*   AdMob integration with Reward system.

### Phase 2 (Planned)
*   **Interval Speed Checks:** Logic to calculate average speed between two points.
*   **Navigation Integration:** Turn-by-turn directions.
*   **Subscription Model:** Premium tier for ad-free experience, advanced charts, and automatic cloud sync.
*   **Data Export:** Export records to CSV/PDF.

## 5. Success Metrics
*   **User Retention:** High DAU for driving mode and WAU for record keeping.
*   **Monetization:** Balanced ad revenue without compromising user experience (monitored via store ratings).
*   **Stability:** Crash-free sessions > 99% (tracked via Crashlytics).
*   **Performance:** Consistent 60fps UI, particularly for map and 3D rendering.