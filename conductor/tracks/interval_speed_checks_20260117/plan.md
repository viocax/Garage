# Implementation Plan - Interval Speed Checks

## Phase 1: Data Modeling & Repository
- [ ] Task: Define `IntervalZone` data model
    - [ ] Create `IntervalZone` class with `startCameraId`, `endCameraId`, `distance`, `speedLimit`.
    - [ ] Update `SpeedCamera` model to optionally link to a zone ID or type.
    - [ ] Write Unit Tests for model serialization.
- [ ] Task: Update Repository
    - [ ] Modify `SpeedCameraRepository` to fetch/store interval zones.
    - [ ] Add mock data for an Interval Zone for testing.
    - [ ] Write Unit Tests for repository data retrieval.
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Data Modeling & Repository' (Protocol in workflow.md)

## Phase 2: Logic Engine (IntervalManager)
- [ ] Task: Create `IntervalManager` Service
    - [ ] Implement `enterZone(zone)`: Record entry time and location.
    - [ ] Implement `updatePosition(location)`: Calculate distance traveled and current average speed.
    - [ ] Implement `exitZone()`: Reset state.
    - [ ] Write Unit Tests for average speed calculation math.
- [ ] Task: Integrate with Location Service
    - [ ] Listen to location stream in `IntervalManager`.
    - [ ] Trigger entry/exit based on geofence/distance to start/end points.
    - [ ] Write Unit Tests for trigger logic.
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Logic Engine' (Protocol in workflow.md)

## Phase 3: UI & HUD Integration
- [ ] Task: Update Speed Bloc
    - [ ] Add `IntervalState` to `SpeedState`.
    - [ ] Listen to `IntervalManager` updates and emit new states.
    - [ ] Write Bloc Tests.
- [ ] Task: Implement Interval HUD Widget
    - [ ] Create `IntervalInfoWidget` to display: Average Speed, Speed Limit, Remaining Distance.
    - [ ] Visual style: Orange/Red background or border if `avgSpeed > limit`.
    - [ ] Integrate into main `SpeedPage`.
    - [ ] Write Widget Tests.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: UI & HUD Integration' (Protocol in workflow.md)

## Phase 4: Alerts & Testing
- [ ] Task: Implement TTS Alerts
    - [ ] "Entering average speed check zone. Limit 60."
    - [ ] "Average speed too high." (if speeding)
    - [ ] "Leaving zone."
- [ ] Task: Final Integration Test
    - [ ] Simulate a drive through the mock zone.
    - [ ] Verify UI switches modes and alerts trigger correctly.
- [ ] Task: Conductor - User Manual Verification 'Phase 4: Alerts & Testing' (Protocol in workflow.md)
