# Xcode MCP Client - Essential Guide

Quick reference for building, running, and interacting with iOS apps using the Xcode MCP client.

## Essential Setup

### 1. Discover Projects
```bash
mcp_XcodeBuildMCP_discover_projs({ workspaceRoot: "/path/to/workspace" })
```

### 2. List Schemes
```bash
mcp_XcodeBuildMCP_list_schems_ws({ workspacePath: "/path/to/App.xcworkspace" })
```

### 3. List Simulators
```bash
mcp_XcodeBuildMCP_list_sims({ enabled: true })
```

## Build and Run

### Build and Run App
```bash
mcp_XcodeBuildMCP_build_run_ios_sim_name_ws({
  workspacePath: "/path/to/Sportsbook.xcworkspace",
  scheme: "BetssonCM STG",
  simulatorName: "iPhone 16 Pro"
})
```

### Build Only
```bash
mcp_XcodeBuildMCP_build_ios_sim_name_ws({
  workspacePath: "/path/to/Sportsbook.xcworkspace",
  scheme: "BetssonCM STG",
  simulatorName: "iPhone 16 Pro"
})
```

### Clean Build
```bash
mcp_XcodeBuildMCP_clean_ws({
  workspacePath: "/path/to/Sportsbook.xcworkspace",
  scheme: "BetssonCM STG"
})
```

## Interact with App

### Take Screenshot
```bash
mcp_XcodeBuildMCP_screenshot({ simulatorUuid: "SIMULATOR_UUID" })
```

### Get UI Elements
```bash
mcp_XcodeBuildMCP_describe_all({ simulatorUuid: "SIMULATOR_UUID" })
```

### Tap Element
```bash
mcp_XcodeBuildMCP_tap({
  simulatorUuid: "SIMULATOR_UUID",
  x: 120,
  y: 816
})
```

### Type Text
```bash
mcp_XcodeBuildMCP_type_text({
  simulatorUuid: "SIMULATOR_UUID",
  text: "Hello World"
})
```

## Quick Workflow

```bash
# 1. Find workspace and schemes
mcp_XcodeBuildMCP_discover_projs({ workspaceRoot: "/Users/user/project" })
mcp_XcodeBuildMCP_list_schems_ws({ workspacePath: "/path/to/app.xcworkspace" })

# 2. Build and run
mcp_XcodeBuildMCP_build_run_ios_sim_name_ws({
  workspacePath: "/path/to/app.xcworkspace",
  scheme: "MyScheme",
  simulatorName: "iPhone 16 Pro"
})

# 3. Test UI
mcp_XcodeBuildMCP_screenshot({ simulatorUuid: "UUID" })
mcp_XcodeBuildMCP_describe_all({ simulatorUuid: "UUID" })
mcp_XcodeBuildMCP_tap({ simulatorUuid: "UUID", x: 120, y: 816 })
```

## Real Example
```bash
# Build BetssonCM STG
mcp_XcodeBuildMCP_build_run_ios_sim_id_ws({
  workspacePath: "/Users/rroques/Desktop/GOMA/iOS/sportsbook-ios/Sportsbook.xcworkspace",
  scheme: "BetssonCM STG",
  simulatorId: "07CBEC5A-B1AE-4C93-BECD-A45FA9C1C534"
})

# Test tab navigation
mcp_XcodeBuildMCP_tap({
  simulatorUuid: "07CBEC5A-B1AE-4C93-BECD-A45FA9C1C534",
  x: 120, y: 816
})
```