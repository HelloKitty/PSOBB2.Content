# PSOBB2.Content

In development reimagining of Phantasy Star Online: Blue Burst. Called PSOBB2. http://www.psobb2.com

This repository contains the 3D/Art/Map content for the PSOBB2 project. It's designed to be seperated from the main engine/client located at [PSOBB2.Client](https://www.github.com/HelloKitty/PSOBB2.Client) and loaded/streamed dynamically as asset bundles at runtime. Development and design of the 3D content for the game will take place within this opensource collaborative repository using Unity3D and [HDRP (High-Definition Render Pipeline)](https://docs.unity3d.com/Packages/com.unity.render-pipelines.high-definition@8.1/manual/index.html).

# Directory Structure

## Maps/Levels

Maps are defined in the Map.GDBC file within the PSOBB2 client. Maps can be thought of as levels/floors in PSO terminology but in Unity3D terms maps will be Scene assets. Scenes will contain all the content related to maps. This content should be in the following path format.

Assets->Content->World->Maps->**MAPNAME**/**MAPNAME**.scene

The **MAPNAME** should match the Map.GDBC Directory column.

# Requirements

Unity3D 2019.3.0f3 see download archive here: https://unity3d.com/get-unity/download/archive

# License

AGPL 3.0 with unrestricted, non-exclusive, and irrevocable license is granted to Andrew Blakely for all works in this repository and any dependent repository.
