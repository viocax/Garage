# UI Specifications

> This document defines the UI specifications and field descriptions for each functional page.

---

## Phase 1: Core Experience (Records + Visual Speedometer)

### Records Page
**Record Types**
| Type | Required Fields | Optional Fields |
|------|-----------------|-----------------|
| Fuel | Date, Amount, Mileage, Fuel Type | Liters, Price/Unit, Remaining Fuel |
| Service | Date, Amount, Mileage, Items | Also Next Service Mileage |
| Other | Title, Date, Amount | Mileage, Note |

**Maintenance Health Calculation**
```
healthPercentage = remindKm / maintenanceIntervalKm
(Clamped between 0.0 ~ 1.0)
```

### Speed Camera Page (Visual Only)
**Speed Display Specs**
| Item | Spec |
|------|------|
| Source | GPS speed (geolocator) |
| Format | Integer, supports km/h or mph |
| Color Logic | Normal: White, Near Limit: Orange, Speeding: Red |

**Speed Camera Alerts (Visual Only)**
| Item | Spec |
|------|------|
| Alert Distance | Configurable (500m / 1000m / 1500m / 2000m) |
| Display Content | Distance + Speed Limit |
| **Note** | **No Voice/TTS announcements in Phase 1** |

**Interval Speed Checks**
| Phase | Trigger | System Behavior |
|-------|---------|-----------------|
| Entry | Pass Start Point | Record time, start calculation |
| Inside | Between Start & End | Show "Interval Check" + Avg Speed + Distance Left |
| Exit | Pass End Point | Calculate final avg speed, determine overspeed |

**3D Vehicle Scene**
| Item | Spec |
|------|------|
| Tech | model_viewer_plus |
| Dynamics | Animation speed adjusts based on vehicle speed |

### Settings Page
**Setting Items**
| Category | Item | Type |
|----------|------|------|
| Display | Speed Unit (km/h / mph) | Selection |
| Display | Map Mode (Standard / Satellite) | Selection |
| Vehicle | Vehicle Management | Navigation |
| Speed | Speed Camera Settings | **(Visual alerts config only)** |
| About | App Version, Privacy Policy, Contact Us | Navigation |

---

## Phase 2: Advanced Data & Monetization

### Invoice Scanner Page
**Functional Specs**
- E-Invoice QR Code scanning
- Automatic parsing of amount and date
- Apply to "Add Record" form

**Supported Formats**
- Ministry of Finance E-Invoice QR Code (Left side)
- Parsed Fields: Invoice Number, Date, Amount

### Cloud Sync Page
**Functional Specs**
- Manual Backup / Restore
- Data Format: JSON
- Platform Support:
  - iOS: iCloud, Google Drive
  - Android: Google Drive

### Subscription Model
**Subscription Plans**
- Free Tier: Basic Records, Speedometer (with Ads), Local Data
- Pro Tier: Cloud Sync, Ad-free experience, Advanced Charts

---

## Phase 3: Enhanced Assistance

### Voice Alerts (TTS)
**Functional Specs**
- Add Text-To-Speech (TTS) engine integration
- Voice announcements for:
  - Fixed Speed Cameras ("Speed camera ahead, limit 60")
  - Interval Speed Checks ("Entering interval check zone, limit 70")
  - Overspeed warnings
- Settings to toggle Voice/Sound effects

