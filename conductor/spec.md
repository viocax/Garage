# UI Specifications

> This document defines the UI specifications and field descriptions for each functional page.

---

## Phase 1: Vehicle Records

### Records Page

**Screen Structure**
```
┌─────────────────────────────────────┐
│  Records                            │
├─────────────────────────────────────┤
│  🚗 Vehicle Selector                 │
│     ├─ Vehicle 1                    │
│     ├─ Vehicle 2                    │
│     └─ + Add Vehicle                │
│                                     │
│  ┌─────────────────────────────────┐│
│  │ Maintenance Health Bar          ││
│  │ [====== 80% ======]            ││
│  │ Next Service: 2000 km           ││
│  └─────────────────────────────────┘│
│                                     │
│  ┌─────────────┐ ┌─────────────────┐│
│  │ This Month  │ │ Total Spent     ││
│  │ $12,500    │ │ $156,200       ││
│  └─────────────┘ └─────────────────┘│
│                                     │
│  Recent Records                     │
│  ⛽ Fuel        $1,200   2025/12/24  │
│  🔧 Service     $3,500   2025/12/20  │
│  📋 Other       $500     2025/12/15  │
│              ＋ Add Record           │
└─────────────────────────────────────┘
```

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

---

### Settings Page

**Setting Items**

| Category | Item | Type |
|----------|------|------|
| Display | Speed Unit (km/h / mph) | Selection |
| Display | Map Mode (Standard / Satellite) | Selection |
| Vehicle | Vehicle Management | Navigation |
| About | App Version, Privacy Policy, Contact Us | Navigation |

---

## Phase 2: QR Code & Cloud Sync

### Invoice Scanner Page

**Functional Specs**
- E-Invoice QR Code scanning
- Automatic parsing of amount and date
- Apply to "Add Record" form

**Supported Formats**
- Ministry of Finance E-Invoice QR Code (Left side)
- Parsed Fields: Invoice Number, Date, Amount

---

### Cloud Sync Page

**Functional Specs**
- Manual Backup / Restore
- Data Format: JSON
- Platform Support:
  - iOS: iCloud, Google Drive
  - Android: Google Drive

---

## Phase 3: Speed Camera

### Speed Camera Page

**Screen Structure**
```
┌─────────────────────────────────────┐
│      🗺️ Map Area                     │
│      (OpenStreetMap / flutter_map)   │
│                                     │
│           ┌───────────┐             │
│           │    72     │             │
│           │   km/h    │             │
│           └───────────┘             │
│                                     │
│         ┌─────────────────┐         │
│         │ ⚠️ 500m Limit 50 │         │
│         └─────────────────┘         │
│                                     │
│      ┌────────────────────────┐     │
│      │   🚗 3D Vehicle Anim   │     │
│      └────────────────────────┘     │
└─────────────────────────────────────┘
```

**Speed Display Specs**

| Item | Spec |
|------|------|
| Source | GPS speed (geolocator) |
| Format | Integer, supports km/h or mph |
| Color Logic | Normal: White, Near Limit: Orange, Speeding: Red |

**Speed Camera Alerts**

| Item | Spec |
|------|------|
| Alert Distance | Configurable (500m / 1000m / 1500m / 2000m) |
| Display Content | Distance + Speed Limit |
| Alert Method | Visual + TTS Voice Announcement |
| Performance | QuadTree for fast lookup |

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
