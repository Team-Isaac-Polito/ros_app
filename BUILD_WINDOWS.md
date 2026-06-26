# Building RESE.Q Control Station for Windows

This document describes how to build and run the Flutter desktop control app
for Windows. The app connects to the Jetson Orin Nano over Ethernet via the
rosbridge WebSocket protocol (port 9090).

## Prerequisites

1. **Install Flutter SDK** (stable channel, ≥ 3.9.2):
   ```powershell
   # Using git
   git clone https://github.com/flutter/flutter.git -b stable $env:USERPROFILE\flutter
   # Add to PATH
   $env:PATH = "$env:USERPROFILE\flutter\bin;$env:PATH"
   ```

2. **Enable Windows desktop support**:
   ```powershell
   flutter config --enable-windows-desktop
   ```

3. **Install Visual Studio 2022** with "Desktop development with C++" workload
   (required by Flutter for Windows builds).

4. **Verify the setup**:
   ```powershell
   flutter doctor
   ```

## Building

From the `ros_app` directory:

```powershell
# Install dependencies
flutter pub get

# Build release executable
flutter build windows --release
```

The output will be at:
```
build\windows\x64\runner\Release\isaac_app.exe
```

## Running

### Development / Debug

```powershell
flutter run -d windows
```

### Release

```powershell
.\build\windows\x64\runner\Release\isaac_app.exe
```

## Network Setup (Ethernet to Jetson Orin Nano)

### Jetson side (inside Docker)

The Docker container runs with `--network host`, so rosbridge listens on
`0.0.0.0:9090` and is reachable on every Jetson network interface,
including the Ethernet port.

Assign a static IP to the Jetson's Ethernet interface (e.g. `eth0`):

```bash
# Inside the Docker container or on the Jetson host
sudo ip addr add 192.168.8.104/24 dev eth0
sudo ip link set eth0 up
```

### Windows side

Connect the Ethernet cable from the Windows computer to the Jetson dev kit.
Configure the Windows Ethernet adapter with a static IP on the same subnet:

```
IP address:  192.168.8.100
Subnet mask: 255.255.255.0
Gateway:     (leave empty)
```

### Selecting the robot IP in the app

Use the dropdown in the app bar to choose:
- **"Robot (Ethernet Direct)"** → `ws://192.168.8.104:9090` (direct cable)
- **"Local (Simulator)"** → `ws://localhost:9090` (local testing)

## Adding custom IP addresses

Edit `lib/features/main_page/data/robot_ip_notifier/robot_ip_list.dart` to
add or modify entries in the `robotIpListProvider` map.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| "Connection refused" | Verify rosbridge is running on the Jetson: `ros2 topic list` inside the container |
| "Timeout" | Ping the Jetson: `ping 192.168.8.104`. Check the Ethernet cable and IP config. |
| Blank camera view | Verify the camera nodes are running: `ros2 topic list \| grep image` |
| Map not loading | Verify SLAM is running and publishing `/map` |
