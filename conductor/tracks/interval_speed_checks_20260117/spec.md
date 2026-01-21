# Track Specification: Interval Speed Checks

## Overview
Implement the "Interval Speed Check" (Average Speed Control) feature. This system calculates a vehicle's average speed between a defined entry point (Start Camera) and an exit point (End Camera). It alerts the user if their average speed exceeds the limit while traversing the zone.

## Goals
1.  **Detect Entry/Exit:** Accurately detect when the user enters and leaves an interval speed check zone.
2.  **Calculate Average Speed:** Real-time calculation of average speed since entering the zone.
3.  **Visual Feedback:** Display a specific "Interval Mode" UI showing average speed and remaining distance.
4.  **Alerts:** Provide visual and auditory warnings if the calculated average speed exceeds the zone's limit.

## Scope
*   **Data Model:** Update `Camera` or create `IntervalZone` model to support paired start/end points.
*   **Location Service:** Logic to trigger "Enter Zone" and "Exit Zone" events.
*   **UI/HUD:** New widget or state for the Speedometer view to show interval-specific data (Avg Speed vs Instant Speed).
*   **Simulation:** Basic ability to simulate entering/exiting a zone for testing.

## Out of Scope
*   Backend server integration (data is local for now).
*   Complex multi-segment zones (focus on simple A-to-B segments).

## key Components
1.  **IntervalManager (Service):** Singleton managing the state (Active/Inactive), start time, start location, and current average calculation.
2.  **SpeedCameraRepository:** Enhanced to return interval zones.
3.  **SpeedHUD Widget:** Updated to switch between "Instant Speed" and "Interval Average Speed" modes.
