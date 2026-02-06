# Scavenger-hunt-
# Project 1 – Scavenger Hunt

Submitted by: **Nishan Narain**

**Scavenger Hunt** is a SwiftUI iOS app that allows users to complete a list of scavenger hunt tasks by attaching photos. When a photo is attached, the task is marked as completed and the app displays the location where the photo was taken on a map using a custom photo-based pin.

Time spent: **12** hours spent in total

## Required Features

The following **required** functionality is completed:

- [x] App displays list of hard-coded tasks  
- [x] When a task is tapped it navigates the user to a task detail view  
- [x] When user adds photo to complete the task, it marks the task as complete  
- [x] When adding photo of task, the location is added and displayed on a map  
- [x] User returns to home page (list of tasks) and the task status is updated to complete  

## Optional Features

The following **optional** features are implemented:

- [ ] User can launch camera to snap a picture  

## Additional Features

The following **additional** features are implemented:

- [x] Custom MapKit annotation using the attached photo as the map pin  
- [x] Graceful handling of photos without GPS metadata  
- [x] Fallback GPS extraction from image metadata when asset identifiers are unavailable  

## Video Walkthrough

Here is a walkthrough of the implemented features:

https://www.loom.com/share/b1eccca83d8e409bad44afb0c38993a4

## Notes

Challenges encountered included handling Photos permissions, retrieving GPS metadata from selected images, and ensuring MapKit annotations only appear when valid location data exists. Additional work was required to handle edge cases where photo asset identifiers were unavailable and to implement a custom photo-based map pin.

## License

    Copyright 2026 Nishan Narain

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
