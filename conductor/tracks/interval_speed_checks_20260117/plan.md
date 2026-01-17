# Implementation Plan - Interval Speed Checks

## Phase 1: Data Modeling & Repository
- [x] Task: Define `IntervalZone` data model
    - [x] Create `IntervalZone` class with `startCameraId`, `endCameraId`, `distance`, `speedLimit`.
    - [x] Update `SpeedCamera` model to optionally link to a zone ID or type.
    - [x] Write Unit Tests for model serialization.
- [x] Task: Update Repository
    - [x] Modify `SpeedCameraRepository` to fetch/store interval zones.
    - [x] Add mock data for an Interval Zone for testing.
    - [x] Write Unit Tests for repository data retrieval.
- [x] Task: Conductor - User Manual Verification 'Phase 1: Data Modeling & Repository' (Protocol in workflow.md)

## Phase 2: Logic Engine (IntervalManager)
- [x] Task: Create `IntervalManager` Service
    - [x] Implement `enterZone(zone)`: Record entry time and location.
    - [x] Implement `updatePosition(location)`: Calculate distance traveled and current average speed.
    - [x] Implement `exitZone()`: Reset state.
    - [x] Write Unit Tests for average speed calculation math.
- [x] Task: Integrate with Location Service
    - [x] Listen to location stream in `IntervalManager`.
    - [x] Trigger entry/exit based on geofence/distance to start/end points.
    - [x] Write Unit Tests for trigger logic.
- [x] Task: Conductor - User Manual Verification 'Phase 2: Logic Engine' (Protocol in workflow.md)

## Phase 3: UI & HUD Integration
- [x] Task: Update Speed Bloc
    - [x] Add `IntervalState` to `SpeedState`.
    - [x] Listen to `IntervalManager` updates and emit new states.
    - [x] Write Bloc Tests.
- [x] Task: Implement Interval HUD Widget
    - [x] Create `IntervalInfoWidget` to display: Average Speed, Speed Limit, Remaining Distance.
    - [x] Visual style: Orange/Red background or border if `avgSpeed > limit`.
    - [x] Integrate into main `SpeedPage`.
    - [x] Write Widget Tests.
- [x] Task: Conductor - User Manual Verification 'Phase 3: UI & HUD Integration' (Protocol in workflow.md)

## Phase 4: Alerts & Testing
- [x] Task: Implement TTS Alerts
    - [x] "Entering average speed check zone. Limit 60."
    - [x] "Average speed too high." (if speeding)
    - [x] "Leaving zone."
- [ ] Task: Final Integration Test
    - [ ] Simulate a drive through the mock zone.
    - [ ] Verify UI switches modes and alerts trigger correctly.
- [ ] Task: Conductor - User Manual Verification 'Phase 4: Alerts & Testing' (Protocol in workflow.md)
