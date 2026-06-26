# RESE.Q Control Station

Flutter desktop application for controlling the RESE.Q robot. Runs on the operator's Windows computer and connects to the Jetson Orin
Nano over Ethernet via the rosbridge WebSocket protocol.

## Building for Windows

See [BUILD_WINDOWS.md](BUILD_WINDOWS.md) for detailed build instructions.

Quick build:

```powershell
flutter pub get
flutter build windows --release
```

Output: `build\windows\x64\runner\Release\isaac_app.exe`

## Features

- **Control Panel**: Live SLAM map with waypoint drawing, joystick teleoperation
  (drive + arm), autonomy toggle, switch/button control
- **Camera Monitor**: Multi-camera view (RGB, thermal, detection output, USB cam)
  with hazmat and QR code detection overlays
- **Modules**: Dynamic node management (thermal camera, LiDAR, etc.) with
  start/stop toggles
- **Sensors**: Real-time velocity gauge and network bandwidth chart

## Architecture

```
┌─────────────────────┐   Ethernet   ┌──────────────────────────┐
│  Windows Computer   │◄────────────►│  Jetson Orin Nano        │
│  (Flutter Desktop)  │  WebSocket   │  (Docker Container)      │
│  isaac_app.exe      │  port 9090   │  - ROS 2 Humble          │
│                     │              │  - rosbridge-server      │
│                     │              │  - reseq_ros2 nodes      │
└─────────────────────┘              │  - Computer Vision       │
                                     └──────────────────────────┘
```

## Network Configuration

Default robot IPs (configurable in the app bar dropdown):

| Label | Address | Use Case |
|-------|---------|----------|
| Local (Simulator) | `ws://localhost:9090` | Local testing |
| Robot (Ethernet Direct) | `ws://192.168.8.104:9090` | Direct Ethernet cable |

## Documentation

- Team Isaac Outline: https://docs.teamisaac.it/collection/app-7tofEtYcFh/recent
